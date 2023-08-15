# BCRSimplexGaps

[![Build Status](https://github.com/roberthree/BCRSimplexGaps.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/roberthree/BCRSimplexGaps.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/roberthree/BCRSimplexGaps.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/roberthree/BCRSimplexGaps.jl)

This repository provides a [Julia](https://julialang.org) module for constructing and optimizing the dual-LP $\mathrm{SE}\_{s}^{d, l}$ defined in:

Vicari, Robert. "Simplex based Steiner tree instances yield large integrality gaps for the bidirected cut relaxation." arXiv preprint [arXiv:2002.07912](https://arxiv.org/abs/2002.07912) (2020).

An instance of $\mathrm{SE}\_{s}^{d, l}$ consists of an integer triple $(d, s, l)$.
The function `compute_simplex_gap(d::Int, s::Int, l::Int = d; verbose::Bool = true)` computes the ratio between the optimum value of $\mathrm{SE}\_{s}^{d, l}$ and the primal integer optimum value, in general called gap of the respective LP.
The following script can be executed in native Julia and will optimize instances with gaps larger than $1.2$.

```julia
import Pkg
Pkg.add(url = "https://github.com/roberthree/BCRSimplexGaps.jl.git")

import BCRSimplexGaps

d, s, l = (23, 22, 3)
result = BCRSimplexGaps.compute_simplex_gap(d, s, l; verbose = true)

display(result)
```

