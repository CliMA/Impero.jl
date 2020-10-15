var documenterSearchIndex = {"docs":
[{"location":"equations/#Equations","page":"Equations","title":"Equations","text":"","category":"section"},{"location":"equations/","page":"Equations","title":"Equations","text":"One of the goals of Impero is to provide a language for specifying partial differential equations as well as their discretization. For example, one can  specify Burgers' equation fairly easily in Impero:","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"using Impero, Plots, GraphRecipes\n@wrapper σ=nothing u=nothing\n∂x = Operator(nothing, DerivativeMetaData(nothing, \"x\"))\n∂t = Operator(nothing, DerivativeMetaData(nothing, \"t\"))\n@pde_system pde_system = [\n    σ = ∂x(u),\n    ∂t(u) = -∂x(u * u - ∂x(σ)),\n];","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"We see that we have defined","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"println(pde_system[1])\nprintln(pde_system[2])","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"The code snippet does not perform any computation, but rather servers as a  descriptor for the problem at hand. One can also plot the PDE system","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"p1 = plot(pde_system[1]); p2 = plot(pde_system[2]);\nplot(p1)","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"and","category":"page"},{"location":"equations/","page":"Equations","title":"Equations","text":"plot(p2, size = (1000,1000))","category":"page"},{"location":"basics/#Basics","page":"Basics","title":"Basics","text":"","category":"section"},{"location":"basics/","page":"Basics","title":"Basics","text":"Here we show how to wrap Julia arrays and create an Impero expression.","category":"page"},{"location":"basics/#Numbers","page":"Basics","title":"Numbers","text":"","category":"section"},{"location":"basics/","page":"Basics","title":"Basics","text":"using Impero, Plots, GraphRecipes","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"@wrapper a=1 b=2;","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"We can even plot it","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"c = a+b\nplot(c)","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"and compute values with it","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"compute(c)","category":"page"},{"location":"basics/#Arrays","page":"Basics","title":"Arrays","text":"","category":"section"},{"location":"basics/","page":"Basics","title":"Basics","text":"We can also wrap Arrays or Matrices","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"using Impero, Plots, GraphRecipes\narray_1 = ones(3)\narray_2 = ones(3)\n@wrapper a=array_1 b=array_2;","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"and compute values with it","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"c = a+b\ncompute(c)","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"Note that Impero does not provide an error check for improperly defined Julia objects on this level since","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"c = a*b","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"is fine, but compute(c) will yield an error.","category":"page"},{"location":"basics/#User-Defined-Structs","page":"Basics","title":"User Defined Structs","text":"","category":"section"},{"location":"basics/","page":"Basics","title":"Basics","text":"As long as a user has the operations","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"unary_operators","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"and","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"binary_operators","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"defined then one can use Impero exactly as before","category":"page"},{"location":"basics/#Converting-to-Julia-Expressions","page":"Basics","title":"Converting to Julia Expressions","text":"","category":"section"},{"location":"basics/","page":"Basics","title":"Basics","text":"Any Impero object can be converted to a Julia expression through the to_expr function","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"@wrapper a=1 b=2\nimpero_expr = a+b","category":"page"},{"location":"basics/","page":"Basics","title":"Basics","text":"julia_expr = to_expr(impero_expr)","category":"page"},{"location":"#Impero.jl","page":"Impero","title":"Impero.jl","text":"","category":"section"},{"location":"","page":"Impero","title":"Impero","text":"Documentation for Impero.jl","category":"page"},{"location":"expression_rewriting/#Expression-Rewriting-with-SymbolicUtils","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"","category":"section"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"Impero provides hooks to  SymbolicUtils.jl  to allow manipuation of the syntax tree. In the following code snippet we take an expression that was originally a \"+\" operation and convert it to a \"*\" operation","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"using Impero, SymbolicUtils, Plots\nimport SymbolicUtils: Chain, Postwalk, Fixpoint\n@wrapper a=1 b=2\nc = a+b\nr1 = @acrule ~ra + ~rb => ~ra * ~rb\nnew_c = Fixpoint(Postwalk(Chain([r1])))(c);","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"We can now check to see that this conversion happened succesfully","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"compute(c)","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"compute(new_c)","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"and even plot to show that the tree has been rewritten","category":"page"},{"location":"expression_rewriting/","page":"Expression Rewriting with SymbolicUtils","title":"Expression Rewriting with SymbolicUtils","text":"p1 = plot(c); p2 = plot(new_c);\nplot(p1,p2)","category":"page"}]
}
