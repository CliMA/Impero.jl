using ModelingToolkit, BenchmarkTools, LinearAlgebra, SparseArrays
include(pwd() * "/src" * "/HesthavenWarburton" * "/utils.jl")
include(pwd() * "/src" * "/HesthavenWarburton" * "/mesh.jl")

@variables x y

z = x^2 + y

to_compute = [z, x]
f_expr = build_function(to_compute, [x,y])

myf = eval(f_expr[1])
myf([2.0,3.0])

function myf_custom(x,y)
    return [x^2 + y, x]
end



# Check Speed
@btime myf([2.0,3.0]);
@btime myf_custom(x,y);

# Check arbitrary untyped function
function my_customz(x,y)
    return x^2 + y
end

to_compute2 = [my_customz(x,y), x]
f_expr = build_function(to_compute2, [x,y])
myf2 = eval(f_expr[1])
myf2([2.0, 3.0])

@btime myf([2.0,3.0]);

# checking vector calculus

cross([y,y,y],[y,y,y])


@parameters t x
@variables u(..)
@derivatives Dt'~t
@derivatives Dxx''~x
eq  = Dt(u(t,x)) ~ Dxx(u(t,x))
bcs = [u(0,x) ~ - x * (x-1) * sin(x),
           u(t,0) ~ 0, u(t,1) ~ 0]

domains = [t ∈ IntervalDomain(0.0,1.0),
           x ∈ IntervalDomain(0.0,1.0)]

pdesys = PDESystem(eq,bcs,domains,[t,x],[u])



# now do some DG
#=
struct Rusanov{𝒯}
    α::𝒯
end

function compute_volume_terms(data, D, rx)
    q = D * data
    q = q .* rx
    return q
end

compute_volume_terms(data, mesh::Mesh) = compute_volume_terms(data, mesh.D, mesh.rx)

# Periodic Boundary Conditions
function compute_surface_terms(mesh::AbstractMesh, data, state, method::Rusanov{𝒯}) where {𝒯}
    # first compute central numerical fluxes at interface
    diffs = reshape( (data[mesh.vmapM] + data[mesh.vmapP]), (mesh.nFP * mesh.nFaces, mesh.K ))
    # Include factor of 2 for the weak-strong form
    @. diffs *= 1.0 / 2.0
    # Extra dissipation for Rusanov
    @. diffs[:] += method.α * mesh.normals[:] .* (state[mesh.vmapM] - state[mesh.vmapP]) / 2.0
    # Now create jump in flux, (Weak-Strong form)
    @. diffs[:] -= data[mesh.vmapM]
    # Compute Lift Operator
    lifted =  mesh.lift * (mesh.fscale .* mesh.normals .* diffs)
    return lifted
end

function dg_derivative(mesh::AbstractMesh, data, state, method)
    ∫dV = compute_volume_terms(data, mesh)
    ∫dA = compute_surface_terms(mesh, data, state, method)
    return ∫dV .+ ∫dA
end

# Concrete Realization
K = 20     # Number of elements
n = 1      # Polynomial Order
a = 0.0 # left endpoint of domain
b = 2π  # right endpoint of domain
mesh = Mesh(K, n, a, b, periodic = true) # Generate Uniform Periodic Mesh
x = mesh.x
u0 = @. exp(-2 * (b-a) / 3 * (x - (b-a)/2)^2);

# modeling toolkit part
@parameters x, t
@variables u(x, t)

α = 0.2

# DG Objects set up
κ = 0.001 # Diffusivity Constant
=#