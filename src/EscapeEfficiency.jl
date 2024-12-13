# using Glob, UnROOT
function get_nEvents(path)
    f = ROOTFile(path) 
    return LazyTree(f, "tree", keys(f["tree"])) |> length
end

function get_energy_from_path(path)
    s = split(path, "/")
    e = split(s[end-2], "_")[1]
    parse(Int, e)
end

function get_thickness_from_path(path)
    s = split(path, "/")
    t = split(s[end-3], "_")[1]
    parse(Int, t)
end


function load_efficiency_data(pattern)
    # Work/Falaise/mountSPS/Projects/PhD/Cluster_sim_data/Job33_100kpf/
    # pattern = joinpath("Work/Falaise/mountSPS/Projects/PhD/Cluster_sim_data/Job33_100kpf", "*_um", "*_keV", "*", root_file_name)
    
    paths = glob(pattern)
    t = Int[]
    e = Int[]
    n = Int[]

    for path in paths
        println("processing $path")
        push!(t, get_thickness_from_path(path))
        push!(e, get_energy_from_path(path))
        push!(n, get_nEvents(path))
    end

    return DataFrame(thickness = t, energy = e, nEscaped = n)
end
