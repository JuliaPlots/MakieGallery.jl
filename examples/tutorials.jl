
@block AnthonyWang [tutorials] begin

    @cell "Tutorial simple scatter" [tutorial, scatter] begin
        x = rand(10)
        y = rand(10)
        colors = rand(10)
        scene = scatter(x, y, color = colors)
    end

    @cell "Tutorial markersize" [tutorial, scatter, markersize] begin
        x = 1:10
        y = 1:10
        sizevec = [s for s = 1:length(x)] ./ 10
        scene = scatter(x, y, markersize = sizevec)
    end

    @cell "Tutorial simple line" [tutorial, line] begin
        x = range(0, stop = 2pi, length = 40)
        f(x) = sin.(x)
        y = f(x)
        scene = lines(x, y, color = :blue)
    end

    @cell "Tutorial adding to a scene" [tutorial, line, scene, markers] begin
        x = range(0, stop = 2pi, length = 80)
        f1(x) = sin.(x)
        f2(x) = exp.(-x) .* cos.(2pi*x)
        y1 = f1(x)
        y2 = f2(x)

        scene = lines(x, y1, color = :blue)
        scatter!(scene, x, y1, color = :red, markersize = 0.1)

        lines!(scene, x, y2, color = :black)
        scatter!(scene, x, y2, color = :green, marker = :utriangle, markersize = 0.1)
    end

    @cell "Tutorial removing from a scene" [tutorial, line, scene, markers] begin
        x = range(0, stop = 2pi, length = 80)
        f1(x) = sin.(x)
        f2(x) = exp.(-x) .* cos.(2pi*x)
        y1 = f1(x)
        y2 = f2(x)

        scene = lines(x, y1, color = :blue)
        scatter!(scene, x, y1, color = :red, markersize = 0.1)

        lines!(scene, x, y2, color = :black)
        scatter!(scene, x, y2, color = :green, marker = :utriangle, markersize = 0.1)
        # initialize the stepper and give it an output destination
        st = Stepper(scene, @replace_with_a_path)
        step!(st)

        pop!(scene.plots)
        step!(st)

        pop!(scene.plots)
        step!(st)
    end

    @cell "Tutorial adjusting scene limits" [tutorial, scene, limits] begin
        x = range(0, stop = 10, length = 40)
        y = x
        #= specify the scene limits, note that the arguments for FRect are
            x_min, y_min, x_dist, y_dist,
            therefore, the maximum x and y limits are then x_min + x_dist and y_min + y_dist
        =#
        limits = FRect(-5, -10, 20, 30)

        scene = lines(x, y, color = :blue, limits = limits)

    end

    @cell "Tutorial basic theming" [tutorial, scene, limits] begin
        x = range(0, stop = 2pi, length = 40)
        f(x) = cos.(x)
        y = f(x)
        scene = lines(x, y, color = :blue)

        axis = scene[Axis] # get the axis object from the scene
        axis.grid.linecolor = ((:red, 0.5), (:blue, 0.5))
        axis.names.textcolor = ((:red, 1.0), (:blue, 1.0))
        axis.names.axisnames = ("x", "y = cos(x)")
        scene
    end

    @cell "Tutorial heatmap" [tutorial, heatmap] begin
        data = rand(50, 50)
        scene = heatmap(data)
    end

    @cell "Tutorial linesegments" [tutorial, linesegments] begin
        points = [
            Point2f0(0, 0) => Point2f0(5, 5);
            Point2f0(15, 15) => Point2f0(25, 25);
            Point2f0(0, 15) => Point2f0(35, 5);
            ]
        scene = linesegments(points, color = :red, linewidth = 2)
    end

    @cell "Tutorial barplot" [tutorial, barplot] begin
        data = sort(randn(100))
        barplot(data)
    end

    @cell "Tutorial title" [tutorial, title] begin

        scene = lines(rand(10))

        sc_t = title(scene, "Random lines")

        sc_t

    end

    @cell "Tutorial plot transformation" [tutorial, transformation] begin
        data = rand(10)

        scene = Scene()
        st = Stepper(scene, @replace_with_a_path)
        lineplot = lines!(scene, data)[end]    # gets the last defined plot for the Scene
        scatplot = scatter!(scene, data)[end]  # same thing but the last defined plot is scatter
        step!(st)

        rotate!(lineplot, 0.025π) # only the lines are rotated, not the scatter
        step!(st)
        st
    end

    # @cell "Tutorial markersizes" [tutorial, markersize, scatter] begin
    #
    #     scene = scatter(rand(10); markersize = 10px)
    #
    # end

