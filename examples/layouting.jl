@block SimonDanisch [layout] begin

    @cell "Layouting" [scatter, lines, surface, heatmap, vbox] begin
        p1 = scatter(rand(10), markersize = 1)
        p2 = lines(rand(10), rand(10))
        p3 = surface(0..1, 0..1, rand(100, 100))
        p4 = heatmap(rand(100, 100))
        x = 0:0.1:10
        p5 = lines(0:0.1:10, sin.(x))
        pscene = vbox(
            hbox(p1, p2),
            p3,
            hbox(p4, p5, sizes = [0.7, 0.3]),
            sizes = [0.2, 0.6, 0.2]
        )
    end

    @cell "Comparing contours, image, surfaces and heatmaps" [image, contour, surface, heatmap, vbox] begin
        N = 20
        x = LinRange(-0.3, 1, N)
        y = LinRange(-1, 0.5, N)
        z = x .* y'
        hbox(
            vbox(
                contour(x, y, z, levels = 20, linewidth =3),
                contour(x, y, z, levels = 0, linewidth = 0, fillrange = true),
                heatmap(x, y, z),
            ),
            vbox(
                image(x, y, z, colormap = :viridis),
                surface(x, y, fill(0f0, N, N), color = z, shading = false),
                image(-0.3..1, -1..0.5, AbstractPlotting.logo())
            )
        )
    end
end

