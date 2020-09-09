using Impero

struct Wrapper{T, S} <: AbstractExpression
    data::T
    meta_data::S
end

function Base.show(io::IO, ∇::Gradient) 
    color = 220
    printstyled(io, "∇(", color = color)
    print(∇.operand)
    printstyled(io, ")", color = color)
end

function Base.show(io::IO, ∇::Gradient) 
    color = 220
    printstyled(io, "∇(", color = color)
    print(∇.operand)
    printstyled(io, ")", color = color)
end

function Base.show(io::IO, ϕ::Field) 
    print(ϕ.data)
end

function Base.show(io::IO, eq::AbstractEquation) 
    color = 118
    print(io, eq.lhs)
    printstyled(io, "=", color = color)
    print(io, eq.rhs)
end

function Base.show(io::IO, eq::Implicit) 
    print(io, eq.operand)
end
function Base.show(io::IO, eq::Explicit) 
    print(io, eq.operand)
end

# TODO: make this actually work
#=
function Base.show(io::IO, system::Array{T}) where {T <: AbstractEquation}
    for equation in system
        println(io, equation)
    end
end
=#
