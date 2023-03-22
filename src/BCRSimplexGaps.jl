module BCRSimplexGaps

import Combinatorics
import JuMP
import HiGHS

function optimize_model!(model::JuMP.Model; verbose::Bool)
    verbose || JuMP.set_silent(model)
    JuMP.optimize!(model)
    @assert JuMP.MOI.get(model, JuMP.MOI.TerminationStatus()) == JuMP.MOI.OPTIMAL
    (
        value = JuMP.MOI.get(model, JuMP.MOI.ObjectiveValue()),
        time  = JuMP.MOI.get(model, JuMP.MOI.SolveTimeSec()),
    )
end

function construct_simplex_numbers(d::Int, s::Int, l::Int = d)
    [
        p .- ones(Int, d + 1)
        for p in Combinatorics.partitions(s + d + 1, d + 1)
        if sum(p .> 1) <= l + 1
    ]
end

struct SimplexInstance
    max_value::AbstractFloat
    model::JuMP.Model
    simplex_numbers::Dict{Int, Vector{Vector{Int}}}
    model_variables::NamedTuple
end

function construct_simplex_instance(d::Int, s::Int, l::Int = d)
    @assert 0 <= l <= d

    # determine length of simplex numbers
    n = l < d ? l + 2 : d + 1

    # construct simplex numbers for s + 0 and s + 1
    sn = Dict(
        o => construct_simplex_numbers(n - 1, s + o, l)
        for o in [0, 1]
    )
    sn_union = Iterators.flatten((sn[0], sn[1]))

    # construct edges between simplex numbers
    sn_edges = [
        let v_0 = copy(v_1)
            v_0[i] -= 1
            (v_0, v_1)
        end
        for v_1 in sn[1]
        for i in 1:sum(v_1 .> 0)
        if i == n || v_1[i] > v_1[i + 1]
    ]

    model = JuMP.Model(HiGHS.Optimizer; add_bridges = false)

    # y(v)_i
    JuMP.@variable(model, y[sn_union, 1:n])

    # z(v, w)_i
    JuMP.@variable(model, z[sn_edges, 1:n])

    for v in sn_union
        # 0-centric
        JuMP.@constraint(model, ones(n)' * y[v, :] == 0)

        # v_i = v_j => y(v)_i = y(v)_j
        for k in unique(v)
            # for each possible value k find all indices i such that v_i = k
            indices = findall(==(k), v)
            for i in indices[2:end]
                # determine factor for correct equality
                factor = i < l + 2 ? 1 : (d - l)
                JuMP.@constraint(model, y[v, i] == factor * y[v, indices[1]])
            end
        end
    end

    # L1-embedding with unit edge-costs
    for edge in sn_edges
        for j in 1:n
            JuMP.@constraints(model, begin
                +(y[edge[1], j] - y[edge[2], j]) <= z[edge, j]
                -(y[edge[1], j] - y[edge[2], j]) <= z[edge, j]
            end)
        end

        JuMP.@constraint(model, ones(n)' * z[edge, :] <= 1)
    end

    JuMP.@objective(model, Max, 1 * y[sn[0][1], 1])

    SimplexInstance(s * d / (d + 1), model, sn, (y = y, z = z))
end

function compute_simplex_gap(simplex_instance::SimplexInstance; verbose::Bool = true)
    result = optimize_model!(simplex_instance.model; verbose)
    (
        max = simplex_instance.max_value,
        opt = result.value,
        gap = simplex_instance.max_value / result.value,
        time = result.time,
    )
end

function compute_simplex_gap(d::Int, s::Int, l::Int = d; verbose::Bool = true)
    compute_simplex_gap(construct_simplex_instance(d, s, l); verbose)
end

end
