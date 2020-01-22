@block KimFung [intermediate] begin

    @cell "simple line plot" [lines] begin
        scene = Scene()
        lines!(scene, rand(10), linewidth=3.0, color=:blue)
        lines!(scene, rand(10), linewidth=3.0, color=:red)
        lines!(scene, rand(10), linewidth=3.0, color=:green)
        lines!(scene, rand(10), linewidth=3.0, color=:purple)
        lines!(scene, rand(10), linewidth=3.0, color=:orange)
    end

    @cell "multiple functions" [lines] begin
        scene = Scene()
        x = range(0, stop = 3pi, step = 0.01)
        lines!(scene, x, sin.(x), color = :black)
        lines!(scene, x, cos.(x), color = :blue)
    end

    @cell "animations" [lines] begin
        scene = Scene()
        mytime = Node(0.0)
        f(v, t) = sin(v + t)
        g(v, t) = cos(v + t)
        lines!(scene,lift(t -> f.(range(0, stop = 2pi, length = 50), t), mytime),color = :blue)
        lines!(scene,lift(t -> g.(range(0, stop = 2pi, length = 50), t), mytime),color = :orange)
        record(scene, @replace_with_a_path(mp4), range(0, stop = 4pi, length = 100)) do i
            mytime[] = i
        end
    end

    @cell "parametric plots" [poly] begin
        x = LinRange(0, 2pi, 100)
        poly(Point2f0.(sin.(x), sin.(2x)), color = "orange", strokecolor = "blue", strokewidth = 4)
    end

    @cell "colors" [lines] begin
        lines(1:50, 1:1, linewidth = 20, color = to_colormap(:viridis, 50))
    end

    @cell "image" [image] begin
        import FileIO
        img = Makie.logo()

        image(img, scale_plot = false)
    end

    @cell "attributes" [attributes, lines, color, colormap, linewidth] begin
        scene = Scene()
        lines!(scene, rand(10), color = to_colormap(:viridis, 10), linewidth = 5)
        lines!(scene, rand(20), color = :red, alpha = 0.5)
    end

    @cell "build plot in pieces" [lines] begin
         scene = Scene()
         # initialize the stepper and give it an output destination
         st = Stepper(scene, @replace_with_a_path)
         lines!(scene, rand(50)/3, color = :purple, linewidth = 5)
         step!(st)
         scatter!(scene, rand(50), color = :orange, markersize = 1)
         step!(st)
    end

    @cell "histogram 2d" [histogram] begin
        using StatsMakie
        plot(histogram(nbins = 20), randn(10000), randn(10000))
    end

    @cell "barplot" [barplot] begin
        barplot(randn(99))
    end

    @cell "histogram" [histogram] begin
        using StatsMakie
        plot(histogram, randn(1000))
    end

    @cell "subplots" [lines, scatter, barplot, histogram, vbox, hbox] begin
        scene1, scene2, scene3, scene4 = Scene(), Scene(), Scene(), Scene()
        lines!(scene1, rand(10), color=:red)
        lines!(scene1, rand(10), color=:blue)
        lines!(scene1, rand(10), color=:green)
        scatter!(scene2, rand(10), color=:red)
        scatter!(scene2, rand(10), color=:blue)
        scatter!(scene2, rand(10), color=:orange)
        barplot!(scene3, randn(99))
        plot!(scene4, histogram, randn(1000))
        vbox(hbox(scene2,scene1),hbox(scene4,scene3))
    end

    @cell "text" [scatter, text] begin
        scene = Scene()
        scatter!(scene, rand(10), color=:red)
        text!(scene,"adding text",textsize = 0.6, position = (5.0, 1.1))
    end

    @cell "contours" [contour, fillrange] begin
        x = LinRange(-1, 1, 20)
        y = LinRange(-1, 1, 20)
        z = x .* y'

        vbox(
        contour(x, y, z, levels = 50, linewidth =3),
        contour(x, y, z, levels = 0, linewidth = 0, fillrange = true)
         )
    end

    @cell "3D" [meshscatter, colormap] begin
        x = [2 .* (i/3) .* cos(i) for i in range(0, stop = 4pi, length = 30)]
        y = [2 .* (i/3) .* sin(i) for i in range(0, stop = 4pi, length = 30)]
        z = range(0, stop = 5, length = 30)
        meshscatter(x, y, z, markersize = 0.5, color = to_colormap(:blues, 30))
    end

    @cell "heatmap" [heatmap] begin
        x = LinRange(-1, 1, 40)
        y = LinRange(-1, 1, 40)
        z = x .* y'
        heatmap(x, y, z)
    end

    @cell "label rotation, title location" [lines, axisnames, rotation, legend, position, vbox] begin
        scene = Scene()
        line = lines!(scene, rand(10), linewidth=3.0, color=:red)
        scene[Axis][:names, :axisnames] = ("text","")
        scene[Axis][:names, :rotation] = (1.5pi)
        leg = legend([scene[2]], ["line"], position = (1, -1))
        vbox(line, leg)
    end

    @cell "lines with varying colors" [lines, scatter, vbox, colormap] begin
        t = range(0, stop=1, length=100)
        θ = (6π) .* t
        x = t .* cos.(θ)
        y = t .* sin.(θ)
        p1 = lines(x,y,color=t,colormap=:colorwheel,linewidth= 8,scale_plot= false)
        p2 = scatter(x,y,color=t,colormap=:colorwheel,linewidth= 8,scale_plot= false)
        vbox(p1, p2)
    end

end
