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
    plot_all_histos

include("VertexPlots.jl")
export 
    plot_foil_yz_vertex_map,
    plot_foil_yz_distance,
    plot_foil_3D_distance,
    plot_foil_d_vs_r,
    plot_foil_t_vs_r,
    plot_foil_t_vs_d

include("AnglesPlots.jl")
export 
    plot_angles_1D

end