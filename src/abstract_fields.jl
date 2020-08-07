using LinearAlgebra

import Base: +, -, *, convert, promote_rule

abstract type AbstractField <: AbstractExpression end

struct Field{𝒯, 𝒮} <: AbstractField
    data::𝒯
    metadata::𝒮
end

Field() = Field(nothing, nothing)
Field(md::AbstractMetaData) = Field(nothing, md)

# Interpret Numbers as special Fields
for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval $b_symbol(a::Number, b::AbstractExpression) = $b_name(Field(a, nothing), b)
    @eval $b_symbol(a::AbstractExpression, b::Number) = $b_name(a, Field(b, nothing))
end






