# Equations

One of the goals of Impero is to provide a language for specifying partial
differential equations as well as their discretization. For example, one can 
specify [Burgers' equation](https://en.wikipedia.org/wiki/Burgers%27_equation) fairly easily in Impero:

```@example equations
using Impero, Plots, GraphRecipes
@wrapper σ=nothing u=nothing
∂x = Operator(nothing, DerivativeMetaData(nothing, "x"))
∂t = Operator(nothing, DerivativeMetaData(nothing, "t"))
@pde_system pde_system = [
    σ = ∂x(u),
    ∂t(u) = -∂x(u * u - ∂x(σ)),
];
```
We see that we have defined
```@example equations
println(pde_system[1])
println(pde_system[2])
```
The code snippet does not perform any computation, but rather servers as a 
descriptor for the problem at hand. One can also plot the PDE system
```@example equations
p1 = plot(pde_system[1]); p2 = plot(pde_system[2]);
plot(p1)
```
and
```@example equations
plot(p2, size = (1000,1000))
```

