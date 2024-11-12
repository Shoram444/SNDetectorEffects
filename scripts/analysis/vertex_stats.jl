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
f = ROOTFile(datadir("sims/Boff/TIT.root"))
data = LazyTree(f, "tree", VERTEX_POS_VARS) 

E = Float64[]
t = Float64[]
r = Float64[]
dy = Float64[]
dz = Float64[]

Threads.@threads for (i, event) in enumerate(data)
    # Discard fake it till you make it events
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


p_foil_yz_distance, h1_foil_yz_distance, h2_foil_yz_distance = plot_foil_yz_distance(
    dy, dz, E, t, r;
    t_range=(0.0, 0.25),
    binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
    binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0),
)

v_stats = get_vertex_stats_df(
    dy, dz, E, t, r;
    E_vals = [500, 1500, 2500], E_step = 1000,t_vals = [0.0, 0.083, 2*0.083], t_step = 0.083,
    t_range=(0.0, 0.25), binning2D=(range(-4, 4, 50), range(-4, 4, 50)), binning1D=range(0, 2, 50),
    E_range=(0.0, 3500.0)
)

pretty_table(v_stats)
safesave(CSV.write(plotsdir("vertex_stats/vertex_stats_TIT_full_array.csv"), v_stats))
