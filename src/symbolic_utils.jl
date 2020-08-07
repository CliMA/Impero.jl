using SymbolicUtils

abstract type AbstractAnimal end

struct GenericAnimal <: AbstractAnimal end

struct Duck{T} <: AbstractAnimal
    type::T
end

struct DuckMetaData{T} 
    sound::T
end

make_sound(a::AbstractAnimal) = println("roof")

make_sound(a::Duck) = println("quack")
make_sound(a::Duck{T}) where {T <: Float64} = println("float quack")
make_sound(a::Duck{T}) where {T <: DuckMetaData} = println("meta quack")
make_sound(a::Duck{DuckMetaData{T}}) where {T <: String} = println(a.type.sound)

dog = GenericAnimal()
int_mallard = Duck(1)
float_mallard = Duck(1.0)
meta_mallard = Duck(DuckMetaData(1))
super_duck = Duck(DuckMetaData("Super Quack!!!!!"))

make_sound(dog)
make_sound(int_mallard)
make_sound(float_mallard)
make_sound(meta_mallard)
make_sound(super_duck)

##
import Base: +, *, -, show

abstract type AbstractContext end
abstract type AbstractExpression end

struct Standard <: AbstractContext end
struct NonStandard <: AbstractContext end

struct Wrapper{T, C} <: AbstractExpression
    arg1::T
    context::C
end

Base.show(io::IO, w::Wrapper) = println(w.arg1)

struct Add{T,S,C} <: AbstractExpression
    arg1::T
    arg2::S
    context::C
end

struct Multiply{T,S,C} <: AbstractExpression
    arg1::T
    arg2::S
    context::C
end

Base.show(io::IO, w::Add) = print(w.arg1, " + ", w.arg2)
Base.show(io::IO, w::Multiply) = print(w.arg1, " * ", w.arg2)

Wrapper(a) = Wrapper(a, Standard())
Add(a, b) = Add(a, b, Standard())
Multiply(a, b) = Multiply(a, b, Standard())

+(a::AbstractExpression, b::AbstractExpression) = Add(a, b)
*(a::AbstractExpression, b::AbstractExpression) = Multiply(a, b)
+(a::AbstractExpression, b::AbstractExpression, c::NonStandard) = Multiply(a, b)
*(a::AbstractExpression, b::AbstractExpression, c::NonStandard) = Add(a, b)

eval(e::Wrapper) = eval(e.arg1)
eval(e::Add) = eval(e.arg1) + eval(e.arg2)
eval(e::Multiply) = eval(e.arg1) * eval(e.arg2)

eval(e::Add{Wrapper{S, T}, U}) where {S, T <: NonStandard, U} = eval(e.arg1) * eval(e.arg2)

eval(Add(1,2))
eval(Add(Wrapper(1), 2))
eval(Add(Wrapper(1, NonStandard()), 2))
eval(Add(Wrapper(1), Wrapper(1, NonStandard())))

expression = Wrapper(1) + Wrapper(2)

eval(+(Wrapper(1), Wrapper(1)))
eval(+(Wrapper(1), Wrapper(1), NonStandard()))

##
∂t(u) = ∂x(u*u) + ∂x(∂x(u))

