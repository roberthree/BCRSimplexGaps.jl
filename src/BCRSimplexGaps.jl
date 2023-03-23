module BCRSimplexGaps

using Combinatorics
using JuMP
using HiGHS

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

    model = Model(HiGHS.Optimizer; add_bridges = false)

    # y(v)_i
    @variable(model, y[sn_union, 1:n])

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

    # L1-embedding
    for p₁ in sn[1], i in 1:sum(p₁ .> 0)
        i == n || p₁[i] > p₁[i + 1] || continue
        
        p₀ = copy(p₁)
        p₀[i] -= 1

        r = @variable(model, [1:n])

        for j in 1:n
            @constraints(model, begin
                +(y[p₀, j] - y[p₁, j]) <= r[j]
                -(y[p₀, j] - y[p₁, j]) <= r[j]
            end)
        end

        @constraint(model, ones(n)' * r <= 1)
    end

    @objective(model, Max, 1 * y[sn[0][1], 1])

    model, sn, y
end

function compute_gap(d::Int, s::Int, l::Int = d)
    model, sn, y = BCRSimplexGaps.simplex_instance(d, s, l)
    # set_silent(model)
    optimize!(model)
    s_max = s * d / (d + 1)
    s_opt = MOI.get(model, MOI.ObjectiveValue())
    (
        model = model,
        sn    = sn,
        y     = y,
        s_max = s_max,
        s_opt = s_opt,
        gap   = s_max / s_opt,
        time  = MOI.get(model, MOI.SolveTimeSec()),
    )
end

end
