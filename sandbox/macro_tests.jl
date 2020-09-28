## could be done either way I guess
function checking_scope(custom_type)
    @eval function hello(a::$custom_type)
        println("Hello tmp")
    end
    return nothing
end
macro checking_scope(custom_type)
    @show custom_type
    expr = :(
    function hello(a::$custom_type)
        println("hello 3")
    end
    )
    return expr
end

checking_scope(String)
#
@checking_scope(String)

##
function check_scope()
    # puts into global scope
    @eval a=1
    @eval b=2
    return nothing
end

##
using Impero
import Base: show

struct DirectionalDerivative{𝒮} <: AbstractExpression
    direction::𝒮
end
struct GradientMetaData{𝒮}
    direction::𝒮
end

∂x = DirectionalDerivative("x")
∂y = DirectionalDerivative("y")
∂z = DirectionalDerivative("z")
∂t = DirectionalDerivative("t")

function (p::DirectionalDerivative)(expr::AbstractExpression)
    return Gradient(expr, GradientMetaData(p.direction))
end

#Char(0x2080 + parse(Int, "0"))
# partial derivative

function Base.show(io::IO, p::DirectionalDerivative{S}) where S <: String
    print(io, Char(0x02202) * p.direction)
end

function Base.show(io::IO, p::Gradient{S, T}) where {S, T <: GradientMetaData{String}}
    printstyled(io, Char(0x02202) * p.metadata.direction, "(", color = 165)
    print(io, p.operand)
    printstyled(io, ")", color = 165)
end

function print_colors()
    for i in 0:255
        printstyled("color(" * string(i) * ")", color = i)
    end
    return nothing
end

include(pwd() * "/test/test_utils.jl")
@wrapper u=1 σ=1

function Base.show(io::IO, p::PDEEquation) 
    print(io, p.lhs, "=", p.rhs)
end

pde_system = [
    PDEEquation(σ, ∂x(u)),
    PDEEquation(∂t(u), -∂x(u * u - ∂x(σ)))
]

for pde in pde_system
    println(pde)
end


##

macro show_stuff(expr)
    @show expr
    return nothing
end

@show_stuff pde_system = [
    PDEEquation(σ, ∂x(u)),
    PDEEquation(∂t(u), -∂x(u * u - ∂x(σ)))
]
##
expr_0 = :(pde_system = [σ = ∂x(u), ∂t(u)= -(∂x(u * u - ∂x(σ)))])
expr = :(pde_system = [PDEEquation(σ, ∂x(u)), PDEEquation(∂t(u), -(∂x(u * u - ∂x(σ))))])

for expr_system in expr.args[2].args
    @show expr_system
end

function _to_pde(expr)
    lhs = expr.args[1]
    rhs = expr.args[2]
    new_expr = :(PDEEquation($lhs, $rhs))
    return new_expr
end

macro to_pde(expr)
    return _to_pde(expr)
end

macro pde_system(expr)
    system_name = expr.args[1]
    system = expr_0.args[2].args
    converted_system = [eval(_to_pde(equation)) for equation in system]
    new_expr = :($(esc(system_name)) =  $converted_system)
    return new_expr
end

#=
@pde_system pde_system = [
    PDEEquation(σ, ∂x(u)),
    PDEEquation(∂t(u), -∂x(u * u - ∂x(σ)))
]
=#
pde_1 = _to_pde(:(σ = ∂x(u)))

pde1 = @to_pde σ = ∂x(u)

#
@pde_system pde_system = [
    PDEEquation(σ, ∂x(u)),
    PDEEquation(∂t(u), -∂x(u * u - ∂x(σ)))
]