struct SimpleCrankRod{T<:Base.IEEEFloat}
    R::T    # crank radius, m
    L::T    # rod length, m
    D::T    # piston diameter, m
    V::T    # minimum volume, m³
    function SimpleCrankRod(r::T, l::T, d::T, v::T) where {T<:Base.IEEEFloat}
        @assert(r > zero(T), "Error: R <= 0")
        @assert(l > r,       "Error: L <= R")
        @assert(d > zero(T), "Error: D <= 0")
        @assert(v > zero(T), "Error: V <= 0")
        new(r, l, d, v)
    end
end

export SimpleCrankRod

