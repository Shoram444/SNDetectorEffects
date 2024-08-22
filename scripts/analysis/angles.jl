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

data = load_data(TIT_FILE, ANGLES_VARS)

@chain data begin
    # FakeItTillYouMakeIt events have SE set to 0, we can filter them out now   
    @subset! @. :py1SE != 0.0 && :py2SE != 0.0

    # Ambiguities have the same reconstructed z-component, filter them out
    @subset! @. :z1RE != :z2RE
end

# quick glance at data
describe(data)
plot_all_histos(data)

plot_angles_1D(data)
#