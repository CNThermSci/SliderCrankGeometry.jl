using InteractiveUtils

# Collects and returns Union members into a DataType[], allowing loop through Union types
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
    # Set type conversion outer constructor
    for ℙ in union2vec(Base.IEEEFloat)
        RLDr = (1, 2//1, BigFloat("1"), ℯ)
        @test SimpleCR{ℙ}(RLDr...) isa SimpleCR{ℙ}
        RLDr = (1u"cm", 2//1 * u"cm", BigFloat("1")u"cm", 200 * ℯ * u"percent")
        @test SimpleCR{ℙ}(RLDr...) isa SimpleCR{ℙ}
    end
    # Promotion type conversion outer constructor
    RLDr = (1, 2//1, BigFloat("1"), 2//1)
    @test SimpleCR(RLDr...) isa SimpleCR{Float64}
    RLDr = (1u"cm", 2//1 * u"cm", BigFloat("1")u"cm", 200//1 * u"percent")
    @test SimpleCR(RLDr...) isa SimpleCR{Float64}
    for ℙ in union2vec(Base.IEEEFloat)
        RLDr = (1, 2//1, 0x01, ℙ(ℯ))
        @test SimpleCR(RLDr...) isa SimpleCR{ℙ}
        RLDr = (1u"cm", 2//1 * u"cm", 0x01 * u"cm", ℙ(200 * ℯ * u"percent"))
        @test SimpleCR(RLDr...) isa SimpleCR{ℙ}
    end
end

function suffKwargsTest(; kwargs...)
    KW = (; kwargs...) # Builds back NamedTuple from Base.Pairs
    # Sufficient kwargs must pass
    @test SimpleCR(; KW...) isa SimpleCR
    for kw in [Base.structdiff(KW, NamedTuple{(k,)}) for k in keys(KW)]
        # Incomplete kwargs must fail
        @test_throws AssertionError SimpleCR(; kw...)
    end
end

@testset "simple-crank-rod.test.jl: kwargs external constructor                   " begin
    suffKwargsTest(R=1, L=2, D=1, r=2)
end

