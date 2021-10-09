
export UnaryOperation, BinaryOperation, NaryOperation
export AbstractOperation, Gradient
export to_expr

import Base: +, *, -, √, /, tanh, sin, cos, tan, ^, exp, convert, promote_rule

# Unary Operators, (name, symbol)
unary_operators = []
push!(unary_operators, ["Negative", "-"])
push!(unary_operators, ["SquareRoot", "√"])
push!(unary_operators, ["Tanh", "tanh"])
push!(unary_operators, ["Sin", "sin"])
push!(unary_operators, ["Cos", "cos"])
push!(unary_operators, ["Tan", "tan"])
push!(unary_operators, ["Exp", "exp"])

# Binary Operators, (name, symbol)
binary_operators = []
push!(binary_operators, ["Add", "+"])
push!(binary_operators, ["Multiply", "*"])
push!(binary_operators, ["Divide", "/"])
push!(binary_operators, ["Exponentiation", "^"])

nary_operators = []
push!(nary_operators, ["Sum", "+"])
push!(nary_operators, ["Product", "*"])


abstract type AbstractOperation <: AbstractExpression end
abstract type UnaryOperation  <: AbstractOperation end
abstract type BinaryOperation <: AbstractOperation end
abstract type NaryOperation <: AbstractOperation end

# Define to_expression function
to_expr(x) = x
# Define Struct and Symbol Overload for Unary Operators
for unary_operator in unary_operators
    b_name, b_symbol = Meta.parse.(unary_operator)
    @eval struct $b_name{𝒯} <: UnaryOperation
        term::𝒯
    end
    @eval $b_symbol(a::AbstractExpression) = $b_name(a)
    @eval to_expr(a::$b_name) = Expr(:call, $b_symbol, to_expr(a.term))
end

# Define Struct and Symbol Overload for Binary Operators
for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval struct $b_name{𝒯, 𝒮} <: BinaryOperation
        term1::𝒯
        term2::𝒮
    end
    @eval $b_symbol(a::AbstractExpression, b::AbstractExpression) = $b_name(a, b)
    @eval to_expr(a::$b_name) = Expr(:call, $b_symbol, to_expr(a.term1), to_expr(a.term2))
end

# Define Struct and Symbol Overload for n-ary Operators
for nary_operator in nary_operators
    # Defining the nary name and symbol
    n_name, n_symbol = Meta.parse.(nary_operator)

    # Defining the struct, along with outer constructor
    @eval struct $n_name{q} <: NaryOperation
        terms::Vector{q}
    end

    # Linking the defined symbol to a cuntion that creates the struct
    @eval $n_symbol(a::Vector{T} where T <: AbstractExpression) = $n_name([a...])

    # This should be defining Sum -> +(term1, term2, ... termN)
    @eval to_expr(a::$n_name) = Expr(:call, $n_symbol, to_expr(a.terms...))
end

# Special Structs
struct Gradient{𝒯, 𝒰} <: AbstractExpression
    operand::𝒯
    metadata::𝒰
end

# Special Rules
-(a::AbstractExpression, b::AbstractExpression) = a + -b
