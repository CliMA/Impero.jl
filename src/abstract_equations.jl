
export AbstractSystem, AbstractEquation
export PDESystem, PDEEquation

abstract type AbstractSystem end
abstract type AbstractEquation end

mutable struct PDEEquation <: AbstractEquation
    lhs
    rhs
end
# can't use due to interaction with symbolic utils, need dispatch 
# Base.:(==)(a::AbstractExpression, b::AbstractExpression) = PDEEquation(a, b)

mutable struct PDESystem <: AbstractSystem
    equations
    domain
    bcs
    initial_conditions
    metadata
end

function PDESystem(
    equations,
    domain;
    bcs = nothing,
    initial_condition = nothing,
    metadata = nothing,
)
    return PDESystem(equations, domain, bcs, initial_condition, metadata)
end
