


function plot_foil_yz_vertex_map(df; binning=(range(-2500, 2500, 50), range(-1350, 1350, 50)))
    fig = Figure(size=(800,800), fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
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
    E_range=(0.0, 3500.0),
)

    df = @chain df begin
        @subset t_range[1] .<= :t .< t_range[2]
        @subset E_range[1] .<= :simuE .< E_range[2]
    end
    fig = Figure(size=FIG_size_w, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding, px_per_unit=1)
    # Label(fig[0, 1:3], L"Relative vertex separation in y-z plane \\ Simulated Decay - Simulated Escape $$")
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$\Delta y$ [mm]",
        ylabel=L"$\Delta z$ [mm]",
        aspect=1,
    )
    ax2 = Axis(
        fig[1, 3],
        xlabel=L"$r$ [mm]",
        ylabel=L"count $$",
        aspect=1,
        # limits=(nothing, nothing,0,5e6)
    )

    h2d = Hist2D((df.dy, df.dz); binedges=binning2D)
    h1d = Hist1D(df.r; binedges=binning1D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    p2 = plot!(ax2, h1d)

    c = Colorbar(
        fig[1, 2],
        p1,
        height=Relative(0.73),
    )
    colgap!(fig.layout, 1, 3)
    # colgap!(fig.layout, 2, -2)
    resize_to_layout!(fig)
    return fig
end

function plot_foil_3D_distance(
    df,
    binning1D=range(0, 3.5, 50)
)
    fig = Figure(size=FIG_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding, px_per_unit=1)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$d$ [mm]",
        ylabel=L"counts $$",
        # title=L"3D Distance\\Decay vs Escape $$",
        titlealign = :left,
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

    fig = Figure(size=FIG_size, fontsize=FIG_fontsize, figure_padding=5, px_per_unit=1)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$d$ [mm]",
        ylabel=L"$r$ [mm]",
        aspect=1,
    )

    h2d = Hist2D((df.d, df.r); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(2/3))
    resize_to_layout!(fig)

    return fig
end

function plot_foil_t_vs_r(
    df,
    binning2D=(range(0, 0.25, 100), range(0, 1.5, 100))
)

    fig = Figure(size=1.5 .* FIG_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$t$ [mm]",
        ylabel=L"$r$ [mm]",
        aspect=1,
    )

    h2d = Hist2D((df.t, df.r); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(3/4))

    return fig
end

