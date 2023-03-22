using Combinatorics
using JuMP
using HiGHS
using DataFrames
using ProgressMeter

function simplex_numbers(d::I, s::I; max_level::I = d) where {I <: Int}
    [
        p .- ones(I, d + 1)
        for p in partitions(s + d + 1, d + 1)
        if sum(p .> 1) <= max_level + 1
    ]
end

function construct_simplex_instance(d::I, s::I; max_level::I = d) where {I <: Int}
    @assert 0 <= max_level <= d
    n = max_level < d ? max_level + 2 : d + 1

    sn = Dict(
        o => simplex_numbers(n - 1, s + o; max_level = max_level)
        for o in [0, 1]
    )
    sn_union = Iterators.flatten((sn[0], sn[1]))

    model = Model(HiGHS.Optimizer; add_bridges = false)
    set_optimizer_attribute(model, "parallel", "on")

    @variable(model, y[sn_union, 1:n])

    for p in sn_union
        @constraint(model, ones(n)' * y[p, :] == 0)

        for k in 0:sum(p)
            indices = findall(==(k), p)
            for i in indices[2:end]
                factor = i < max_level + 2 ? 1 : (d - max_level)
                @constraint(model, y[p, i] == factor * y[p, indices[1]])
            end
        end
    end

    for p₁ in sn[1]
        for i in 1:sum(p₁ .> 0)
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
    end

    @objective(model, Max, 1 * y[sn[0][1], 1])

    model, sn, y
end

simplex_parameters = [
    (d, s, l)
    for d in [40, 500]
    for l in 3:3
    for s in max(l, 30):40
    # for d in max(s, 500):500
]

result = DataFrame(
    d = Int[],
    s = Int[],
    l = Int[],
    s_max = AbstractFloat[],
    s_opt = AbstractFloat[],
    gap = AbstractFloat[],
    time = AbstractFloat[],
)

@showprogress for (d, s, l) in simplex_parameters
    model, sn, y = construct_simplex_instance(d, s; max_level = l)
    # set_silent(model)
    optimize!(model)
    s_max = s * d / (d + 1)
    s_opt = MOI.get(model, MOI.ObjectiveValue())
    gap = s_max / s_opt
    time = MOI.get(model, MOI.SolveTimeSec())
    push!(result, [d, s, l, s_max, s_opt, gap, time])
end

display(sort(result, :gap; rev = false))

gaps = zeros((0, 0))

@showprogress for index in CartesianIndices(gaps)
    (d, l) = Tuple(index)
    l <= d || continue
    s = d
    model, sn, y = construct_simplex_instance(d, s; max_level = l)
    set_silent(model)
    optimize!(model)
    s_max = s * d / (d + 1)
    s_opt = MOI.get(model, MOI.ObjectiveValue())
    gap = s_max / s_opt
    gaps[index] = gap
end

display(gaps)
