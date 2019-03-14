# Colors

`Makie` has support for you to color your plots however you want to.
You can manipulate the color of a plot by using the `color` keyword,
nd change the colormap by using the `colormap` keyword.

## Colors

For line plots, you can provide a single color or symbol that will color the entire line;
or, you can provide an array of values that map to colors using a colormap.

Any color symbol supported by Color.jl is supported, check out their page on [named colors](http://juliagraphics.github.io/Colors.jl/latest/namedcolors.html) to see what you can get away with!  You can also pass RGB or RGBA values.

## Colormaps

Colormaps are mappings of values to colors.  You can supply the coloring values using the `color` keyword argument, and the colormap will automatically be adjusted to fit those values.  THe default colormap is `viridis`, which looks like this:

@example_database("Viridis color scheme")

You can copy this code and substitute `cmap` with any `Colormap` to show the colormap.

`Makie` supports multiple colormap libraries.  Currently, support for colormaps provided by `PlotUtils` and `ColorBrewer` is inbuilt, meaning that any colormap symbol that works with Plots will also work with Makie.  

Many colormaps (but not all) can be reversed by appending `_r`, e.g. `:magma_r`. The `clims::NTuple{2,Number}` attribute can be used to define the data values that correspond with the ends of the schemes.

Natively, `Makie` supports these colormaps:

@example_database("colormaps")

Similarly, the `PerceptualColourMaps` library of colormaps can also be used (though it requires `PyCall` and may not play well with `PackageCompiler` system images).  This library is geared more towards 'publication quality' plots, and you can see examples of its colormaps on the [repo page](https://github.com/peterkovesi/PerceptualColourMaps.jl).

## Color legends

To show the colormap and scaling, you can use a color legend.  Color legends can be automatically produced by the `colorlegend` function, to which a Plot object must be passed.  Its range and the colormap it shows can also be manually altered, as can many of its attributes.

To simply produce a color legend and plot it to the left of the original plot, you can produce a colorlegend and `vbox` it.  In the example below, `p1` is the initial Scene, with only one plot.

```julia
scene = vbox(
  p1,
  colorlegend(
    p1[end],            # get Plot object from Scene
    camera = campixel!, # let vbox decide scene limits
    raw = true          # no axes, other things as well
  )
)
```

You can also pass keyword attributes to it, as shown below.

@example_database("Line with varying colors")
