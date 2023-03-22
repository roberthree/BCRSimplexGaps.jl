using BCRSimplexGaps
using Documenter

DocMeta.setdocmeta!(BCRSimplexGaps, :DocTestSetup, :(using BCRSimplexGaps); recursive=true)

makedocs(;
    modules=[BCRSimplexGaps],
    authors="Robert Three <roberthree@proton.me> and contributors",
    repo="https://github.com/roberthree/BCRSimplexGaps.jl/blob/{commit}{path}#{line}",
    sitename="BCRSimplexGaps.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://roberthree.github.io/BCRSimplexGaps.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/roberthree/BCRSimplexGaps.jl",
    devbranch="main",
)
