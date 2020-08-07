include(pwd()*"/symbolics" * "/dg_eval_rules.jl")
# bug eval(u * u * (u+u))
# just need to wrap things in data so that eval(field) = field.data
# and that field.data remains a closed system
# i.e. data * data should be data
##
abstract type AbstractBoundaryCondition end
struct BoundaryConditions{ℬ} <: AbstractBoundaryCondition
    bcs::ℬ
end
struct IntervalBoundaryCondition{ℬ, 𝒞} <: AbstractBoundaryCondition
    boundary::ℬ
    condition::𝒞
end
struct TransmissiveCondition <: AbstractBoundaryCondition end
struct ValueBoundaryCondition{𝒱} <: AbstractBoundaryCondition
    value::𝒱
end
## evaluate bc
for unary_operator in unary_operators
    b_name, b_symbol = Meta.parse.(unary_operator)
    @eval eval_ghost(a::$b_name{𝒮}) where {𝒮} = $b_symbol(eval_ghost(a.term))
end

for binary_operator in binary_operators
    b_name, b_symbol = Meta.parse.(binary_operator)
    @eval eval_ghost(a::$b_name{𝒮, 𝒯}) where {𝒮, 𝒯} = $b_symbol(eval_ghost(a.term1), eval_ghost(a.term2))
end

# Rules for evaluating the ghost point, hacky since it uses DGMetaData
# insteand of field meta data
eval_ghost(x) = x
eval_ghost(x::Field{S, T}) where {S <: Number, T} = Data(x.data)
function eval_ghost(x::Field)
    # automatically assumes the kind of boundary condition
    tmp = [bc.condition.value for bc in u.metadata.state.bcs]
    return Data(tmp)
end

compute_ghost(x) = eval_ghost(x).data

## info printing would be nice
function info(x::Field)
    println("The is a field object")
    println("The members of this struct are " , fieldnames(typeof(x)))
    println("Its name is " * x.metadata.method.name)
    println("--")
    for i in x.metadata.state.bcs
        println("It has a " , typeof(i.condition) )
        println("with value = " , i.condition.value ,  " at x = " ,  i.boundary)
        println("--")
    end
end

## Pretty printing
abstract type AbstractName end
struct Name{𝒩} <: AbstractName
    name::𝒩
end

function Base.show(io::IO, f::Field{D, T}) where {D <: Number, T}
    printstyled(io, f.data, color = 112)
end

function Base.show(io::IO, f::Field{D, DGMetaData{S, V, N}}) where {D <: Data, S, V, N <: AbstractName}
    printstyled(io, f.metadata.method.name, color = 170)
end

function Base.show(io::IO, ∇::Gradient{S, T}) where {S, T}
    printstyled(io, "∇", "(", color = 172)
    print( ∇.operand)
    printstyled( ")", color = 172)
end

##

# Domain and Boundary, fieldnames(typeof(∂Ω))
Ω  = IntervalDomain(0, 2π, periodic = false)
∂Ω = ∂(Ω)

bcL = IntervalBoundaryCondition(∂Ω.closure[1], ValueBoundaryCondition(1.0))
bcR = IntervalBoundaryCondition(∂Ω.closure[2], ValueBoundaryCondition(0.0))
bcs = BoundaryConditions((bcL, bcR))

# Initial Condition
u⁰(x, a, b) = exp(-2 * (b-a) / 3 * (x - (b-a)/2)^2);

K = 8      # Number of elements
n = 1      # Polynomial Order
mesh = create_mesh(Ω, elements = K, polynomial_order =  n) # Generate Uniform Periodic Mesh
x = mesh.x
u0 = @. u⁰(x, Ω.a, Ω.b) # use initial condition for array
α = 0.2; # Rusanov parameter
field_md = DGMetaData(mesh, bcs, Name('u'));   # wrap field metadata (should not use DGMetaData, but lazy)
central = DGMetaData(mesh, u0, Rusanov(0.0));  # wrap derivative metadata
rusanov = DGMetaData(mesh, u0, Rusanov(α));    # wrap derivative metadata
y_dg = Data(u0);
u̇ = Data(nothing);
u = Field(y_dg, field_md);
∂xᶜ(a::AbstractExpression) = Gradient(a, central);
∂xᴿ(a::AbstractExpression) = Gradient(a, rusanov);
κ = 0.001 # Diffusivity Constant
##
# Burgers equation rhs
rhs = -∂xᴿ(u * u * 0.5)  + κ * ∂xᶜ(∂xᶜ(u))
pde_equation = [
    σ == ∂xᶜ(u),
    u̇ == -∂xᴿ(u * u * 0.5) + κ * ∂xᶜ(σ),
]

##
function compute_surface_terms(mesh::AbstractMesh, data, state::AbstractArray, method::Rusanov{𝒯}) where {𝒯, 𝒮}
    # first compute numerical fluxes at interface
    diffs = reshape( (data[mesh.vmapM] + data[mesh.vmapP]), (mesh.nFP * mesh.nFaces, mesh.K))
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

function dg_derivative(mesh, data, state, method)
    ∫dV = compute_volume_terms(data, mesh)
    ∫dA = compute_surface_terms(mesh, data, state, method)
    return ∫dV .+ ∫dA
end

#=
# throw in right after reshape in compute_surface_terms
function compute_boundary!(diffs, data, mesh, bc::Outflow{𝒮}, calculate::Function) where 𝒮
    uin  =  data[mesh.vmapI]
    uout =  data[mesh.vmapO] - 2.0 .* calculate(bc.out) # calculate(bc.out) is the flux on the boundary
    diffs[mesh.mapI]  =  @. (data[mesh.vmapI] + uin)
    diffs[mesh.mapO]  =  @. (data[mesh.vmapO] + uout)
    return nothing
end
# perhaps

abstract type AbstractBoundaryCondition end
struct Periodic <: AbstractBoundaryCondition end
scruct Left{𝒯} <: AbstractBoundaryCondition
    left::𝒯
end
eval_ghost_flux(a::AbstractExpression) = eval(a).data
function eval_ghost_flux(ϕ::Field{𝒯, DGMetaData{𝒮, 𝒱, 𝒰, Left}}) where {𝒯, 𝒱, 𝒰, ℬ} 
    uin  =  bc.out
    uout =  bc.in
    return Field([uin, uout], nothing)
end

function compute_boundary!(diffs, data, mesh, bc::Outflow{𝒮}, calculate::Function) where 𝒮
    uin  =  data[mesh.vmapI]
    uout =  data[mesh.vmapO] - 2.0 .* calculate(bc.out) # calculate(bc.out) is the flux on the boundary
    diffs[mesh.mapI]  =  @. (data[mesh.vmapI] + uin)
    diffs[mesh.mapO]  =  @. (data[mesh.vmapO] + uout)
    return nothing
end
=#

##

# Derivatives
dg_derivative(y::AbstractArray, md) = dg_derivative(md.mesh, y, md.state, md.method)
dg_derivative(y::AbstractData, md) = dg_derivative(y.data, md)
function eval(e::Gradient{𝒯, 𝒰}) where {𝒯, 𝒰 <: DGMetaData}
    return Data(dg_derivative(eval(e.operand), e.metadata))
end