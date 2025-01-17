using DrWatson
@quickactivate "SNDetectorEffects"
using Revise

push!(LOAD_PATH, srcdir())
using DetectorEffects
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase, Revise
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())
#######################################################
#######################################################
#######                ANGLES                   #######
#######################################################
#######################################################

file = datadir("sims", "Boff", "0", "TIT.root")
data = LazyTree(file, "tree", ANGLES_VARS) 

# df = load_data(file, ANGLES_VARS)

# Data wrangling
# @chain df begin
#     # FakeItTillYouMakeIt events have SE set to 0, we can filter them out now   
#     @subset! @. :py1SE != 0.0 && :py2SE != 0.0

#     # Ambiguities have the same reconstructed z-component, filter them out
#     @subset! @. :z1RE != :z2RE
    
#     # add column t - horizontal distance traveled
#     @rtransform! :dmin = 0.125 - abs(:x1SD)      # distance to closest wall
#     @rtransform! :dmax = 2 * 0.125 - :dmin         # distance to furthest wall
#     @rtransform! :t = @. :x1SD * :px1SE > 0 ? :dmin : :dmax # horizontal distance traveled
# end

E = Float32[]
t = Float32[]
phi = Float32[]
theta = Float32[]

Threads.@threads for (i, event) in enumerate(data)
    # Discard fake it till you make it events
    if(i%100000 == 0)
        @show "processed $i events"
    end

    if(event.py1SE == 0.0 || event.py2SE == 0.0)
        continue
    end
    if(event.z1RE == event.z2RE)
        continue
    end

    #  calculate t - horizontal distance traveled
    dmin1 = 0.125 - abs(event.x1SD)                 # distance to closest wall
    dmax1 = 2 * 0.125 - dmin1                       # distance to furthest wall
    t1_ = event.x1SD * event.px1SE > 0 ? dmin1 : dmax1  # horizontal distance traveled
    
    push!(t, t1_)
    push!(E, event.simuEnergy1)
    push!(phi, event.phiRE)
    push!(theta, event.theta)
end

# quick glance at data
# describe(df)
# f_all_histos = plot_all_histos(df)
# safesave(plotsdir("angles", "plot_all_histos.png"), f_all_histos)


# f_angles_1D = plot_angles_1D(df)
# safesave(plotsdir("angles", "plot_angles_1D.png"), f_angles_1D)

# f_angles_theta_vs_phiSE = plot_angles_theta_vs_phiSE(df)
# safesave(plotsdir("angles", "plot_angles_theta_vs_phiSE.png"), f_angles_theta_vs_phiSE)

f_h1_h2 = plot_h1_h2(E,t,phi, theta)
safesave(plotsdir("angles", "plot_h1_h2.png"), f_h1_h2)



@show sigma = get_sigma(phi, theta)

f_plot_angles_subsets = plot_angles_subsets(E,t,phi,theta; normed = true)
safesave(plotsdir("angles", "plot_angles_subsets_unnormed.png"), f_plot_angles_subsets)



sE, st = get_sigma_stats_E_t(E,t,phi,theta)

using PrettyTables
@show "E_subset table stats"
pretty_table(
    DataFrame(
        E_min = [x.e_range[1] for x in sE],
        E_max = [x.e_range[2] for x in sE],
        sigma = [x.sE for x in sE]
    ),
    header = ([L"E_{min}", L"E_{max}", L"\sigma"], [L"(keV)", L"(keV)", L"({}^{\circ})"]),
    backend = Val(:markdown)
)

@show "t_subset table stats"
pretty_table(
    DataFrame(
        t_min = [x.t_range[1] for x in st],
        t_max = [x.t_range[2] for x in st],
        sigma = [x.st for x in st]
    ),
    header = ([L"t_{min}", L"t_{max}", L"\sigma"], [L"(mm)", L"(mm)", L"({}^{\circ})"]),
    backend = Val(:markdown)
)


plot_h1_h2(E,t,phi, theta; t_range=(0.00, 0.08), title = "t ∈ (0.00, 0.08)mm")
plot_h1_h2(E,t,phi, theta; t_range=(0.08, 0.16), title = "t ∈ (0.08, 0.16)mm")
plot_h1_h2(E,t,phi, theta; t_range=(0.16, 0.25), title = "t ∈ (0.16, 0.25)mm")