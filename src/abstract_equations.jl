struct PDEEquation{TT <: AbstractExpression, ET <: AbstractExpression} <: AbstractEquation
    lhs::TT
    rhs::ET
end
Base.:(==)(a::AbstractExpression, b::AbstractExpression) = PDEEquation(a, b)

struct PDESystem{ET, DT, BCT, ICT, MD} <: AbstractSystem
    equations::ET
    domain::DT
    bcs::BCT
    initial_conditions::ICT
    metadata::MD
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
