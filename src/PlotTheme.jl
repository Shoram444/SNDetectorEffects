using Makie, Colors, ColorSchemes, MathTeXEngine


function my_makie_theme(spinewidth = 1.5, gridwidth = 1.5)
    colors = ColorSchemes.tol_vibrant
    
    # cmap = Makie.to_colormap([ColorSchemes.tol_vibrant[3],ColorSchemes.tol_vibrant[5]])
    # cmap = Makie.to_colormap(ColorSchemes.jet)
    cmap = Makie.to_colormap(ColorSchemes.:coolwarm)
    cpalette = Attributes(
        color = colors,
        patchcolor = colors,
        marker = [:circle, :utriangle, :cross, :rect, :diamond, :dtriangle, :pentagon, :xcross],
        linestyle = [nothing, :dash, :dot, :dashdot, :dashdotdot],
        side = [:left, :right],
        Lines = (cycle = Cycle([:color]),),
    )

    return Theme(
        palette=cpalette,
        Axis = Attributes(
            titlesize = 14,
            titlefont = :bold,
            titlegap = 4f0,
            titlealign = :center,
            # subtitlesize = 14,
            subtitlegap = 6f0,
            subtitlealign = :left,
            topspinevisible = true,
            rightspinevisible = true,
            bottomspinevisible = true,
            leftspinevisible = true,
            spinewidth = spinewidth,
            xticksvisible = true,
            yticksvisible = true,
            xticklabelsvisible = true,
            yticklabelsvisible = true,
            xticklabelsize = 12,
            yticklabelsize = 12,
            xminorgridvisible = true,
            yminorgridvisible = true,
            xgridvisible = true,
            ygridvisible = true,
            xgridwidth = gridwidth,
            ygridwidth = gridwidth,
            xautolimitmargin = (0.0f0, 0.0f0),
			yautolimitmargin = (0.0f0, 0.05f0),
        ),
        Axis3 = Attributes(
            titlesize = 14,
            titlefont = :bold,
            titlegap = 6f0,
            subtitlesize = 12,
            subtitlegap = 6f0,
        ),
        Legend = Attributes(
            framevisible = true, 
            rowgap = 0,
            labelsize = 14, 
        ),
        fonts = Attributes(
            :bold => texfont(:bold),
            :bolditalic => texfont(:bolditalic),
            :italic => texfont(:italic),
            :regular => texfont(:regular)
        ),
        Scatter = Attributes(
            markersize = 5,
            strokewidth = 0,
        ),
		Heatmap = Attributes(
			colormap = cmap,
		),
    )
end

