@block SebastianM_C ["3d"] begin
    @cell "DifferentialEquations path animation" [lines, meshscatter, animated, record, diffeq] begin
        using OrdinaryDiffEq
        using Statistics

        function lorenz(du,u,p,t)
            du[1] = 10.0*(u[2]-u[1])
            du[2] = u[1]*(28.0-u[3]) - u[2]
            du[3] = u[1]*u[2] - (8/3)*u[3]
        end

        u0 = [1.0; 0.0; 0.0]
        tspan = (0.0, 10.0)
        prob = ODEProblem(lorenz, u0, tspan)
        sol = solve(prob, Tsit5())

        t = Node(tspan[1])
        trajectory = lift(t; init = [Point3f0(sol(t[], idxs = [1,2,3]))]) do t
            push!(trajectory[], Point3f0(sol(t, idxs=[1,2,3])))
        end
        endpoint = lift(t->[Point3f0(sol(t, idxs = [1,2,3]))], t)

        xm, xM = extrema(sol[1,:])
        ym, yM = extrema(sol[2,:])
        zm, zM = extrema(sol[3,:])

        limits = FRect3D((xm,ym,zm), (xM-xm,yM-ym,zM-zm))

        scene = lines(trajectory, limits = limits, markersize = 0.7)
        meshscatter!(scene, endpoint, limits = limits, markersize = 0.5, color = :red)
        eyepos = Vec3f0(100, 5.0, 25)
        N = 1000
        record(scene, @replace_with_a_path(mp4), LinRange(tspan..., N)) do tᵢ
            global eyepos
            push!(t, tᵢ)
            eyepos = Vec3f0(eyepos[1] - (N / 10000), eyepos[2], eyepos[3])
            update_cam!(scene, eyepos, mean(trajectory[]))
            sleep(0.001)
        end
    end

end

@block AnshulSinghvi ["interactive"]  begin

    @cell "Interactive Differential Equation" [lines, slider, animated, record, diffeq, interactive] begin
        using DifferentialEquations, ParameterizedFunctions
        import AbstractPlotting: textslider
        lorenz = @ode_def Lorenz begin           # define the system
            dx = σ * (y - x)
            dy = x * (ρ - z) - y
            dz = x * y - β*z
        end σ ρ β

        u0 = [1.0,0.0,0.0]                       # initial conditions
        tspan0 = (0.0,100.0)                      # initial timespan
        p0 = [10.0,28.0,8/3]                      # initial parameters
        prob = ODEProblem(lorenz, u0, tspan0, p0)  # define the problem

        ## setup sliders and plotting

        "The order of magnitude to range between."
        OME = 8

        sσ, oσ = textslider(exp10.(-OME:0.001:OME), "σ", start = p0[1]);

        sρ, oρ = textslider(exp10.(-OME:0.001:OME), "ρ", start = p0[2]);

        sβ, oβ = textslider(exp10.(-OME:0.001:OME), "β", start = p0[3]);

        st, ot = textslider(exp10.(-OME:0.001:OME), "tₘₐₓ", start = tspan0[end]);

        sr, or = textslider(100:10000, "resolution", start = 2000);

        trange = lift(ot, or) do tmax, resolution
            LinRange(0.0, tmax, resolution)
        end

        data = lift(oσ, oρ, oβ, trange) do σ, ρ, β, ts
            Point3f0.(
                solve(
                    remake(
                        prob;
                        p = [σ, ρ, β],
                        tspan = (ts[1], ts[end])
                    )
                )(ts).u
            )  # change to fit the dimensionality - maybe even return 2 arrays, or a set of `Point2`s...
        end
        parent = Scene(resolution = (1000, 500))

        three = lines(
            data, linewidth = 2,
            transparency = true, color = ("#fe4a49", 0.4),
            show_axis = false
        )

        scatter!(
            three, data, markersize = 0.3, color = (:white, 0.3),
            strokecolor = :black, strokewidth = 1
        )
        on(data) do x
            # center camera etc
            update!(three)
        end
        scene = vbox(hbox(sσ, sρ, sβ, st, sr), three, parent = parent)

        RecordEvents(scene, @replace_with_a_path)

    end

end
