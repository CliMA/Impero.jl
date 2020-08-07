include(pwd()*"/symbolics" * "/dg_eval_rules.jl")

# Domain and Boundary
Ω  = IntervalDomain(0, 2π, periodic = true)
∂Ω = ∂(Ω)

# Initial Condition
u⁰(x, a, b) = exp(-2 * (b-a) / 3 * (x - (b-a)/2)^2);

# DG Objects set up
# (TODO: need to work out how to organize the DGModel)
# 
# struct DGModel
#     pde_system
#     mesh
#     metadata
# end
#
# metadata = Dict("first_order_flux"    => (rusanov,),
#                 "second_order_fluxes" => (central, central))
# dgmodel = DGModel(pde_system, mesh, metadata)

K = 8      # Number of elements
n = 1      # Polynomial Order
mesh = create_mesh(Ω, elements = K, polynomial_order =  n) # Generate Uniform Periodic Mesh
x = mesh.x
u0 = @. u⁰(x, Ω.a, Ω.b) # use initial condition for array
α = 0.2; # Rusanov parameter
field_md = DGMetaData(mesh, nothing, nothing); # wrap field metadata
central = DGMetaData(mesh, u0, Rusanov(0.0));  # wrap derivative metadata
rusanov = DGMetaData(mesh, u0, Rusanov(α));    # wrap derivative metadata
y_dg = Data(u0);
u̇ = Data(nothing);
u = Field(y_dg, field_md);
∂xᶜ(a::AbstractExpression) = Gradient(a, central);
∂xᴿ(a::AbstractExpression) = Gradient(a, rusanov);
κ = 0.001 # Diffusivity Constant

# Burgers equation rhs
pde_equation = [
    u̇ == -∂xᴿ(u * u * 0.5)  + κ * ∂xᶜ(∂xᶜ(u)),
]
# GalerkinMethod <: AbstractSpatialDiscretization
# ElementGalerkin <: GalerkinMethod
# DiscontinuousGalerkin <: ElementGalerkin

# "method_type" => "galerkin"
# "galerkin_type" => "element"
# "element_galerkin_type" => "discontinuous"

pde_meta_data = Dict("name" => "Burgers Equation", "method" => "discontinuous Galerkin")
pde_system = PDESystem(pde_equation,
                       Ω;
                       initial_condition=u0,
                       bcs=nothing,
                       metadata=pde_meta_data)

##
# expr = :(u̇ = -∂xᴿ(u * u * 0.5)  + κ * ∂xᶜ(∂xᶜ(u));); 
# to change expr.args[1].args[2].args[2].args[2].args[1] = :∂xᶜ; eval(expr)
# ODE set up
p = (pde_system, u);

function dg_burgers!(v̇ , v, params, t)
    # unpack parameters
    pde_system = params[1]
    u = params[2]
    u.data.data .= real.(v)
    v̇ .= compute(pde_system.equations[1].rhs)
    return nothing
end

rhs! = dg_burgers!
tspan = (0.0, 20.0)

# Define ODE problem
ode_problem = (rhs!, u0, tspan, p);
##
using DifferentialEquations
prob = ODEProblem(ode_problem...);
# Solve it
ode_method = RK4() # Heun(), RK4, Tsit5
Δx = mesh.x[2] - mesh.x[1]
dt = minimum([Δx^2 / κ * 0.05, abs(Δx / α)*0.05])
sol  = solve(prob, ode_method, dt=dt, adaptive = false);

# Plot it
##
theme(:juno)
nt =  length(sol.t)
num = 40 # Number of Frames
stp = floor(Int, nt/num)
num = floor(Int, nt/stp)
indices = stp * collect(1:num)
pushfirst!(indices, 1)
push!(indices, nt)
for i in indices
    plt = plot(x, real.(sol.u[i]), xlims=(Ω.a, Ω.b), ylims = (-1.1,1.1), marker = 3,  leg = false)
    plot!(x, real.(sol.u[1]), xlims = (Ω.a, Ω.b), ylims = (-1.1,1.1), color = "red", leg = false, grid = true, gridstyle = :dash, gridalpha = 0.25, framestyle = :box)
    display(plt)
    sleep(0.1)
end
reference = sol.u[end]
##
plot(x, real.(sol.u[end]), xlims=(Ω.a, Ω.b), ylims = (-1.1,1.1), marker = 3,  leg = false)
plot!(ref_grid, ref_sol, xlims = (a, b), ylims = (-1.1,1.1), color = "blue", leg = false, grid = true, gridstyle = :dash, gridalpha = 0.25, framestyle = :box, line = 3, label = "Reference Solution")