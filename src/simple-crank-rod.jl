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
    r::ℙ    # volume ratio, –
    # Internal constructors
    # Validating
    function SimpleCR(R::ℙ, L::ℙ, D::ℙ, r::ℙ) where {ℙ <: FLOAT}
        @assert(R > zero(ℙ), "Error: R <= 0")
        @assert(L > R, "Error: L <= R")
        @assert(D > zero(ℙ), "Error: D <= 0")
        @assert(r > one(ℙ), "Error: r <= 1")
        return new{ℙ}(R, L, D, r)
    end
end

# External constructors
# ---------------------

# Set type conversion / 1 indirection
function SimpleCR{ℙ}(R::Real, L::Real, D::Real, r::Real) where {ℙ <: FLOAT}
    return SimpleCR(ℙ.((R, L, D, r))...)
end

# Promotion type conversion / 2 indirections
function SimpleCR(R::Real, L::Real, D::Real, r::Real)
    ℙ = promote_type(typeof.((R, L, D, r))...)
    ℙ = ℙ <: FLOAT ? ℙ : Float64
    return SimpleCR{ℙ}(R, L, D, r)
end

# Set type with unit conversion and stripping / 2 indirections
function SimpleCR{ℙ}(
        R::Unitful.Length{Real},
        L::Unitful.Length{Real},
        D::Unitful.Length{Real},
        r::Unitful.Volume{Real}
    ) where {ℙ <: FLOAT}
    return SimpleCR{ℙ}(
        uconvert(u"m", R).val,
        uconvert(u"m", L).val,
        uconvert(u"m", D).val,
        uconvert(u"m^3", r).val,
    )
end

# Promotion type with unit conversion and stripping / 3 indirections
function SimpleCR(
        R::Unitful.Length{Real},
        L::Unitful.Length{Real},
        D::Unitful.Length{Real},
        r::Unitful.Volume{Real}
    )
    return SimpleCR(
        uconvert(u"m", R).val,
        uconvert(u"m", L).val,
        uconvert(u"m", D).val,
        uconvert(u"m^3", r).val,
    )
end

# Conversions
# -----------

import Base: convert

function convert(::Type{SimpleCR{ℙ}}, ξ::SimpleCR{ℚ}) where {ℙ <: FLOAT, ℚ <: FLOAT}
    return SimpleCR{ℙ}(ξ.R, ξ.L, ξ.D, ξ.r)
end

import Base: Float16, Float32, Float64

Float16(ξ::SimpleCR) = convert(SimpleCR{Float16}, ξ)
Float32(ξ::SimpleCR) = convert(SimpleCR{Float32}, ξ)
Float64(ξ::SimpleCR) = convert(SimpleCR{Float64}, ξ)

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
Radius(ξ::SimpleCR) = ξ.R
Length(ξ::SimpleCR) = ξ.L
Diameter(ξ::SimpleCR) = ξ.D
VRatio(ξ::SimpleCR) = ξ.r
Ratio = VRatio

# Length relations
Stroke(ξ::SimpleCR) = 2 * ξ.R

# Area relations
Area(ξ::SimpleCR) = π * ξ.D^2 / 4

# Volume relations
Vdu(ξ::SimpleCR) = Stroke(ξ) * Area(ξ)
Vmin(ξ::SimpleCR) = Vdu(ξ) / (ξ.r - 1)
Vmax(ξ::SimpleCR) = ξ.r * Vmin(ξ)

# Ratio relations
rLR(ξ::SimpleCR) = ξ.L / ξ.R
rRL(ξ::SimpleCR) = ξ.R / ξ.L
rSD(ξ::SimpleCR) = ξ.S / ξ.D
rDS(ξ::SimpleCR) = ξ.D / ξ.S

# Type Functor
(ξ::SimpleCR{ℙ})(units = false) where ℙ = begin
    Bool(units) ? (
            R = Radius(ξ) * u"m",
            L = Length(ξ) * u"m",
            D = Diameter(ξ) * u"m",
            r = Quantity{ℙ, NoDims, typeof(NoUnits)}(VRatio(ξ)),
        ) : (
            R = Radius(ξ),
            L = Length(ξ),
            D = Diameter(ξ),
            r = VRatio(ξ),
        )
end

# User-facing functions
# ---------------------

# Position from TDC; 𝛼 in rad
x(ξ::SimpleCR{ℙ}, 𝛼::Real) where {ℙ} = begin
    𝟙 = one(ℙ)
    LR = [ξ.L ξ.R]
    sc = [𝟙 - √(𝟙 - (rRL(ξ) * sin(ℙ(𝛼)))^2), 𝟙 - cos(ℙ(𝛼))]
    return (LR * sc)[1]
end

# Instantaneous volume; 𝛼 in rad
V(ξ::SimpleCR, 𝛼::Real) = Vmin(ξ) + Area(ξ) * x(ξ, 𝛼)

