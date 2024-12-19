# using Glob, UnROOT
function get_nEvents(path)
    f = ROOTFile(path) 
    return LazyTree(f, "tree", keys(f["tree"])) |> length
end

function get_nRecoTracks(path)
    f = ROOTFile(path) 
    l = LazyTree(f, "tree", "nRecoTracks") 
    n0 = filter( x-> x == 0, l.nRecoTracks ) |> length
    n1 = filter( x-> x == 1, l.nRecoTracks ) |> length
    n2 = filter( x-> x == 2, l.nRecoTracks ) |> length
    n3 = filter( x-> x == 3, l.nRecoTracks ) |> length
    n4 = filter( x-> x == 4, l.nRecoTracks ) |> length
    n5 = filter( x-> x == 5, l.nRecoTracks ) |> length
    n6 = filter( x-> x == 6, l.nRecoTracks ) |> length
    n7 = filter( x-> x == 7, l.nRecoTracks ) |> length
    n8 = filter( x-> x == 8, l.nRecoTracks ) |> length
    return n0, n1, n2, n3, n4, n5, n6, n7, n8
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

function load_efficiency_nReco_data(pattern)
    # Work/Falaise/mountSPS/Projects/PhD/Cluster_sim_data/Job33_100kpf/
    # pattern = joinpath("Work/Falaise/mountSPS/Projects/PhD/Cluster_sim_data/Job33_100kpf", "*_um", "*_keV", "*", root_file_name)
    
    paths = glob(pattern)
    t = Int[]
    e = Int[]
    n = Int[]
    nRecoTracks = []

    for path in paths
        println("processing $path")
        push!(t, get_thickness_from_path(path))
        push!(e, get_energy_from_path(path))
        push!(n, get_nEvents(path))
        push!(nRecoTracks, get_nRecoTracks(path))
    end

    return DataFrame(thickness = t, energy = e, nEscaped = n, nRecoTracks = nRecoTracks)
end
