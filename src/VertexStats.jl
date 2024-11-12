mutable struct Vertex_stats
    E_min
    E_max
    t_min
    t_max
    mean_2d
    max_2d
    min_2d
    mean_1d
    std_1d
    q50_1d
    q90_1d
    q99_1d
    sigma_1d
    sigma2_1d
    sigma3_1d
end
    
function get_vertex_stats(
        dy, dz, E, t, r;
        t_range=(0.0, 0.25),
        binning2D=(range(-4, 4, 50), range(-4, 4, 50)),
        binning1D=range(0, 2, 50),
        E_range=(0.0, 3500.0)
    )

    _, h1, h2 = plot_foil_yz_distance(dy, dz, E, t, r; t_range, binning2D, binning1D, E_range)
    
    E_min = E_range[1]
    E_max = E_range[2]
    t_min = t_range[1]
    t_max = t_range[2]
    mean_2d = h2 |> mean
    max_2d = (0,0)
    min_2d = (0,0)
    mean_1d = h1 |> mean
    std_1d = h1 |> std
    q50_1d = quantile(h1, 0.5)
    q90_1d = quantile(h1, 0.9)
    q99_1d = quantile(h1, 0.99)
    sigma_1d = quantile(h1, 0.682689492137086)
    sigma2_1d = quantile(h1, 0.954499736103642)
    sigma3_1d = quantile(h1, 0.997300203936740)

    return Vertex_stats(
        E_min, E_max, t_min, t_max, 
        mean_2d, max_2d, min_2d, 
        mean_1d, std_1d, q50_1d, q90_1d, q99_1d, sigma_1d, sigma2_1d, sigma3_1d
        )
end


function get_vertex_stats_df(
        dy, dz, E, t, r;
        E_vals = [500, 1500, 2500], E_step = 1000,t_vals = [0.0, 0.083, 2*0.083], t_step = 0.083,
        t_range=(0.0, 0.25), binning2D=(range(-4, 4, 50), range(-4, 4, 50)), binning1D=range(0, 2, 50),
        E_range=(0.0, 3500.0)
    )

    vertex_stats = []

    for (E_, t_) in zip(E_vals, t_vals)
        v_sE = get_vertex_stats(dy, dz, E, t, r;t_range=t_range,binning2D=binning2D,binning1D=binning1D,E_range=(E_, E_+E_step))
        push!(vertex_stats, v_sE)

        v_st = get_vertex_stats(dy, dz, E, t, r;t_range=(t_,t_+t_step),binning2D=binning2D,binning1D=binning1D,E_range=E_range)
        push!(vertex_stats, v_st)
    end

    df_stats = DataFrame(
        E_min = [v.E_min for v in vertex_stats],
        E_max = [v.E_max for v in vertex_stats],
        t_min = [v.t_min for v in vertex_stats],
        t_max = [v.t_max for v in vertex_stats],
        mean_2d = [v.mean_2d for v in vertex_stats],
        max_2d = [v.max_2d for v in vertex_stats],
        min_2d = [v.min_2d for v in vertex_stats],
        mean_1d = [v.mean_1d for v in vertex_stats],
        std_1d = [v.std_1d for v in vertex_stats],
        q50_1d = [v.q50_1d for v in vertex_stats],
        q90_1d = [v.q90_1d for v in vertex_stats],
        q99_1d = [v.q99_1d for v in vertex_stats],
        sigma_1d = [v.sigma_1d for v in vertex_stats],
        sigma2_1d = [v.sigma2_1d for v in vertex_stats],
        sigma3_1d = [v.sigma3_1d for v in vertex_stats]
    )


    return df_stats
end
