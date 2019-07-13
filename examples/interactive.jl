@block SimonDanisch [interaction, record_events] begin
    @cell "Interaction with Mouse" [interactive, camera, scatter, lines, marker, record] begin
        using LinearAlgebra
        scene = Scene(raw = true, camera = cam2d!, resolution = (500, 500))
        r = range(0, stop = 3, length = 4)
        the_time = Node(time())
        last_open = false
        @async while true
            global last_open
            the_time[] = time()
            # this is a bit awkward, since the isopen(scene) is false
            # as long as the scene isn't displayed
            last_open && !isopen(scene) && break
            last_open = isopen(scene)
            sleep(1/25)
        end
        pos = lift(scene.events.mouseposition, the_time) do mpos, t
            map(LinRange(0, 2pi, 60)) do i
                circle = Point2f0(sin(i), cos(i))
                mouse = to_world(scene, Point2f0(mpos))
                secondary = (sin((i * 10f0) + t) * 0.09) * normalize(circle)
                (secondary .+ circle) .+ mouse
            end
        end
        lines!(scene, pos)
        p1 = scene[end]
        p2 = scatter!(
            scene,
            pos, markersize = 0.1f0,
            marker = :star5,
            color = p1[:color],
        )[end]
        center!(scene)
        t = Theme(raw = true, camera = campixel!)
        b1 = button(t, "color")
        b2 = button(t, "marker")
        msize = slider(t, 0.1:0.01:0.5)
        on(b1[end][:clicks]) do c
            p1[:color] = rand(RGBAf0)
        end
        markers = ('π', '😹', '⚃', '◑', '▼')
        on(b2[end][:clicks]) do c
            p2[:marker] = markers[rand(1:5)]
        end
        on(msize[end][:value]) do val
            p2[:markersize] = val
        end
        RecordEvents(hbox(
            vbox(b1, b2, msize),
            scene
        ), @replace_with_a_path)
    end

    @cell "Mouse Picking" [scatter, heatmap, interactive] begin
        img = rand(100, 100)
        scene = Scene(resolution = (500, 500))
        heatmap!(scene, img, scale_plot = false)
        clicks = Node(Point2f0[(0,0)])
        on(scene.events.mousebuttons) do buttons
           if ispressed(scene, Mouse.left)
               pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
               push!(clicks, push!(clicks[], pos))
           end
           return
        end
        scatter!(scene, clicks, color = :red, marker = '+', markersize = 10)
        RecordEvents(scene, @replace_with_a_path)
    end

    @cell "sliders" [scatter, slider, vbox] begin
        s1 = slider(LinRange(0.01, 1, 100), raw = true, camera = campixel!, start = 0.3)
        s2 = slider(LinRange(-2pi, 2pi, 100), raw = true, camera = campixel!)
        data = lift(s2[end][:value]) do v
            map(LinRange(0, 2pi, 100)) do x
                4f0 .* Point2f0(sin(x) + (sin(x * v) .* 0.1), cos(x) + (cos(x * v) .* 0.1))
            end
        end
        p = scatter(data, markersize = s1[end][:value])

        RecordEvents(
            hbox(p, vbox(s1, s2), parent = Scene(resolution = (500, 500))),
            @replace_with_a_path
        )
    end

    @cell "Mouse Hover" [lines, hover, lift, poly, translate, text, popup, on] begin
        using Colors, Observables
        r = range(0, stop=5pi, length=100)
        scene = Scene(resolution = (500, 500))
        lines!(scene, r, sin.(r), linewidth = 3)
        lineplot = scene[end]
        visible = node(:visible, false)
        poprect = lift(scene.events.mouseposition) do mp
            FRect((mp .+ 5), 250, 40)
        end
        textpos = lift(scene.events.mouseposition) do mp
            Vec3f0((mp .+ 5 .+ (250/2, 40 / 2))..., 120)
        end
        popup = poly!(campixel(scene), poprect, raw = true, color = :white, strokewidth = 2, strokecolor = :black, visible = visible)
        rect = popup[end]
        translate!(rect, Vec3f0(0, 0, 100))
        text!(popup, "( 0.000,  0.000)", textsize = 30, position = textpos, color = :darkred, align = (:center, :center), raw = true, visible = visible)
        text_field = popup[end]
        scene
        x = Node(false)
        on(scene.events.mouseposition) do event
            plot, idx = mouse_selection(scene)
            if plot == lineplot && idx > 0
                visible[] = true
                text_field[1] = sprint(io-> print(io, round.(Float64.(Tuple(lineplot[1][][idx])), digits = 3)))
            else
                visible[] = false
            end
            return
        end
        RecordEvents(scene, @replace_with_a_path)
    end

    @cell "GUI for exploring Lorenz equation" [vbox, hbox, meshscatter, slider, textslider, colorswatch] begin
        using Colors
        using AbstractPlotting: textslider, colorswatch
        s1, a = textslider(0f0:50f0, "a", start = 13)
        s2, b = textslider(-20f0:20f0, "b", start = 10)
        s3, c = textslider(0f0:20f0, "c", start = 2)
        s4, d = textslider(range(0.0, stop = 0.02, length = 100), "d", start = 0.01)
        s5, scales = textslider(range(0.01, stop = 0.5, length = 100), "scale", start = 0.1)
        s6, colorsw, pop = colorswatch()

        function lorenz(t0, a, b, c, h)
            Point3f0(
                t0[1] + h * a * (t0[2] - t0[1]),
                t0[2] + h * (t0[1] * (b - t0[3]) - t0[2]),
                t0[3] + h * (t0[1] * t0[2] - c * t0[3]),
            )
        end
        # step through the `time`
        function lorenz(array::Vector, a = 5.0 ,b = 2.0, c = 6.0, d = 0.01)
            t0 = Point3f0(0.1, 0, 0)
            for i = eachindex(array)
                t0 = lorenz(t0, a,b,c,d)
                array[i] = t0
            end
            array
        end
        n1, n2 = 18, 30
        N = n1*n2
        args_n = (a, b, c, d)
        v0 = lorenz(zeros(Point3f0, N), to_value.(args_n)...)
        positions = lift(lorenz, Node(v0), args_n...)
        rotations = lift(diff, positions)
        rotations = lift(x-> push!(x, x[end]), rotations)

        mesh_scene = meshscatter(
            positions,
            markersize = scales, rotation = rotations,
            intensity = collect(range(0f0, stop = 1f0, length = length(positions[]))),
            color = colorsw
        )
        parent = Scene(resolution = (1000, 800))
        vbox(
            hbox(s1, s2, s3, s4, s5, s6),
            mesh_scene, parent = parent
        )
        RecordEvents(parent, @replace_with_a_path)
    end

    @cell "Edit Polygon" [poly, node, on, events] begin
        points = node(:poly, Point2f0[(0, 0), (0.5, 0.5), (1.0, 0.0)])
        scene = Scene(resolution = (500, 500))
        poly!(scene, points, strokewidth = 2, strokecolor = :black, color = :skyblue2, show_axis = false, scale_plot = false)
        scatter!(points, color = :white, strokewidth = 10, markersize = 0.05, strokecolor = :black, raw = true)
        pplot = scene[end]
        push!(points[], Point2f0(0.6, -0.3))
        points[] = points[]
        function add_move!(scene, points, pplot)
            idx = Ref(0); dragstart = Ref(false); startpos = Base.RefValue(Point2f0(0))
            on(events(scene).mousedrag) do drag
                if ispressed(scene, Mouse.left)
                    if drag == Mouse.down
                        plot, _idx = mouse_selection(scene)
                        if plot == pplot
                            idx[] = _idx; dragstart[] = true
                            startpos[] = to_world(scene, Point2f0(scene.events.mouseposition[]))
                        end
                    elseif drag == Mouse.pressed && dragstart[] && checkbounds(Bool, points[], idx[])
                        pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
                        points[][idx[]] = pos
                        points[] = points[]
                    end
                else
                    dragstart[] = false
                end
                return
            end
        end

        function add_remove_add!(scene, points, pplot)
            on(events(scene).mousebuttons) do but
                if ispressed(but, Mouse.left) && ispressed(scene, Keyboard.left_control)
                    pos = to_world(scene, Point2f0(events(scene).mouseposition[]))
                    push!(points[], pos)
                    points[] = points[]
                elseif ispressed(but, Mouse.right)
                    plot, idx = mouse_selection(scene)
                    if plot == pplot && checkbounds(Bool, points[], idx)
                        deleteat!(points[], idx)
                        points[] = points[]
                    end
                end
                return
            end
        end
        add_move!(scene, points, pplot)
        add_remove_add!(scene, points, pplot)
        center!(scene)
        RecordEvents(scene, @replace_with_a_path)
    end

    @cell "Add and change points" [heatmap, on, ispressed, to_world, scatter, center] begin
        using LinearAlgebra
        img = rand(100, 100)
        scene = Scene(scale_plot = false, resolution = (500, 500))
        heatmap!(scene, img)
        clicks = Node(Point2f0[(0, 0)])
        blues = Node(Point2f0[])
        on(scene.events.mousebuttons) do buttons
            if ispressed(scene, Mouse.left)
                pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
                found = -1
                c = clicks[]
                for i in 1:length(c)
                   if norm(pos - c[i]) < 1
                       found = i
                   end
                end
                if found >= 1
                    blues[] = push!(blues[], pos)
                    deleteat!(clicks[], found)
                else
                    push!(clicks[], pos)
                end
                clicks[] = clicks[]
           end
           return
        end
        t = Theme(markersize = 10, raw = true)
        scatter!(scene, t, clicks, color = :red, marker = '+')
        red_clicks = scene[end]
        scatter!(scene, t, blues, color = :blue, marker = 'o')
        center!(scene)
        RecordEvents(scene, @replace_with_a_path)
    end
    @cell "Orbit Diagram" [scatter, slider] begin
        # example by @datseris
        using Observables
        growth(🐇, 🥕) = 🐇 * 🥕 * (1.0 - 🐇)
        function orbitdiagram(growth, r1, r2, n = 500, a = zeros(1000, n); T = 1000)
            rs = range(r1, stop = r2, length = 1000)
            for (j, r) in enumerate(rs)
                x = 0.5
                for _ in 1:T; x = growth(x, r); end
                for i in 1:n
                    x = growth(x, r)
                    @inbounds a[j, i] = x
                end
            end
            rs, a
        end
        r1 = slider(0:0.001:4, raw = true, camera=campixel!, start = 0.0)
        r2 = slider(0:0.001:4, raw = true, camera=campixel!, start = 4)
        n1 = 500; n2 = 1000; a = zeros(n2, n1)
        positions = Vector{Point2f0}(undef, n1 * n2)
        r1node, r2node = r1[end][:value], r2[end][:value]
        r1r2 = async_latest(lift(tuple, r1node, r2node))
        pos = lift(r1r2) do (r1, r2,)
            global a
            rs, a = orbitdiagram(growth, r1, r2, size(a, 2), a)
            dim = size(a, 2)
            for (i, r) in enumerate(rs)
                positions[((i-1)*dim) + 1 : (i*dim)] .= Point2f0.(r, view(a, i, :))
            end
            positions
        end
        p = scatter(
            pos, markersize = 0.006, color = (:black, 0.2),
            show_axis = false
        )
        onany(pos) do pos
            # faster to give the boundingbox ourselves, since otherwise we'll need to
            # loop over pos!
            #AbstractPlotting.update_limits!(p) # <- would calculate bb
            AbstractPlotting.update_limits!(p, FRect(r1node[], 0, r2node[] - r1node[], 1))
            AbstractPlotting.update!(p)
        end
        scene = hbox(
            p,
            vbox(r1, r2)
        )
        RecordEvents(scene, @replace_with_a_path)
    end


    @cell "Robot Arm" [slider, interactive, linesegments, vbox] begin

        using AbstractPlotting: Mesh, Scene, LineSegments, translate!, rotate!, vbox, hbox, qrotation, mesh!
        using GeometryTypes: HyperRectangle, Vec3f0, Point3f0, Sphere
        using StaticArrays: SVector
        using AbstractPlotting: textslider
        using Observables: on

        """
            example by @pbouffard from JuliaPlots/Makie.jl#307
            https://github.com/pbouffard/miniature-garbanzo/
        """

        function triad!(scene, len; translation = (0f0,0f0,0f0), show_axis = false)
            ret = linesegments!(
                scene, [
                    Point3f0(0,0,0) => Point3f0(len,0,0),
                    Point3f0(0,0,0) => Point3f0(0,len,0),
                    Point3f0(0,0,0) => Point3f0(0,0,len)
                ],
                color = [:red, :green, :blue],
                linewidth = 3, show_axis = show_axis
            )[end]
            translate!(ret, translation)
            return ret
        end
        # Joint vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        mutable struct Joint
            scene::Scene
            triad::LineSegments
            # link::Mesh
            angle::Float32
            axis::Vec3f0
            offset::Vec3f0
        end

        s = Scene()

        function Joint(s::Scene)
            newscene = Scene(s)
            triad = triad!(newscene, 1)
            Joint(newscene, triad, 0f0, (0, 1, 0), (0, 0, 0))
        end

        function Joint(j::Joint; offset::Point3f0=(0,0,0), axis=(0, 1, 0), angle=0)
            jnew = Joint(j.scene)
            translate!(jnew.scene, j.offset)
            linesegments!(jnew.scene, [Point3f0(0) => offset], linewidth=4, color=:magenta, show_axis=false)
            jnew.axis = axis
            jnew.offset = offset
            setangle!(jnew, angle)
            return jnew
        end

        function setangle!(j::Joint, angle::Real)
            j.angle = angle
            rotate!(j.scene, qrotation(j.axis, angle))
        end

        # Joint ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        joints = Vector{Joint}()
        links = Float32[5, 5]
        #triad!(s, 10; show_axis=true)

        push!(joints, Joint(s))
        joints[1].axis = (0,0,1) # first joint is yaw
        joints[1].offset = (0, 0, 1)
        push!(joints, Joint(joints[end]; offset=Point3f0(3,0,0), axis=(0,1,0), angle=-pi/4)) # Pitch
        push!(joints, Joint(joints[end]; offset=Point3f0(3,0,0), axis=(0,1,0), angle=pi/2)) # Pitch
        push!(joints, Joint(joints[end]; offset=Point3f0(1,0,0), axis=(0,1,0), angle=-pi/4)) # Pitch
        push!(joints, Joint(joints[end]; offset=Point3f0(1,0,0), axis=(0,0,1))) # Yaw
        push!(joints, Joint(joints[end]; offset=Point3f0(0,0,0), axis=(1,0,0))) # Roll

        sliders = []
        vals = []
        for i = 1:length(joints)
            slider, val = textslider(-180.0:1.0:180.0, "Joint $(i)", start=rad2deg(joints[i].angle))
            push!(sliders, slider)
            push!(vals, val)
            on(val) do x
                setangle!(joints[i], deg2rad(x))
            end
        end

        # Add sphere to end effector:
        mesh!(joints[end].scene, Sphere(Point3f0(0.5, 0, 0), 0.25f0), color=:cyan, show_axis=false)
        center!(s)
        RecordEvents(vbox(hbox(sliders...), s), @replace_with_a_path)
    end

    @cell "Earth & Ships" [slider, interactive, lines, mesh, vbox] begin

        using AbstractPlotting: textslider
        using GeometryTypes, FileIO
        using LinearAlgebra

        """
            example by @pbouffard from JuliaPlots/Makie.jl#307
            https://github.com/pbouffard/miniature-garbanzo/
        """

        const rearth_km = 6371.1f0
        const mearth_kg = 5.972e24
        const rmoon_km = 1738.1f0
        const mmoon_kg = 7.34e22
        const rship_km = 500f0
        const mship_kg = 1000.0
        const dbetween_km = 378_000.0f0
        const radius_mult = 1.0f0
        const timestep = 1.0f0

        mutable struct Ship
            mass_kg::Float32
            position_m::Vec3f0
            velocity_mps::Vec3f0
            color::Symbol
            mesh::Mesh
        end


        function moveto!(ship::Ship, (x, y, z))
            ship.position_m = Vec3f0(x, y, z)
            translate!(ship.mesh, x, y, z)
            ship.position_m, ship.velocity_mps
        end

        function orbit(r; steps=80)
            return [Point3f0(r*cos(x), r*sin(x), 0) for x in range(0, stop=2pi, length=steps)]
        end

        function loadordownload(localfname, url)
            return isfile(localfname) ? load(localfname) : load(download(url, localfname))
        end

        # http://corysimon.github.io/articles/uniformdistn-on-sphere/
        function makestars(n)
            return map(1:n) do i
                v = [0, 0, 0]  # initialize so we go into the while loop
                while norm(v) < .0001
                    v = randn(Point3f0)
                end
                v = v / norm(v)  # normalize to unit norm
                v
            end
        end

        function makecontrols()
            orbit_slider, orbit_speed = textslider(0f0:10f0, "Speed", start=1.0)
            scale_slider, scale = textslider(1f0:20f0, "Scale", start=10.0)
            return orbit_slider, orbit_speed, scale_slider, scale
        end


        function makeships(scene, N)
            return map(1:N) do i
                sm = mesh!(scene, Sphere(Point3f0(0), rship_km*radius_mult), color=:green, show_axis=false)[end]
                ship = Ship(mship_kg, [0, 0, 0], [0, 0, 0], :green, sm)
                moveto!(ship, (100000f0 * randn(Float32), dbetween_km/2 + randn(Float32) * 50000f0, 50000f0*randn(Float32)))
                ship.velocity_mps = [40000*randn(Float32), -1000*randn(Float32), 1000*randn(Float32)]
                ship
            end
        end

        function makeobjects(scene)
            earthfname = "bluemarble-2048.png"
            earthurl = "https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/" * earthfname
            earthbitmap = loadordownload(earthfname, earthurl)
            earth = mesh!(scene, Sphere(Point3f0(0), rearth_km*radius_mult), color=earthbitmap)[end]

            moonfname = "phases.0001_print.jpg"
            moonurl = "https://svs.gsfc.nasa.gov/vis/a000000/a004600/a004675/" * moonfname
            moonbitmap = loadordownload(moonfname, moonurl)
            moon = mesh!(scene, Sphere(Point3f0(0), rmoon_km*radius_mult), color=moonbitmap)[end]
            translate!(moon, Vec3f0(0, dbetween_km, 0))
            orb = lines!(scene, orbit(dbetween_km), color=:gray)
            # stars = scatter!(1000000*makestars(1000), color=:white, markersize=2000)

            return earth, moon #, stars#, ships
        end

        function spin(scene, orbit_speed, scale, moon, earth, ships)
            center!(scene) # update far / near automatically.
            # could also be done manually:
            # cam.near[] = 100
            # cam.far[] = 1.5*dbetween_km
            update_cam!(scene, Vec3f0(1.3032e5, 7.12119e5, 3.60022e5), Vec3f0(0, 0, 0))
            θ = 0.0
            # wait untill window is open
            while !isopen(scene)
                sleep(0.1)
            end
            while isopen(scene)
                scale!(moon, (scale[], scale[], scale[]))
                scale!(earth, (scale[], scale[], scale[]))
                for ship in ships
                    scale!(ship.mesh, (scale[], scale[], scale[]))
                end
                translate!(moon, Vec3f0(-dbetween_km*sin(θ/28), dbetween_km*cos(θ/28), 0))
                rotate!(earth, Vec3f0(0, 0, 1), θ)
                rotate!(moon, Vec3f0(0, 0, 1), π/2 + θ/28)
                sleep(0.01)
                θ += 0.05 * orbit_speed[]
                timestep = 10 * orbit_speed[]
                gravity(timestep, ships, earth, moon)
            end
        end

        function gravity(timestep, ships, earth, moon)
            for ship in ships
                rship = ship.position_m #translation(ship)[]
                rearth = translation(earth)[]
                rmoon = translation(moon)[]
                rship_earth = (rearth - rship) * 1e3 # convert to m
                rship_moon = (rmoon - rship) * 1e3 # convert to m
                G = 6.67408e-11 # m^3⋅kg^-2⋅s^-1
                nrship_earth = max(0.1, norm(rship_earth))
                nrship_moon = max(0.1, norm(rship_moon))
                fearth = G * (mship_kg * mearth_kg)/(nrship_earth^2) * rship_earth/nrship_earth
                fmoon = G * (mship_kg * mmoon_kg)/(nrship_moon^2) * rship_earth/nrship_earth
                ftot = fearth + fmoon
                ship.velocity_mps += timestep * ftot
                drship = timestep * ship.velocity_mps / 1e3
                rship = rship + drship
                moveto!(ship, rship)
            end
        end
        universe = Scene(backgroundcolor=:black, show_axis=false, resolution=(2048,1024))
        ships = makeships(universe, 600)
        earth, moon = makeobjects(universe);
        orbit_slider, orbit_speed, scale_slider, scale = makecontrols();
        controls = (orbit_slider, scale_slider);
        scene = hbox(vbox(controls...), universe)
        universe.center = false
        task = @async spin(universe, orbit_speed, scale, moon, earth, ships)
        scene.center = false
        RecordEvents(scene, @replace_with_a_path)
    end

end

function record_example_events()
    eval_examples(:record_events, :scatter, :slider, :interactive, outputfile = event_path) do example, value
        record_events(value.scene, value.path) do
            wait(value.scene)
        end
    end
end
function record_example(title = "Orbit Diagram")
    set_theme!(resolution = (500, 500))
    idx = findfirst(x-> x.title == title, database)
    entry = database[idx]
    value = MakieGallery.eval_example(entry, outputfile = MakieGallery.event_path)
    last = AbstractPlotting.use_display[]
    AbstractPlotting.inline!(false)
    record_events(value.scene, value.path) do
        wait(value.scene)
    end
    AbstractPlotting.use_display[] = last
end
# record_example("Interactive Differential Equation")
