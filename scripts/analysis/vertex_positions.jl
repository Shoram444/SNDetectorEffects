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
f = ROOTFile(datadir("sims/Boff/0/CAT.root"))
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

# quick glance at data
describe(df_vertex)

# PLOTS
f_all_histos = plot_all_histos(df_vertex)
safesave(plotsdir("foil_effects", "plot_all_histos.png"), f_all_histos, px_per_unit=6)

f_foil_yz_vertex_map = plot_foil_yz_vertex_map(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_yz_vertex_map.png"), f_foil_yz_vertex_map, px_per_unit=6)

f_foil_yz_distance = plot_foil_yz_distance(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_yz_distance.png"), f_foil_yz_distance, px_per_unit=5, px_per_unit=6)

f_foil_3D_distance = plot_foil_3D_distance(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_3D_distance.png"), f_foil_3D_distance, px_per_unit=6)

f_foil_d_vs_r = plot_foil_d_vs_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_d_vs_r.png"), f_foil_d_vs_r, px_per_unit=6)

f_foil_t_vs_r = plot_foil_t_vs_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_t_vs_r.png"), f_foil_t_vs_r, px_per_unit=6)

f_foil_t_vs_d = plot_foil_t_vs_d(df_vertex)
safesave(plotsdir("foil_effects", "plot_foil_t_vs_d.png"), f_foil_t_vs_d, px_per_unit=6)


f_plot_grid_E_t_vertex_sizes = plot_grid_E_t_vertex_sizes(df_vertex; f_size=(600, 400), normed=false)
safesave(plotsdir("foil_effects", "plot_grid_E_t_vertex_sizes.png"), f_plot_grid_E_t_vertex_sizes, px_per_unit=6)

f_plot_grid_E_t_vertex_sizes_normed = plot_grid_E_t_vertex_sizes(df_vertex; f_size=(600, 400), normed=true)
safesave(plotsdir("foil_effects", "plot_grid_E_t_vertex_sizes_normed.png"), f_plot_grid_E_t_vertex_sizes_normed, px_per_unit=6)

f_plot_heatmap_E_t_mean_r = plot_heatmap_E_t_mean_r(df_vertex, f_size = (600,400), binning2D = (range(0, 3500 , 30), range(0, 0.25, 30)))
safesave(plotsdir("foil_effects", "plot_heatmap_E_t_mean_r.png"), f_plot_heatmap_E_t_mean_r, px_per_unit=6)

f_plot_heatmap_theta_phi_mean_r = plot_heatmap_theta_phi_mean_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_heatmap_theta_phi_mean_r.png"), f_plot_heatmap_theta_phi_mean_r, px_per_unit=6)

f_plot_scatter_t_vs_r = plot_scatter_t_vs_r(df_vertex)
safesave(plotsdir("foil_effects", "plot_scatter_t_vs_r.png"), f_plot_scatter_t_vs_r, px_per_unit=6)

plot_h1d_r_by_t(df_vertex, normed = true)

plot_h1d_r_by_E(df_vertex)

t_range = (0.00:0.05:0.25)
r_range = (0.001:0.01:1)
hh = Hist2D(
    (df_vertex.t, df_vertex.r); 
    binedges=(t_range, r_range)
) |> normalize
r_1 = bincounts(hh)[1,:]
r_2 = bincounts(hh)[2,:]
r_3 = bincounts(hh)[3,:]

using Optim

function fit_func(x, p)
    k, α = p
    1/(2^(k/2) * gamma(k/2)) * (x*α)^(k/2 - 1) * exp(-(x*α)/2)
end

x = 0.1:0.1:10


plot(x,y)

initial_params = [1.0, 1.0, 1.0]
lower_bounds = [0.001, 0.001, 0.001]

function neg_log_likelihood(params, x, y)
    k, α, σ = params
    y_pred = map(x->fit_func(x, [k, α]), x)

    # Log likelihood is defined as normally distributed error about prediction
    return sum(@. log(σ * √(2 * π)) + (y .- y_pred).^2 / (2 * σ^2))
end

result = optimize(params -> neg_log_likelihood(params, x, y), lower_bounds, Inf, initial_params, Fminbox(BFGS()))
fitted_k, fitted_α = Optim.minimizer(result)


fitted_k, fitted_α, fitted_σ = fit_chi_square_mle(midpoints(r_range), r_1)
y_fit = map(x->fit_func(x, [fitted_k,fitted_α]), midpoints(r_range))

f,a,p = plot(midpoints(r_range), r_1)
lines!(a, midpoints(r_range), y_fit)
f

plot(midpoints(r_range), y_fit)