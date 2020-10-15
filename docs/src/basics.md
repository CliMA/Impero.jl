# Basics

Here we show how to wrap Julia arrays and create an Impero expression.

## Numbers
```@example 1
using Impero, Plots, GraphRecipes
```

```@example 1
@wrapper a=1 b=2
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
This also works on Arrays or matrices
```@example 1
using Impero, Plots, GraphRecipes
```

```@example 1
a = ones(3)
array_2 = ones(3)
@wrapper a=array_1 b=array_2
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

## User Defined Structs
As long as a user has the operations
```@example 1
unary_operators
```
and
```@example 1
binary_operators
```
defined then one can use Impero exactly as before. 