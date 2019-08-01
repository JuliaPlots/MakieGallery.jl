@block AnshulSinghvi [videoplayer] begin
    @cell "VideoPlayer.jl Makie5" begin
        # # VideoPlayer.jl: Building a Video Player with Makie and VideoIO
        # This is a video player built with Makie.jl, with the intent to support VFR,
        # arbitrary resolution, out-of-memory video playing.  We used Makie so mouse
        # and keyboard inputs could be captured and used within Julia effortlessly.
        # The project was started by Yakir Gagnon (@yakir12), Ian Butterworth (@ianshmean)
        # and Anshul Singhvi (@asinghvi17).

        # # Overview of the program
        # Using VideoIO.jl, we read frames in from file, and extract an approximate timestamp.
        # Then, we rotate the image matrix, and plot it.
        # Buttons, keyboard callbacks, and a slider are set up to move through the video.

        # Imports:
        using Makie, Observables
        using VideoIO, Dates

        # In preparation for turning this into a function, we define some parameters here.
        const filename = joinpath(tempdir(), "testvideo.mp4") # can change

        # Define some helper functions.

        """
            correctimg(img)
        Corrects the input image before plotting it.
        Currently aliased to `rotr90`, but that could
        change - that's why this abstraction was used.
        """
        correctimg(img) = rotr90(img)

        rsc() = Scene(;camera = campixel!, raw = true, backgroundcolor = :black)

        # Begin by loading the file.
        f = VideoIO.openvideo(filename)             # Load the file
        duration = VideoIO.get_duration(f.avin.io)  # Get the duration of the video.

        # Now, we read in a frame from the file, to initialize our Observable.
        img = correctimg(read(f)) |> Observable
        seekstart(f) # seek back to the beginning of the video, since we've read 1 frame.

        # We also read in the aspect ratio and resolution of the file.
        pixelaspectratio = VideoIO.aspect_ratio(f)
        h = f.height
        w = round(typeof(h), f.width * pixelaspectratio)

        # # Time system
        # We also need to set a time system up.  This consists of three Observables:
        # - `current`: seeks to the next timestamp, since FFMPEG does not have good
        #   support for seeking by frame number
        # - `correctcurrent`: provides the current time in the video, accounting for VFR,
        #   using VideoIO's `gettime` function.
        # - `timestamp`: a Observable `Time` which contains the correct, formatted time
        #    for display.
        # To update our Observables, we use two functions: `lift` provided by Makie, and
        # `on` provided by Observables.  While `on` simply executes a function when the
        # relevant Observable is updated, `lift` returns an Observable which is linked to
        # the input observable, and its value is whatever the function returns.

        current = Observable(0.0) # set up the first observable

        # Now, we set up an "event handler" function, which will seek `f` to the value of
        # `current` whenever `current` is updated.

        on(current) do t
            try
                seek(f, t)            # seek the video to the nearest frame to `t`
            catch ex
                if !isa(ex, EOFError) # if the at end of file, that's fine, let it stay.
                    throw(ex)
                end
            end
        end

        # Using the `lift` function, we create another Observable, which triggers on
        # `img` being triggered; this seems unrelated to `current`, but they really update
        # in the same way.

        correctcurrent = lift(_ -> gettime(f), img)

        # We also set up the timestamp, which takes a value and converts it to `DateTime`.

        timestamp = lift(correctcurrent) do cc
            Time(0,0,0,1) + Millisecond(round(Int, 1000 * cc))
        end

        # # Plotting the video
        # Now we get to the exciting bit - plotting!  Using Makie, we can plot an Observable
        # in place of data, which will cause the plot to update whenever the Observable
        # updates.  This is the core building block of the video player.

        # Then, we plot it!
        scene = Makie.image!(
                        rsc(),
                        1:w, # the "`x`-extent"
                        1:h, # the "`y`-extent"
                        img, # the data
                        show_axis = false,  # do not show axis
                        scale_plot = false, # do not scale the plot, maintain SAR.
                )

        # also, we set a default global theme:
        AbstractPlotting.set_theme!(;
            backgroundcolor = :black, # a black backgrounc colour
            textcolor = :white,       # so you can read text on black background 😉
            color = :white,           # so you can read text on black background 😉
            # src raw = true,               # plot raw data
            # src camera = campixel!        # use a pixel-level camera, no projection nonsense.
        )

        # We now set up a slider.  This slider will display how far along we are in the
        # video, and control the updating of the `img` Observable.
        # The slider itself simply seeks to that place in the file (through updating
        # `current`) and then reads in the image, and corrects it.

        # Set up the slider range:

        slidersteps = range(0, duration, length = 100)
        steplen = duration / 100.0

        slider_h = slider!(Scene(camera = campixel!, raw=true, backgroundcolor=:black, textcolor=:white),
                           0:10,                    # the values you can slide to
                           start = 0,                      # default starting point
                           valueprinter = _ -> "slide me", # no value should be printed by
                                                           # the slider, so we print this instead.
                       textcolor=:white)
        # We now create a callback to the slider's value changing, which can happen when
        # the user slides it, or its value is programatically set.

        on(slider_h[end].value) do val
            current[] = val    # update the "current" time
            if !eof(f)
                img[] = correctimg(read(f))
            end
        end

        # This is for a separate display of the time stamp, due to the fact that we
        # cannot calculate with the time stamp is from the frame number (which is what
        # the slider has)

        timestamp_h = text!(rsc(), lift(string, timestamp), color = :white)

        # Now we define the forward button, which simply increments the value of the slider.

        fwdbutton = button!(rsc(), ">", textcolor = :white)
        lift(fwdbutton[end][:clicks]) do _
            if !eof(f)
                img[] = correctimg(read(f))
            end
            nothing
        end

        # The back button is more complicated, perhaps @yakir12 can explain it.
        bckbutton = button!(rsc(), "<", textcolor = :white)
        lift(bckbutton[end][:clicks]) do _
            t2 = correctcurrent[]
            seek(f, max(t2 - 1, 0.0))
            # read(f)
            # t0 = 0.0
            # t1 = 0.0
            # while t1 < t2
            #     t0 = gettime(f)
            #     read(f) # TODO FIXME inefficient
            #     t1 = gettime(f)
            # end
            current[] = max(t2 - 1, 0.0)
            img[] = correctimg(read(f))
        end

        # Now we're done with all the plotting and interaction setup; we only need to
        # layout the scene and set up the callbacks!
        sc = Scene(resolution = (Int64(w) + 300, Int64(h) + 100)) # create a Scene
        sc.center = false # do not recenter

        # layout the Scene with its subscenes
        hbox(vbox(bckbutton, slider_h, fwdbutton, timestamp_h), scene; parent=sc)

        # # Keyboard and mouse callbacks
        # In Makie, you can access the keyboard and mouse buttons through the Events API.
        # Every Scene has events associated with it, which you can find a full accounting of
        # in the documentation for [`Events`](@ref).
        # These Events include keyboard and mouse buttons, which are represented by the
        # [`Keyboard`](@ref) and [`Mouse`](@ref) enums.

        # ## Keyboard events
        # - Right arrow to go forward
        # - Left arrow to go back (not working right now)

        kb = on(sc.events.keyboardbuttons) do kb
            if ispressed(sc, Keyboard.right)
                fwdbutton[end][:clicks][] += 1
            elseif ispressed(sc,Keyboard.left)
                bckbutton[end][:clicks][] += 1
            end
        end

        # ## Mouse events
        # - Left click positions are captured in the Observable `lastmpos`

        lastmpos = Observable(Point2f0(0e0, 0e0))

        to_screen(scene, mpos) = Point2f0(mpos) .- Point2f0(minimum(pixelarea(scene)[]))
        mouseposition(scene) = to_world(scene, to_screen(scene, events(scene).mouseposition[]))

        mb = on(scene.events.mousebuttons) do mb
            if ispressed(scene, Mouse.left)
                lastmpos[] = mouseposition(scene)
            end
        end

        RecordEvents(scene, @replace_with_a_path(mp4))
    end

    @cell "VFR test video" begin
        using Dates, Observables, Printf

        tosecond(x::T) where {T} = x/convert(T, Second(1))

        dar = 2
        w = 200
        h = dar*w
        Δt = Millisecond(1):oneunit(Millisecond):Millisecond(w)
        ts = cumsum(Δt)
        # totaltime = ts[end]
        frame = Observable(1)
        point = lift(frame) do fn
            [(fn, 2fn)]
        end
        msg = lift(frame, point) do fn, p
            ti = @sprintf "%03i" fn
            t = @sprintf "%-012s" Time(0) + ts[fn]
            x, y = p[]
            """
        Frame #: $ti
        Time: $t
        x: $x
        y: $y"""
        end
        limits = FRect(1, 2, w - 1, 2w - 2)
        scene = Scene(resolution = (w, h), limits = limits,  scale_plot = false, show_axis = false)#, padding=(0,0), backgroundcolor=:red)
        poly!(scene, limits, color = :gray)
        text!(scene, msg, position = (2, w), align = (:left,  :bottom))#, color = :white)
        scatter!(scene, point, markersize = 10, marker = :+)#, color = :white)
        for i in 1:w
            frame[] = i
            AbstractPlotting.update_limits!(scene)
            AbstractPlotting.update!(scene)
            fname = @sprintf "%03i.png" i
            save(fname, scene)
        end
        run(`mogrify -resize $(h)x$h\! "*".png`)
        open("timecodes.txt", "w") do io
            for (Δ, i) in zip(Δt, 1:w)
                fname = @sprintf "%03i.png" i
                duration = tosecond(Δ)
                println(io, "file '$fname'")
                println(io, "duration $duration")
            end
            i = w
            fname = @sprintf "%03i.png" i
            println(io, "file '$fname'")
        end

        path = @replace_with_a_path(mp4)

        ffmpeg_exe(`-y -safe 0 -f concat -i timecodes.txt -segment_time_metadata 1 -vf setdar=dar=1/$dar -vsync vfr -copyts $path`)

        ffmpeg_exe(`-y -f concat -i timecodes.txt -vf setdar=dar=1/$dar -vsync 0 $path`)

        # cleanup
        rm.([@sprintf "%03i.png" i for i in 1:w])
    end
end
