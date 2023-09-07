using Dates, NanoDates
using Dates: value, CompoundPeriod, toms, tons, UTM, UTD
using NanoDates: nanosecs, NanoDate0, DateTime0, Date0, Time0
using Aqua, Test

Aqua.test_ambiguities([NanoDates, Base, Core])
Aqua.test_unbound_args(NanoDates)
Aqua.test_undefined_exports(NanoDates)
Aqua.test_project_extras(NanoDates)
Aqua.test_stale_deps(NanoDates; ignore=[:Aqua])
Aqua.test_deps_compat(NanoDates)

include("constants.jl")

@testset "accessors" begin
    include("accessors.jl")
end

@testset "adjusters" begin
    include("adjusters.jl")
end

@testset "arith" begin
    include("arith.jl")
end

@testset "compare" begin
    include("compare.jl")
end

@testset "compound" begin
    include("compound.jl")
end

@testset "convert" begin
    include("convert.jl")
end

@testset "interop" begin
    include("interop.jl")
end

@testset "nanodate" begin
    include("nanodate.jl")
end

@testset "strings" begin
    include("strings.jl")
end

@testset "timestamp" begin
    include("timestamp.jl")
end
