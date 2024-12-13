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
using FHist, UnROOT, DataFramesMeta, CairoMakie, LaTeXStrings, StatsBase, PrettyTables, Glob, ColorSchemes
Revise.track(DetectorEffects)
set_theme!(my_makie_theme())

nSimulated = 100_000
root_file_name = "efficiency_count.root"
pattern = joinpath("data/sims/eff", "300_um", "*_keV", "*", root_file_name)

data = load_efficiency_data(pattern)

df = @chain data begin
    @groupby :thickness :energy
    @combine begin
        :nEscaped = sum(:nEscaped)
        :nSimulated = $nrow
    end
    @rtransform :nSimulated = :nSimulated * nSimulated
    @rtransform :efficiency = :nEscaped / :nSimulated
    @rtransform :efficiency_percent = :nEscaped / :nSimulated * 100
    @orderby :thickness :energy
end

e_bins = vcat(unique(df.energy)[2:end], 4000)
t_bins = vcat(unique(df.thickness), 2000)
h2 = Hist2D(;
    binedges = (e_bins, t_bins),
    counttype = Float64,
    overflow = false
    )

for row in eachrow(df)
    push!(h2, row.energy, row.thickness, row.efficiency_percent)
end
let
    e_ticks = (1:length(e_bins), string.(e_bins))
    t_ticks = (1:length(t_bins), string.(t_bins))
    f = Figure(size=(520, 400), fontsize=14, figure_padding=4, px_per_unit=5)
    a = Axis(
        f[1,1], 
        ylabel = L"thickness ($\mu m$)", 
        xlabel = L"energy (keV) $$",
        xticks = e_ticks,
        yticks = t_ticks,
        title = L"$$ Probability for an electron to escape the source foil \n for a combination of thickness and energy",
        xticklabelsize = 14,
        yticklabelsize = 14,
        xlabelsize = 18,
        ylabelsize = 18,
        titlesize = 16,
        
        ) 
    p = heatmap!(a, bincounts(h2), colormap = Makie.to_colormap(ColorSchemes.:jblue), colorrange = (0,100))

    for (i,e) in zip(e_ticks[1], midpoints(binedges(h2)[1]))
        for (j, t) in zip(t_ticks[1], midpoints(binedges(h2)[2]))
            txtcolor = lookup(h2, e, t) > 30 ? :white : :black
            text!(
                a, 
                "$(round(lookup(h2, e, t), digits = 2))", 
                position = (i, j),
                color = txtcolor, 
                align = (:center, :center)
            )
        end
    end

    Colorbar(f[1,2], p, label = L"probability (%) $$", labelsize = 19,)
    # safesave(plotsdir("escape_efficiencies", "heatmap.png"), f)
    f
end