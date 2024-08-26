using DrWatson
@quickactivate "SNDetectorEffects"
using Revise

push!(LOAD_PATH, srcdir())
using DetectorEffects
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())
#######################################################
#######################################################
#######                ANGLES                   #######
#######################################################
#######################################################

df = load_data(TIT_FILE, ANGLES_VARS)

# Data wrangling
@chain df begin
    # FakeItTillYouMakeIt events have SE set to 0, we can filter them out now   
    @subset! @. :py1SE != 0.0 && :py2SE != 0.0

    # Ambiguities have the same reconstructed z-component, filter them out
    @subset! @. :z1RE != :z2RE
end

# quick glance at data
describe(df)
f_all_histos = plot_all_histos(df)
safesave(plotsdir("angles", "plot_all_histos.png"), f_all_histos)


f_angles_1D = plot_angles_1D(df)
safesave(plotsdir("angles", "plot_angles_1D.png"), f_angles_1D)

f_angles_theta_vs_phiSE = plot_angles_theta_vs_phiSE(df)
safesave(plotsdir("angles", "plot_angles_theta_vs_phiSE.png"), f_angles_theta_vs_phiSE)

hh = Hist2D((df.simuEnergy1, df.simuEnergy2))
plot(hh)
#

