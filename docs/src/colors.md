# Colors

`Makie` has support for you to color your plots however you want to. You can manipulate the color of a plot by using the `color` keyword, and change the colormap by using the `colormap` keyword.

## Colors

For line plots, you can provide a single color or symbol that will color the entire line;
or, you can provide an array of values that map to colors using a colormap.

Any color symbol supported by Color.jl is supported, check out their page on [named colors](http://juliagraphics.github.io/Colors.jl/latest/namedcolors.html) to see what you can get away with!  You can also pass RGB or RGBA values.

## Colormaps

Colormaps are mappings of values to colors.  You can supply the coloring values using the `color` keyword argument, and the colormap will automatically be adjusted to fit those values.  THe default colormap is `viridis`, which looks like this:

@example_database("Viridis color scheme")

You can copy this code and substitute `cmap` with any `Colormap` to show the colormap.

`Makie` supports multiple colormap libraries.  Currently, support for colormaps provided by `PlotUtils` is inbuilt, meaning that any colormap symbol that works with Plots will also work with Makie.  Colormaps from the `ColorSchemes` package can be used by `colormap = ColorSchemes.<name of colormap>.colors`.  Similarly, colormaps from the `PerceptualColourMaps` package (which is a superset of the `colorcet` library) can be used by `colormap = PerceptualColourMaps.cgrad("<name of colormap>")`.  In principle, any Array of `RGB` values can be used as a colormap.

### Builtins

Color gradients are arranged into color libraries. To get a list of color libraries, use the `clibraries` function. To get a list of color gradients in each library, call `cgradients(library)`. `showlibrary(library)` creates a visual representation of color schemes. To change the active library, use `clibrary(library)`. This is only necessary in the case of namespace clashes, e.g. if there are multiple `:blues`. The gradients can be reversed by `Reverse(:<gradient_name>)`. The `clims::NTuple{2,Number}` attribute can be used to define the data values that correspond with the ends of the colormap.

PlotUtils bundles with it colormaps from many libraries.  As of the 16th of March, 2019, those are:

```julia
:Plots    # default
:cmocean
:colorbrewer
:colorcet
```

Again, the `clibrary` function can be used to change the preferred colour library in case of namespae conflict.  For example, to prefer the use of `cmocean` colourmaps if available, you might call `clibrary(:cmocean)` before plotting.

## Libraries

### PLOTS

The default library.  Created by Nathaniel J. Smith, Stefan van der Walt, and (in the case of viridis) Eric Firing. Released under CC0 license / public domain dedication. Full license info available [here](https://github.com/JuliaPlots/PlotUtils.jl/blob/master/LICENSE.md#matplotlib).

@example_database("Colormap collection", 1)
### CMOCEAN

Released under The MIT License (MIT) Copyright (c) 2015 Kristen M. Thyng. RGB values were taken from https://github.com/matplotlib/cmocean/tree/master/cmocean/rgb

@example_database("Colormap collection", 2)

### COLORCET

Released under The MIT License (MIT) Copyright (c) 2015 Peter Kovesi. These are the perceptually correct color maps designed by Peter Kovesi and described in Peter Kovesi. Good Colour Maps: How to Design Them. arXiv:1509.03700 [cs.GR] 2015

@example_database("Colormap collection", 3)

### COLORBREWER

Created by Cynthia Brewer, Mark Harrower, and The Pennsylvania State University. Released under the Apache License, Version 2.0. Full license info available [here](https://github.com/JuliaPlots/PlotUtils.jl/blob/master/LICENSE.md#colorbrewer).

@example_database("Colormap collection", 4)

!!! note
    Due to the font in the image above, it may be difficult to tell that the yellow-orange-brown gradient, `YlOrBr`, is not `YIOrBr` - the second character is an `l`, not an `I`.

### MISC

@example_database("Colormap collection", 5)

## Color legends

To show the colormap and its scaling, you can use a color legend.  Color legends can be automatically produced by the `colorlegend` function, to which a Plot object must be passed.  Its range and the colormap it shows can also be manually altered, as can many of its attributes.

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

Be warned that in its current form, this will look quite small compared to the size of the plot!

To fix that, you can theme it, as shown below:

@example_database("Line with varying colors")
