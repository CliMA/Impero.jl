export unary_operators, binary_operators, compute
export AbstractExpression

# Define abstract base type
abstract type AbstractExpression end

# Define Algebraic Operators
include("abstract_operations.jl")
# Define Domains
include("abstract_domains.jl")
# Define Fields
include("abstract_fields.jl")
# Define Data
include("abstract_data.jl")
# Define equations and systems
include("abstract_equations.jl")

# compute function
compute(a::AbstractExpression) = throw(error("compute not defined for $(typeof(a))"))

# Include Generic Evaluation Rules and Output Format
for unary_operator in unary_operators
    b_name, b_symbol = Meta.parse.(unary_operator)
    @eval compute(a::$b_name{𝒮}) where {𝒮} = $b_symbol(compute(a.term))
    @eval function Base.show(io::IO, operation::$b_name{𝒮}) where {𝒮}
        print(io, $b_symbol, "(", operation.term, ")")
    end
    @eval export $b_name
end

for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval compute(a::$b_name{𝒮, 𝒯}) where {𝒮, 𝒯} = $b_symbol(compute(a.term1), compute(a.term2))
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
    @eval export $b_name
end
