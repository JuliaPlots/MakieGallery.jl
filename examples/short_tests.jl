@block SimonDanisch ["short tests"] begin
    @cell begin
        scene = Scene(raw = true, camera = campixel!)
        text!(
            scene, "boundingbox",
            align = (:left, :center),
            position = (50, 50)
        )
        scale!(scene, Vec3f0(4, 1, 1))
        linesegments!(boundingbox(scene))
        offset = 0
        for a_lign in (:center, :left, :right), b_lign in (:center, :left, :right)
            global offset
            t = text!(
                "boundingbox",
                align = (a_lign, b_lign),
                position = (50, 100 + offset)
            )[end]
            linesegments!(boundingbox(t))
            offset += 50
        end
        scene
    end

    # @cell mesh(IRect(0, 0, 200, 200))

    @cell begin
        r = range(-3pi, stop = 3pi, length = 100)
        s = volume(r, r, r, (x, y, z)-> cos(x) + sin(y) + cos(z), algorithm = :iso, isorange = 0.1f0, show_axis = false)
        v2 = volume!(r, r, r, (x, y, z)-> cos(x) + sin(y) + cos(z), algorithm = :mip, show_axis = false)[end]
        translate!(v2, Vec3f0(6pi, 0, 0))
        s
    end
    @cell poly(IRect(0, 0, 200, 200), strokewidth = 20, strokecolor = :red, color = (:black, 0.4))

    @cell begin
        scene = poly([Rect(0, 0, 20, 20)])
        scatter!(Rect(0, 0, 20, 20), color = :red, markersize = 2)
    end

    @cell scatter(rand(10), color = rand(10), colormap = :Spectral)

    @cell begin
        lines(Rect(0, 0, 1, 1), linewidth = 4, scale_plot = false)
        scatter!([Point2f0(0.5, 0.5)], markersize = 1, marker = 'I', scale_plot = false)
    end

    @cell lines(rand(10), rand(10), color = rand(10), linewidth = 10)
    @cell lines(rand(10), rand(10), color = rand(RGBAf0, 10), linewidth = 10)
    @cell meshscatter(rand(10), rand(10), rand(10), color = rand(10))
    @cell meshscatter(rand(10), rand(10), rand(10), color = rand(RGBAf0, 10))
    @cell scatter(0..1, rand(10), markersize = rand(10) .* 0.1)
    @cell scatter(LinRange(0, 1, 10), rand(10))
    @cell scatter(rand(10), LinRange(0, 1, 10))


    @cell begin
        scene = Scene()
        cam2d!(scene)
        axis2d!(
            scene, IRect(Vec2f0(0), Vec2f0(1)),
            ticks = (
                ranges = ([0.1, 0.2, 0.9], [0.1, 0.2, 0.9]),
                labels = (["😸", "♡", "𝕴"], ["β ÷ δ", "22", "≙"])
            ), raw = true
        )
        center!(scene)
        scene
    end

    @cell begin
        angles = range(0, stop = 2pi, length = 20)
        pos = Point2f0.(sin.(angles), cos.(angles))
        scatter(pos, rotations = -angles , marker = '▲', scale_plot = false)
        scatter!(pos, markersize = 0.02, color = :red, scale_plot = false)
    end
    @cell begin
        using GeometryTypes
        s1 = GLNormalUVMesh(Sphere(Point3f0(0), 1f0))
        mesh(GLNormalUVMesh(Sphere(Point3f0(0), 1f0)), color = rand(50, 50))
        # ugh, bug In GeometryTypes for UVs of non unit spheres.
        s2 = GLNormalUVMesh(Sphere(Point3f0(0), 1f0))
        s2.vertices .= s2.vertices .+ (Point3f0(0, 2, 0),)
        mesh!(s2, color = rand(RGBAf0, 50, 50))
    end
    @cell heatmap(rand(50, 50), colormap = :RdBu, alpha = 0.2)

    @cell arc(Point2f0(0), 10f0, 0f0, pi, linewidth = 20)

    # themes
    @cell scatter(Theme(color = :green), rand(10), rand(10), markersize = 0.1)
    @cell scatter!(Scene(), Theme(color = :green), rand(10), rand(10), markersize = 0.01)
    @cell scatter!(Scene(), Theme(color = :green), rand(10), rand(10))
    @cell scatter(Theme(color = :green), rand(10), rand(10))
    @cell scatter(Theme(color = :green), rand(10), rand(10), markersize = 0.05)

    @cell contour(rand(10, 100))
    @cell contour(rand(100, 10))
    @cell contour(randn(100, 90), levels = 3)

    @cell contour(randn(100, 90), levels = [0.1, 0.5, 0.8])
    @cell contour(randn(100, 90), levels = [0.1, 0.5, 0.8], color = :black)
    @cell contour(randn(33, 30), levels = [0.1, 0.5, 0.9], color = [:black, :green, (:blue, 0.4)], linewidth = 2)
    @cell contour(randn(33, 30), levels = [0.1, 0.5, 0.9], colormap = :Spectral)
    @cell contour(
        rand(33, 30) .* 6 .- 3, levels = [-2.5, 0.4, 0.5, 0.6, 2.5],
        colormap = [(:black, 0.2), :red, :blue, :green, (:black, 0.2)],
        colorrange = (0.2, 0.8)
    )

    @cell lines(Circle(Point2f0(0), Float32(1)); scale_plot = false, resolution = (800, 1000))

    @cell begin
        v(x::Point2{T}) where T = Point2{T}(x[2], 4*x[1])
        streamplot(v, -2..2, -2..2)
    end
    
    @cell lines(-1..1, x -> x^2)
    @cell scatter(-1..1, x -> x^2)
end



#
# a = Point2f0.(200, 150:50:offset)
# b = Point2f0.(0, 150:50:offset)
# c = Point2f0.(500, 150:50:offset)
# yrange = 150:50:offset
# #axis2d!(range(0, stop = 500, length = length(yrange)), yrange)
#
#     import RDatasets
#     singers = RDatasets.dataset("lattice","singer")
#     x = singers[:VoicePart]
#     x2 = sort(collect(unique(x)))
#     xidx = map(x-> findfirst(x2, x), x)
#     boxplot(xidx, singers[:Height], strokewidth = 2, strokecolor = :green)
#     wireframe(Rect(0, 0, 10, 10), linewidth = 10, color = :gray)
#     using Makie
#     scene = poly([Rect(-2, -2, 9, 14)], strokewidth = 0.0, scale_plot = false, color = (:black, 0.4))
#     poly!([Rect(5, 0, -5, 10)], strokewidth = 2, strokecolor = (:gray, 0.4), color = :white, scale_plot = false)
#     histogram(rand(100000))
#     y = rand(10)
#     x = bar(1:10, y, color = y)
