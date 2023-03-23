using CSV
using DataFrames
using ProgressMeter

include("BCRSimplexGaps.jl")

simplex_parameters = [
    (d, s, l)
    for d in 3:10#[40]#, 500]
    for l in 3:3
    for s in 20:20#max(l, 30):40
    # for d in max(s, 500):500
]

result = DataFrame(
    d = Int[],
    s = Int[],
    l = Int[],
    s_max = Float64[],
    s_opt = Float64[],
    gap   = Float64[],
    time  = Float64[],
)

@showprogress for (d, s, l) in simplex_parameters
    printstyled("d = $(d), s = $(s), l = $(l)\n"; color = :red)
    gap = BCRSimplexGaps.compute_gap(d, s, l)
    push!(result, [d, s, l, gap.s_max, gap.s_opt, gap.gap, gap.time])
end

display(sort(result, :gap; rev = false))
CSV.write("gaps.csv", result[:, [:d, :s, :l, :gap]])

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
