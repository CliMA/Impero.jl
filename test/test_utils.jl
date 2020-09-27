# Quick Structs for checking calculations
using Impero
import Impero:compute
struct Wrapper{T, S} <: AbstractExpression
    data::T
    meta_data::S
end
# Struct for MetaData
struct WrapperMetaData{T}
    io_name::T
end

function Base.show(io::IO, field::Wrapper{T, S}) where {T <: Char, S}
    color = 230
    printstyled(io, field.data, color = color)
end
function Base.show(io::IO, field::Wrapper{T, S}) where {T, S <: WrapperMetaData}
    color = 230
    printstyled(io, field.meta_data.io_name, color = color)
end

compute(a::Wrapper) = a.data

# Danger Zone
# a convenience function for 
# a = Wrapper(1, WrapperMetaData("a"))
# instead we want to do
# @wrapper a=1

macro wrapper(expr)
    rewritten_expr = _wrapper(expr)
    return rewritten_expr
end

function _wrapper(expr::Expr)
    symb = expr.args[1]
    val  = expr.args[2]
    if expr.head != :(=)
        println( "@wrapper macro not in proper form")
        println( "must be ")
        println( "@wrapper a=1 b=2 c=3")
        return error()
    end
    @show symb
    @show val
    string_symb = String(symb)
    new_expr = :($(esc(symb)) =  Wrapper($val, WrapperMetaData($string_symb)))
    return new_expr
end

macro wrapper(exprs...)
    @show exprs
    rewritten_exprs = [_wrapper(expr) for expr in exprs]
    @show rewritten_exprs
    return Expr(:block, rewritten_exprs...)
end

