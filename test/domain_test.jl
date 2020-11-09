using Test
using Impero
using LinearAlgebra

Ω =  Circle(0,2pi) × Interval(-1,1)
t1 = Ω * Interval(-1,1)
∂(Ω)
∂(t1)
info(Ω)

@testset "domain tests" begin
    @test ndims(Ω) == 2
    @test ndims(t1) == 3
    @test Ω.domains[1] == Ω[1]
    @test ndims(∂(Ω)[1]) == 1
    @test ndims(∂(t1)[1]) == 2
end


