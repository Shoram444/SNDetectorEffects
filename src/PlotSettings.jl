FIG_pt_per_unit = 1
FIG_width = 9          # cm
FIG_height = 9          # cm
dpi = 72/2.54           # dpi/cm
px_per_unit = 21.1666   # equivalent of final 600dpi
FIG_size=(FIG_width*dpi, FIG_height*dpi) 
FIG_size_w=(FIG_width*dpi*2, FIG_height*dpi) 
FIG_fontsize=12
FIG_figure_padding=5

function plot_all_histos(df)
    # Create a grid layout for the plots
    fig = Figure(size=(800,800), fontsize=FIG_fontsize, figure_padding=5, px_per_unit=1)
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
