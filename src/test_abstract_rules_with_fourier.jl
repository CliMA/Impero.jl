using FFTW, BenchmarkTools, Plots
include(pwd()*"/symbolics" * "/fourier_eval_rules.jl")
# Test concrete implementation
N = 2^7
a, b = (0, 2π)
x = fourier_nodes(a, b, N)
k = fourier_wavenumbers(a, b, N)
P = plan_fft(x*(1+0im))

# Test Abstract implementation
fourier_meta_data = FourierMetaData(N, k, nothing, P)
∂x(a::AbstractExpression) = Gradient(a, fourier_meta_data)

# initial condition
u0 = @. exp(-2 * (b-a) / 3 * (x - (b-a)/2)^2)*(1+0im)
# metadata and fields
fourier_meta_data = FourierMetaData(N, k, nothing, P)
y_fourier = Data(u0)
field = Field(y_fourier, fourier_meta_data)
u = field
κ = 0.001
# Burgers equation rhs
u̇ = -∂x(u * u * 0.5)  + κ * ∂x(∂x(u))
p = (u̇, u, κ)

function fourier_burgers!(v̇ , v, params, t)
    # unpack params
    u̇ = params[1]           # Gradient operator
    u = params[2]           # flux term
    κ = params[3]           # diffusion constant
    u.data.data .= real.(v)
    v̇ .= compute(u̇)
    return nothing
end

##

rhs! = fourier_burgers!
tspan = (0.0, 20.0)

# Define ODE problem
ode_problem = (rhs!, u0, tspan, p);

##
using DifferentialEquations
prob = ODEProblem(ode_problem...);
# Solve it
ode_method = Heun() # Heun(), RK4, Tsit5
dt = 0.1 / N
sol  = solve(prob, ode_method, dt=dt, adaptive = false);

# Plot it
##
theme(:juno)
nt = length(sol.t)
num = 40 # Number of Frames
step = floor(Int, nt/num)
num = floor(Int, nt/step)
indices = step * collect(1:num)
pushfirst!(indices, 1)
push!(indices, nt)
for i in indices
    plt = plot(x, real.(sol.u[i]), xlims=(a, b), ylims = (-1.1,1.1), marker = 3,    leg = false)
    plot!(x, real.(sol.u[1]), xlims = (a, b), ylims = (-1.1,1.1), color = "red", leg = false, grid = true, gridstyle = :dash, gridalpha = 0.25, framestyle = :box)
    display(plt)
    sleep(0.1)
end

# ref_grid = copy(x)
# ref_sol = copy(real.(sol.u[end]))
#=
ref_plt = plot(ref_grid, ref_sol, xlims = (a, b), ylims = (-1.1,1.1), color = "blue", leg = false, grid = true, gridstyle = :dash, gridalpha = 0.25, framestyle = :box)
plot!(x, real.(sol.u[end]), xlims=(a, b), ylims = (-1.1,1.1), marker = 3,    leg = false)
display(ref_plt)
=#

#=
# compare these two philosophies
∂ˣ(y) = fourier_derivative(y, P, k)
y = @. sin(x)*(1+0im)
@btime -∂ˣ(y .* y .* 0.5) + 0.01 .* ∂ˣ(∂ˣ(y));
@btime eval(-∂x(u * u * 0.5) + κ * ∂x(∂x(u)));
=#