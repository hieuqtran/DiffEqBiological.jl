# DiffEqBiological.jl

[![Join the chat at https://gitter.im/JuliaDiffEq/Lobby](https://badges.gitter.im/JuliaDiffEq/Lobby.svg)](https://gitter.im/JuliaDiffEq/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/JuliaDiffEq/DiffEqBiological.jl.svg?branch=master)](https://travis-ci.org/JuliaDiffEq/DiffEqBiological.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/y62d627e5hd513wf?svg=true)](https://ci.appveyor.com/project/ChrisRackauckas/diffeqbiological-jl)
<!-- [![Coverage Status](https://coveralls.io/repos/ChrisRackauckas/DiffEqBiological.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaDiffEq/DiffEqBiological.jl?branch=master)
[![codecov.io](http://codecov.io/github/ChrisRackauckas/DiffEqBiological.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaDiffEq/DiffEqBiological.jl?branch=master) -->

Here we give a brief introduction to using the `DiffEqBiological` package. Full
documentation is in the [DifferentialEquations.jl Chemical Reaction Models
documentation](http://docs.juliadiffeq.org/latest/models/biological.html).

## The Reaction DSL

The `@reaction_network` DSL allows for the definition of reaction networks using a simple format. Its input is a set of chemical reactions, from which it generates a reaction network object which can be used as input to `ODEProblem`, `SteadyStateProblem`, `SDEProblem` and `JumpProblem` constructors.

The basic syntax is
```julia
rn = @reaction_network rType begin
  2.0, X + Y --> XY               
  1.0, XY --> Z            
end
```
where each line corresponds to a chemical reaction. The (optional) input `rType` designates the type of this instance (all instances will inherit from the abstract type `AbstractReactionNetwork`).

The DSL has many features:
* It supports many different arrow types, corresponding to different directions of reactions and different rate laws:
  ```julia
  rn = @reaction_network begin
    1.0, X + Y --> XY               
    1.0, X + Y → XY      
    1.0, XY ← X + Y      
    2.0, X + Y ↔ XY               
  end
  ```
* It allows multiple reactions to be defined simultaneously on one line. The following two networks
are equivalent:
  ```julia
  rn1 = @reaction_network begin
    (1.0,2.0), (S1,S2) → P             
  end
  rn2 = @reaction_network begin
    1.0, S1 → P     
    2.0, S2 → P
  end
  ```
* It allows the use of symbols to represent reaction rate parameters, with their numeric values specified during problem construction. i.e., the previous example could be given by
  ```julia
  rn2 = @reaction_network begin
    k1, S1 → P     
    k2, S2 → P
  end k1 k2 
  ```
  with `k1` and `k2` corresponding to the reaction rates.
* Rate law functions can be pre-defined and used within the DSL:
  ```julia
  @reaction_func myHill(x) = 2.0*x^3/(x^3+1.5^3)
  rn = @reaction_network begin
    myHill(X), ∅ → X
  end
  ```
* Pre-made rate laws for Hill and Michaelis-Menten reactions are provided:
  ```julia
  rn1 = @reaction_network begin
    hill(X,v,K,n), ∅ → X
    mm(X,v,K), ∅ → X
  end v K n
  ```
* Simple rate law functions of the species populations can be used within the DSL:
  ```julia
  rn = @reaction_network begin
    2.0*X^2, 0 → X + Y
    gamma(Y)/5, X → ∅
    pi*X/Y, Y → ∅
  end
  ```
* It is possible to access expressions corresponding to the functions determining the deterministic and stochastic terms within resulting ODE, SDE or jump models using
  ```julia
    f_expr = rn.f_func
    g_expr = rn.g_func
    affects = rn.jump_affect_expr
    rates = rn.jump_rate_expr
  ```
  These can be used to generate LaTeX code corresponding to the system using packages such as [`Latexify`](https://github.com/korsbo/Latexify.jl).


## Simulating ODE, Steady-State, SDE and Jump Problems

Once a reaction network has been created it can be passed as input to either one of the `ODEProblem`, `SteadyStateProblem`, `SDEProblem` or `JumpProblem` constructors.
```julia
  probODE = ODEProblem(rn, args...; kwargs...)      
  probSS = SteadyStateProblem(rn, args...; kwargs...)
  probSDE = SDEProblem(rn, args...; kwargs...)
  probJump = JumpProblem(prob, Direct(), rn)
```
The output problems may then be used as input to the solvers of [DifferentialEquations.jl](http://juliadiffeq.org/). *Note*, the noise used by the `SDEProblem` will correspond to the Chemical Langevin Equations. 

As an example, consider models for a simple birth-death process:
```julia
rs = @reaction_network begin
  c1, X --> 2X
  c2, X --> 0
  c3, 0 --> X
end c1 c2 c3
params = (1.0,2.0,50.)
tspan = (0.,4.)
u0 = [5.]

# solve ODEs
oprob = ODEProblem(rs, u0, tspan, params)
osol  = solve(oprob, Tsit5())

# solve for Steady-States
ssprob = SteadyStateProblem(rs, u0, params)
sssol  = solve(ssprob, SSRootfind())

# solve Chemical Langevin SDEs
sprob = SDEProblem(rs, u0, tspan, params)
ssol  = solve(sprob, EM(), dt=.01)

# solve JumpProblem
u0 = [5]
dprob = DiscreteProblem(u0, tspan, params)
jprob = JumpProblem(dprob, Direct(), rs)
jsol = solve(jprob, SSAStepper())
```

