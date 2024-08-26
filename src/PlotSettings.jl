const FIG_pt_per_unit = 1
const FIG_width = 7          # cm
const FIG_height = 7          # cm
const dpi = 72/2.54           # dpi/cm
const px_per_unit = 21.1666   # equivalent of final 600dpi
const FIG_size=(FIG_width*dpi, FIG_height*dpi) 
const FIG_size_w=(FIG_width*dpi*2, FIG_height*dpi) 
const FIG_fontsize=12
const FIG_figure_padding=10

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
