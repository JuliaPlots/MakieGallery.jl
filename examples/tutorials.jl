
@block AnthonyWang [tutorials] begin

    @cell "Tutorial simple scatter" [tutorial, scatter, "2d"] begin
        x = RNG.rand(10)
        y = RNG.rand(10)
        colors = RNG.rand(10)
        scene = scatter(x, y, color = colors)
    end

    @cell "Tutorial markersize" [tutorial, scatter, markersize, "2d"] begin
        x = 1:10
        y = 1:10
        sizevec = x ./ 10
        scene = scatter(x, y, markersize = sizevec)
    end

    @cell "Tutorial simple line" [tutorial, line, "2d"] begin
        x = range(0, stop = 2pi, length = 40)
        f(x) = sin.(x)
        y = f(x)
        scene = lines(x, y, color = :blue)
    end

    @cell "Tutorial adding to a scene" [tutorial, line, scene, markers, "2d"] begin
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

    @cell "Tutorial removing from a scene" [tutorial, line, scene, markers, "2d"] begin
        x = range(0, stop = 2pi, length = 80)
        y1 = sin.(x)
        y2 = exp.(-x) .* cos.(2pi * x)

        scene = lines(x, y1, color = :blue)
        scatter!(scene, x, y1, color = :red, markersize = 0.1)

        lines!(scene, x, y2, color = :black)
        scatter!(scene, x, y2, color = :green, marker = :utriangle, markersize = 0.1)
        # initialize the stepper and give it an output destination
        st = Stepper(scene, @replace_with_a_path)
        step!(st)

        # remove last plot in scene
        delete!(scene, scene[end])
        step!(st)
        # remove second plot in scene
        delete!(scene, scene[2])
        step!(st)
        st
    end

    @cell "Tutorial adjusting scene limits" [tutorial, scene, limits, "2d"] begin
        x = range(0, stop = 10, length = 40)
        y = x
        #= specify the scene limits, note that the arguments for FRect are
            x_min, y_min, x_dist, y_dist,
            therefore, the maximum x and y limits are then x_min + x_dist and y_min + y_dist
        =#
        limits = FRect(-5, -10, 20, 30)

        scene = lines(x, y, color = :blue, limits = limits)

    end

    @cell "Tutorial basic theming" [tutorial, scene, limits, "2d"] begin
        x = range(0, stop = 2pi, length = 40)
        y = cos.(x)
        scene = lines(x, y, color = :blue)

        axis = scene[Axis] # get the axis object from the scene
        axis.grid.linecolor = ((:red, 0.5), (:blue, 0.5))
        axis.names.textcolor = ((:red, 1.0), (:blue, 1.0))
        axis.names.axisnames = ("x", "y = cos(x)")
        scene
    end

    @cell "Tutorial heatmap" [tutorial, heatmap, "2d"] begin
        data = RNG.rand(50, 50)
        scene = heatmap(data)
    end

    @cell "Tutorial linesegments" [tutorial, linesegments, "2d"] begin
        points = [
            Point2f0(0, 0) => Point2f0(5, 5);
            Point2f0(15, 15) => Point2f0(25, 25);
            Point2f0(0, 15) => Point2f0(35, 5);
        ]
        linesegments(points, color = :red, linewidth = 2)
    end

    @cell "Tutorial barplot" [tutorial, barplot, "2d"] begin
        data = sort(randn(100))
        barplot(data)
    end

    @cell "Tutorial title" [tutorial, title, "2d"] begin
        scene = lines(RNG.rand(10), axis=(names=(title="Random lines",),))
    end

    @cell "Tutorial title function" [tutorial, title, "2d"] begin
        scene = lines(RNG.rand(10))
        sc_t = title(scene, "Random lines")
        sc_t
    end

    @cell "Tutorial plot transformation" [tutorial, transformation, "2d"] begin
        data = RNG.rand(10)

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
    #     scene = scatter(RNG.rand(10); markersize = 10px)
    #
    # end

end
