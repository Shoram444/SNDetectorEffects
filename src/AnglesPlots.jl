
function plot_angles_1D(df; binning1D=range(0,180,180))
    fig = Figure(size=FIG_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(fig[1, 1], xlabel=L"angle [${}^{\circ}$]", ylabel=L"counts $$", title="Angular distribution DECAY vs ESACPE", aspect=1)

    h1 = Hist1D((df.theta); counttype=Float64, binedges=binning1D)
    h2 = Hist1D((df.phiSE); counttype=Float64, binedges=binning1D)
    h3 = Hist1D((df.phiRE); counttype=Float64, binedges=binning1D)

    p1 = stephist!(ax1, h1, label = L"$\vartheta$ - decay", linewidth=3)
    p2 = stephist!(ax1, h2, label = L"$\varphi$ - simulated escape", linewidth=3)
    p3 = stephist!(ax1, h3, label = L"$\varphi$ - reconstructed escape", linewidth=3)

    axislegend(ax1, position = :cb, labelsize = 24)

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