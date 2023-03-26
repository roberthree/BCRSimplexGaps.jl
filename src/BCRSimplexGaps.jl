module BCRSimplexGaps

using Combinatorics
using JuMP
using HiGHS
using JSON

function simplex_numbers(d::Int, s::Int, l::Int = d)
    [
        p .- ones(Int, d + 1)
        for p in partitions(s + d + 1, d + 1)
        if sum(p .> 1) <= l + 1
    ]
end

function simplex_instance(d::Int, s::Int, l::Int = d)
    @assert 0 <= l <= d
    n = l < d ? l + 2 : d + 1

    sn = Dict(
        o => simplex_numbers(n - 1, s + o, l)
        for o in [0, 1]
    )
    sn_union = Iterators.flatten((sn[0], sn[1]))

    sn_edges = [
        begin
            p_0 = copy(p_1)
            p_0[i] -= 1
            (p_0, p_1)
        end
        for p_1 in sn[1]
        for i in 1:sum(p_1 .> 0)
        if i == n || p_1[i] > p_1[i + 1]
    ]

    model = Model(HiGHS.Optimizer; add_bridges = false)

    # y(v)_i
    @variable(model, y[sn_union, 1:n])

    # r(v, w)_i
    @variable(model, z[sn_edges, 1:n])

    for p in sn_union
        # 0-centric
        @constraint(model, ones(n)' * y[p, :] == 0)

        # v_i = v_j => y(v)_i = y(v)_j
        for k in 0:sum(p)
            indices = findall(==(k), p)
            for i in indices[2:end]
                factor = i < l + 2 ? 1 : (d - l)
                @constraint(model, y[p, i] == factor * y[p, indices[1]])
            end
        end
    end

    # L1-embedding with unit edge-costs
    for edge in sn_edges
        for j in 1:n
            @constraints(model, begin
                +(y[edge[1], j] - y[edge[2], j]) <= z[edge, j]
                -(y[edge[1], j] - y[edge[2], j]) <= z[edge, j]
            end)
        end

        @constraint(model, ones(n)' * z[edge, :] <= 1)
    end

    @objective(model, Max, 1 * y[sn[0][1], 1])

    model, sn, y, z
end

function compute_gap(d::Int, s::Int, l::Int = d; verbose = true)
    model, sn, y, z = BCRSimplexGaps.simplex_instance(d, s, l)
    verbose || set_silent(model)
    optimize!(model)
    @assert MOI.get(model, MOI.TerminationStatus()) == MOI.OPTIMAL
    s_max = s * d / (d + 1)
    s_opt = MOI.get(model, MOI.ObjectiveValue())
    (
        model = model,
        sn    = sn,
        y     = y,
        z     = z,
        s_max = s_max,
        s_opt = s_opt,
        gap   = s_max / s_opt,
        time  = MOI.get(model, MOI.SolveTimeSec()),
    )
end

function save_solution(model::Model, filename::String)
    @assert MOI.get(model, MOI.TerminationStatus()) == MOI.OPTIMAL
    open(filename, "w") do file
        JSON.print(
            file,
            Dict(
                name(variable) => value(variable)
                for variable in all_variables(model)
            ),
        )
    end
end

function load_solution(model::Model, filename::String)
    variable_values = JSON.parsefile(filename)
    for (variable_name, variable_value) in variable_values
        set_start_value(
            variable_by_name(model, variable_name),
            variable_value,
        )
    end
end

end
