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
        R::Unitful.Length{<:Real},
        L::Unitful.Length{<:Real},
        D::Unitful.Length{<:Real},
        r::Real,
    ) where {ℙ <: FLOAT}
    return SimpleCR{ℙ}(
        uconvert(u"m", R).val,
        uconvert(u"m", L).val,
        uconvert(u"m", D).val,
        r,
    )
end

# Promotion type with unit conversion and stripping / 3 indirections
function SimpleCR(
        R::Unitful.Length{<:Real},
        L::Unitful.Length{<:Real},
        D::Unitful.Length{<:Real},
        r::Real,
    )
    return SimpleCR(
        uconvert(u"m", R).val,
        uconvert(u"m", L).val,
        uconvert(u"m", D).val,
        r,
    )
end

# Arbitrary input kwargs constructor
RULES = [
    # 2R / S = 1
    (o = (:R,), i = (:S,), f = k -> (R = k.S / 2,),),
    (o = (:S,), i = (:R,), f = k -> (S = 2 * k.R,),),
    # rLR * rRL = 1
    (o = (:rLR,), i = (:rRL,), f = k -> (rLR = inv(k.rRL),),),
    (o = (:rRL,), i = (:rLR,), f = k -> (rRL = inv(k.rLR),),),
    # rDS * rSD = 1
    (o = (:rDS,), i = (:rSD,), f = k -> (rDS = inv(k.rSD),),),
    (o = (:rSD,), i = (:rDS,), f = k -> (rSD = inv(k.rDS),),),
    # A = π * D^2 / 4
    (o = (:D,), i = (:A,), f = k -> (D = √(4 * k.A / π),),),
    (o = (:A,), i = (:D,), f = k -> (A = π * k.D^2 / 4,),),
    # rLR * R / L = 1
    (o = (:R,), i = (:rLR, :L), f = k -> (R = k.L / k.rLR,),),
    (o = (:L,), i = (:rLR, :R), f = k -> (L = k.rLR * k.R,),),
    # rDS * S / D = 1
    (o = (:S,), i = (:rDS, :D), f = k -> (S = k.D / k.rDS,),),
    (o = (:D,), i = (:rDS, :S), f = k -> (D = k.rDS * k.S,),),
    # r = Vmax / Vmin
    (o = (:r,), i = (:Vmax, :Vmin), f = k -> (r = k.Vmax / k.Vmin,)),
    (o = (:Vmax,), i = (:r, :Vmin), f = k -> (Vmax = k.Vmin * k.r,)),
    (o = (:Vmin,), i = (:Vmax, :r), f = k -> (Vmin = k.Vmax / k.r,)),
    # Vdu = Vmax - Vmin
    (o = (:Vdu,), i = (:Vmax, :Vmin), f = k -> (Vdu = k.Vmax - k.Vmin,)),
    (o = (:Vmax,), i = (:Vdu, :Vmin), f = k -> (Vmax = k.Vmin + k.Vdu,)),
    (o = (:Vmin,), i = (:Vmax, :Vdu), f = k -> (Vmin = k.Vmax - k.Vdu,)),
    # Vmin = Vdu / (r - 1)
    (o = (:Vmin,), i = (:Vdu, :r), f = k -> (Vmin = k.Vdu / (k.r - 1),)),
    # Vdu = A * S
    (o = (:Vdu,), i = (:A, :S), f = k -> (Vdu = k.A * k.S,)),
    (o = (:A,), i = (:Vdu, :S), f = k -> (A = k.Vdu / k.S,)),
    (o = (:S,), i = (:A, :Vdu), f = k -> (S = k.Vdu / k.A,)),
    # Vdu = π * S^3 * rDS^2 / 4
    (o = (:Vdu,), i = (:S, :rDS), f = k -> (Vdu = π * k.S^3 * k.rDS^2 / 4,)),
    (o = (:S,), i = (:Vdu, :rDS), f = k -> (S = cbrt((4 * k.Vdu) / (k.rDS^2 * π)),)),
    # Vmin = x0 * A
    (o = (:Vmin,), i = (:A, :x0), f = k -> (Vmin = k.x0 * k.A,)),
    (o = (:A,), i = (:Vmin, :x0), f = k -> (A = k.Vmin / k.x0,)),
    (o = (:x0,), i = (:A, :Vmin), f = k -> (x0 = k.Vmin / k.A,)),
    # Vd = Vdu * z
    (o = (:Vd,), i = (:Vdu, :z), f = k -> (Vd = k.Vdu * k.z,)),
    (o = (:Vdu,), i = (:Vd, :z), f = k -> (Vdu = k.Vd / k.z,)),
    (o = (:z,), i = (:Vdu, :Vd), f = k -> (z = k.Vd / k.Vdu,)),
]

function SimpleCR(; kwargs...)
    known = (; kwargs...)
    changed = true
    while changed
        changed = false
        for RULE in RULES
            if all(haskey(known, key) for key in RULE.i)
                result = RULE.f(known)
                for (key, value) in pairs(result)
                    if !haskey(known, key)
                        known = (; known..., key => value)
                        changed = true
                    end
                end
            end
        end
    end
    @assert(
        all(haskey(known, key) for key in (:R, :L, :D, :r)),
        "Error: Insufficient inputs to compute (R, L, D, r)"
    )
    return SimpleCR(known.R, known.L, known.D, known.r)
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
