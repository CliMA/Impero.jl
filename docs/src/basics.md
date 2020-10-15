# Basics

Here we show how to wrap Julia arrays and create an Impero expression.

## Numbers
```@example 1
using Impero, Plots, GraphRecipes
```

```@example 1
@wrapper a=1 b=2;
```

We can even plot it
```@example 1
c = a+b
plot(c)
```
and compute values with it
```@example 1
compute(c)
```

## Arrays
We can also wrap Arrays or Matrices
```@example 1
using Impero, Plots, GraphRecipes
array_1 = ones(3)
array_2 = ones(3)
@wrapper a=array_1 b=array_2;
```
and compute values with it
```@example 1
c = a+b
compute(c)
```
Note that Impero does not provide an error check for improperly defined Julia
objects on this level since
```@example 1
c = a*b
```
is fine, but ```compute(c)``` will yield an error.


## User Defined Structs
As long as a user has the operations
```@example 1
unary_operators
```
and
```@example 1
binary_operators
```
defined then one can use Impero exactly as before

## Converting to Julia Expressions
Any Impero object can be converted to a Julia expression through the
to_expr function
```@example 1
@wrapper a=1 b=2
impero_expr = a+b
```
```@example 1
julia_expr = to_expr(impero_expr)
```