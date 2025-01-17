module DetectorEffects

include("Init.jl")
export 
    CAT_FILE,
    TIT_FILE,
    ALL_VARS,
    VERTEX_POS_VARS,
    ANGLES_VARS

include("Load.jl")
export 
    load_data

include("PlotTheme.jl")
export 
    my_makie_theme

include("PlotSettings.jl")
export 
    plot_all_histos,
    FIG_pt_per_unit, 
    FIG_width_inch, 
    FIG_height_inch, 
    dpi, 
    px_per_unit,
    FIG_size,
    FIG_size_w,
    FIG_fontsize,
    FIG_figure_padding

include("VertexPlots.jl")
export 
    plot_foil_yz_vertex_map,
    plot_foil_yz_distance,
    plot_foil_3D_distance,
    plot_heatmap_t_vs_r,
    plot_foil_d_vs_r,
    plot_foil_t_vs_r,
    plot_foil_t_vs_d,
    plot_grid_E_t_vertex_sizes,
    plot_heatmap_E_t_mean_r,
    plot_heatmap_theta_phi_mean_r,
    plot_scatter_t_vs_r,
    plot_h1d_r_by_t,
    plot_h1d_r_by_E,
    plot_E_t_subsets_r

include("AnglesPlots.jl")
export 
    plot_angles_1D,
    plot_angles_theta_vs_phiSE,
    plot_h1_h2,
    plot_angles_subsets

include("AnglesStats.jl")
export 
    get_sigma,
    get_sigma_stats_E_t

include("FitFunctions.jl")
export 
    fit_chi_square_mle

include("VertexStats.jl")
export 
    Vertex_stats,
    get_vertex_stats,
    get_vertex_stats_df

include("EscapeEfficiency.jl")
export 
    get_nEvents,
    get_energy_from_path,
    get_thickness_from_path,
    load_efficiency_data,
    load_efficiency_nReco_data

end