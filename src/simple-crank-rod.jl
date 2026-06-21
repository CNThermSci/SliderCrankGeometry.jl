# Structure (type) definition
# ---------------------------

struct SimpleCR{ℙ <: Base.IEEEFloat}
    R::ℙ    # crank radius, m
    L::ℙ    # rod length, m
    D::ℙ    # piston diameter, m
    V::ℙ    # minimum volume, m³
    # Internal constructors
    # Validating
    function SimpleCR(r::ℙ, l::ℙ, d::ℙ, v::ℙ) where {ℙ <: Base.IEEEFloat}
        @assert(r > zero(ℙ), "Error: R <= 0")
        @assert(l > r, "Error: L <= R")
        @assert(d > zero(ℙ), "Error: D <= 0")
        @assert(v > zero(ℙ), "Error: V <= 0")
        return new{ℙ}(r, l, d, v)
    end
end

# External constructors
# ---------------------

# Set type conversion / 1 indirection
function SimpleCR{ℙ}(r::Real, l::Real, d::Real, v::Real) where {ℙ <: Base.IEEEFloat}
    return SimpleCR(ℙ.((r, l, d, v))...)
end

# Promotion type conversion / 2 indirections
function SimpleCR(r::Real, l::Real, d::Real, v::Real)
    ℙ = promote_type(typeof.((r, l, d, v))...)
    ℙ = ℙ <: Base.IEEEFloat ? ℙ : Float64
    return SimpleCR{ℙ}(r, l, d, v)
end

# Set type with unit conversion and stripping / 2 indirections
function SimpleCR{ℙ}(
        r::Unitful.Length{Real},
        l::Unitful.Length{Real},
        d::Unitful.Length{Real},
        v::Unitful.Volume{Real}
    ) where {ℙ <: Base.IEEEFloat}
    return SimpleCR{ℙ}(
        uconvert(u"m", r).val,
        uconvert(u"m", l).val,
        uconvert(u"m", d).val,
        uconvert(u"m^3", v).val,
    )
end

# Promotion type with unit conversion and stripping / 3 indirections
function SimpleCR(
        r::Unitful.Length{Real},
        l::Unitful.Length{Real},
        d::Unitful.Length{Real},
        v::Unitful.Volume{Real}
    )
    return SimpleCR(
        uconvert(u"m", r).val,
        uconvert(u"m", l).val,
        uconvert(u"m", d).val,
        uconvert(u"m^3", v).val,
    )
end

# Conversions
# -----------

import Base: convert

function convert(::Type{SimpleCR{ℙ}}, x::SimpleCR{ℚ}) where {ℙ <: Base.IEEEFloat, ℚ <: Base.IEEEFloat}
    return SimpleCR(
        ℙ(x.R), ℙ(x.L), ℙ(x.D), ℙ(x.V)
    )
end

# Promotions
import Base: promote_rule

function promote_rule(
        ::Type{SimpleCR{ℙ}},
        ::Type{SimpleCR{ℚ}}
    ) where {ℙ <: Base.IEEEFloat, ℚ <: Base.IEEEFloat}
    return SimpleCR{promote_type(ℙ, ℚ)}
end

# Export
export SimpleCR
