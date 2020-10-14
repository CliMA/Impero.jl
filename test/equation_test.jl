using Impero, Test

Impero.@wrapper u=1 σ=1

@testset "Impero Equation Specification" begin
    equ = @to_equation σ=u
    @test equ.rhs == u
    @test equ.lhs == σ

    @pde_system pde_system = [
        σ = ∂x(u),
        ∂t(u) = -∂x(u * u - ∂x(σ)),
    ]
    @test pde_system[1].lhs == σ
    @test pde_system[2].lhs == ∂t(u)
    @test pde_system[1].rhs == ∂x(u)
    @test pde_system[2].rhs == -∂x(u * u - ∂x(σ))
end

@testset "Impero Equation Modification" begin
    @pde_system pde_system = [
        σ = ∂x(u),
        ∂t(u)= ∂x(∂x(σ)),
    ]
    pde_system[2].rhs += -∂x(u*u)
    rhs = (∂x(∂x(σ))+-(∂x((u*u))))
    @test pde_system[2].rhs == rhs
end

@testset "Impero Equation Augmentation" begin
    @pde_system pde_system = [
        σ = ∂x(u),
        ∂t(u)= ∂x(∂x(σ)),
    ]
    push!(pde_system, @to_equation σ=u)
    @test pde_system[3].lhs == σ
    @test pde_system[3].rhs == u
end
