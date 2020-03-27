@block JuliusKrumbiegel ["legend"] begin
    using MakieLayout
    using AbstractPlotting: px
    @cell "Basic legend" [legend] begin

        using AbstractPlotting: px

        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.5:10
        ys = sin.(xs)
        lin = lines!(ax, xs, ys, color = :blue)
        sca = scatter!(ax, xs, ys, color = :red, markersize = 15px)

        leg = LLegend(scene, [lin, sca, [lin, sca]], ["a line", "some dots", "both together"])
        layout[1, 2] = leg
        
        scene
    end

    @cell "Inline legend" [legend] begin
        scene, layout = layoutscene()

        ax = layout[1, 1] = LAxis(scene)

        ls = [lines!(ax, 1:10, (1:10) .* i, color = rand(RGBf0)) for i in 1:5]

        leg = layout[1, 1] = LLegend(scene, ls, ["line $i" for i in 1:5];
            width = Auto(false), height = Auto(false), halign = :left, valign = :top,
            margin = (10, 10, 10, 10))

        scene
    end

    @cell "Inline legend postioning" [legend] begin
        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.1:10
        lins = [
            lines!(ax, xs, sin.(xs .* i), color = color)
            for (i, color) in zip(1:3, [:red, :blue, :green])
        ]

        legends = [LLegend(
            scene, lins, ["Line $i" for i in 1:3],
            width = Auto(false),
            margin = (10, 10, 10, 10),
        ) for j in 1:3]

        haligns = [:left, :right, :center]
        valigns = [:top, :bottom, :center]

        for (leg, hal, val) in zip(legends, haligns, valigns)
            layout[1, 1] = leg
            leg.title = "$hal & $val"
            leg.halign = hal
            leg.valign = val
        end

        scene
    end

    @cell "Multi-column legend" [legend] begin
        using AbstractPlotting: px

        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.1:10
        lins = [lines!(ax, xs, sin.(xs .+ 3v), color = RGBf0(v, 0, 1-v)) for v in 0:0.1:1]

        leg = LLegend(scene, lins, string.(1:length(lins)), ncols = 3)
        
        layout[1, 2] = leg
        
        scene
    end

    @cell "Manual legend" [legend] begin
        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)


        elem_1 = [LineElement(color = :red, linestyle = nothing),
                  MarkerElement(color = :blue, marker = 'x', strokecolor = :black)]

        elem_2 = [PolyElement(color = :red, strokecolor = :blue),
                  LineElement(color = :black, linestyle = :dash)]

        elem_3 = LineElement(color = :green, linestyle = nothing,
                linepoints = Point2f0[(0, 0), (0, 1), (1, 0), (1, 1)])

        elem_4 = MarkerElement(color = :blue, marker = 'π',
                strokecolor = :transparent,
                markerpoints = Point2f0[(0.2, 0.2), (0.5, 0.8), (0.8, 0.2)])

        elem_5 = PolyElement(color = :green, strokecolor = :black,
                polypoints = Point2f0[(0, 0), (1, 0), (0, 1)])


        leg = layout[1, 2] = LLegend(scene,
            [elem_1, elem_2, elem_3, elem_4, elem_5],
            ["Line & Marker", "Poly & Line", "Line", "Marker", "Poly"])
        
        scene
    end

    @cell "Horizontal legend" [legend] begin
        using AbstractPlotting: px

        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.5:10
        ys = sin.(xs)
        lin = lines!(ax, xs, ys, color = :blue)
        sca = scatter!(ax, xs, ys, color = :red, markersize = 15px)

        leg = LLegend(scene, [lin, sca, lin], ["a line", "some dots", "line again"])
        layout[1, 2] = leg

        leg_horizontal = LLegend(scene, [lin, sca, lin], ["a line", "some dots", "line again"],
        orientation = :horizontal, width = Auto(false), height = Auto(true))
        layout[2, 1] = leg_horizontal
        scene
    end
    
    @cell "Multi-bank legend" [legend] begin
        
        # You can control the number of banks with the `nbanks` attribute. 
        # Banks are columns when in vertical mode, 
        # and rows when in horizontal mode.
        
        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.1:10
        lins = [lines!(ax, xs, sin.(xs .+ 3v), color = RGBf0(v, 0, 1-v)) for v in 0:0.1:1]

        leg = LLegend(scene, lins, string.(1:length(lins)), nbanks = 3)
        layout[1, 2] = leg
        
        scene
        
    end
    
    @cell "Multi-group legends" [legend] begin
        
        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        markersizes = [5, 10, 15, 20]
        colors = [:red, :green, :blue, :orange]

        for ms in markersizes, color in colors
            scatter!(ax, randn(5, 2), markersize = ms * px, color = color)
        end

        group_size = [MarkerElement(marker = :circle, color = :black, strokecolor = :transparent,
            markersize = ms * px) for ms in markersizes]

        group_color = [PolyElement(color = color, strokecolor = :transparent)
            for color in colors]

        legends = [LLegend(scene,
            [group_size, group_color],
            [string.(markersizes), string.(colors)],
            ["Size", "Color"]) for _ in 1:6]

        layout[1, 2:4] = legends[1:3]
        layout[2:4, 1] = legends[4:6]

        for l in legends[4:6]
            l.orientation = :horizontal
            l.height = Auto(true)
            l.width = Auto(false)
        end

        legends[2].titleposition = :left
        legends[5].titleposition = :left

        legends[3].nbanks = 2
        legends[5].nbanks = 2
        legends[6].nbanks = 2

        scene
    end
end
