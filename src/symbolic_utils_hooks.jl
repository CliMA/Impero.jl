using SymbolicUtils
import SymbolicUtils: Chain, Postwalk
import SymbolicUtils: Sym, Term, istree, operation, arguments, to_symbolic, Fixpoint

include("abstract_operations.jl")

for unary_operator in unary_operators
    b_name, b_symbol = Meta.parse.(unary_operator)
    @eval SymbolicUtils.istree(a::$b_name) = true
    @eval SymbolicUtils.arguments(a::$b_name) = [a.term] 
    @eval SymbolicUtils.operation(a::$b_name) = $b_symbol
    @eval SymbolicUtils.symtype(a::$b_name) = Number
end

# Define Struct and Symbol Overload for Binary Operators
for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval SymbolicUtils.istree(a::$b_name) = true
    @eval SymbolicUtils.arguments(a::$b_name) = [a.term1, a.term2] 
    @eval SymbolicUtils.operation(a::$b_name) = $b_symbol
    @eval SymbolicUtils.symtype(a::$b_name) = Number
end

# Define Struct and Symbol Overload for n-ary Operators
for nary_operator in nary_operators
    n_name, n_symbol = Meta.parse.(nary_operator)
    @eval SymbolicUtils.istree(a::$b_name) = true
    @eval SymbolicUtils.arguments(a::$b_name) = [a.terms...] 
    @eval SymbolicUtils.operation(a::$b_name) = $b_symbol
    @eval SymbolicUtils.symtype(a::$b_name) = Number
end