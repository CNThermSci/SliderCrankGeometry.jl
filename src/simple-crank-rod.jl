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

function convert(::Type{SimpleCR{ℙ}}, 𝑥::SimpleCR{ℚ}) where {ℙ <: FLOAT, ℚ <: FLOAT}
    return SimpleCR{ℙ}(𝑥.R, 𝑥.L, 𝑥.D, 𝑥.V)
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

# User-facing parameter functions
# -------------------------------

# Stored data
Radius(𝑥::SimpleCR) = 𝑥.R
Length(𝑥::SimpleCR) = 𝑥.L
Diameter(𝑥::SimpleCR) = 𝑥.D
Vmin(𝑥::SimpleCR) = 𝑥.V

# Length relations
Stroke(𝑥::SimpleCR) = 2 * 𝑥.R

# Area relations
Area(𝑥::SimpleCR) = π * 𝑥.D^2 / 4

# Volume relations
Vdu(𝑥::SimpleCR) = Stroke(𝑥) * Area(𝑥)
Vmax(𝑥::SimpleCR) = Vmin(𝑥) + Vdu(𝑥)

# Ratio relations
rv(𝑥::SimpleCR) = Vmax(𝑥) / Vmin(𝑥)
rLR(𝑥::SimpleCR) = 𝑥.L / 𝑥.R
rRL(𝑥::SimpleCR) = 𝑥.R / 𝑥.L
rSD(𝑥::SimpleCR) = 𝑥.S / 𝑥.D
rDS(𝑥::SimpleCR) = 𝑥.D / 𝑥.S

# Type Functor
(𝑥::SimpleCR)(units = false) = begin
    Bool(units) ? (
            r = Radius(𝑥) * u"m",
            L = Length(𝑥) * u"m",
            D = Diameter(𝑥) * u"m",
            Vmin = Vmin(𝑥) * u"m^3",
        ) : (
            r = Radius(𝑥),
            L = Length(𝑥),
            D = Diameter(𝑥),
            Vmin = Vmin(𝑥),
        )
end

# User-facing functions
# ---------------------

# Position from TDC; 𝛼 in rad
x(𝑥::SimpleCR{ℙ}, 𝛼::Real) where {ℙ} = begin
    𝟙 = one(ℙ)
    LR = [𝑥.L 𝑥.R]
    sc = [𝟙 - √(𝟙 - (rRL(𝑥) * sin(ℙ(𝛼)))^2), 𝟙 - cos(ℙ(𝛼))]
    return (LR * sc)[1]
end

# Instantaneous volume; 𝛼 in rad
V(𝑥::SimpleCR, 𝛼::Real) = Vmin(𝑥) + Area(𝑥) * x(𝑥, 𝛼)

