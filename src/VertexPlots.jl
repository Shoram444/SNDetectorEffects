


function plot_foil_yz_vertex_map(df; binning=(range(-2500, 2500, 50), range(-1350, 1350, 50)))
    fig = Figure(size=(1200, 1600), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(fig[1, 1], xlabel="y [mm]", ylabel="z [mm]", title="Map of simulated DECAY vertices on y-z plane", aspect=DataAspect())
    ax2 = Axis(fig[2, 1], xlabel="y [mm]", ylabel="z [mm]", title="Map of simulated ESCAPE vertices on y-z plane", aspect=DataAspect())
    ax3 = Axis(fig[3, 1], xlabel="y [mm]", ylabel="z [mm]", title="Map of simulated DECAY - ESCAPE vertices on y-z plane", aspect=DataAspect())

    h1 = Hist2D((df.ySD, df.zSD); counttype=Float64, binedges=binning)
    h2 = Hist2D((df.ySE, df.zSE); counttype=Float64, binedges=binning)
    h3 = h1 - h2

    min_color = [minimum(bincounts(h1)), minimum(bincounts(h2))] |> minimum
    max_color = [maximum(bincounts(h1)), maximum(bincounts(h2))] |> maximum

    p1 = plot!(ax1, h1, colorrange=(min_color, max_color))
    p2 = plot!(ax2, h2, colorrange=(min_color, max_color))
    p3 = plot!(ax3, h3, colorrange=(min_color, max_color))

    Colorbar(fig[1:3, 2], p1, size=35)

    rowgap!(fig.layout, 0)

    return fig
end

function plot_foil_yz_distance(
    df;
    t_range=(0.0, 0.25),
    binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
    binning1D=range(0, 2, 50),
    E_range=(0.0,3500.0)
)

    df = @chain df begin
        @subset t_range[1] .<= :t .< t_range[2]
        @subset E_range[1] .<= :simuE .< E_range[2]
    end

    fig = Figure(size=(1200, 800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$\Delta y \equiv y_{SD} - y_{SE}$  [mm]",
        ylabel=L"$\Delta z \equiv z_{SD} - z_{SE}$ [mm]",
        title=L"Distance of Decay vs Escape vertices \\ in yz plane for $t \in (%$(t_range[1]), %$(t_range[2]))$ [mm]",
        aspect=1,
    )
    ax2 = Axis(fig[1, 3], xlabel=L"$r \equiv \sqrt{ (\Delta y)^2 + (\Delta z)^2 }$ [mm]", ylabel=L"counts $$", title=L"3D Distance in the yz plane $$", aspect=1)

    h2d = Hist2D((df.dy, df.dz); binedges=binning2D)
    h1d = Hist1D(df.r; binedges=binning1D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    p2 = plot!(ax2, h1d)

    c = Colorbar(
        fig[1, 2],
        p1,
        height=Relative(2 / 3),
    )
    return fig
end

function plot_foil_3D_distance(
    df,
    binning1D=range(0, 3.5, 50)
)

    fig = Figure(size=(1200, 800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$d \equiv \sqrt{(\Delta x)^2 + (\Delta y)^2 + (\Delta z)^2 }$ [mm]",
        ylabel=L"counts $$",
        title=L"3D Distance of Decay vs Escape vertices $$",
        aspect=1,
    )

    h1d = Hist1D(df.d; binedges=binning1D)

    p1 = plot!(ax1, h1d)

    return fig
end

function plot_foil_d_vs_r(
    df,
    binning2D=(range(0, 3, 100), range(0, 3, 100))
)

    fig = Figure(size=(800, 800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$d$ [mm]",
        ylabel=L"$r$ [mm]",
        title=L"Distance travelled by electrons within foil \\ vs vertex separation on Escape $$",
        aspect=1,
    )

    h2d = Hist2D((df.d, df.r); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(1))

    return fig
end

function plot_foil_t_vs_r(
    df,
    binning2D=(range(0, 0.25, 100), range(0, 1.5, 100))
)

    fig = Figure(size=(800, 800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$t$ [mm]",
        ylabel=L"$r$ [mm]",
        title=L"Horizontal distance travelled by electrons within foil \\ vs vertex separation on Escape $$",
        aspect=1,
    )

    h2d = Hist2D((df.t, df.r); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(0.9))

    return fig
end

function plot_foil_t_vs_d(
    df,
    binning2D=(range(0, 0.25, 100), range(0, 1.5, 100))
)

    fig = Figure(size=(800, 800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$t$ [mm]",
        ylabel=L"$d$ [mm]",
        title=L"Horizontal distance travelled by electrons within foil \\ vs 3D distance traveled Escape $$",
        aspect=1,
    )

    h2d = Hist2D((df.t, df.d); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(0.9))

    return fig
end