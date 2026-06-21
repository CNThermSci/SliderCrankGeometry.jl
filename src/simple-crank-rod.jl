struct SimpleCrankRod{T <: Base.IEEEFloat}
    R::T    # crank radius, m
    L::T    # rod length, m
    D::T    # piston diameter, m
    V::T    # minimum volume, m³
    function SimpleCrankRod(r::T, l::T, d::T, v::T) where {T <: Base.IEEEFloat}
        @assert(r > zero(T), "Error: R <= 0")
        @assert(l > r, "Error: L <= R")
        @assert(d > zero(T), "Error: D <= 0")
        @assert(v > zero(T), "Error: V <= 0")
        return new{T}(r, l, d, v)
    end
end

# External constructors
function SimpleCrankRod(
        r::Base.IEEEFloat,
        l::Base.IEEEFloat,
        d::Base.IEEEFloat,
        v::Base.IEEEFloat,
    )
    return SimpleCrankRod(promote(r, l, d, v)...)
end

# Conversions
import Base: convert

function convert(
        ::Type{SimpleCrankRod{T}},
        x::SimpleCrankRod{S}
    ) where {T <: Base.IEEEFloat, S <: Base.IEEEFloat}
    return SimpleCrankRod(
        T(x.R), T(x.L), T(x.D), T(x.V)
    )
end

# Promotions

export SimpleCrankRod
