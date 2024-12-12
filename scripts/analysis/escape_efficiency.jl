#######################################################
#######################################################
#######          ESCAPE EFFICIENCY              #######
#######################################################
#######################################################

using DrWatson
@quickactivate "SNDetectorEffects"
using Revise

push!(LOAD_PATH, srcdir())
using DetectorEffects
using FHist, UnROOT, DataFramesMeta, CairoMakie, StatsBase, PrettyTables, Glob
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())

nSimulated = 100_000

function get_nEvents(path)
    f = ROOTFile(path) 
    return LazyTree(f, "tree", keys(f["tree"])) |> length
end

function get_energy_from_path(path)
    s = split(path, "/")
    e = split(s[end-2], "_")[1]
    parse(Int, e)
end

function get_thickness_from_path(path)
    s = split(path, "/")
    t = split(s[end-3], "_")[1]
    parse(Int, e)
end


function load_efficiency_data()
    pattern = joinpath(datadir("sims/eff"), "*_um", "*_keV", "efficiency_count.root")
    paths = glob(pattern)
    t = Int[]
    e = Int[]
    n = Int[]

    for path in paths
        push!(t, get_thickness_from_path(path))
        push!(e, get_energy_from_path(path))
        push!(n, get_nEvents(path))
    end

    return DataFrame(thickness = t, energy = e, nEscaped = n)
end

data = load_efficiency_data()

df = @chain df begin
    @groupby :thickness :energy
    @combine begin
        :nEscaped = sum
        :nSimulated = nrow * nSimulated
        :thickness
        :energy
    end
    @transform! :efficiency = :nEscaped / :nSimulated
end


