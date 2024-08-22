module DetectorEffects

include("Init.jl")
export 
    CAT_FILE,
    TIT_FILE,
    ALL_VARS,
    FOIL_EFFECTS_VARS

include("Load.jl")
export 
    load_data

include("MakieUtils.jl")
export 
    my_makie_theme

include("PlottingUtils.jl")
export 
    plot_foil_all_histos,
    plot_foil_yz_vertex_map,
    plot_foil_yz_distance,
    plot_foil_3D_distance
end