@block JuliusKrumbiegel ["layout"] begin
    using MakieLayout

    @cell "Faceting" [faceting, grid] begin
        # layoutscene is a convenience function that creates a Scene and a GridLayout
        # that are already connected correctly and with Outside alignment
        scene, layout = layoutscene(30, resolution = (1200, 900))

        using ColorSchemes

        ncols = 4
        nrows = 4

        # create a grid of LAxis objects
        axes = [LAxis(scene) for i in 1:nrows, j in 1:ncols]
        # and place them into the layout
        layout[1:nrows, 1:ncols] = axes

        # link x and y axes of all LAxis objects
        linkxaxes!(axes...)
        linkyaxes!(axes...)

        lineplots = [lines!(axes[i, j], (1:0.1:8pi) .+ i, sin.(1:0.1:8pi) .+ j,
                color = get(ColorSchemes.rainbow, ((i - 1) * nrows + j) / (nrows * ncols)), linewidth = 4)
            for i in 1:nrows, j in 1:ncols]

        for i in 1:nrows, j in 1:ncols
            # remove unnecessary decorations in some of the facets, this will have an
            # effect on the layout as the freed up space will be used to make the axes
            # bigger
            i > 1 && (axes[i, j].titlevisible = false)
            j > 1 && (axes[i, j].ylabelvisible = false)
            j > 1 && (axes[i, j].yticklabelsvisible = false)
            j > 1 && (axes[i, j].yticksvisible = false)
            i < nrows && (axes[i, j].xticklabelsvisible = false)
            i < nrows && (axes[i, j].xticksvisible = false)
            i < nrows && (axes[i, j].xlabelvisible = false)
        end

        autolimits!(axes[1]) # hide

        legend = LLegend(scene, permutedims(lineplots, (2, 1)), ["Line $i" for i in 1:length(lineplots)],
            ncols = 2)
        # place a legend on the side by indexing into one column after the current last
        layout[:, end+1] = legend

        # index into the 0th row, thereby adding a new row into the layout and place
        # a text object across the first four columns as a super title
        layout[0, 1:4] = LText(scene, text="MakieLayout Facets", textsize=50)

        scene

    end

    @cell "ManualTicks" [layout, ticks] begin
        scene = Scene(resolution = (1000, 1000));
        campixel!(scene);

        maingl = GridLayout(scene, alignmode = Outside(30))

        la = maingl[1, 1] = LAxis(scene)
        la.attributes.yautolimitmargin = (0f0, 0.05f0)


        poly!(la, BBox(0, 1, 4, 0), color=:blue)
        poly!(la, BBox(1, 2, 7, 0), color=:red)
        poly!(la, BBox(2, 3, 1, 0), color=:green)

        la.attributes.xticks = ManualTicks([0.5, 1.5, 2.5], ["blue", "red", "green"])
        la.attributes.xlabel = "Color"
        la.attributes.ylabel = "Value"

        scene
    end

    @cell "Protrusion changes" [protrusions] begin
        using MakieLayout.Animations

        scene, layout = layoutscene(resolution = (600, 600))

        axes = [LAxis(scene) for i in 1:2, j in 1:2]
        layout[1:2, 1:2] = axes

        a_title = Animation([0, 2], [30.0, 50.0], sineio(n=2, yoyo=true, prewait=0.2))
        a_xlabel = Animation([2, 4], [20.0, 40.0], sineio(n=2, yoyo=true, prewait=0.2))
        a_ylabel = Animation([4, 6], [20.0, 40.0], sineio(n=2, yoyo=true, prewait=0.2))

        record(scene, @replace_with_a_path(mp4), 0:1/60:6, framerate = 60) do t
            axes[1, 1].titlesize = a_title(t)
            axes[1, 1].xlabelsize = a_xlabel(t)
            axes[1, 1].ylabelsize = a_ylabel(t)
        end
    end

    @cell "Hiding decorations" [decorations] begin
        scene = Scene(resolution = (600, 600), camera=campixel!)

        layout = GridLayout(
            scene, 2, 2, # we need to specify rows and columns so the gap sizes don't get lost
            addedcolgaps = Fixed(0),
            addedrowgaps = Fixed(0),
            alignmode = Outside(30)
        )

        axes = [LAxis(scene) for j in 1:2, i in 1:2]
        layout[1:2, 1:2] = axes

        re = record(scene, @replace_with_a_path(mp4), framerate=3) do io
            recordframe!(io)
            for ax in axes
                ax.titlevisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.xlabelvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.ylabelvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.xticklabelsvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.yticklabelsvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.xticksvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.yticksvisible = false
                recordframe!(io)
            end
            for ax in axes
                ax.bottomspinevisible = false
                ax.leftspinevisible = false
                ax.topspinevisible = false
                ax.rightspinevisible = false
                recordframe!(io)
            end
        end
        return re
    end

    @cell "Axis aspects" [axis, aspect] begin
        using FileIO
        scene, layout = layoutscene(30, resolution = (1200, 900))

        axes = [LAxis(scene) for i in 1:2, j in 1:3]
        tightlimits!.(axes)
        layout[1:2, 1:3] = axes

        img = rotr90(MakieGallery.loadasset("cow.png"))

        for ax in axes
            image!(ax, img)
        end

        axes[1, 1].title = "Default"

        axes[1, 2].title = "DataAspect"
        axes[1, 2].aspect = DataAspect()

        axes[1, 3].title = "AxisAspect(418/348)"
        axes[1, 3].aspect = AxisAspect(418/348)

        axes[2, 1].title = "AxisAspect(1)"
        axes[2, 1].aspect = AxisAspect(1)

        axes[2, 2].title = "AxisAspect(2)"
        axes[2, 2].aspect = AxisAspect(2)

        axes[2, 3].title = "AxisAspect(0.5)"
        axes[2, 3].aspect = AxisAspect(0.5)

        scene
    end

    @cell "Linked axes" [axis, link] begin
        scene, layout = layoutscene()

        layout[1, 1:3] = axs = [LAxis(scene) for i in 1:3]
        linkxaxes!(axs[1:2]...)
        linkyaxes!(axs[2:3]...)

        axs[1].title = "x linked"
        axs[2].title = "x & y linked"
        axs[3].title = "y linked"

        for i in 1:3
            lines!(axs[i], 1:10, 1:10, color = "green")
            if i != 1
                lines!(axs[i], 1:10, 11:20, color = "blue")
            end
            if i != 3
                lines!(axs[i], 11:20, 1:10, color = "red")
            end
        end

        scene
    end

    @cell "Nested grids" [grid] begin
        scene, layout = layoutscene(30, resolution = (1200, 900))

        subgl_left = GridLayout()
        subgl_left[1:2, 1:2] = [LAxis(scene) for i in 1:2, j in 1:2]

        subgl_right = GridLayout()
        subgl_right[1:3, 1] = [LAxis(scene) for i in 1:3]

        layout[1, 1] = subgl_left
        layout[1, 2] = subgl_right

        scene
    end

    @cell "Grid alignment" [grid] begin
        scene, layout = layoutscene(30, resolution = (1200, 1200))

        layout[1, 1] = LAxis(scene, title="No grid layout")
        layout[2, 1] = LAxis(scene, title="No grid layout")
        layout[3, 1] = LAxis(scene, title="No grid layout")

        subgl_1 = layout[1, 2] = GridLayout(alignmode=Inside())
        subgl_2 = layout[2, 2] = GridLayout(alignmode=Outside())
        subgl_3 = layout[3, 2] = GridLayout(alignmode=Outside(50))

        subgl_1[1, 1] = LAxis(scene, title="Inside")
        subgl_2[1, 1] = LAxis(scene, title="Outside")
        subgl_3[1, 1] = LAxis(scene, title="Outside(50)")

        layout[1:3, 2] = [LRect(scene, color = :transparent, strokecolor = :red) for i in 1:3]

        scene
    end

    @cell "Spanned grid content" [grid] begin

        scene, layout = layoutscene(4, 4, 30, resolution = (1200, 1200))

        layout[1, 1:2] = LAxis(scene, title="[1, 1:2]")
        layout[2:4, 1:2] = LAxis(scene, title="[2:4, 1:2]")
        layout[:, 3] = LAxis(scene, title="[:, 3]")
        layout[1:3, end] = LAxis(scene, title="[1:3, end]")
        layout[end, end] = LAxis(scene, title="[end, end]")

        scene
    end

    @cell "Indexing outside grid" [grid] begin
        scene, layout = layoutscene(30, resolution = (1200, 1200))

        layout[1, 1] = LAxis(scene)
        for i in 1:3
            layout[:, end+1] = LAxis(scene)
            layout[end+1, :] = LAxis(scene)
        end

        layout[0, :] = LText(scene, text="Super Title", textsize=50)
        layout[end+1, :] = LText(scene, text="Sub Title", textsize=50)
        layout[2:end-1, 0] = LText(scene, text="Left Text", textsize=50,
        rotation=pi/2)
        layout[2:end-1, end+1] = LText(scene, text="Right Text", textsize=50,
        rotation=-pi/2)

        scene
    end

    @cell "Column and row sizes" [grid] begin
        scene = Scene(resolution = (1200, 900), camera=campixel!)

        layout = GridLayout(
        scene, 6, 6,
        colsizes = [Fixed(200), Relative(0.25), Auto(), Auto(), Auto(2), Auto()],
        rowsizes = [Auto(), Fixed(100), Relative(0.25), Aspect(2, 1), Auto(), Auto()],
        alignmode = Outside(30, 30, 30, 30))


        for i in 2:6, j in 1:5
            if i == 6 && j == 3
                layout[i, j] = LText(scene, text="My Size is Inferred")
            else
                layout[i, j] = LRect(scene)
            end
        end

        for (j, label) in enumerate(["Fixed(200)", "Relative(0.25)", "Auto()", "Auto()", "Auto(2)"])
            layout[1, j] = LText(scene, width = Auto(false), text = label)
        end

        for (i, label) in enumerate(["Fixed(100)", "Relative(0.25)", "Aspect(2, 1)", "Auto()", "Auto()"])
            layout[i + 1, 6] = LText(scene, height = Auto(false), text = label)
        end

        scene
    end

    @cell "Trimming grids" [grid] begin

        scene, layout = layoutscene(resolution = (600, 600))

        record(scene, @replace_with_a_path(mp4), framerate=1) do io

            ax1 = layout[1, 1] = LAxis(scene, title = "Axis 1")
            recordframe!(io)

            ax2 = layout[1, 2] = LAxis(scene, title = "Axis 2")
            recordframe!(io)

            layout[2, 1] = ax2
            recordframe!(io)

            trim!(layout)
            recordframe!(io)

            layout[2, 3:4] = ax1
            recordframe!(io)

            trim!(layout)
            recordframe!(io)
        end
    end
    
    @cell "3D scenes" ["3d"] begin
        scene, layout = layoutscene()
        makescene() = LScene(scene, camera = cam3d!, raw = false,
            scenekw = (backgroundcolor = RGBf0(0.9, 0.9, 0.9), clear = true))
        layout[1, 1]   = makescene()
        layout[1, 2]   = makescene()
        layout[2, 1:2] = makescene()
        layout[1:2, 3] = makescene()
        foreach(LScene, layout) do s
            scatter!(s, rand(100, 3));
        end
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
end
