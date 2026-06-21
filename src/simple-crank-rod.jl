struct SimpleCrankRod{ℙ <: Base.IEEEFloat}
    R::ℙ    # crank radius, m
    L::ℙ    # rod length, m
    D::ℙ    # piston diameter, m
    V::ℙ    # minimum volume, m³
    function SimpleCrankRod(r::ℙ, l::ℙ, d::ℙ, v::ℙ) where {ℙ <: Base.IEEEFloat}
        @assert(r > zero(ℙ), "Error: R <= 0")
        @assert(l > r, "Error: L <= R")
        @assert(d > zero(ℙ), "Error: D <= 0")
        @assert(v > zero(ℙ), "Error: V <= 0")
        return new{ℙ}(r, l, d, v)
    end
end

# External constructors
function SimpleCrankRod{ℙ}(r::Real, l::Real, d::Real, v::Real) where {ℙ <: Base.IEEEFloat}
    return SimpleCrankRod(ℙ.((r, l, d, v))...)
end

function SimpleCrankRod(r::Real, l::Real, d::Real, v::Real)
    ℙ = promote_type(typeof.((r, l, d, v))...)
    ℙ = ℙ <: Base.IEEEFloat ? ℙ : Float64
    return SimpleCrankRod(ℙ.((r, l, d, v))...)
end

function SimpleCrankRod(
        r::Quantity{T, Unitful.𝐋} where {T <: Real},
        l::Quantity{T, Unitful.𝐋} where {T <: Real},
        d::Quantity{T, Unitful.𝐋} where {T <: Real},
        v::Quantity{T, Unitful.𝐋^3} where {T <: Real},
    )
    return SimpleCrankRod(
        uconvert(u"m", r).val,
        uconvert(u"m", l).val,
        uconvert(u"m", d).val,
        uconvert(u"m^3", v).val,
    )
end

# Conversions
import Base: convert

function convert(
        ::Type{SimpleCrankRod{ℙ}},
        x::SimpleCrankRod{ℚ}
    ) where {ℙ <: Base.IEEEFloat, ℚ <: Base.IEEEFloat}
    return SimpleCrankRod(
        ℙ(x.R), ℙ(x.L), ℙ(x.D), ℙ(x.V)
    )
end

# Promotions
import Base: promote_rule

function promote_rule(
        ::Type{SimpleCrankRod{ℙ}},
        ::Type{SimpleCrankRod{ℚ}}
    ) where {ℙ <: Base.IEEEFloat, ℚ <: Base.IEEEFloat}
    return SimpleCrankRod{promote_type(ℙ, ℚ)}
end

# Export
export SimpleCrankRod
