# Tutorial

Below is a quick tutorial to help get you started. Note that we assume you have [Julia](https://julialang.org/) installed and configured already.

## Getting Makie
Enter the package manager by typing `]` into the Repl. You should see `pkg>`.
```julia
add Makie
```

## Getting the latest version of Makie
Run the following commands in the package manager:
```Julia
add Makie#master AbstractPlotting#master GLMakie#master
test Makie
```

The first use of Makie might take a little bit of time, due to precompilation.

## Set the `Scene`

The `Scene` object holds everything in a plot, and you can initialize it like so:

```julia
scene = Scene()
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

@example_database("Tutorial simple scatter")

@example_database("Tutorial markersize")

### Line plot

@example_database("Tutorial simple line")

### Adding a title

@example_database("Tutorial title")

### Adding to a scene

@example_database("Tutorial adding to a scene")

### Removing from a scene

@example_database("Tutorial removing from a scene")

### Adjusting scene limits

@example_database("Tutorial adjusting scene limits")

You can also use the convenience functions [`xlims!`](@ref), [`ylims!`](@ref) and [`zlims!`](@ref).

### Basic theming

@example_database("Tutorial basic theming")

### Statistical plotting

`Makie` has a lot of support for statistical plots through `StatsMakie.jl`.
See the [StatsMakie Tutorial](@ref) section for more information on this.

## Controlling display programmatically

`Scene`s will only display by default in global scope.  To make a Scene display when it's defined in a local scope,
like a function or a module, you can call `display(scene)`, which will automatically display it in the best available
display.  
You can force display to the backend's preferred window by calling `display(AbstractPlotting.PlotDisplay(), scene)`.

## Saving plots

See the [Output](@ref) section.

## Animations

See the [Animation](@ref) section, as well as the [Interaction](@ref) section.

## More examples

See the [Example Gallery](http://juliaplots.org/MakieReferenceImages/gallery/index.html).
