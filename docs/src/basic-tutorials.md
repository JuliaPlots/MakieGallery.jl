# Tutorial

Below is a quick tutorial to help get you started. Note that we assume you have [Julia](https://julialang.org/) installed and configured already.

## Getting Makie

Enter the package manager by typing `]` into the Repl. You should see `pkg>`.

```julia
add Makie
```

This installs AbstractPlotting & GLMakie, which

## Getting the development version of Makie

Run the following commands in the package manager:

```julia
add Makie#master AbstractPlotting#master GLMakie#master
```

The first use of Makie might take a little bit of time, due to precompilation.

## Set the `Scene`

The `Scene` object holds everything in a plot, and you can initialize it like so:

```@example 1
# `using Makie` is equivalent to `using AbstractPlotting, GLMakie`
using Makie
using AbstractPlotting
# Inline output into documentation / IJulia / Pluto.jl
AbstractPlotting.inline!(true)
scene = Scene();
```

Note that before you put anything in the scene, it will be blank!

## Getting help

The user-facing functions of Makie are pretty well documented, so you can usually use the help mode in the REPL, or your editor of choice. If you countinue to have issues, see [Getting Help](@ref).

## Basic plotting

Below are some examples of basic plots to help you get oriented.

You can put your mouse in the plot window and scroll to zoom. **Right click and drag** lets you pan around the scene, and **left click and drag** lets you do selection zoom (in 2D plots), or orbit around the scene (in 3D plots).

Many of these examples also work in 3D.

It is worth noting initally that if you run a Makie.jl example and nothing shows up, you likely need to do `display(scene)` to render the example on screen.

### Scatter plot

```@example 1
x = rand(10)
y = rand(10)
colors = rand(10)
scene = scatter(x, y, color = colors)
```

```@example 1
x = 1:10
y = 1:10
sizevec = x ./ 10
scene = scatter(x, y, markersize = sizevec)
```

### Line plot

```@example 1
x = range(0, stop = 2pi, length = 40)
f(x) = sin.(x)
y = f(x)
scene = lines(x, y, color = :blue)
```

### Adding a title

```@example 1
scene = lines(rand(10), axis=(names=(title="Random lines",),))
```

### Adding to a scene
```@example 1
x = range(0, stop = 2pi, length = 80)
f1(x) = sin.(x)
f2(x) = exp.(-x) .* cos.(2pi*x)
y1 = f1(x)
y2 = f2(x)

scene = lines(x, y1, color = :blue)
scatter!(scene, x, y1, color = :red, markersize = 0.1)

lines!(scene, x, y2, color = :black)
scatter!(scene, x, y2, color = :green, marker = :utriangle, markersize = 0.1)
```

### Removing from a scene

```@example 1
x = range(0, stop = 2pi, length = 80)
y1 = sin.(x)
y2 = exp.(-x) .* cos.(2pi * x)

scene = lines(x, y1, color = :blue)
scatter!(scene, x, y1, color = :red, markersize = 0.1)

lines!(scene, x, y2, color = :black)
scatter!(scene, x, y2, color = :green, marker = :utriangle, markersize = 0.1)
# initialize the stepper and give it an output destination
st = Stepper(scene, "output_folder")
step!(st)

# remove last plot in scene
delete!(scene, scene[end])
step!(st)
# remove second plot in scene
delete!(scene, scene[2])
step!(st)
st
```

### Adjusting scene limits

```@example 1
x = range(0, stop = 10, length = 40)
y = x
#= specify the scene limits, note that the arguments for FRect are
    x_min, y_min, x_dist, y_dist,
    therefore, the maximum x and y limits are then x_min + x_dist and y_min + y_dist
=#
limits = FRect(-5, -10, 20, 30)

scene = lines(x, y, color = :blue, limits = limits)
```

You can also use the convenience functions [`xlims!`](@ref), [`ylims!`](@ref) and [`zlims!`](@ref).

### Basic theming

```@example 1
x = range(0, stop = 2pi, length = 40)
y = cos.(x)
scene = lines(x, y, color = :blue)

axis = scene[Axis] # get the axis object from the scene
axis.grid.linecolor = ((:red, 0.5), (:blue, 0.5))
axis.names.textcolor = ((:red, 1.0), (:blue, 1.0))
axis.names.axisnames = ("x", "y = cos(x)")
scene
```

### Statistical plotting

`Makie` has a nice API for statistical plotting through [AlgebraOfGraphics.jl](http://juliaplots.org/AlgebraOfGraphics.jl/dev/).

## Controlling display programmatically

`Scene`s will only display by default in global scope. To make a Scene display when it's defined in a local scope,
like a function or a module, you can call `display(scene)`, which will automatically display it in the best available
display.  
You can force display to the backend's preferred window by calling `display(AbstractPlotting.PlotDisplay(), scene)`.

## Saving plots

Makie overloads the `FileIO` interface, so it is simple to save Scenes as images.

## Static plots

To save a `scene` as an image, you can just write e.g.:

```julia
Makie.save("plot.png", scene)
Makie.save("plot.jpg", scene)
```

where `scene` is the scene handle.

See [Output](@ref) for more information.

## Animations

See the [Animation](@ref) section, as well as the [Interaction](@ref) section.

## More examples

See the [Example Gallery](http://juliaplots.org/MakieReferenceImages/gallery/index.html).
