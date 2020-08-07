include(pwd() * "/symbolics/abstract_core.jl")

# Fourier Structs
struct FourierMetaData{𝒮, 𝒱, ℱ, 𝒫} <: AbstractMetaData
    size::𝒮
    k::𝒱
    filter::ℱ
    transform::𝒫
end

# Functions
function fourier_nodes(a, b, N)
    return (b-a) .* collect(0:(N-1))/N .+ a
end

function fourier_wavenumbers(a, b, N)
    up = collect(0:1:N-1)
    down = collect(-N:1:-1)
    indices = up
    indices[floor(Int, N/2):end] = down[floor(Int, N/2):end]
    wavenumbers = 2π/(b-a) .* indices
    return wavenumbers
end

function fourier_derivative(y, P, k)
    tmp = copy(y)
    dy = copy(y)
    mul!(tmp, P, y)
    @. tmp *= im * k 
    ldiv!(dy, P, tmp)
    return dy
end

struct Gradient{𝒯, 𝒰} <: AbstractExpression
    operand::𝒯
    metadata::𝒰
end

fourier_derivative(y::AbstractData, P, k) = fourier_derivative(y.data, P, k)
function eval(e::Gradient{𝒯, 𝒰}) where {𝒯, 𝒰 <: FourierMetaData}
    return Data(fourier_derivative(eval(e.operand), e.metadata.transform, e.metadata.k))
end

