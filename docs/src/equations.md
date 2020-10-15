# Equations

One of the goals of Impero is to provide a language for specifying partial
differential equations as well as their discretization. For example, one can 
specify Burger's equation fairly easily in Impero:

```example equations
using Impero
@wrapper σ=nothing u=nothing
@pde_system pde_system = [
    σ = ∂x(u),
    ∂t(u) = -∂x(u * u - ∂x(σ)),
]
```
The code snippet does not perform any computation, but rather servers as a 
descriptor for the problem at hand. One can also plot the PDE system

