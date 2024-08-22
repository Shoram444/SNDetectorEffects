using DrWatson
@quickactivate "SNDetectorEffects"
using Revise

push!(LOAD_PATH, srcdir())
using DetectorEffects
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())

# DATA PREPARATION
data = load_data(TIT_FILE, FOIL_EFFECTS_VARS)

# FakeItTillYouMakeIt events have SE set to 0, we can filter them out now
filter!(row -> (row.y1SE != 0.0 && row.y2SE != 0.0), data)

df = DataFrame(
    xSD=vcat(data.x1SD, data.x2SD),
    ySD=vcat(data.y1SD, data.y2SD),
    zSD=vcat(data.z1SD, data.z2SD),
    xSE=vcat(data.x1SE, data.x2SE),
    ySE=vcat(data.y1SE, data.y2SE),
    zSE=vcat(data.z1SE, data.z2SE)
)

@chain df begin
    # add column for 3D distance traveled within foil bulk
    @transform! :d = @. sqrt((:xSD - :xSE)^2 + (:ySD - :ySE)^2 + (:zSD - :zSE)^2)

    # add column t - horizontal distance traveled
    @transform! :dmin = @. 0.125 - abs(:xSD)      # distance to closest wall
    @transform! :dmax = @. 2 * 0.125 - :dmin         # distance to furthest wall
    @rtransform! :t = @. :xSD * :xSE > 0 ? :dmin : :dmax # horizontal distance traveled

    # add column r - distance traveled in foil plane; r ≡ √(Δy² + Δz²)
    @transform! :dy = @. :ySD - :ySE
    @transform! :dz = @. :zSD - :zSE
    @transform! :r = @. sqrt(:dy^2 + :dz^2)


    # Filter out outliers (might be cause of something bad happened in simulation)
    @subset! :d .<= 3.0
end

# quick glance at data
describe(df)


# PLOTS
f_foil_all_histos = plot_foil_all_histos(df)
safesave(plotsdir("foil_effects", "plot_foil_all_histos.png"), f_foil_all_histos)

f_foil_yz_vertex_map = plot_foil_yz_vertex_map(df)
safesave(plotsdir("foil_effects", "plot_foil_yz_vertex_map.png"), f_foil_yz_vertex_map)

f_foil_yz_distance = plot_foil_yz_distance(df)
safesave(plotsdir("foil_effects", "plot_foil_yz_distance.png"), f_foil_yz_distance)

f_foil_3D_distance = plot_foil_3D_distance(df)
safesave(plotsdir("foil_effects", "plot_foil_3D_distance.png"), f_foil_3D_distance)


plot_foil_yz_distance(df; t_range=(0.0, 0.05))
#
