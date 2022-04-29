@testset "construct by periods" begin
    @test NanoDate(yr,mn,dy,hr,mi,sc,ms,cs,ns) == nd
    @test NanoDate(Yr,Mn,Dy,Hr,Mi,Sc,Ms,Cs,Ns) == nd
    @test NanoDate(yr,mn,dy,hr,mi,sc,ms) == nd0
    @test NanoDate(Yr,Mn,Dy,Hr,Mi,Sc,Ms) == nd0
    @test NanoDate(yr,mn,dy) == nd00
    @test NanoDate(Yr,Mn,Dy) == nd00 
end

@testset "construct by Dates types" begin
    @test NanoDate(dayt, tyme) == nd
    @test NanoDate(daytime, ananosecs) == nd
    @test NanoDate(daytime) == nd0
    @test NanoDate(dayt) == nd00
end



    
