struct SimpleCrankRod{𝕋 <: Base.IEEEFloat}
    R::𝕋    # crank radius, m
    L::𝕋    # rod length, m
    D::𝕋    # piston diameter, m
    V::𝕋    # minimum volume, m³
    function SimpleCrankRod(r::𝕋, l::𝕋, d::𝕋, v::𝕋) where {𝕋 <: Base.IEEEFloat}
        @assert(r > zero(𝕋), "Error: R <= 0")
        @assert(l > r, "Error: L <= R")
        @assert(d > zero(𝕋), "Error: D <= 0")
        @assert(v > zero(𝕋), "Error: V <= 0")
        return new{𝕋}(r, l, d, v)
    end
end

# External constructors
function SimpleCrankRod(r::Real, l::Real, d::Real, v::Real)
    𝕋 = promote_type(typeof.((r, l, d, v))...)
    𝕋 = 𝕋 <: Base.IEEEFloat ? 𝕋 : Float64
    return SimpleCrankRod(𝕋.((r, l, d, v))...)
end

#function SimpleCrankRod(
#                        r::
#                       )

# Conversions
import Base: convert

function convert(
        ::Type{SimpleCrankRod{𝕋}},
        x::SimpleCrankRod{𝕊}
    ) where {𝕋 <: Base.IEEEFloat, 𝕊 <: Base.IEEEFloat}
    return SimpleCrankRod(
        𝕋(x.R), 𝕋(x.L), 𝕋(x.D), 𝕋(x.V)
    )
end

# Promotions
import Base: promote_rule

function promote_rule(
        ::Type{SimpleCrankRod{𝕋}},
        ::Type{SimpleCrankRod{𝕊}}
    ) where {𝕋 <: Base.IEEEFloat, 𝕊 <: Base.IEEEFloat}
    return SimpleCrankRod{promote_type(𝕋, 𝕊)}
end

# Export
export SimpleCrankRod
