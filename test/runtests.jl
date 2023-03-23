using BCRSimplexGaps
using Test

@testset "simplex_numbers" begin
    @test BCRSimplexGaps.simplex_numbers(0, 0) == [[0]]
    @test BCRSimplexGaps.simplex_numbers(0, 1) == [[1]]
    @test BCRSimplexGaps.simplex_numbers(0, 9) == [[9]]

    @test BCRSimplexGaps.simplex_numbers(1, 0) == [[0, 0]]
    @test BCRSimplexGaps.simplex_numbers(1, 1) == [[1, 0]]
    @test BCRSimplexGaps.simplex_numbers(1, 9) == [
        [9, 0],
        [8, 1],
        [7, 2],
        [6, 3],
        [5, 4],
    ]

    @test BCRSimplexGaps.simplex_numbers(2, 0) == [[0, 0, 0]]
    @test BCRSimplexGaps.simplex_numbers(2, 1) == [[1, 0, 0]]
    @test BCRSimplexGaps.simplex_numbers(2, 2) == [
        [2, 0, 0],
        [1, 1, 0],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 3) == [
        [3, 0, 0],
        [2, 1, 0],
        [1, 1, 1],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 4) == [
        [4, 0, 0],
        [3, 1, 0],
        [2, 2, 0],
        [2, 1, 1],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 5) == [
        [5, 0, 0],
        [4, 1, 0],
        [3, 2, 0],
        [3, 1, 1],
        [2, 2, 1],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 9) == [
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

    @test BCRSimplexGaps.simplex_numbers(0, 0, -2) == []
    @test BCRSimplexGaps.simplex_numbers(0, 0, -1) == [[0]]
    @test BCRSimplexGaps.simplex_numbers(0, 0, 0) == [[0]]
    @test BCRSimplexGaps.simplex_numbers(0, 0, 1) == [[0]]

    @test BCRSimplexGaps.simplex_numbers(2, 9, 0) == [
        [9, 0, 0],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 9, 1) == [
        [9, 0, 0],
        [8, 1, 0],
        [7, 2, 0],
        [6, 3, 0],
        [5, 4, 0],
    ]
    @test BCRSimplexGaps.simplex_numbers(2, 9, 2) == [
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
    @test BCRSimplexGaps.simplex_numbers(2, 9, 3) == [
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

@testset "simplex_instance" begin
    model, sn, y, r = BCRSimplexGaps.simplex_instance(2, 2)

    @test sn[0] == [[2, 0, 0], [1, 1, 0]]
    @test sn[1] == [[3, 0, 0], [2, 1, 0], [1, 1, 1]]

    @test size(y) == (5, 3)
    @test size(r) == (4, 3)

    constraint_refs = BCRSimplexGaps.all_constraints(
        model;
        include_variable_in_set_constraints = true,
    )

    @test length(constraint_refs) == 38

    # 0-centric
    @test string(constraint_refs[1]) == "$(y[sn[0][1], 1]) + $(y[sn[0][1], 2]) + $(y[sn[0][1], 3]) = 0.0"
    @test string(constraint_refs[3]) == "$(y[sn[0][2], 1]) + $(y[sn[0][2], 2]) + $(y[sn[0][2], 3]) = 0.0"
    @test string(constraint_refs[5]) == "$(y[sn[1][1], 1]) + $(y[sn[1][1], 2]) + $(y[sn[1][1], 3]) = 0.0"
    @test string(constraint_refs[7]) == "$(y[sn[1][2], 1]) + $(y[sn[1][2], 2]) + $(y[sn[1][2], 3]) = 0.0"
    @test string(constraint_refs[8]) == "$(y[sn[1][3], 1]) + $(y[sn[1][3], 2]) + $(y[sn[1][3], 3]) = 0.0"

    # v_i = v_j => y(v)_i = y(v)_j
    @test string(constraint_refs[2]) == "-$(y[sn[0][1], 2]) + $(y[sn[0][1], 3]) = 0.0"
    @test string(constraint_refs[4]) == "-$(y[sn[0][2], 1]) + $(y[sn[0][2], 2]) = 0.0"
    @test string(constraint_refs[6]) == "-$(y[sn[1][1], 2]) + $(y[sn[1][1], 3]) = 0.0"
    @test string(constraint_refs[9]) == "-$(y[sn[1][3], 1]) + $(y[sn[1][3], 2]) = 0.0"
    @test string(constraint_refs[10]) == "-$(y[sn[1][3], 1]) + $(y[sn[1][3], 3]) = 0.0"

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
            @test string(constraint_refs[constraint_index + 0]) == "$(y[edge[1], j]) - $(y[edge[2], j]) - $(r[edge, j]) ≤ 0.0"
            @test string(constraint_refs[constraint_index + 1]) == "-$(y[edge[1], j]) + $(y[edge[2], j]) - $(r[edge, j]) ≤ 0.0"
            constraint_index += 2
        end
        @test string(constraint_refs[constraint_index]) == "$(r[edge, 1]) + $(r[edge, 2]) + $(r[edge, 3]) ≤ 1.0"
        constraint_index += 1
    end

    @test constraint_index == length(constraint_refs) + 1
end
