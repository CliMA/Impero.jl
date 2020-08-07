
export AbstractField, AbstractMetaData
export Field

abstract type AbstractField <: AbstractExpression end
abstract type AbstractMetaData <: AbstractExpression end

struct Field{𝒯, 𝒮} <: AbstractField
    data::𝒯
    metadata::𝒮
    function Field(data; metadata = nothing)
        return new{typeof(data), typeof(metadata)}(data, metadata)
    end
end

Field() = Field(nothing, nothing)
Field(md::AbstractMetaData) = Field(nothing, md)

# Interpret Numbers as special Fields
for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval $b_symbol(a::Number, b::AbstractExpression) = $b_name(Field(a), b)
    @eval $b_symbol(a::AbstractExpression, b::Number) = $b_name(a, Field(b))
end
