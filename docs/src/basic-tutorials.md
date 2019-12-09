# Tutorial

Below is a quick tutorial to help get you started. Note that we assume you have [Julia](https://julialang.org/) installed and configured already.

## Getting Makie
Enter the package manager by typing `]` into the Repl. You should see `pkg>`.
```julia
add Makie
```

## Getting the latest version of Makie
Run the following commands in the package manager, this is required if you have Julia version above v1.0.0:
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

## Plotting in Scripts

If you go and try out each example listed here in the interactive Julia terminal/repl then you would not need the _display(scene)_ at the end. However if you go and try to do it in script _.jl_ file then you 
would need the _display(scene)_ to display the graph, as in the repl Julia automatically calls _display_.

```Julia
display(scene)
```

## Basic plotting

Below are some examples of basic plots to help you get oriented.

You can put your mouse in the plot window and scroll to zoom. **Right click and drag** lets you pan around the scene, and **left click and drag** lets you do selection zoom (in 2D plots), or orbit around the scene (in 3D plots).

Many of these examples also work in 3D.

It is worth noting initally that if you run a Makie.jl example and nothing shows up, you likely need to do `display(scene)` to render the example on screen.

## Plot Attributes

Plot attributes are used to style the plots and in Makie.jl these modifiers are called attributes. They are documented on the [Attributes](@ref) page.

As an example we will change the line width of the line by using the __linewidth__ attribute.

```Julia
x = 1:10
y = rand(10, 2)
scene = lines(x, y, linewidth = 2)
```

### Scatter plot

@example_database("Tutorial simple scatter")

@example_database("Tutorial markersize")

### Line plot

@example_database("Tutorial simple line")

## Different types of Plot Layouts

In Makie.jl you can use multiple types of plots listed over [here](http://makie.juliaplots.org/dev/functions-overview.html). You can either combine multiple plots or display them seperately.

## Combining Multiple Plots as Subplots

If you want multiple plots or multiple types of plots on a single graph then you can use functions such as _lines!_ to
add to the plot, you just have to add the scene as a arguement and you can have all the available attributes for the type
of graph you want.

```Julia
x1 = 1:10
y1 = rand(10)
scene = lines(x1,y1)

x2 = 1:10
y2 = rand(10)
scatter!(scene, x2, y2, color = :red)
```

This will display a line and multiple circles scattered at many points as it uses a line and a scatter type graph.

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
