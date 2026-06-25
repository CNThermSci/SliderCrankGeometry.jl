using InteractiveUtils

# Collects and returns Union members into a DataType[]
# ```julia
# julia> union2vec(Base.IEEEFloat)
# 3-element Vector{DataType}:
#  Float16
#  Float32
#  Float64
# ```
function union2vec(theU::Union)
    ret = DataType[]
    while theU isa Union
        push!(ret, theU.a)
        theU = theU.b
    end
    push!(ret, theU)
    return ret
end

@testset "simple-crank-rod.test.jl: inner constructor return types                " begin
    for ℙ in union2vec(Base.IEEEFloat)
        RLDr = ℙ.((1, 2, 1, 2))
        @test SimpleCR(RLDr...) isa SimpleCR{ℙ}
    end
end

@testset "simple-crank-rod.test.jl: inner constructor validations                 " begin
    for ℙ in union2vec(Base.IEEEFloat)
        RLDr = ℙ.((0, 2, 1, 2))
        @test_throws "Error: R <= 0" SimpleCR(RLDr...)
        RLDr = ℙ.((1, 1, 1, 2))
        @test_throws "Error: L <= R" SimpleCR(RLDr...)
        RLDr = ℙ.((1, 2, 0, 2))
        @test_throws "Error: D <= 0" SimpleCR(RLDr...)
        RLDr = ℙ.((1, 2, 1, 1))
        @test_throws "Error: r <= 1" SimpleCR(RLDr...)
    end
    #invR = Real[]
    #push!(invR, [prevfloat(one(ℙ)) for ℙ in union2vec(Base.IEEEFloat)])
    #push!(invR, [99//100, 0, 0x00, BigFloat("0.99")])
    #for ℙ in union2vec(Base.IEEEFloat)
    #    for invR in 
    #end
end

@testset "simple-crank-rod.test.jl: outer constructor return types                " begin
    for ℙ in union2vec(Base.IEEEFloat)
        for ℝ in [Int64, Rational{Int64}, BigFloat]
            RLDr = ℝ.((1, 2, 1, 2))
            # Set type conversion outer constructors
            @test SimpleCR{ℙ}(RLDr...) isa SimpleCR{ℙ}
        end
        RLDr = (ℯ, π, ℯ, π)
        # Set type conversion outer constructors
        @test SimpleCR{ℙ}(RLDr...) isa SimpleCR{ℙ}
    end
end

