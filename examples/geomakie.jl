@block AnshulSinghvi ["geo", "geomakie"] begin

    using GeoMakie

    @cell "Geographical axes" [geoaxis, projection] begin

        projections = [
            Projection("+proj=longlat") => "Standard lon-lat",
            Projection("+proj=robin")   => "Robinson",
            Projection("+proj=moll")    => "Molleweide",
            Projection("+proj=vandg")   => "van der Grinten I",
            Projection("+proj=wintri")  => "Winkel Tripel",
        ]

        geoaxis_scenes = Scene[]

        for (projection, titlestr) in projections
            push!(geoaxis_scenes, title(geoaxis(-180, 180, -90, 90; show_axis = false, crs = (dest = projection,), scale_plot = false), titlestr))
        end

        vbox(geoaxis_scenes...; parent = Scene(resolution = (1440, 200)))

    end

    @cell "Earth and Coastlines" [earth, coastlines, geoaxis] begin
        using GeoMakie

        coastlines(; crs = (dest = WinkelTripel(),), show_axis = false, scale_plot = false)
        earth!(; crs = (dest = WinkelTripel(),))
        geoaxis!(-180, 180, -90, 90; crs = (dest = WinkelTripel(),))
    end

    @cell "Air Particulates" [record, animation] begin
        using GeoMakie
        using GeoMakie: ImageMagick, Glob

        source = LonLat()
        dest = WinkelTripel()

        imgdir = observations("rgb/MYDAL2_M_AER_RA")

        imgpaths = sort(Glob.glob("*.PNG", imgdir)) # change this to your requirements

        img = ImageMagick.load(imgpaths[1])

        re = GeoMakie.date_regex("MYDAL2_M_AER_RA", "PNG")
        titletext = Node(join(match(re, basename(imgpaths[1])).captures, '-'))

        lons = LinRange(-179.5, 179.5, size(img)[2])
        lats = LinRange(89.5, -89.5, size(img)[1])

        xs = [lon for lat in lats, lon in lons]
        ys = [lat for lat in lats, lon in lons]

        Proj4.transform!(source, dest, vec(xs), vec(ys))

        scene = surface(xs, ys, zeros(size(xs)); color = img, shading = false, show_axis = false, scale_plot = false)
        surfplot = scene.plots[end]

        geoaxis!(scene, -180, 180, -90, 90; crs = (src = source, dest = dest,));

        titletext = Node("07/2016")

        fullsc = title(scene, titletext; fontsize = 40);

        record(fullsc, @replace_with_a_path(mp4), imgpaths; framerate = 10) do img
            year, month = match(re, img).captures
            surfplot.color = ImageMagick.load(img)
            titletext[] = "$month/$year"
        end

    end

    @cell "MakieLayout with GeoMakie" [layout] begin

        using MakieLayout

        lons = LinRange(-179.5, 179.5, 360)
        lats = LinRange(-89.5, 89.5, 180)

        field = [exp(cosd(l)) + 3(y/90) for l in lons, y in lats]

        source = LonLat()
        dest = WinkelTripel()

        xs, ys = xygrid(lons, lats)
        Proj4.transform!(source, dest, vec(xs), vec(ys))

        xmin, xmax = extrema(xs)
        ymin, ymax = extrema(ys)

        aspect_ratio = (ymax - ymin) / (xmax - xmin)

        scene, layout = layoutscene(
            resolution = (1300, 900)
        )

        layout[1, 1] = lsc = LScene(scene; scenekw = (show_axis = false, scale_plot = false))

        splot = surface!(lsc, xs, ys; color = field, shading = false, show_axis = false)

        geoaxis!(lsc, -180, 180, -90, 90; crs = (src = source, dest = dest,))

        coastlines!(lsc; crs = (src = source, dest = dest,))

        layout[1, 2] = LColorbar(scene, splot; label = "Arbitrary data", width = 30)

        colsize!(layout, 1, Relative(1))
        rowsize!(layout, 1, Aspect(1, aspect_ratio))

        layout[0, :] = LText(scene, "MakieLayout is cool!"; textsize = 40)

        return scene

    end

end
