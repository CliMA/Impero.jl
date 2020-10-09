using GraphRecipes, Impero, Test
using Plots
theme(:default)
default(size=(500, 500))
plot_flag = false

include(pwd() * "/test/test_utils.jl")
@wrapper α=1 β=1 ψ=1 ϕ=1

@testset "Testing to_expr function" begin
    impero_expr = α + β + sin(ϕ)^2
    julia_expr = to_expr(impero_expr)
    @test impero_expr == eval(julia_expr)
end

if plot_flag
    impero_expr = α + β + sin(ϕ)
    julia_expr = to_expr(impero_expr)
    plot(julia_expr)
end