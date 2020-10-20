using Test
using Impero
using LinearAlgebra

Ω =  Circle(0,2pi) × Interval(-1,1)
t1 = Ω * Interval(-1,1)

info(Ω)

@testset "domain tests" begin
    @test dims(Ω) == 2
    @test dims(t1) == 3
    @test Ω.domains[1] == Ω[1]
end