function plot_foil_t_vs_d(
    df,
    binning2D=(range(0, 0.25, 100), range(0, 1.5, 100))
)

    fig = Figure(size=1.5 .* FIG_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(
        fig[1, 1],
        xlabel=L"$t$ [mm]",
        ylabel=L"$d$ [mm]",
        aspect=1,
    )

    h2d = Hist2D((df.t, df.d); binedges=binning2D)

    p1 = plot!(ax1, h2d, colorscale=log10)
    Colorbar(fig[1, 2], p1, height=Relative(3/4))

    return fig
end

function plot_grid_E_t_vertex_sizes(
    df;
    E_vals = [500, 1500, 2500],
    E_step = 1000,
    t_vals = [0.0, 0.083, 2*0.083],
    t_step = 0.083,
    f_size = FIG_size,
    normed = false,
    binning2D = (range(-5, 5, 50), range(-5, 5, 50))
)
    hE = []
    ht = []
    for (E, t) in zip(E_vals, t_vals)
        dE = @chain df begin
            @subset E .<= :simuE .< E + E_step
        end
        _hE = Hist2D((dE.dy, dE.dz); binedges=binning2D)

        dt = @chain df begin
            @subset t .<= :t .< t + t_step
        end
        _ht = Hist2D((dt.dy, dt.dz); binedges=binning2D)

        if(normed)
            _hE = _hE |> normalize
            _ht = _ht |> normalize
        end
        push!(hE, _hE)
        push!(ht, _ht)
    end

    largest_bin = vcat(
        hE .|> bincounts .|> maximum, 
        ht .|> bincounts .|> maximum
        ) |> maximum

    min1(A) = minimum(x-> ifelse(x==0, 1e10, x), A) # consider only non-zero bins
    smallest_bin = vcat(
        hE .|> bincounts .|> min1, 
        ht .|> bincounts .|> min1
        ) |> minimum
    @show c_range = (smallest_bin, largest_bin)

    fig = Figure(size=f_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding, px_per_unit=1)
    p = []
    for (i, e) in enumerate(E_vals)
        if(i==1)
            ax = Axis(
                fig[1, i],
                ylabel=L"$\Delta z$ [mm]",
                title=L"$E_{i} \in (%$e, %$(e+E_step))$ keV",
                aspect=1,
            )
        else
            ax = Axis(
                fig[1, i],
                title=L"$E_{i} \in (%$e, %$(e+E_step))$ keV",
                aspect=1,
            )
            hideydecorations!(ax, grid=false, minorgrid=false)
        end

        hidexdecorations!(ax, grid=false, minorgrid=false)

        p1 = plot!(ax, hE[i], colorscale=log10, colorrange=c_range)
        push!(p, p1)
    end
    for (i, tt) in enumerate(t_vals)
        if(i == 1)
            ax = Axis(
                fig[2, i],
                xlabel=L"$\Delta y$ [mm]",
                ylabel=L"$\Delta z$ [mm]",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=1,
            )
        else
            ax = Axis(
                fig[2, i],
                xlabel=L"$\Delta y$ [mm]",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=1,
            )
            hideydecorations!(ax, grid=false, minorgrid=false)
        end

        p1 = plot!(ax, ht[i], colorscale=log10, colorrange=c_range)

        push!(p, p1)
    end
    Colorbar(fig[1:2, end+1], p[end], height=Relative(1),)
    return fig
end

function plot_heatmap_E_t_mean_r(
    df;
    f_size = FIG_size,
    binning2D = (range(0, 3500 , 100), range(0, 0.25, 100))
)
    h1 = Hist2D(; binedges=binning2D, counttype=Float64)
    h2 = Hist2D(; binedges=binning2D, counttype=Float64)

    push!.(h1, df.simuE, df.t)
    push!.(h2, df.simuE, df.t, df.r)

    h3 = h2/h1

    fig = Figure(size=f_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding, px_per_unit=1)
    ax = Axis(fig[1,1], aspect = 1, xlabel=L"E [keV]$$", ylabel = L"t [mm]$$")
    p = plot!(ax, h3,)
    c = Colorbar(fig[1,2], p, label=L"$\bar{r}$ [mm]")
    c.alignmode = Mixed(right = 35)
    colgap!(fig.layout, 1, Relative(-0.05))

    resize_to_layout!(fig)
    return fig
end

function plot_heatmap_theta_phi_mean_r(
    df;
    f_size = FIG_size_w,
    binning2D = (-180:5:180, -90:5:90)
)
    h1 = Hist2D(; binedges=binning2D, counttype=Float64)
    h2 = Hist2D(; binedges=binning2D, counttype=Float64)

    push!.(h1,  df.phi, df.theta)
    push!.(h2,  df.phi, df.theta, df.r)
    h3 = h2/h1

    fig = Figure(size=f_size, fontsize=FIG_fontsize, figure_padding=5, px_per_unit=1)
    ax = Axis(fig[1,1], aspect = DataAspect(), xlabel=L"$\varphi$ [${}^{\circ}$]", ylabel = L"$\vartheta$ [${}^{\circ}$]")
    p = plot!(ax, h3,colormap=Makie.to_colormap(ColorSchemes.:linear_kbc_5_95_c73_n256 |> reverse))
    c = Colorbar(fig[1,2], p, label=L"$\bar{r}$ [mm]", tellheight = true, height=Relative(0.85))
    
    ax.xticks = -180:60:180
    colgap!(fig.layout, 1, Relative(0.05))

    resize_to_layout!(fig)
    return fig
end