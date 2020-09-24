using Impero
using Test
import Impero:compute

# Quick Structs for checking calculations
struct Wrapper{T, S} <: AbstractExpression
    data::T
    meta_data::S
end
# Struct for MetaData
struct MetaData{T}
    io_name::T
end

function Base.show(io::IO, field::Wrapper{T, S}) where {T <: Char, S}
    color = 230
    printstyled(io, field.data, color = color)
end
function Base.show(io::IO, field::Wrapper{T, S}) where {T, S <: MetaData}
    color = 230
    printstyled(io, field.meta_data.io_name, color = color)
end

a = Wrapper(1, MetaData("a"))
b = Wrapper(2, MetaData("b"))
d = Wrapper(4, MetaData("d"))

compute(a::Wrapper) = a.data

@testset "Impero operator matching" begin

    println("for $a = ", a.data, ", $b = ", b.data, " $d = ", d.data)
    for unary_operator in unary_operators
        b_name, b_symbol = Meta.parse.(unary_operator)
        @eval c = $b_symbol(a)
        println("The value of $c is ", compute(c))
        @test @eval ( compute(c) == $b_symbol(a.data) )
    end

    for binary_operator in binary_operators
        b_name, b_symbol = Meta.parse.(binary_operator)
        @eval c = $b_symbol(a, b)
        println("The value of $c is ", compute(c))
        @test @eval compute(c) == $b_symbol(a.data, b.data) 
    end

    for nary_operator in nary_operators
        b_name, b_symbol = Meta.parse.(nary_operator)
        @eval c = $b_name([a, b, d])
        println("The value of $c is ", compute(c))
        @test @eval compute(c) == $b_symbol(a.data, b.data, d.data) 
    end

end
