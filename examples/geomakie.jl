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
        coastlines(; crs = (dest = WinkelTripel(),), show_axis = false, scale_plot = false)
        earth!(; crs = (dest = WinkelTripel(),))
        geoaxis!(-180, 180, -90, 90; crs = (dest = WinkelTripel(),))
    end

    @cell "Longitudes in 0-360" [earth, geomakie] begin

        lons = LinRange(0.5, 359.5, 360) # this is not the recommended way
        lats = LinRange(-89.5, 89.5, 180)

        field = [exp(cosd(l)) + 3(y/90) for l in lons, y in lats]

        cf = circshift(field, 180) # shift the field to the correct position

        source = Projection("+proj=lonlat +lon_0=180 +pm=180")
        dest = Projection("+proj=moll +lon_0=0")

        xs, ys = xygrid(lons, lats)
        Proj4.transform!(source, dest, vec(xs), vec(ys))

        scene = surface(xs, ys; color = cf, shading = false, show_axis = false)

        geoaxis!(scene, -180, 180, -90, 90; crs = (src = source, dest = dest,))

        coastlines!(scene, 1; crs = (src = source, dest = dest,))

    end

    @cell "Simple field over the Earth" [earth, geomakie] begin
        lons = LinRange(-179.5, 179.5, 360)
        lats = LinRange(-89.5, 89.5, 180)

        field = [exp(cosd(l)) + 3(y/90) for l in lons, y in lats]

        source = LonLat()
        dest = WinkelTripel()

        xs, ys = xygrid(lons, lats)
        Proj4.transform!(source, dest, vec(xs), vec(ys))

        scene = surface(xs, ys; color = field, shading = false, show_axis = false, scale_plot = false)

        geoaxis!(scene, -180, 180, -90, 90; crs = (src = source, dest = dest,))

        coastlines!(scene, 1; crs = (src = source, dest = dest,))
    end

    @cell "Air Particulates" [record, animation] begin
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

end
