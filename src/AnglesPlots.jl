
function plot_angles_1D(df; binning1D=range(0,180,180))
    fig = Figure(size=FIG_size, fontsize=FIG_fontsize, figure_padding=FIG_figure_padding)
    ax1 = Axis(fig[1, 1], xlabel=L"angle [${}^{\circ}$]", ylabel=L"count $$")

    h1 = Hist1D((df.theta); counttype=Float64, binedges=binning1D)
    h2 = Hist1D((df.phiSE); counttype=Float64, binedges=binning1D)
    # h3 = Hist1D((df.phiRE); counttype=Float64, binedges=binning1D)

    p1 = stephist!(ax1, h1, label = L"$\vartheta$", linewidth=3)
    p2 = stephist!(ax1, h2, label = L"$\varphi$", linewidth=3)
    # p3 = stephist!(ax1, h3, label = L"$\varphi$ - reconstructed escape", linewidth=3)

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

function plot_h1_h2(df; 
    binning1D=range(0,180,36),
    binning2D=(range(0,180,90),range(0,180,90)), 
    E_range=(0,3500), 
    t_range=(0, 0.25),
    f_size = FIG_size_w
    )
    fig = Figure(size=f_size, fontsize=FIG_fontsize, figure_padding=1.5*FIG_figure_padding, px_per_unit=5)
    ax1 = Axis(fig[1, 1], xlabel=L"angle (${}^{\circ}$)", ylabel=L"count $$", aspect = 1)

    indexes_to_keep = Int[]
    Threads.@threads for i in eachindex(df.t)
        if( 
            (t_range[1] <= df.t[i] <= t_range[2]) &&
            (E_range[1] <= (df.simuEnergy1[i] + df.simuEnergy2[i])<= E_range[2])
          )
          push!(indexes_to_keep, i)
        end
    end

    h1 = Hist1D(view(df.theta, indexes_to_keep); counttype=Float64, binedges=binning1D)
    h2 = Hist1D(view(df.phiSE, indexes_to_keep); counttype=Float64, binedges=binning1D)

    p1 = stephist!(ax1, h1, label = L"$\vartheta$", linewidth=3)
    p2 = stephist!(ax1, h2, label = L"$\varphi$", linewidth=3)

    ax2 = Axis(fig[1,2], 
        xlabel = L"$\vartheta$ (${}^{\circ}$)", 
        ylabel = L"$\varphi$ (${}^{\circ}$)",
        aspect = 1,
        )

    h2 = Hist2D( 
        (view(df.theta, indexes_to_keep), view(df.phiSE, indexes_to_keep));
        binedges = binning2D,
        )
    p3 = plot!(ax2, h2, colormap=Makie.to_colormap(ColorSchemes.RdBu |> reverse))
    
    lines!(ax2, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )

    axislegend(ax1, position = :cb, labelsize = 16)
    
    Colorbar(fig[1, 3], p3, height=Relative(0.85), label = "count")
    colgap!(fig.layout, 2, Relative(0.02))

    fig 
end

