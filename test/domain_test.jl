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
import Base: show
function Base.show(io::IO, o::PointBoundary)
    print("{",o.point,"}")
end

ndims(p::PointBoundary) = 0
function ∂(p::ProductDomain)
    boundaries = []
    for domain in p.domains
        push!(boundaries, ∂(domain))
    end
    return boundaries
end

∂(Interval(-1,1))
∂Ω = ∂(Ω)
function futureconstructor(Ω)
    ∂Ω = ∂(Ω)
    splitb = []
    for (i,boundary) in enumerate(∂Ω)
        tmp = Any[]
        push!(tmp, Ω.domains...)
        if boundary != nothing
            tmp1 = copy(tmp)
            tmp2 = copy(tmp)
            tmp1[i] = boundary[1]
            push!(splitb, (tmp1))
            tmp2[i] = boundary[2]
            push!(splitb, (tmp2))
        end
    end
    return splitb
end
boundaries = futureconstructor(Ω);
for i in eachindex(boundaries)
    println(boundaries[i][1], "×",boundaries[i][2])
end