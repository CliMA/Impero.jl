using Impero

abstract type SpatialDiscretization <: AbstractExpression end
abstract type TimeDiscretization <: AbstractExpression end
struct Fourier <: SpatialDiscretization end
struct Time <: TimeDiscretization end

struct AB1 <: TimeDiscretization end
struct BDF1 <: TimeDiscretization end

struct Explicit{T,S} <: TimeDiscretization
    operand::T
    meta_data::S
end

struct Implicit{T,S} <: TimeDiscretization
    operand::T
    meta_data::S
end

# Assumes seperation by addition should be okay since quadrature is a 
# linear operation
function get_implicit(a::Implicit)
    return a
end
function get_implicit(a::Explicit)
    return Field(0) # probably need a rule like 0 + field = field
end
function get_implicit(a::Add)
    t1 = get_implicit(a.term1)
    t2 = get_implicit(a.term2)
    return t1 + t2
end
function get_implicit(a::Negative)
    t1 = get_implicit(a.term)
    return t1
end

function get_explicit(a::Explicit)
    return a
end

function get_explicit(a::Implicit)
    return Field(0) # probably need a rule like 0 + field = field
end

function get_explicit(a::Add) 
    t1 = get_explicit(a.term1)
    t2 = get_explicit(a.term2)
    return t1 + t2
end
function get_explicit(a::Negative)
    t1 = get_explicit(a.term)
    return t1
end

function get_implicit(eq::AbstractEquation)
    # place all implicit terms on left-hand side
    implicit = get_implicit(eq.lhs) - get_implicit(eq.rhs)
    return implicit
end
function get_explicit(eq::AbstractEquation)
    # place all explicit terms on left-hand side
    explicit = get_explicit(eq.rhs) - get_explicit(eq.lhs)
    return explicit
end
function get_imex(eq::AbstractEquation)
    implicit = get_implicit(eq)
    explicit = get_explicit(eq)
    return implicit == explicit
end
function get_imex(system::Array{S}) where {S <: AbstractEquation}
    return [get_imex(equation) for equation in system]
end