function plot_h1_h2(E, t, phi, theta; 
    binning1D=range(0,180,36),
    binning2D=(range(0,180,90),range(0,180,90)), 
    E_range=(0,3500), 
    t_range=(0, 0.25),
    f_size = FIG_size_w,
    title = ""
    )
    fig = Figure(size=f_size, fontsize=FIG_fontsize, figure_padding=1.5*FIG_figure_padding, px_per_unit=5)
    if (title != "")
        Label(fig[0,1:2], title)
    end
    ax1 = Axis(fig[1, 1], xlabel=L"angle (${}^{\circ}$)", ylabel=L"count $$", aspect = 1)

    indexes_to_keep = Int[]
    Threads.@threads for i in eachindex(t)
        if( 
            (t_range[1] <= t[i] <= t_range[2]) &&
            (E_range[1] <= E[i] <= E_range[2])
          )
          push!(indexes_to_keep, i)
        end
    end

    h1 = Hist1D(view(theta, indexes_to_keep); counttype=Float64, binedges=binning1D)
    h2 = Hist1D(view(phi, indexes_to_keep); counttype=Float64, binedges=binning1D)

    p1 = stephist!(ax1, h1, label = L"$\vartheta$", linewidth=3)
    p2 = stephist!(ax1, h2, label = L"$\varphi$", linewidth=3)

    ax2 = Axis(fig[1,2], 
        xlabel = L"$\vartheta$ (${}^{\circ}$)", 
        ylabel = L"$\varphi$ (${}^{\circ}$)",
        aspect = 1,
        xticks = 0:45:180,
        yticks = 0:45:180,
        )

    h2 = Hist2D( 
        (view(theta, indexes_to_keep), view(phi, indexes_to_keep));
        binedges = binning2D,
        )
    p3 = plot!(ax2, h2, colormap=Makie.to_colormap(ColorSchemes.coolwarm))
    
    lines!(ax2, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )

    axislegend(ax1, position = :cb, labelsize = 16)
    
    Colorbar(fig[1, 3], p3, height=Relative(0.7), label = "count")
    colgap!(fig.layout, 2, Relative(0.05))

    fig 
end


function plot_angles_subsets(
    df;
    binning2D=(range(0,180,90),range(0,180,90)), 
    E_vals = [500, 1500, 2500],
    E_step = 1000,
    t_vals = [0.0, 0.083, 2*0.083],
    t_step = 0.083,
    f_size = FIG_size_w,
    normed = true
    )
    E = df.recoEnergy1 .+ df.recoEnergy2
    t = df.t
    hE = []
    ht = []
    for (_E, _t) in zip(E_vals, t_vals)
        println("processing _E = $(_E), _t = $(_t) data")
        indexes_to_keep_E = Int[]
        Threads.@threads for i in eachindex(E)
            if( 
                (_E <= E[i] <= _E+E_step)
              )
              push!(indexes_to_keep_E, i)
            end
        end
        _hE = Hist2D((view(df.theta, indexes_to_keep_E), view(df.phiRE, indexes_to_keep_E) ); binedges=binning2D)

        indexes_to_keep_t = Int[]
        Threads.@threads for i in eachindex(t)
            if( 
                (_t <= t[i] <= _t+t_step)
              )
              push!(indexes_to_keep_t, i)
            end
        end
        _ht = Hist2D((view(df.theta, indexes_to_keep_t), view(df.phiRE, indexes_to_keep_t) ); binedges=binning2D)

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

    fig = Figure(size=f_size, fontsize=10, figure_padding=FIG_figure_padding, px_per_unit=6)
    p = []
    for (i, e) in enumerate(E_vals)
        if(i==1)
            ax = Axis(
                fig[1, i],
                ylabel=L"$\varphi (\degree)$",
                title=L"$E_{sum} \in (%$e, %$(e+E_step))$ keV",
                titlesize= 12,
                aspect=DataAspect(),
                xticklabelsize = 10,
                yticklabelsize = 10,
            )
        else
            ax = Axis(
                fig[1, i],
                title=L"$E_{sum} \in (%$e, %$(e+E_step))$ keV",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
            )
            # hideydecorations!(ax, grid=false, minorgrid=false)
        end

        # hidexdecorations!(ax, grid=false, minorgrid=false)

        p1 = plot!(ax, hE[i], colorscale=log10, colorrange=c_range)
        lines!(ax, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )
        push!(p, p1)
    end
    for (i, tt) in enumerate(t_vals)
        if(i == 1)
            ax = Axis(
                fig[2, i],
                xlabel=L"$\vartheta (\degree)$",
                ylabel=L"$\varphi (\degree)$",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
            )
        else
            ax = Axis(
                fig[2, i],
                xlabel=L"$\vartheta (\degree)$",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
            )
            # hideydecorations!(ax, grid=false, minorgrid=false)
        end

        p1 = plot!(ax, ht[i], colorscale=log10, colorrange=c_range)
        lines!(ax, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )

        push!(p, p1)
    end

    Colorbar(fig[1:2, end+1], p[end], height=Relative(1),)
    rowgap!(fig.layout, 1, Relative(0.02))
    return fig
