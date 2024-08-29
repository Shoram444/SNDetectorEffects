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

include("MakieUtils.jl")
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
    plot_foil_d_vs_r,
    plot_foil_t_vs_r,
    plot_foil_t_vs_d,
    plot_grid_E_t_vertex_sizes,
    plot_heatmap_E_t_mean_r

include("AnglesPlots.jl")
export 
    plot_angles_1D,
    plot_angles_theta_vs_phiSE

end