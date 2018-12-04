@block piever [statsmakie] begin
    @cell "StatsMakie 1" [] begin
        using StatsMakie
        N = 1000
        a = rand(1:2, N) # a discrete variable
        b = rand(1:2, N) # a discrete variable
        x = randn(N) # a continuous variable
        y = @. x * a + 0.8*randn() # a continuous variable
        z = x .+ y # a continuous variable
    end
    @cell "StatsMakie 2" [] begin
        scatter(x, y, markersize = 0.2)

    end
    @cell "StatsMakie 3" [] begin
        scatter(Group(a), x, y, markersize = 0.2)

    end
    @cell "StatsMakie 4" [] begin
        scatter(Group(a), x, y, color = [:black, :red], markersize = 0.2)

    end
    @cell "StatsMakie 5" [] begin
        scatter(Group(marker = a), x, y, markersize = 0.2)

    end
    @cell "StatsMakie 6" [] begin
        scatter(Group(marker = a, color = b), x, y, markersize = 0.2)

    end
    @cell "StatsMakie 7" [] begin
        scatter(Group(marker = a), Style(color = z), x, y)

    end
    @cell "StatsMakie 8" [] begin
        scatter(Group(color = a), x, y, Style(markersize = z ./ 10))

    end
    @cell "StatsMakie 9" [] begin
        using StatsMakie: linear, smooth

        plot(linear, x, y)

    end
    @cell "StatsMakie 10" [] begin
        plot(linear, Group(a), x, y)

    end
    @cell "StatsMakie 11" [] begin
        scatter(Group(a), x, y, markersize = 0.2)
        plot!(linear, Group(a), x, y)

    end
    @cell "StatsMakie 12" [] begin
        plot(linear, Group(linestyle = a), x, y)

    end
    @cell "StatsMakie 13" [] begin
        N = 200
        x = 10 .* rand(N)
        a = rand(1:2, N)
        y = sin.(x) .+ 0.5 .* rand(N) .+ cos.(x) .* a

    end
    @cell "StatsMakie 14" [] begin
        scatter(Group(a), x, y)
        plot!(smooth, Group(a), x, y)

    end
    @cell "StatsMakie 15" [] begin
        plot(histogram, y)

    end
    @cell "StatsMakie 16" [] begin
        plot(histogram, x, y)

    end
    @cell "StatsMakie 17" [] begin
        plot(histogram(nbins = 30), x, y)

    end
    @cell "StatsMakie 18" [] begin
        wireframe(histogram(nbins = 30), x, y)

    end
    @cell "StatsMakie 19" [] begin
        using DataFrames, RDatasets
        iris = RDatasets.dataset("datasets", "iris")
        scatter(Data(iris), Group(:Species), :SepalLength, :SepalWidth)

    end
    @cell "StatsMakie 20" [] begin
        # use Position.stack to signal that you want bars stacked vertically rather than superimposed
        plot(Position.stack, histogram, Data(iris), Group(:Species), :SepalLength)

    end
    @cell "StatsMakie 21" [] begin
        wireframe(density(trim=true), Data(iris), Group(:Species), :SepalLength, :SepalWidth)

    end
    @cell "StatsMakie 22" [] begin
        scatter(
            Data(iris),
            Group(marker = :Species, color = bycolumn),
            :SepalLength, (:PetalLength, :PetalWidth)
        )

    end
end
