# Quick Structs for checking calculations
import Impero: compute
import Impero: to_expr

export Wrapper, WrapperMetaData, @wrapper
export Operator, DerivativeMetaData, OperatorMetaData

struct Wrapper{T, S} <: AbstractExpression
    data::T
    meta_data::S
end
# Struct for MetaData
struct WrapperMetaData{T}
    io_name::T
end

to_expr(a::Wrapper) = :($a)

function Base.show(io::IO, field::Wrapper{T, S}) where {T <: Char, S}
    color = 230
    printstyled(io, field.data, color = color)
end
function Base.show(io::IO, field::Wrapper{T, S}) where {T, S <: WrapperMetaData}
    color = 230
    printstyled(io, field.meta_data.io_name, color = color)
end

compute(a::Wrapper) = a.data

macro wrapper(expr)
    rewritten_expr = _wrapper(expr)
    return rewritten_expr
end

function _wrapper(expr::Expr)
    symb = expr.args[1]
    val  = expr.args[2]
    string_symb = String(symb)
    new_expr = :($(esc(symb)) =  Wrapper($(esc(val)), WrapperMetaData($string_symb)))
    return new_expr
end

macro wrapper(exprs...)
    rewritten_exprs = [_wrapper(expr) for expr in exprs]
    return Expr(:block, rewritten_exprs...)
end

## Add Operators
struct Operator{𝒮, 𝒯} <: AbstractExpression
    operand::𝒮
    metadata::𝒯
end

function (o::Operator)(expr::AbstractExpression)
    return Operator(expr, o.metadata)
end

function compute(o::Operator)
    return o.metadata.operation(compute(o.operand))
end

function compute(o::Operator{𝒮, 𝒯}) where 
    {𝒮 <: Nothing, 𝒯}
    return compute(o.metadata)
end

struct DerivativeMetaData{𝒪, 𝒟}
    operation::𝒪
    direction::𝒟
end

function Base.show(io::IO, o::Operator{S,T}) where
    {S <: Nothing, T <: DerivativeMetaData}
    name = Char(0x02202) * o.metadata.direction
    printstyled(io, name, color = 14 )
end

function Base.show(io::IO, o::Operator{S,T}) where 
    {S <: AbstractExpression, T <: DerivativeMetaData}
    name = Char(0x02202) * o.metadata.direction
    printstyled(io, name, "(",  color = 14 )
    print(o.operand)
    printstyled(io, ")",  color = 14 )
end

struct OperatorMetaData{𝒪, 𝒩}
    operation::𝒪
    name::𝒩
end

function Base.show(io::IO, o::Operator{S,T}) where
    {S <: Nothing, T <: OperatorMetaData}
    name = o.metadata.name
    printstyled(io, name, color = 14 )
end

function Base.show(io::IO, o::Operator{S,T}) where 
    {S <: AbstractExpression, T <: OperatorMetaData}
    name = o.metadata.name
    printstyled(io, name, "(",  color = 14 )
    print(o.operand)
    printstyled(io, ")",  color = 14 )
end

to_expr(t::Operator) = Expr(:call, t, to_expr(t.operand))