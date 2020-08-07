# Define Operators (perhaps overload getproperty eventually?)
import Base.show
import Base: +, *, -, √, tanh, sin, cos, tan, ^

# Unary Operators, (name, symbol)
unary_operators = []
push!(unary_operators, ["Negative", "-"])
push!(unary_operators, ["SquareRoot", "√"])
push!(unary_operators, ["Tanh", "tanh"])
push!(unary_operators, ["Sin", "sin"])
push!(unary_operators, ["Cos", "cos"])
push!(unary_operators, ["Tan", "tan"])

# Binary Operators, (name, symbol)
binary_operators = []
push!(binary_operators, ["Add", "+"])
push!(binary_operators, ["Multiply", "*"])
push!(binary_operators, ["Exponentiation", "^"])

nary_operators = []
push!(nary_operators, ["Sum", "+"])
push!(nary_operators, ["Multiplicative_Sum", "*"])

# Define Abstract Types
abstract type AbstractEquation end
abstract type AbstractSystem end
abstract type AbstractExpression end
abstract type AbstractOperation <: AbstractExpression end
abstract type UnaryOperation  <: AbstractOperation end
abstract type BinaryOperation <: AbstractOperation end
abstract type NaryOperation <: AbstractOperation end
abstract type AbstractData <: AbstractExpression end
abstract type AbstractMetaData <: AbstractExpression end


# Define Algebraic Operators
include(pwd() * "/symbolics/abstract_operations.jl")
# Define Domains
include(pwd() * "/symbolics/abstract_domains.jl")
# Define Fields
include(pwd() * "/symbolics/abstract_fields.jl")
# Define Data
include(pwd() * "/symbolics/abstract_data.jl")
# Define equations and systems
include(pwd() * "/symbolics/abstract_equations.jl")


# Include Generic Evaluation Rules and Output Format
for unary_operator in unary_operators
    b_name, b_symbol = Meta.parse.(unary_operator)
    @eval eval(a::$b_name{𝒮}) where {𝒮} = $b_symbol(eval(a.term))
    @eval function Base.show(io::IO, operation::$b_name{𝒮}) where {𝒮}
        print(io, $b_symbol, "(", operation.term, ")")
    end
end

for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval eval(a::$b_name{𝒮, 𝒯}) where {𝒮, 𝒯} = $b_symbol(eval(a.term1), eval(a.term2))

    @eval function Base.show(io::IO, operation::$b_name{𝒮, 𝒯}) where {𝒮, 𝒯}
        # print(io, "(", operation.term1, $b_symbol , operation.term2, ")")
        # clearly a great option
        color_numbers = [30:33, 65:69, 136:142, 202:207]
        choices = collect(Iterators.flatten(color_numbers))
        color = 226 # rand(choices)
        printstyled(io, "(", color = color)
        print(io, operation.term1)
        printstyled(io, $b_symbol, color = color )
        print(io,  operation.term2)
        printstyled(io, ")", color = color)
    end
end

# Data Eval
eval(Φ::AbstractData) = Φ
# Field Eval
eval(Φ::AbstractField) = Φ.data

# TO work with symbolic utils and just a good idea anyway
Base.isequal(a::AbstractExpression, b::AbstractExpression) = a === b
