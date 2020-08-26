
import LinearAlgebra: ×

export AbstractDomain
export AbstractBoundary
export PredefinedBoundary
export GeneralDomain
export GeneralBoundary

export DomainBoundary
export IntervalDomain, ProductDomain, SphereSurfaceDomain

abstract type AbstractDomain end
abstract type AbstractBoundary end
abstract type PredefinedBoundary <: AbstractDomain end

struct GeneralDomain <: AbstractDomain end
∂(::GeneralDomain) = DomainBoundary(nothing)

struct DomainBoundary <: AbstractBoundary
    closure
end

struct GeneralBoundary <: AbstractBoundary end

struct IntervalDomain{AT, BT, PT} <: PredefinedBoundary
    a::AT
    b::BT
    periodic::PT
end

function IntervalDomain(a, b; periodic=false)
    @assert a < b
    return IntervalDomain(a, b, periodic)
end

∂(Ω::IntervalDomain) = Ω.periodic ? DomainBoundary(nothing) : DomainBoundary((Ω.a, Ω.b))

struct ProductDomain{DT} <: AbstractDomain
    domains::DT
end
×(args::AbstractDomain...) = ProductDomain{typeof(args)}(args)

struct SphereSurfaceDomain{FT} <: PredefinedBoundary
    r::FT
    SphereSurfaceDomain(r) = new{typeof(r)}(r)
end

∂(Ω::SphereSurfaceDomain) = DomainBoundary(nothing)