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
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase, CategoricalArrays, CSV, PrettyTables
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())

# DATA PREPARATION
# data = load_data(CAT_FILE, VERTEX_POS_VARS)
f = ROOTFile(datadir("sims/Boff/CAT.root"))
data = LazyTree(f, "tree", VERTEX_POS_VARS) 

E = Float32[]
t = Float32[]
r = Float32[]
dy = Float32[]
dz = Float32[]

Threads.@threads for (i, event) in enumerate(data)
    # Discard fake it till you make it events
    if(i%100000 == 0)
        @show "processed $i events"
    end

    if(event.y1SE == 0.0 || event.y2SE == 0.0)
        continue
    end

    #  calculate t - horizontal distance traveled
    dmin1 = 0.125 - abs(event.x1SD)                 # distance to closest wall
    dmax1 = 2 * 0.125 - dmin1                       # distance to furthest wall
    t1 = event.x1SD * event.x1SE > 0 ? dmin1 : dmax1  # horizontal distance traveled
    
    dmin2 = 0.125 - abs(event.x2SD)                 # distance to closest wall
    dmax2 = 2 * 0.125 - dmin2                       # distance to furthest wall
    t2 = event.x2SD * event.x2SE > 0 ? dmin2 : dmax2  # horizontal distance traveled

    # calculate r - distance traveled in foil plane; r ≡ √(Δy² + Δz²)
    dy1 = event.y1SD - event.y1SE
    dz1 = event.z1SD - event.z1SE
    r1  = sqrt(dy1^2 + dz1^2)
    
    dy2 = event.y2SD - event.y2SE
    dz2 = event.z2SD - event.z2SE
    r2  = sqrt(dy2^2 + dz2^2)
    push!(t, t1)
    push!(t, t2)
    push!(r, r1)
    push!(r, r2)
    push!(E, event.simuEnergy1)
    push!(E, event.simuEnergy2)
    push!(dy, dy1)
    push!(dy, dy2)
    push!(dz, dz1)
    push!(dz, dz2)
end

# let
#     f,h1,h2 =plot_foil_yz_distance(
#         dy, dz, E, t, r;
#         t_range=(0.0, 0.25),
#         binning2D=(range(-20, 20, 100), range(-20, 20, 100)),
#         binning1D=range(0, 2, 50),
#         E_range=(0.0, 1500.0),
#     )
#     safesave(plotsdir("foil_effects/plot_foil_yz_distance_full.png"), f)
#     f
# end

# let 
#     f = plot_grid_E_t_vertex_sizes(
#         dy, dz, E, t, r;
#         E_vals = [500, 1500, 2500],
#         E_step = 1000,
#         t_vals = [0.0, 0.083, 2*0.083],
#         t_step = 0.083,
#         f_size = FIG_size_w,
#         normed = true,
#         binning2D = (range(-11, 11, 50), range(-11, 11, 50))
#     )
#     safesave(plotsdir("foil_effects/plot_grid_E_t_vertex_sizes_normed.png"), f)
#     f
# end



v_stats = get_vertex_stats_df(
    dy, dz, E, t, r;
    E_vals = [500, 1500, 2500], E_step = 1000,t_vals = [0.0, 0.083, 2*0.083], t_step = 0.083,
    t_range=(0.0, 0.25), binning2D=(range(-11, 11, 50), range(-11, 11, 50)), binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
)

pretty_table(v_stats)
# safesave(CSV.write(plotsdir("vertex_stats/vertex_stats_CAT_full_array.csv"), v_stats))

E_stats = @chain v_stats begin
    @orderby :E_min
    @select :E_min :E_max :mean_1d :std_1d :sigma3_1d 
end

pretty_table(
    E_stats[4:end, :], 
    header = (
        [L"E_{min}", L"E_{max}", L"\bar{r}", L"\sigma", L"3\sigma"],
        [L"(keV)", L"(keV)", L"(mm)", L"(mm)", L"(mm)"]
    ), 
    backend = Val(:latex)
)

t_stats = @chain v_stats begin
    @orderby :t_min
    @select :t_min :t_max :mean_1d :std_1d :sigma3_1d 
end

pretty_table(
    t_stats[[2, 5, 6], :], 
    header = (
        [L"t_{min}", L"t_{max}", L"\bar{r}", L"\sigma", L"3\sigma"],
        [L"(mm)", L"(mm)", L"(mm)", L"(mm)", L"(mm)"]
    ), 
    backend = Val(:latex)
)


fig_grid_E_t_vertex_sizes = plot_E_t_subsets_r(
    dy, dz, E, t, r;
    E_vals = [500, 1500, 2500],
    E_step = 1000,
    t_vals = [0.0, 0.083, 2*0.083],
    t_step = 0.083,
    f_size = FIG_size_w,
    normed = true,
    binning1D = range(0, 2, 50),
)
safesave(plotsdir("foil_effects/plot_E_t_subsets_r.png"), fig_grid_E_t_vertex_sizes)


# df = DataFrame(
#     E  = E ,
#     t  = t ,
#     r  = r ,
#     dy = dy,
#     dz = dz,
# )

# r_cut = quantile(df.r, 0.99)
# filter!(row -> row.r < r_cut, df)

# gdf = @chain df begin
#     @transform :E_bins = cut(:E, [0, 500, 1500, 2500, 3500])
#     @groupby :E_bins
#     @combine :r_mean = mean(:r)
# end

# df_cut = @chain df begin
#     @transform :E_bins = cut(:E, [0, 500, 1500, 2500, 3500])
#     @groupby :E_bins
# end
# let 
#     f = Figure()
#     a = Axis(f[1,1], yscale =log10, limits = (0,3,1,100000))
#     stephist!(a, df_cut[2].r , bins = 100, )
#     stephist!(a, df_cut[3].r , bins = 100, )
#     stephist!(a, df_cut[4].r , bins = 100, )
#     f
# end

# df_cut = @chain df begin
#     @transform :t_bins = cut(:t, [0, 0.25/3, 0.25/3*2, 0.25, 0.3])
#     @groupby :t_bins
# end
# let 
#     f = Figure()
#     a = Axis(f[1,1], yscale =log10, limits = (0,2,1,100000))
#     stephist!(a, df_cut[1].r , bins = 100, )
#     stephist!(a, df_cut[2].r , bins = 100, )
#     stephist!(a, df_cut[3].r , bins = 100, )
#     f
# end