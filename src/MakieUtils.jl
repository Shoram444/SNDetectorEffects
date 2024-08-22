using Makie, Colors, ColorSchemes, MathTeXEngine

function my_makie_theme(spinewidth = 1.5, gridwidth = 1.5)

    return Theme(
        Axis = Attributes(
            titlesize = 24,
            titlefont = :bold,
            titlegap = 4f0,
            titlealign = :left,
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
            # xticklabelsize = 14,
            # yticklabelsize = 14,
            xminorgridvisible = true,
            yminorgridvisible = true,
            xgridvisible = true,
            ygridvisible = true,
            xgridwidth = gridwidth,
            ygridwidth = gridwidth,
        ),
        Axis3 = Attributes(
            titlesize = 20,
            titlefont = :bold,
            titlegap = 6f0,
            # subtitlesize = 14,
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
			linecolor = ["#65ADC2","#111111",  "#233B43", "#E84646", "#C29365", "#362C21", "#316675", "#168E7F", "#109B37"],
            markersize = 15,
            strokewidth = 0,
        ),
		Heatmap = Attributes(
			colormap = :viridis,
		),
    )
end

