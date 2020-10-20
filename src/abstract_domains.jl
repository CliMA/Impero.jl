using Printf
import Base: getindex, *, dims
import LinearAlgebra: ×

abstract type AbstractDomain end
abstract type AbstractBoundary end

export Interval, Circle
export info, dims
export ×

struct DomainBoundary <: AbstractBoundary
    closure
end
struct IntervalDomain{AT, BT, PT} <: AbstractDomain
    a::AT
    b::BT
    periodic::PT
end

function IntervalDomain(a, b; periodic=false)
    @assert a < b
    return IntervalDomain(a, b, periodic)
end
function Circle(a, b)
    @assert a < b
    return IntervalDomain(a, b, periodic = true)
end
S¹ = Circle
function Interval(a, b)
    @assert a < b
    return IntervalDomain(a, b)
end

function Base.show(io::IO, Ω::IntervalDomain) 
    a = Ω.a
    b = Ω.b
    printstyled(io, "[", color = 226)
    printstyled("$a, $b", color = 7)
    Ω.periodic ? printstyled(io, ")", color = 226) : printstyled(io, "]", color = 226)
 end


∂(Ω::IntervalDomain) = Ω.periodic ? DomainBoundary(nothing) : DomainBoundary((Ω.a, Ω.b))

struct ProductDomain{DT} <: AbstractDomain
    domains::DT
end

function Base.show(io::IO, Ω::ProductDomain) 
    for (i,domain) in enumerate(Ω.domains)
        print(domain)
        if i != length(Ω.domains)
            printstyled(io, "×", color = 118)
        end
    end
 end

function dims(Ω::IntervalDomain)
    return 1
end

function dims(Ω::ProductDomain)
    return length(Ω.domains)
end

×(arg1::AbstractDomain, arg2::AbstractDomain) = ProductDomain((arg1, arg2))
×(args::ProductDomain, arg2::AbstractDomain) = ProductDomain((args.domains..., arg2))
×(arg1::AbstractDomain, args::ProductDomain) = ProductDomain((arg1, args.domains...))
×(arg1::ProductDomain, args::ProductDomain) = ProductDomain((arg1.domains..., args.domains...))
×(args::AbstractDomain) = ProductDomain(args...)
*(arg1::AbstractDomain, arg2::AbstractDomain) = ProductDomain((arg1, arg2))
*(args::ProductDomain, arg2::AbstractDomain) = ProductDomain((args.domains..., arg2))
*(arg1::AbstractDomain, args::ProductDomain) = ProductDomain((arg1, args.domains...))
*(arg1::ProductDomain, args::ProductDomain) = ProductDomain((arg1.domains..., args.domains...))
*(args::AbstractDomain) = ProductDomain(args...)

function info(Ω::ProductDomain)
    println("This is a ", dims(Ω),"-dimensional tensor product domain.")
    print("The domain is ")
    println(Ω, ".")
    for (i,domain) in enumerate(Ω.domains)
        domain_string = domain.periodic ? "periodic" : "wall-bounded"
        length = @sprintf("%.2f ", domain.b-domain.a)
        println("The dimension $i domain is ", domain_string, " with length ≈ ", length)
        
    end
    return nothing
end

function check_full_periodicity(Ω::ProductDomain)
    b = [Ω.domains[i].periodic for i in eachindex(Ω.domains)]
    return prod(b)
end

function periodicity_function(Ω::ProductDomain)
    periodicity = ones(Bool, dims(Ω))
    for i in 1:dims(Ω)
        periodicity[i] = Ω[i].periodic
    end
    return Tuple(periodicity)
end
getindex(Ω::ProductDomain, i::Int) = Ω.domains[i]

