include(pwd() * "/symbolics/abstract_core.jl")
include(pwd() * "/symbolics" * "/dg_eval_rules.jl")
using SymbolicUtils
import SymbolicUtils: Chain, Postwalk
import SymbolicUtils: Sym, Term, istree, operation, arguments, to_symbolic, Fixpoint
# We are interpreting our structs as operations. This makes use of the Default constructor to work backwards in operations
# fieldnames(Add) gives term1 and term2
SymbolicUtils.istree(a::Add) = true
SymbolicUtils.arguments(a::Add) = [a.term1, a.term2] 
SymbolicUtils.operation(a::Add) = +;
SymbolicUtils.symtype(a::Add) = Number

SymbolicUtils.istree(a::Multiply) = true
SymbolicUtils.arguments(a::Multiply) = [a.term1, a.term2]
SymbolicUtils.operation(a::Multiply) = *;
SymbolicUtils.symtype(a::Multiply) = Number

SymbolicUtils.to_symbolic(x::AbstractExpression) = x

##
struct Wrapper{T} <: AbstractExpression
    s::T
end
# wrappers should be fabulous
function Base.show(io::IO, w::Wrapper)
    printstyled(io, w.s, color = 213) # 213 is pink
end
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
##
r1 = @rule ~a+~b => ~a*~b
c = u+u
d = Postwalk(Chain([r1]))(c)
##
u = Wrapper([1,1,1,1])
ar1 = @acrule ∂x(~x, ~z) + ∂x(~y, ~z) => ∂x(~x + ~y, ~z)
c = ∂x(u) + ∂x( ∂x(u))
d = Fixpoint(Postwalk(Chain([ar1])))(c)
d = ∂x(u + ∂x(u))
rhs3 = Fixpoint(Postwalk(Chain([ar1])))(rhs)
isequal(rhs2, rhs3)
u̇ = ∂x(u)
∫dV(ϕ, u̇)  = -∫dV(ϕ, u) + ∫dA(ϕ, u)

u̇ = Explicit(∂x(u), RK2) + Implicit(∂x( ∂x(u)), RK2)

Q .= Qinit
prob = IncrementingODEProblem(rhs!, Q, (t0, finaltime))
solve(prob, method; dt=dt, adjustfinal=true)
# should this be called evolve?
evolve(prob, method; dt=dt, adjustfinal=true)

# 
#=
function simplify(my_expr)
    standard_set_of_rules = [...]
    d = Fixpoint(Postwalk(Chain(standard_set_of_rules)))(c)
    return d
end
=#
#=
perhaps Gradient()
ar1 = @acrule ∂x(~x, ~z) => ∫dV(~x, ~z) + ∫dA(~x, ~z)

σ = ∂x(u)
u̇ = ∂x(u * u ) + ∂x(σ)

σ = ∫dV(u) + ∫dA(u)
u̇ = ∫dV(u*u) + ∫dA(u*u) + ∫dV(σ) + ∫dA(σ)

σ = ∫dV(u) + ∫dA(u)
u̇ = ∫dV(u*u + σ) + ∫dA(u*u +  σ)
=#