end


function plot_angles_subsets(
    E,t,phi,theta;
    binning2D=(range(0,180,90),range(0,180,90)), 
    E_vals = [500, 1500, 2500],
    E_step = 1000,
    t_vals = [0.0, 0.083, 2*0.083],
    t_step = 0.083,
    f_size = FIG_size_w,
    normed = true
    )
    hE = []
    ht = []
    for (_E, _t) in zip(E_vals, t_vals)
        println("processing _E = $(_E), _t = $(_t) data")
        indexes_to_keep_E = Int[]
        Threads.@threads for i in eachindex(E)
            if( 
                (_E <= E[i] <= _E+E_step)
              )
              push!(indexes_to_keep_E, i)
            end
        end
        _hE = Hist2D((view(theta, indexes_to_keep_E), view(phi, indexes_to_keep_E) ); binedges=binning2D)

        indexes_to_keep_t = Int[]
        Threads.@threads for i in eachindex(t)
            if( 
                (_t <= t[i] <= _t+t_step)
              )
              push!(indexes_to_keep_t, i)
            end
        end
        _ht = Hist2D((view(theta, indexes_to_keep_t), view(phi, indexes_to_keep_t) ); binedges=binning2D)

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

    fig = Figure(size=f_size, fontsize=10, figure_padding=FIG_figure_padding, px_per_unit=6)
    p = []
    for (i, e) in enumerate(E_vals)
        if(i==1)
            ax = Axis(
                fig[1, i],
                ylabel=L"$\varphi (\degree)$",
                title=L"$E_{sum} \in (%$e, %$(e+E_step))$ keV",
                titlesize= 12,
                aspect=DataAspect(),
                xticklabelsize = 10,
                yticklabelsize = 10,
                xticks= 0:45:180,
                yticks = 0:45:180,
            )
        else
            ax = Axis(
                fig[1, i],
                title=L"$E_{sum} \in (%$e, %$(e+E_step))$ keV",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
                xticks= 0:45:180,
                yticks = 0:45:180,
            )
            # hideydecorations!(ax, grid=false, minorgrid=false)
        end

        # hidexdecorations!(ax, grid=false, minorgrid=false)

        p1 = plot!(ax, hE[i], colorrange=c_range)
        lines!(ax, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )
        push!(p, p1)
    end
    for (i, tt) in enumerate(t_vals)
        if(i == 1)
            ax = Axis(
                fig[2, i],
                xlabel=L"$\vartheta (\degree)$",
                ylabel=L"$\varphi (\degree)$",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
                xticks= 0:45:180,
                yticks = 0:45:180,

            )
        else
            ax = Axis(
                fig[2, i],
                xlabel=L"$\vartheta (\degree)$",
                title=L"$t \in (%$tt, %$(round(tt+t_step, sigdigits=2)))$ mm",
                aspect=DataAspect(),
                titlesize= 12,
                xticklabelsize = 10,
                yticklabelsize = 10,
                xticks= 0:45:180,
                yticks = 0:45:180,

            )
            # hideydecorations!(ax, grid=false, minorgrid=false)
        end

        p1 = plot!(ax, ht[i], colorrange=c_range)
        lines!(ax, 0:1:180, 0:1:180, color = :black, linestyle=(:dash, :dense), linewidth = 2, )

        push!(p, p1)
    end

    Colorbar(fig[1:2, end+1], p[end], height=Relative(1),tickformat = "{:.2e}")
    rowgap!(fig.layout, 1, Relative(0.02))
    return fig
end