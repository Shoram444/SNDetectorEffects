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
data = load_data(CAT_FILE, VERTEX_POS_VARS)

# FakeItTillYouMakeIt events have SE set to 0, we can filter them out now
filter!(row -> (row.y1SE != 0.0 && row.y2SE != 0.0), data)

df_vertex = DataFrame(
    xSD=vcat(data.x1SD, data.x2SD),
    ySD=vcat(data.y1SD, data.y2SD),
    zSD=vcat(data.z1SD, data.z2SD),
    xSE=vcat(data.x1SE, data.x2SE),
    ySE=vcat(data.y1SE, data.y2SE),
    zSE=vcat(data.z1SE, data.z2SE),
    simuE=vcat(data.simuEnergy1, data.simuEnergy2),
    recoE=vcat(data.recoEnergy1, data.recoEnergy2)
)

@chain df_vertex begin
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
describe(df_vertex)

# PLOTS
f_all_histos = plot_all_histos(df_vertex)
safesave(plotsdir("foil_effects", "plot_all_histos.png"), f_all_histos)

f_foil_yz_vertex_map = plot_foil_yz_vertex_map(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_yz_vertex_map.png"), f_foil_yz_vertex_map)

f_foil_yz_distance = plot_foil_yz_distance(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_yz_distance.png"), f_foil_yz_distance, px_per_unit=5)

f_foil_3D_distance = plot_foil_3D_distance(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_3D_distance.png"), f_foil_3D_distance)

f_foil_d_vs_r = plot_foil_d_vs_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_d_vs_r.png"), f_foil_d_vs_r)

f_foil_t_vs_r = plot_foil_t_vs_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_t_vs_r.png"), f_foil_t_vs_r)

f_foil_t_vs_d = plot_foil_t_vs_d(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_t_vs_d.png"), f_foil_t_vs_d)


f_plot_grid_E_t_vertex_sizes = plot_grid_E_t_vertex_sizes(df_vertex; f_size=(600, 400), normed=false)
safesave(plotsdir("foil_effects", "plot_grid_E_t_vertex_sizes.png"), f_plot_grid_E_t_vertex_sizes)

f_plot_grid_E_t_vertex_sizes_normed = plot_grid_E_t_vertex_sizes(df_vertex; f_size=(600, 400), normed=true)
safesave(plotsdir("foil_effects", "plot_grid_E_t_vertex_sizes_normed.png"), f_plot_grid_E_t_vertex_sizes_normed)

mm = @chain df_vertex begin
    @select :simuE :t :r
    @transform :E_bin = cut(:simuE, range(0, 3500, 100), labels=range(0, 3500, 100-1))
    @transform :t_bin = cut(:t, range(0, 0.26, 100), labels=range(0, 0.26, 100-1))
    @groupby :E_bin :t_bin
    @combine :avg_r = mean(:r)
    @select :E_bin :t_bin :avg_r
end

f_plot_heatmap_E_t_mean_r = plot_heatmap_E_t_mean_r(mm, f_size = (600,400))
safesave(plotsdir("foil_effects", "plot_heatmap_E_t_mean_r.png"), f_plot_heatmap_E_t_mean_r)
