using Test

import BCRSimplexGaps

@testset "construct_simplex_numbers" begin
    @test BCRSimplexGaps.construct_simplex_numbers(0, 0) == [[0]]
    @test BCRSimplexGaps.construct_simplex_numbers(0, 1) == [[1]]
    @test BCRSimplexGaps.construct_simplex_numbers(0, 9) == [[9]]

    @test BCRSimplexGaps.construct_simplex_numbers(1, 0) == [[0, 0]]
    @test BCRSimplexGaps.construct_simplex_numbers(1, 1) == [[1, 0]]
    @test BCRSimplexGaps.construct_simplex_numbers(1, 9) == [
        [9, 0],
        [8, 1],
        [7, 2],
        [6, 3],
        [5, 4],
    ]

    @test BCRSimplexGaps.construct_simplex_numbers(2, 0) == [[0, 0, 0]]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 1) == [[1, 0, 0]]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 2) == [
        [2, 0, 0],
        [1, 1, 0],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 3) == [
        [3, 0, 0],
        [2, 1, 0],
        [1, 1, 1],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 4) == [
        [4, 0, 0],
        [3, 1, 0],
        [2, 2, 0],
        [2, 1, 1],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 5) == [
        [5, 0, 0],
        [4, 1, 0],
        [3, 2, 0],
        [3, 1, 1],
        [2, 2, 1],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 9) == [
        [9, 0, 0],
        [8, 1, 0],
        [7, 2, 0],
        [6, 3, 0],
        [5, 4, 0],
        [7, 1, 1],
        [6, 2, 1],
        [5, 3, 1],
        [4, 4, 1],
        [5, 2, 2],
        [4, 3, 2],
        [3, 3, 3],
    ]

    @test BCRSimplexGaps.construct_simplex_numbers(0, 0, -2) == []
    @test BCRSimplexGaps.construct_simplex_numbers(0, 0, -1) == [[0]]
    @test BCRSimplexGaps.construct_simplex_numbers(0, 0, 0) == [[0]]
    @test BCRSimplexGaps.construct_simplex_numbers(0, 0, 1) == [[0]]

    @test BCRSimplexGaps.construct_simplex_numbers(2, 9, 0) == [
        [9, 0, 0],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 9, 1) == [
        [9, 0, 0],
        [8, 1, 0],
        [7, 2, 0],
        [6, 3, 0],
        [5, 4, 0],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 9, 2) == [
        [9, 0, 0],
        [8, 1, 0],
        [7, 2, 0],
        [6, 3, 0],
        [5, 4, 0],
        [7, 1, 1],
        [6, 2, 1],
        [5, 3, 1],
        [4, 4, 1],
        [5, 2, 2],
        [4, 3, 2],
        [3, 3, 3],
    ]
    @test BCRSimplexGaps.construct_simplex_numbers(2, 9, 3) == [
        [9, 0, 0],
        [8, 1, 0],
        [7, 2, 0],
        [6, 3, 0],
        [5, 4, 0],
        [7, 1, 1],
        [6, 2, 1],
        [5, 3, 1],
        [4, 4, 1],
        [5, 2, 2],
        [4, 3, 2],
        [3, 3, 3],
    ]
end

@testset "construct_simplex_instance" begin
    simplex_instance = BCRSimplexGaps.construct_simplex_instance(2, 2)

    sn = simplex_instance.simplex_numbers
    y = simplex_instance.model_variables.y
    z = simplex_instance.model_variables.z

    @test sn[0] == [[2, 0, 0], [1, 1, 0]]
    @test sn[1] == [[3, 0, 0], [2, 1, 0], [1, 1, 1]]

    @test size(y) == (5, 3)
    @test size(z) == (4, 3)

    constraint_refs = BCRSimplexGaps.JuMP.all_constraints(
        simplex_instance.model;
        include_variable_in_set_constraints = true,
    )

    @test length(constraint_refs) == 38

    # 0-centric
    @test string(constraint_refs[1]) == "$(y[sn[0][1], 1]) + $(y[sn[0][1], 2]) + $(y[sn[0][1], 3]) = 0"
    @test string(constraint_refs[3]) == "$(y[sn[0][2], 1]) + $(y[sn[0][2], 2]) + $(y[sn[0][2], 3]) = 0"
    @test string(constraint_refs[5]) == "$(y[sn[1][1], 1]) + $(y[sn[1][1], 2]) + $(y[sn[1][1], 3]) = 0"
    @test string(constraint_refs[7]) == "$(y[sn[1][2], 1]) + $(y[sn[1][2], 2]) + $(y[sn[1][2], 3]) = 0"
    @test string(constraint_refs[8]) == "$(y[sn[1][3], 1]) + $(y[sn[1][3], 2]) + $(y[sn[1][3], 3]) = 0"

    # v_i = v_j => y(v)_i = y(v)_j
    @test string(constraint_refs[2]) == "-$(y[sn[0][1], 2]) + $(y[sn[0][1], 3]) = 0"
    @test string(constraint_refs[4]) == "-$(y[sn[0][2], 1]) + $(y[sn[0][2], 2]) = 0"
    @test string(constraint_refs[6]) == "-$(y[sn[1][1], 2]) + $(y[sn[1][1], 3]) = 0"
    @test string(constraint_refs[9]) == "-$(y[sn[1][3], 1]) + $(y[sn[1][3], 2]) = 0"
    @test string(constraint_refs[10]) == "-$(y[sn[1][3], 1]) + $(y[sn[1][3], 3]) = 0"

    # L1-embedding with unit edge-costs
    sn_edges = [
        (sn[0][1], sn[1][1]),
        (sn[0][2], sn[1][2]),
        (sn[0][1], sn[1][2]),
        (sn[0][2], sn[1][3]),
    ]

    constraint_index = 11

    for edge in sn_edges
        for j in axes(y, 2)
            @test string(constraint_refs[constraint_index + 0]) == "$(y[edge[1], j]) - $(y[edge[2], j]) - $(z[edge, j]) ≤ 0"
            @test string(constraint_refs[constraint_index + 1]) == "-$(y[edge[1], j]) + $(y[edge[2], j]) - $(z[edge, j]) ≤ 0"
            constraint_index += 2
        end
        @test string(constraint_refs[constraint_index]) == "$(z[edge, 1]) + $(z[edge, 2]) + $(z[edge, 3]) ≤ 1"
        constraint_index += 1
    end

    @test constraint_index == length(constraint_refs) + 1
end

@testset "compute_simplex_gap" begin
    result = BCRSimplexGaps.compute_simplex_gap(22, 23, 3; verbose = false)

    @test result.gap == (Int === Int64 ? 1.200153037333363 : 1.2001530373333638)
end
