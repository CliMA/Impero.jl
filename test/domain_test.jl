using Test
using Impero
using LinearAlgebra

Ω =  Circle(0,2pi) × Interval(-1,1)
t1 = Ω * Interval(-1,1)

info(Ω)

@testset "domain tests" begin
    @test ndims(Ω) == 2
    @test ndims(t1) == 3
    @test Ω.domains[1] == Ω[1]
end

abstract type AbstractBoundary end

struct PointBoundary{S}
    point::S
end

struct Boundaries{S}
    boundaries::S
end


function ∂(a::IntervalDomain)
    if a.periodic
        return (nothing)
    else
        return (PointBoundary(a.a), PointBoundary(a.b))
    end
    return nothing
end
import Impero: ndims
ndims(p::PointBoundary) = 0
function ∂(p::ProductDomain)
    boundaries = []
    for domain in p.domains
        push!(boundaries, ∂(domain))
    end
    return boundaries
end

∂(Interval(-1,1))
∂Ω = ∂(Ω×Ω)