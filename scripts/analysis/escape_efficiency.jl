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
pattern = joinpath("data/sims/eff", "*_um", "*_keV", "*", root_file_name)

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
    f = Figure(size=(420, 260), fontsize=10, figure_padding=4, px_per_unit=5)
    a = Axis(
        f[1,1], 
        ylabel = L"thickness ($\mu m$)", 
        xlabel = L"energy (keV) $$",
        xticks = e_ticks,
        yticks = t_ticks,
        title = L"$$ Probability for an electron to escape the source foil \n for a combination of thickness and energy",
        xticklabelsize = 10,
        yticklabelsize = 10,
        xlabelsize = 12,
        ylabelsize = 12,
        titlesize = 12,
        
        ) 
    p = heatmap!(a, bincounts(h2), colormap = Makie.to_colormap(ColorSchemes.:jblue), colorrange = (0,100))

    for (i,e) in zip(e_ticks[1], midpoints(binedges(h2)[1]))
        for (j, t) in zip(t_ticks[1], midpoints(binedges(h2)[2]))
            txtcolor = lookup(h2, e, t) > 40 ? :white : :black
            text!(
                a, 
                "$(round(lookup(h2, e, t), digits = 2))", 
                position = (i, j),
                color = txtcolor, 
                align = (:center, :center)
            )
        end
    end

    Colorbar(f[1,2], p, label = L"probability (%) $$", labelsize = 12,)
    safesave(plotsdir("escape_efficiencies", "heatmap.png"), f)
    f
end


nSimulated = 100_000
root_file_name2 = "efficiency_count.root"
pattern2 = joinpath("data/sims/eff", "250_um", "*_keV", "*", root_file_name2)

data2 = load_efficiency_nReco_data(pattern2)

df2 = @chain data2 begin
    @rtransform :n0 = :nRecoTracks[1]
    @rtransform :n1 = :nRecoTracks[2]
    @rtransform :n2 = :nRecoTracks[3]
    @rtransform :n3 = :nRecoTracks[4]
    @rtransform :n4 = :nRecoTracks[5]
    @rtransform :n5 = :nRecoTracks[6]
    @rtransform :n6 = :nRecoTracks[7]
    @rtransform :n7 = :nRecoTracks[8]
    @rtransform :n8 = :nRecoTracks[9]

    @groupby :energy
    @combine begin
        :nEscaped = sum(:nEscaped)
        :n0 = sum(:n0)
        :n1 = sum(:n1)
        :n2 = sum(:n2)
        :n3 = sum(:n3)
        :n4 = sum(:n4)
        :n5 = sum(:n5)
        :n6 = sum(:n6)
        :n7 = sum(:n7)
        :n8 = sum(:n8)
    end
    @rtransform :probability0 = :n0 / :nEscaped * 100
    @rtransform :probability1 = :n1 / :nEscaped * 100
    @rtransform :probability2 = :n2 / :nEscaped * 100
    @rtransform :probability3 = :n3 / :nEscaped * 100
    @rtransform :probability4 = :n4 / :nEscaped * 100
    @rtransform :probability5 = :n5 / :nEscaped * 100
    @rtransform :probability6 = :n6 / :nEscaped * 100
    @rtransform :probability7 = :n7 / :nEscaped * 100
    @rtransform :probability8 = :n8 / :nEscaped * 100
    @orderby :energy
end

let
    m = Matrix(df2[2:end, 12:end])'
    e_ticks = (1:length(df2.energy)-1, string.(df2.energy[2:end]))
    n_ticks = (1:9, string.(0:8))
    f = Figure(size=(520, 400), fontsize=14, figure_padding=4, px_per_unit=5)
    a = Axis(
        f[1,1], 
        xlabel = L"number of reconstructed tracks $$", 
        ylabel = L"energy (keV) $$",
        yticks = e_ticks,
        xticks = n_ticks,
        title = L"$$ Probability to reconstruct n tracks per energy",
        xticklabelsize = 14,
        yticklabelsize = 14,
        xlabelsize = 18,
        ylabelsize = 18,
        titlesize = 16,
        ) 
    p = heatmap!(a, m, colormap = Makie.to_colormap(ColorSchemes.:jblue), colorrange = (0,100))

    for (i,e) in zip(e_ticks[1], e_ticks[2])
        for (j, t) in zip(n_ticks[1], n_ticks[2])
            txtcolor = m[j,i] > 30 ? :white : :black
            text!(
                a, 
                "$(round(m[j,i], digits = 2))", 
                position = (j, i),
                color = txtcolor, 
                align = (:center, :center)
            )
        end
    end

    Colorbar(f[1,2], p, label = L"probability (%) $$", labelsize = 19,)
    safesave(plotsdir("escape_efficiencies", "heatmap_nReco.png"), f)
    f
end

mm = Matrix(df2[2:end, 11:end])
