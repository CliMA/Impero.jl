export AbstractField, AbstractMetaData, BasicMetaData
export Field

abstract type AbstractField <: AbstractExpression end
abstract type AbstractMetaData <: AbstractExpression end

struct Field{𝒯, 𝒮} <: AbstractField
    data::𝒯
    metadata::𝒮
end

struct BasicMetaData{𝒩} <: AbstractMetaData
    name::𝒩
end

Field() = Field(nothing, nothing)
Field(a; metadata = nothing) = Field(a, metadata)
Field(a::Number) = Field(a, BasicMetaData(string(a)))

# Interpret Numbers as special Fields
for binary_operator in [binary_operators..., ["Negative", "-"]]
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval $b_symbol(a::Number, b::AbstractExpression) = $b_symbol(Field(a), b)
    @eval $b_symbol(a::AbstractExpression, b::Number) = $b_symbol(a, Field(b))
end

function Base.show(io::IO, ϕ::Field{S, T}) where {S, T <: AbstractMetaData}
    printstyled(io, ϕ.metadata.name, color = 199  )
 end

compute(n::Number) = n
compute(a::Field) = compute(a.data)