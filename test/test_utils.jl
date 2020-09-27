# Quick Structs for checking calculations
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