end
@block "AkshatMehrotra" [tutorials] begin
    @cell "attribute usage : shading" [tutorial, mesh] begin
        using GeometryTypes
            scene = mesh(
                HyperRectangle(Vec3f0(1, 1, 1), Vec3f0(1, 1, 3)),
                color = (:green, 0.4),
                show_axis = false,
                shading = false,
                center = false,
            )
            scene
    end
    @cell "attribute usage : colormap, color, colorrange, linestyle, linewidth, align, pos, textsize, rotation" [tutorial, lines, text, colormap, color, colorrange, linestyle, linewidth, align, pos, textsize, rotation] begin

        scene = Scene()
        y = 200 * rand(300)
        x = range(0, 600, length = 300)
        c = range(1, stop = 0, length = 600)
        lines!(
            scene,
            x,
            y,
            colormap = :BuPu,
            color = c,
            colorrange=(1,0.5),
            linestyle = :dashdotdot,
            linewidth = 3.0,
        )
        text!(
            scene,
            "Red Dead Redemption 2 is the best game ever!",
            align = (:left, :center),
            position = (0, -100),
            color = :red,
            font = "Blackchancery",
            textsize = 70,
            rotation = pi / 6,
        )
        scene
    end
    @cell "attribute usage : markersize, strokecolor, strokewidth, glowcolor, glowwidth, marker, marker offset" [tutorial, scatter, markersize, strokecolor, strokewidth, glowcolor, glowwidth, marker, marker offset] begin
        scene = Scene()
        points = Point2f0[(i, i) for i = 1:6]
        offset = rand(Point2f0, length(points)) ./ 5
        scatter!(
            scene,
            points,
            color = :gray,
            markersize = 0.2,
            strokecolor = :pink,
            strokewidth = 8,
            marker = :x,
        )
        scatter!(
            scene,
            points,
            glowcolor = :red,
            color = :black,
            marker_offset = offset,
            markersize = 1,
            glowwidth = 5.0,
            marker = :+,
        )
        scene
    end
    @cell "attributes usage : visible" [tutorial, scatter, text, visible]
        scene = Scene()
        y = rand(3)
        scatter!(scene, y, visible = false)
        text!(
            scene,
            "The above plot is not visible!",
        )
        scene
    end
    @cell "attribute usage : interpolate" [tutorial, heatmap, image, interpolate]
        source_img = load(download("https://images-na.ssl-images-amazon.com/images/I/41OEdd1En8L._SX322_BO1,204,203,200_.jpg"))
        img = Float32.(channelview(Gray.(source_img)))
        heatmap!(scene, img, interpolate = true)
        scene
    end
    @cell "attribute usage : absorption, algorithm" [tutorial, volume, absorption, algorithm]
        scene = Scene()
        volume!(scene, rand(50, 50, 50), algorithm = :absorption, absorption = 7.0f0)
        scene
    end
    @cell "attribute usage : isorange, isovalue" [tutorial, volume, isorange, isovalue]
        scene = Scene()
        source_img = load(download("https://images-na.ssl-images-amazon.com/images/I/41OEdd1En8L._SX322_BO1,204,203,200_.jpg"))
        img = Float32.(channelview(source_img))
        volume!(scene, img, isorange = 0.012f0, isovalue = 0.3f0)
        scene
    end
    @cell "attribute usage : levels" [contour, levels]
        N = 20
        x = range(-0.5, stop = 0.5, length = N)
        y = range(-0.5, stop = 0.5, length = N)
        z = x .* y'
        a = contour(x, y, z, levels = 100, colormap = :magma, fillrange = true)
        a
    end
end
