
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

function plot_angles_theta_vs_phiSE(df; binning2D=(range(0,180,90),range(0,180,90)), sum_E=(0,3500), single_E=(0,3500))
    df = @chain df begin
        @subset @. sum_E[1] <= (:simuEnergy2 + :simuEnergy1) < sum_E[2]
        @subset @. single_E[1] <= :simuEnergy1 < single_E[2]
        @subset @. single_E[1] <= :simuEnergy2 < single_E[2]
    end

    fig = Figure(size=FIG_size, fontsize=FIG_fontsize, )
    ax1 = Axis(fig[1, 1], xlabel=L"$\vartheta$ [${}^\circ$]", ylabel=L"$\varphi$ [${}^\circ$]", title="Angular distribution DECAY vs ESACPE", aspect=1)

    h = Hist2D((df.theta, df.phiSE); counttype=Float64, binedges=binning2D)

    p1 = plot!(ax1, h, )

    Colorbar(fig[1,2], p1, label= L"counts $$", height=Relative(0.8))

    return fig
end