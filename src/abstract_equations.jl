export AbstractSystem, AbstractEquation
export Equation
export @pde_system, @to_equation

abstract type AbstractSystem end
abstract type AbstractEquation end

mutable struct Equation <: AbstractEquation
    lhs
    rhs
end

function _to_equation(expr)
    lhs = expr.args[1]
    rhs = expr.args[2]
    new_expr = :(Equation($(esc(lhs)), $(esc(rhs))))
    return new_expr
end

macro to_equation(expr)
    return _to_equation(expr)
end

macro pde_system(expr)
    for i in eachindex(expr.args[2].args)
        arg = expr.args[2].args[i]
        tmp = Expr(:call, :Equation, esc(arg.args[1]), esc(arg.args[2]))
        expr.args[2].args[i] = tmp
    end
    expr.args[1]= esc(expr.args[1])
    return expr
end


function Base.show(io::IO, p::Equation)
    print(io, p.lhs, "=", p.rhs)
end