expr = ∂x(u*u, central) + ∂x(∂x(u, central), centra

expr = ∂x(u*u, rusanov) + ∂x(∂x(u, central), central)

expr = ∂x(u*u, rusanov(1)) + ∂x(∂x(u, central), central)

# Is it possible to have "overloaded variables"?
# Also, Any's everywhere... Is the default type always Number
# @syms u::Number v::Array rusanov rusanov(u) ∂x(a::Any)::Any ∂x(a::Any,b::Any)::Any label(a,b) advective diffusive central
@syms u v rusanov rusanov(u) ∂x_w_tag(a, b) ∂x(a) label(a,b) advective diffusive central

expr1 = ∂x(u*u) + ∂x(∂x(u))
import SymbolicUtils: Chain, Postwalk

Postwalk(∂x(u*u) + ∂x(∂x(u)))
[~f::(x->x isa Wrapper{<:Context1}) => do_thing_1,
 ~f::pred2 => do_thing_2]
Postwalk(Chain([@rule ∂x(u) => u]))(expr1)
Postwalk(Chain([∂xf(u*u) + ∂x(∂x(u)) => ∂x_w_tag(u*u, central) + ∂x_w_tag(∂x_w_tag(u, central), central)]))(expr1)
∂x(u,u)

# istree(AbstractExpression) = true; operation(Abst..) = *; arguments(::Abs..) = [...]

b = Wrapper(1)
##
SymbolicUtils.istree(a::Add) = true
SymbolicUtils.arguments(a::Add) = [a.arg1, a.arg2, a.context]
SymbolicUtils.operation(a::Add) = +;
SymbolicUtils.symtype(a) = Number

(@rule +(~a,~b) => Add(~b, ~a, ~ctx))(Wrapper(1) + Wrapper(2))
# (@rule +(~a,~b, ~ctx) => Add(~b, ~a, NonStandard()))(SymbolicUtils.to_symbolic(Wrapper(1) + Wrapper(2))) |> dump
# (@rule b + b => b * b)(SymbolicUtils.to_symbolic(c))
#(@rule b + b => b * b)(SymbolicUtils.to_symbolic(c)) |> typeof
#SymbolicUtils.to_symbolic(Wrapper(1) + Wrapper(1)) |> dump
#∂x = Sym{FnType{Tuple{Vararg{Any}}, Number}}(:∂x)
#Fixpoint(Postwalk(Chain([@rule ∂x(u) => u])))(∂x(u))
 using SymbolicUtils: Sym, FnType
SymbolicUtils.istree(a::Multiply) = true
SymbolicUtils.arguments(a::Multiply) = [a.arg1, a.arg2, a.context]
SymbolicUtils.operation(a::Multiply) = +;
SymbolicUtils.symtype(a) = Number
b = Wrapper(1)
(@rule b + b => b * b)(b+b)

simplify()
c = b+b

symbolic = SymbolicUtils.to_symbolic(c)
SymbolicUtils.to_symbolic(c) |> dump
@rule

reshape(a) = Symbolic{AbstractArray(reshape, a, (100,))

@rule reshape(~x)[~i, MyType([2])] => ~x[iprime(~i), jprime(~j)]


# +(Wrapper(1), Wrapper(1), Standard())
# +(Wrapper(1), Wrapper(1), NonStandard())

# changing the rule for +
# (@rule +(~a,~b, ~ctx) => Add(~b, ~a, NonStandard()))(SymbolicUtils.to_symbolic(Wrapper(1) + Wrapper(2)))
# the rule
# (@rule ~w::(x -> x isa Wrapper && x.ctx isa  Standard) => Wrapper((~w).val, NonStandard()))


# c = SymbolicUtils.to_symbolic(Wrapper(1) + Wrapper(2))


∂t(u) = label(∂x(u*u, standard), advective) + label(∂x(∂x(u, standard), standard), diffusive) + 

+(a, +(b, c)) => +(a,b,c)

a + (b + c) -> label(a) + label(b) + label(c) 

ClimaCtx() # SymbolicUtils ineraction context

@syms a b c


a[ClimaCtx] = Standard()
a[QAlgebra] = MyStuff()

~(a::(x->x[ClimaCtx] isa Standard))

ctx = [1, 1]
2 * a

Term{Number}

# interfaces
# pros: flexibility in types; cons: awkward rules, more interface code

expr = ∂x(u*u, central) + ∂x(∂x(u, central), central)

expr = ∂x(u*u, rusanov) + ∂x(∂x(u, central), central)

print_advective(expr) = ∂x(u*u, standard)
