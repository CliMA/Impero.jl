include(pwd() * "/symbolics/abstract_core.jl")

using SymbolicUtils
import SymbolicUtils: Chain, Postwalk, Sym, Term, istree, operation, arguments, to_symbolic, Fixpoint

# We are interpreting our structs as operations. This makes use of the Default constructor to work backwards in operations
SymbolicUtils.istree(a::Add) = true
SymbolicUtils.arguments(a::Add) = [a.term1, a.term2] 
SymbolicUtils.operation(a::Add) = +;
SymbolicUtils.symtype(a::Add) = Number

SymbolicUtils.istree(a::Multiply) = true
SymbolicUtils.arguments(a::Multiply) = [a.term1, a.term2]
SymbolicUtils.operation(a::Multiply) = *;
SymbolicUtils.symtype(a::Multiply) = Number

a = Field(1, nothing)
c = a + a
struct Wrapper{T} <: AbstractExpression
    s::T
end
# wrappers should be fabulous
function Base.show(io::IO, w::Wrapper)
    printstyled(io, w.s, color = 213) # 213 is pink
end

a = Wrapper(1)
c = a + a

to_expr(t::Term) = Expr(:call, operation(t), to_expr.(arguments(t))...)
to_expr(x) = x
# This is "absolutely" necessary
SymbolicUtils.show_simplified[] = false
symbolic_c = SymbolicUtils.to_symbolic(c);
# to go back
to_expr(t::Term) = Expr(:call, operation(t), to_expr.(arguments(t))...)
to_expr(x) = x
eval(to_expr(symbolic_c))

# (@rule b + b => b * b)(SymbolicUtils.to_symbolic(c))
# ∂x = Sym{FnType{Tuple{Vararg{Any}}, Number}}(:∂x)
#(@rule +(~a,~b) => Add(~b, ~a))(Wrapper(1) + Wrapper(2))
#rule = (@rule a+b => a*b)
##
include(pwd() * "/symbolics" * "/dg_eval_rules.jl")
struct MetaData{𝒰} 
    method::𝒰
end
function Base.show(io::IO, w::MetaData)
    printstyled(io, w.method)
end
function Base.show(io::IO, w::Rusanov)
    printstyled(io, "α=", w.α)
end
# most important feature, maybe make color = rand(1:7)
function Base.show(io::IO, w::Gradient)
    color = 208
    printstyled(io, "∇(", color = color)
    print(w.operand)
    printstyled(")", color = color)
end
# perhaps dispatch on gradient meta data?
#  ∂(ϕ, GradientMetaData('x') =  ∂x(ϕ)
# or ∂(ϕ, GradientMetaData('n̂') = n̂⋅∇ϕ

rusanov = MetaData(Rusanov(0.0));    # wrap derivative metadata
u = Wrapper('u');
∂x(a::AbstractExpression, b::MetaData) = Gradient(a, b);
∂x(a::AbstractExpression) = Gradient(a, rusanov);
eval(a::Gradient) = ∂x(eval(a.operand))
rhs = ∂x(u*u) + ∂x(∂x(u))
rhs2 = ∂x(u*u + ∂x(u))
typeof(rhs)

SymbolicUtils.istree(a::Gradient) = true
SymbolicUtils.arguments(a::Gradient) = [a.operand, a.metadata]
SymbolicUtils.operation(a::Gradient) = ∂x; #has to be defined, could just use Gradient struct
SymbolicUtils.symtype(a::Gradient) = Number
symbolic_rhs = SymbolicUtils.to_symbolic(rhs);
symbolic_rhs2 = SymbolicUtils.to_symbolic(rhs2);
dump(symbolic_rhs)
expr_rhs = to_expr(symbolic_rhs)
expr_rhs2 = to_expr(symbolic_rhs2)
eval(expr_rhs)
##
symbolic_rhs
node = symbolic_rhs 
node2 = symbolic_rhs2
propertynames(symbolic_rhs)
function print_node(node)
    if hasproperty(node, :f)
        println("parent  = ", node.f)
    end
    if hasproperty(node, :arguments)
        for i in 1:length(node.arguments)
            child = node.arguments[i]
            println("child " * string(i) * " = ", child)
        end
    end
    return nothing
end
print(node)
get_children(node) = node.arguments

function recursive_children(node)
    if hasproperty(node, :arguments)
        print_node(node)
        for i in node.arguments
            recursive_children(i)
        end
    end
    return nothing
end

function grab_derivatives(node, container)
    if hasproperty(node, :arguments)
        if hasproperty(node, :f)
            if node.f == ∂x
                push!(container, node.arguments[1])
                print(container)
            end 
        end
        for i in node.arguments
            grab_derivatives(i, container)
        end
    end
    return container
end
container = []
grab_derivatives(node, container)
all_derivatives = container

function grab_derivatives_depth1(node, container)
    if hasproperty(node, :arguments)
        if hasproperty(node, :f)
            if node.f == ∂x
                push!(container, node.arguments[1])
                print(container)
            else
                for i in node.arguments
                    grab_derivatives_depth1(i, container)
                end
            end
        end
    end
    return container
end
container = []
grab_derivatives_depth1(node, container)
container = []
grab_derivatives_depth1(node2, container)
##
# I want rainbows
function print_colors()
    for i in 0:255
        printstyled("color(" * string(i) * ")", color = i)
    end
    return nothing
end
print_colors()
##
# its a start I guess
using GraphRecipes
using Plots
theme(:default)
default(size=(400, 400))
p1 = plot(expr_rhs, shape = :circle, fontsize=10, shorten=0.01, axis_buffer=0.15, title = "primitive")

##
# put code here?``
c = u+u
symb_c = SymbolicUtils.to_symbolic(c)
r = @rule  ~x + ~y => ~x * ~y  # creates a function
r1 = @rule ~x + ~x => ~x * ~x
Postwalk(Chain([r1]))(symb_c)
Postwalk(Chain([@rule ~a+~b => ~a*~b]))(symb_c)

##
# Example
@syms x::Real y::Real z::Complex f(::Number)::Real
r = @rule sinh(im * ~x) => sin(~x)

ar1 = @acrule ∂x(~x, ~z) + ∂x(~y, ~z) => ∂x(~x + ~y, ~z)
another_thing = SymbolicUtils.to_symbolic(∂x(u) + ∂x(u))
Fixpoint(Postwalk(Chain([to_symbolic, ar1, @rule +(~x) => ~x])))(∂x(u) + ∂x(u))
# ar1(symbolic_rhs) only applies the rule once

# f(x+z,y) = f(x,y) + f(z,y)