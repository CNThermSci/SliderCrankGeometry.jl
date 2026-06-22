# Type aliasing
# -------------

# IEEE-754 normalized floating point types of half, single, and double precision
FLOAT = Base.IEEEFloat

# Structure (type) definition
# ---------------------------

struct SimpleCR{ℙ <: FLOAT} # Type parameter ℙ indicates the FLOAT Precision
    R::ℙ    # crank radius, m
    L::ℙ    # rod length, m
    D::ℙ    # piston diameter, m
    V::ℙ    # minimum volume, m³
    # Internal constructors
    # Validating
    function SimpleCR(r::ℙ, l::ℙ, d::ℙ, v::ℙ) where {ℙ <: FLOAT}
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
function SimpleCR{ℙ}(r::Real, l::Real, d::Real, v::Real) where {ℙ <: FLOAT}
    return SimpleCR(ℙ.((r, l, d, v))...)
end

# Promotion type conversion / 2 indirections
function SimpleCR(r::Real, l::Real, d::Real, v::Real)
    ℙ = promote_type(typeof.((r, l, d, v))...)
    ℙ = ℙ <: FLOAT ? ℙ : Float64
    return SimpleCR{ℙ}(r, l, d, v)
end

# Set type with unit conversion and stripping / 2 indirections
function SimpleCR{ℙ}(
        r::Unitful.Length{Real},
        l::Unitful.Length{Real},
        d::Unitful.Length{Real},
        v::Unitful.Volume{Real}
    ) where {ℙ <: FLOAT}
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

function convert(::Type{SimpleCR{ℙ}}, x::SimpleCR{ℚ}) where {ℙ <: FLOAT, ℚ <: FLOAT}
    return SimpleCR{ℙ}(x.R, x.L, x.D, x.V)
end

# Promotions
# ----------

import Base: promote_rule

function promote_rule(::Type{SimpleCR{ℙ}}, ::Type{SimpleCR{ℚ}}) where {ℙ <: FLOAT, ℚ <: FLOAT}
    return SimpleCR{promote_type(ℙ, ℚ)}
end

# Export
# ------

export SimpleCR

# User-facing functions
# ---------------------

# Stored data
Radius(x::SimpleCR{ℙ}, units = false) where ℙ = Bool(units) ? x.R * u"m" : x.R
Length(x::SimpleCR{ℙ}, units = false) where ℙ = Bool(units) ? x.L * u"m" : x.L
Diameter(x::SimpleCR{ℙ}, units = false) where ℙ = Bool(units) ? x.D * u"m" : x.D
Vmin(x::SimpleRC{ℙ}, units = false) where ℙ = Bool(units) ? x.V * u"m^3" : x.V

# Length relations
Stroke(x::SimpleRC{ℙ}, units = false) where ℙ = begin
    𝑢 = Bool(unit) ? u"m" : one(ℙ)
    return 2 * x.R * 𝑢
end

# Area relations
Area(x::SimpleRC{ℙ}, units = false) where ℙ = begin
    𝑢 = Bool(unit) ? u"m^2" : one(ℙ)
    return (π * x.D ^ 2 / 4) * 𝑢
end

# Volume relations
Vdu(x::SimpleRC{ℙ}, units = false) where ℙ = begin
    𝑢 = Bool(unit) ? u"m^3" : one(ℙ)
    return Stroke(x) * Area(x) * 𝑢
end

Vmax(x::SimpleRC{ℙ}, units = false) where ℙ = begin
    𝑢 = Bool(unit) ? u"m^3" : one(ℙ)
    return (Vmin(x) + Vdu(x)) * 𝑢
end


# Type Functor
(x::SimpleCR)(units = false) =
    (
        R = x.R,
        L = x.L,
        D = x.D,
        V = ,
    )

