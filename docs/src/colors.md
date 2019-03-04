# Colors

`Makie` has support for you to color your plots however you want to.
You can manipulate the color of a plot by using the `color` keyword,
nd change the colormap by using the `colormap` keyword.

For line plots, you can provide a single color or symbol that will color the entire line;
or, you can provide an array of values that map to colors using a colormap.

Any color symbol supported by Color.jl is supported, check out their page on [named colors](http://juliagraphics.github.io/Colors.jl/latest/namedcolors.html) to see what you can get away with!  You can also pass RGB or RGBA values.

## Colormaps

Colormaps are mappings of values to colors.  You can supply the coloring values using the `color` keyword argument, and the colormap will automatically be adjusted to fit those values.  THe default colormap is `viridis`, which looks like this:

@example_database("Viridis color scheme")

You can copy this code and substitute `cmap` with any `Colormap` to show the colormap.

`Makie` supports multiple colormap libraries.  Currently, `Colors` and `ColorBrewer` are inbuilt, and `ColorSchemes` and `PerceptualColourMaps` work as well.

Natively, `Makie` supports these `ColorBrewer` colormaps (see (their docs)[https://github.com/timothyrenner/ColorBrewer.jl] as well):

@example_database("colormaps")

On top of this, you can use any `ColorSchemes` colormap as `colormap = ColorSchemes.<colormap name>.colors`.  Check out the [`ColorSchemes.jl` docs](https://juliagraphics.github.io/ColorSchemes.jl/stable/index.html) for more information!

Similarly, the `PerceptualColourMaps` library of colormaps can also be used (though it requires `PyCall` and may not play well with `PackageCompiler` system images).  This library is geared more towards 'publication quality' plots, and you can see examples of its colormaps on the [repo page](https://github.com/peterkovesi/PerceptualColourMaps.jl).
