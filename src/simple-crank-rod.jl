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
x0(ξ::SimpleCR) = Vmin(ξ) / Area(ξ)

# Area relations
Area(ξ::SimpleCR) = π * ξ.D^2 / 4

# Volume relations
Vdu(ξ::SimpleCR) = Stroke(ξ) * Area(ξ)
Vmin(ξ::SimpleCR) = Vdu(ξ) / (ξ.r - 1)
Vmax(ξ::SimpleCR) = ξ.r * Vmin(ξ)

# Ratio relations
rLR(ξ::SimpleCR) = ξ.L / ξ.R
rDS(ξ::SimpleCR) = ξ.D / Stroke(ξ)

# Type Functor
(ξ::SimpleCR{ℙ})(units = false) where {ℙ} = begin
    Bool(units) ? (
            R = uconvert(u"mm", Radius(ξ) * u"m"),
            L = uconvert(u"mm", Length(ξ) * u"m"),
            D = uconvert(u"mm", Diameter(ξ) * u"m"),
            r = Quantity{ℙ, NoDims, typeof(NoUnits)}(VRatio(ξ)),
            S = uconvert(u"mm", Stroke(ξ) * u"m"),
            A = uconvert(u"cm^2", Area(ξ) * u"m^2"),
            x0 = uconvert(u"mm", x0(ξ) * u"m"),
            Vdu = uconvert(u"L", Vdu(ξ) * u"m^3"),
            Vmin = uconvert(u"L", Vmin(ξ) * u"m^3"),
            Vmax = uconvert(u"L", Vmax(ξ) * u"m^3"),
            rLR = Quantity{ℙ, NoDims, typeof(NoUnits)}(rLR(ξ)),
            rDS = Quantity{ℙ, NoDims, typeof(NoUnits)}(rDS(ξ)),
        ) : (
            R = Radius(ξ),
            L = Length(ξ),
            D = Diameter(ξ),
            r = VRatio(ξ),
            S = Stroke(ξ),
            A = Area(ξ),
            x0 = x0(ξ),
            Vdu = Vdu(ξ),
            Vmin = Vmin(ξ),
            Vmax = Vmax(ξ),
            rLR = rLR(ξ),
            rDS = rDS(ξ),
        )
end

# Convenience functions for construction
# --------------------------------------

# (R, L, D) from ratios and cylinder displacement
function RLD(; rDS::Real = 1, rLR::Real = 4, Vdu::Real)
    @assert(rLR > 1, "Error: rLR <= 1")
    @assert(Vdu > 0, "Error: Vdu <= 0")
    S = cbrt(4 * Vdu / (π * rDS^2))
    D = S * rDS
    R = S / 2
    L = R * rLR
    return (R, L, D)
end

function SimpleCR(; rDS::Real = 1, rLR::Real = 4, Vdu::Real, r::Real)
    return SimpleCR(RLD(rDS = rDS, rLR = rLR, Vdu = Vdu)..., r)
end

# User-facing functions
# ---------------------

# Piston position from TDC; α in rad
x(ξ::SimpleCR{ℙ}, α::Real) where {ℙ} = begin
    𝟙 = one(ℙ)
    LR = [ξ.L ξ.R]
    sc = [𝟙 - √(𝟙 - (sin(ℙ(α)) / rLR(ξ))^2), 𝟙 - cos(ℙ(α))]
    return (LR * sc)[1]
end

# Piston position from engine head (simplified as x0 + x(α))
xHead(ξ::SimpleCR, α::Real) = x0(ξ) + x(ξ, α)

# Instantaneous volume; α in rad
V(ξ::SimpleCR, α::Real) = Vmin(ξ) + Area(ξ) * x(ξ, α)

# z-cylinder engine displaced volume
Vd(ξ::SimpleCR, z::Integer) = begin
    @assert(z >= 1, "Error: z < 1")
    Vdu(ξ) * z
end

# Crank-Rod mechanism geometry
# ----------------------------

# Projections
_h(ξ::SimpleCR{ℙ}, α::Real) where {ℙ} = ξ.R * sin(ℙ(α))
_r(ξ::SimpleCR{ℙ}, α::Real) where {ℙ} = ξ.R * cos(ℙ(α))
_l(ξ::SimpleCR, α::Real) = sqrt(ξ.L^2 - _h(ξ, α)^2)

# Angles
ϕ(ξ::SimpleCR, α::Real) = atan(_h(ξ, α), _l(ξ, α))

# Ratios
βy(ξ::SimpleCR, α::Real) = _r(ξ, α) / _l(ξ, α)
βx(ξ::SimpleCR, α::Real) = _h(ξ, α) / _l(ξ, α)

# Angular speed
ϕ′(ξ::SimpleCR{ℙ}, α::Real, α′::Real) where {ℙ} = βy(ξ, α) * ℙ(α′)

# Angular acceleration
𝛀(ξ::SimpleCR{ℙ}, α′::Real, α″::Real) where {ℙ} = [ℙ(α′)^2, ℙ(α″)]
𝐚(ξ::SimpleCR{ℙ}, α::Real) where {ℙ} = [βx(ξ, α) * (βy(ξ, α)^2 - one(ℙ)) βy(ξ, α)]
ϕ″(ξ::SimpleCR{ℙ}, α::Real, α′::Real, α″::Real) where {ℙ} = (𝐚(ξ, α) * 𝛀(ξ, α′, α″))[1]

# Linear acceleration
𝐲p(ξ::SimpleCR{ℙ}, α::Real) where {ℙ} = begin
    ypω = - _r(ξ, α) * (one(ℙ) + βy(ξ, α)) - _h(ξ, α) * 𝐚(ξ, α)[1]
    ypω′ = - _h(ξ, α) * (one(ℙ) + βy(ξ, α))
    return [ypω ypω′]
end
𝐱r(ξ::SimpleCR{ℙ}, rg::Real, α::Real) where {ℙ} = begin
    @assert(0 < rg < 1, "Error: rg ∉ (0, 1)")
    xrω = _h(ξ, α) * (ℙ(rg) - one(ℙ))
    xrω′ = _r(ξ, α) * (one(ℙ) - ℙ(rg))
    return [xrω xrω′]
end
𝐲r(ξ::SimpleCR{ℙ}, rg::Real, α::Real) where {ℙ} = begin
    @assert(0 < rg < 1, "Error: rg ∉ (0, 1)")
    yrω = - _r(ξ, α) * (one(ℙ) + ℙ(rg) * βy(ξ, α)) - _h(ξ, α) * ℙ(rg) * 𝐚(ξ, α)[1]
    yrω′ = - _h(ξ, α) * (one(ℙ) + ℙ(rg) * βy(ξ, α))
    return [yrω yrω′]
end
yp″(ξ::SimpleCR, α::Real, α′::Real, α″::Real) = (𝐲p(ξ, α) * 𝛀(ξ, α′, α″))[1]
xr″(ξ::SimpleCR, rg::Real, α::Real, α′::Real, α″::Real) = (𝐱r(ξ, rg, α) * 𝛀(ξ, α′, α″))[1]
yr″(ξ::SimpleCR, rg::Real, α::Real, α′::Real, α″::Real) = (𝐲r(ξ, rg, α) * 𝛀(ξ, α′, α″))[1]
