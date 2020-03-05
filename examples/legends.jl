@block JuliusKrumbiegel ["legend"] begin
    using MakieLayout
    @cell "Basic legend" [legend] begin
        using AbstractPlotting: px

        scene, layout = layoutscene(resolution = (1400, 900))

        ax = layout[1, 1] = LAxis(scene)

        xs = 0:0.5:10
        ys = sin.(xs)
        lin = lines!(ax, xs, ys, color = :blue)
        sca = scatter!(ax, xs, ys, color = :red, markersize = 15px)

        leg = LLegend(scene, [lin, sca], ["a line", "some dots"])
        layout[1, 2] = leg

        # you can add more elements using push!
        push!(leg, "both together", lin, sca)

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
        lins = [lines!(ax, xs, sin.(xs .* i), color = color)
        for (i, color) in zip(1:3, [:red, :blue, :green])]

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

        leg = layout[1, 1] = LLegend(scene)

        entry1 = LegendEntry(
            "Entry 1",
            LineElement(color = :red, linestyle = nothing),
            MarkerElement(color = :blue, marker = 'x', strokecolor = :black),
        )

        entry2 = LegendEntry(
            "Entry 2",
            PolyElement(color = :red, strokecolor = :blue),
            LineElement(color = :black, linestyle = :dash),
        )

        entry3 = LegendEntry(
            "Entry 3",
            LineElement(color = :green, linestyle = nothing,
                linepoints = Point2f0[(0, 0), (0, 1), (1, 0), (1, 1)])
        )

        entry4 = LegendEntry(
            "Entry 4",
            MarkerElement(color = :blue, marker = 'π',
                strokecolor = :transparent,
                markerpoints = Point2f0[(0.2, 0.2), (0.5, 0.8), (0.8, 0.2)])
        )

        entry5 = LegendEntry(
            "Entry 5",
            PolyElement(color = :green, strokecolor = :black,
                polypoints = Point2f0[(0, 0), (1, 0), (0, 1)])
        )

        push!(leg, entry1)
        push!(leg, entry2)
        push!(leg, entry3)
        push!(leg, entry4)
        push!(leg, entry5)

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
end
