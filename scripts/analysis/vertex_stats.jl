#######################################################
#######################################################
#######          VERTEX POSITIONS               #######
#######################################################
#######################################################

using DrWatson
@quickactivate "SNDetectorEffects"
using Revise

push!(LOAD_PATH, srcdir())
using DetectorEffects
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase, CategoricalArrays
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())

# DATA PREPARATION
# data = load_data(CAT_FILE, VERTEX_POS_VARS)
f = ROOTFile(datadir("sims/Boff/CAT.root"))
data = LazyTree(f, "tree", VERTEX_POS_VARS) |> DataFrame

# FakeItTillYouMakeIt events have SE set to 0, we can filter them out now
filter!(row -> (row.y1SE != 0.0 && row.y2SE != 0.0), data)

df_vertex = DataFrame(
    xSD=vcat(data.x1SD, data.x2SD),
    ySD=vcat(data.y1SD, data.y2SD),
    zSD=vcat(data.z1SD, data.z2SD),

    pzSD=vcat(data.pz1SD, data.pz2SD),
    pxSD=vcat(data.px1SD, data.px2SD),
    pySD=vcat(data.py1SD, data.py2SD),

    xSE=vcat(data.x1SE, data.x2SE),
    ySE=vcat(data.y1SE, data.y2SE),
    zSE=vcat(data.z1SE, data.z2SE),

    pzSE=vcat(data.pz1SE, data.pz2SE),
    pxSE=vcat(data.px1SE, data.px2SE),
    pySE=vcat(data.py1SE, data.py2SE),
    

    simuE=vcat(data.simuEnergy1, data.simuEnergy2),
    recoE=vcat(data.recoEnergy1, data.recoEnergy2)
)

@chain df_vertex begin
    # add column for 3D distance traveled within foil bulk
    @rtransform! :d = sqrt((:xSD - :xSE)^2 + (:ySD - :ySE)^2 + (:zSD - :zSE)^2)

    # add column t - horizontal distance traveled
    @rtransform! :dmin = 0.125 - abs(:xSD)      # distance to closest wall
    @rtransform! :dmax = 2 * 0.125 - :dmin         # distance to furthest wall
    @rtransform! :t = @. :xSD * :xSE > 0 ? :dmin : :dmax # horizontal distance traveled

    # add column r - distance traveled in foil plane; r ≡ √(Δy² + Δz²)
    @rtransform! :dy = :ySD - :ySE
    @rtransform! :dz = :zSD - :zSE
    @rtransform! :r = sqrt(:dy^2 + :dz^2)


    # Filter out outliers (might be cause of something bad happened in simulation)
    @subset! :d .<= 3.0

    @rtransform! :theta = -1 * ( acosd( :pzSD / sqrt( :pxSD^2 + :pySD^2 + :pzSD^2 ) ) - 90)
    @rtransform! :phi  = atand( :pySD , :pxSD)

    @rtransform! :theta_SE = -1 * ( acosd( :pzSE / sqrt( :pxSE^2 + :pySE^2 + :pzSE^2 ) ) - 90)
    @rtransform! :phi_SE  = atand( :pySE , :pxSE)

end

