# BCRSimplexGaps

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://roberthree.github.io/BCRSimplexGaps.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://roberthree.github.io/BCRSimplexGaps.jl/dev/)
[![Build Status](https://github.com/roberthree/BCRSimplexGaps.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/roberthree/BCRSimplexGaps.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/roberthree/BCRSimplexGaps.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/roberthree/BCRSimplexGaps.jl)

This repository provides a [Julia](https://julialang.org) module for constructing and optimizing the dual-LP $\mathrm{SE}\_{s}^{d, l}$ defined in the following article:

Vicari, Robert. "Simplex based Steiner tree instances yield large integrality gaps for the bidirected cut relaxation." arXiv preprint [arXiv:2002.07912](https://arxiv.org/abs/2002.07912) (2020).

An instance of $\mathrm{SE}\_{s}^{d, l}$ consists of an integer triple $(s, d, l)$.
The function `compute_gap(s, d, l; verbose = true)` computes the ratio between the optimum value of $\mathrm{SE}\_{s}^{d, l}$ and the primal integer optimum value, in general called gap of the respective LP.
The following script can be executed in native Julia and will optimize instances with gaps larger than $1.2$ and $1.22$, respectively.

```julia
using Pkg
Pkg.add(url = "https://github.com/roberthree/BCRSimplexGaps.jl.git")

using BCRSimplexGaps

s, d, l = (23, 22, 3)
result = BCRSimplexGaps.compute_gap(s, d, l; verbose = false)

result.gap
```

