FIG_size=(800, 800) 
FIG_fontsize=30 
FIG_figure_padding=50

function plot_all_histos(df)
    # Create a grid layout for the plots
    fig = Figure(size=(1600, 1600), fontsize=FIG_fontsize)
    nvars = ncol(df)
    grid_size = Int(ceil(sqrt(nvars)))    # I want to create a nxn figure where each cell is one histogram

    r, c = 1, 1
    # Iterate through columns and plot histograms
    for (i, colname) in enumerate(names(df))
        ax = Axis(fig[r, c], title=string(colname), aspect=1, xticklabelrotation=45)
        hist!(ax, df[:, colname], bins=50, color=:blue)
        c += 1
        if (i % grid_size == 0)
            r += 1
            c -= grid_size
        end
    end
    return fig
end
