function load_data(inpath, vars)
    f = ROOTFile(inpath)
    df = LazyTree(f, "tree", vars) |> DataFrame
    return df
end
