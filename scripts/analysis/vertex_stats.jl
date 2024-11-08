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

p_foil_yz_distance, h1_foil_yz_distance, h2_foil_yz_distance = plot_foil_yz_distance(
    df_vertex;
    t_range=(0.0, 0.25),
    binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
    binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0),
)

mutable struct Vertex_stats
    E_min
    E_max
    t_min
    t_max
    mean_2d
    max_2d
    min_2d
    mean_1d
    std_1d
    q50_1d
    q90_1d
    q99_1d
    sigma_1d
    sigma2_1d
    sigma3_1d
end
    
function get_vertex_stats(df;
    t_range=(0.0, 0.25),
    binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
    binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
    )

    _, h1, h2 = plot_foil_yz_distance(df_vertex; t_range, binning2D, binning1D, E_range)
    
    E_min = E_range[1]
    E_max = E_range[2]
    t_min = t_range[1]
    t_max = t_range[2]
    mean_2d = h2 |> mean
    max_2d = h2 |> bincounts |> maximum
    min_2d = h2 |> bincounts |> minimum
    mean_1d = h1 |> mean
    std_1d = h1 |> std
    q50_1d = quantile(h1, 0.5)
    q90_1d = quantile(h1, 0.9)
    q99_1d = quantile(h1, 0.99)
    sigma_1d = quantile(h1, 0.682689492137086)
    sigma2_1d = quantile(h1, 0.954499736103642)
    sigma3_1d = quantile(h1, 0.997300203936740)

    return Vertex_stats(
        E_min, E_max, t_min, t_max, 
        mean_2d, max_2d, min_2d, 
        mean_1d, std_1d, q50_1d, q90_1d, q99_1d, sigma_1d, sigma2_1d, sigma3_1d
        )
end

get_vertex_stats(
    df_vertex;
    t_range=(0.0, 0.25),
    binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
    binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
)

function get_vertex_stats_df(
    df; E_vals = [500, 1500, 2500], E_step = 1000,t_vals = [0.0, 0.083, 2*0.083], t_step = 0.083,
    t_range=(0.0, 0.25), binning2D=(range(-4, 4, 50), range(-4, 4, 50)), binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
    )

    vertex_stats = []

    for (E, t) in zip(E_vals, t_vals)
        dE = @chain df begin
            @subset E .<= :simuE .< E + E_step
        end

        v_sE = get_vertex_stats(dE;t_range=t_range,binning2D=binning2D,binning1D=binning1D,E_range=(E, E+E_step))
        push!(vertex_stats, v_sE)

        dt = @chain df begin
            @subset t .<= :t .< t + t_step
        end

        v_st = get_vertex_stats(dt;t_range=(t,t+t_step),binning2D=binning2D,binning1D=binning1D,E_range=E_range)
        push!(vertex_stats, v_st)

        @show E
    end

    df_stats = DataFrame(
        E_min = [v.E_min for v in vertex_stats],
        E_max = [v.E_max for v in vertex_stats],
        t_min = [v.t_min for v in vertex_stats],
        t_max = [v.t_max for v in vertex_stats],
        mean_2d = [v.mean_2d for v in vertex_stats],
        max_2d = [v.max_2d for v in vertex_stats],
        min_2d = [v.min_2d for v in vertex_stats],
        mean_1d = [v.mean_1d for v in vertex_stats],
        std_1d = [v.std_1d for v in vertex_stats],
        q50_1d = [v.q50_1d for v in vertex_stats],
        q90_1d = [v.q90_1d for v in vertex_stats],
        q99_1d = [v.q99_1d for v in vertex_stats],
        sigma_1d = [v.sigma_1d for v in vertex_stats],
        sigma2_1d = [v.sigma2_1d for v in vertex_stats],
        sigma3_1d = [v.sigma3_1d for v in vertex_stats]
    )


    return df_stats
end

v_stats = get_vertex_stats_df(
    df_vertex; E_vals = [500, 1500, 2500], E_step = 1000,t_vals = [0.0, 0.083, 2*0.083], t_step = 0.083,
    t_range=(0.0, 0.25), binning2D=(range(-4, 4, 50), range(-4, 4, 50)), binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
)

pretty_table(v_stats)
safesave(CSV.write(plotsdir("vertex_stats/vertex_stats_CAT.csv"), v_stats))