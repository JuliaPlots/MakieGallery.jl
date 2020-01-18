```@setup plot_attributes
using Makie
```

Below is a list of some common plot attributes for Makie.

To view a plot's attributes and their values, you can call `plot.attributes` to view the raw output,
or `plot.attributes.attributes` to get a Dict of the attribute keys and their values.

```@example plot_attributes
p = scatter(rand(10), rand(10))[end]; # use `[end]` to access the plot
p.attributes
p.attributes.attributes
```

# Usage of the above attributes

### attribute usage : shading
@example_database("attribute usage : shading")

### attribute usage : colormap, color, colorrange, linestyle, linewidth, align, pos, textsize, rotation
@example_database("attribute usage : colormap, color, colorrange, linestyle, linewidth, align, pos, textsize, rotation")

### attribute usage : markersize, strokecolor, strokewidth, glowcolor, glowwidth, marker, marker offset
@example_database("attribute usage : markersize, strokecolor, strokewidth, glowcolor, glowwidth, marker, marker offset")

### attributes usage : visible
@example_database("attributes usage : visible")

### attribute usage : interpolate
@example_database("attribute usage : interpolate")

### attribute usage : absorption, algorithm
@example_database("attribute usage : absorption, algorithm")

### attribute usage : isorange, isovalue
@example_database("attribute usage : isorange, isovalue")

### attribute usage : levels
@example_database("attribute usage : levels")
