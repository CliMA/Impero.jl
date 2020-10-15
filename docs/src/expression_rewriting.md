# Expression Rewriting with SymbolicUtils

Impero provides hooks to 
[SymbolicUtils.jl](https://github.com/JuliaSymbolics/SymbolicUtils.jl) 
to allow manipuation of the syntax tree. In the following code snippet
we take an expression that was originally a "+" operation and convert it
to a "*" operation

```@example 2
using Impero, SymbolicUtils, Plots
import SymbolicUtils: Chain, Postwalk, Fixpoint
@wrapper a=1 b=2
c = a+b
r1 = @acrule ~ra + ~rb => ~ra * ~rb
new_c = Fixpoint(Postwalk(Chain([r1])))(c)
```

We can now check to see that this conversion happened succesfully
```@example 2
compute(new_c)
```
and even plot to show that the tree has been rewritten
```@example 2
p1 = plot(c); p2 = plot(new_c);
plot(p1,p2)
```

