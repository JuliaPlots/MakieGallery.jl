# Examples of Makie Attributes

## algorithm
Defines the algorithms to be used for `volume` plots. The ones that are available are `:iso`, `:absorption`, `:mip`, `:absorptionrgba`, `:indexedabsorption`.

```julia
volume(rand(32, 32, 32), algorithm = :mip) #with mip algorithm
```

![1](https://user-images.githubusercontent.com/28962234/72291305-07d1f680-3647-11ea-83c9-fb85b6f2c6f9.png)

```julia
volume(rand(32, 32, 32), algorithm = :absorptionrgba) #with AbsorptionRGBA algorithm
```

![2](https://user-images.githubusercontent.com/28962234/72291306-086a8d00-3647-11ea-9262-fc7c8d0a46dd.png)

## align
Provides text alignment. `(:pos, :pos)` where `:pos` can be `:left`, `:right`, or `:center`.

```julia
scene = Scene()
scatter!(scene, rand(10), color=:red)
text!(scene,"adding text",textsize = 0.6, align = (:center, :center))
display(scene)
```

![3](https://user-images.githubusercontent.com/28962234/72291307-086a8d00-3647-11ea-9e09-1c3ca5b5cee6.png)

## color
Defines the color of the main plot element (markers, lines, etc...). This can be a color symbol such as `:blue` or an array or matrix of 'z-values' that are converted into colors by the colormap automatically.

```julia
lines(rand(10), linewidth = 20, color = :blue)
```

![4](https://user-images.githubusercontent.com/28962234/72291308-086a8d00-3647-11ea-8a0e-9dfee0ea7230.png)

```julia
lines(rand(10), linewidth = 20, color = to_colormap(:viridis, 10))
```
![5](https://user-images.githubusercontent.com/28962234/72291309-086a8d00-3647-11ea-92d4-ff27ca45d161.png)

## colormap
Defines the color map of the main plot. Call `available_gradients()` to see what gradients are available. Can also be used with any `Vector{<: Colorant}`, or e.g. `[:red, :black]`, or `ColorSchemes.jl` colormaps (by `colormap = ColorSchemes.<colorscheme name>.colors`).

```julia
t = range(0, stop=1, length=300)
θ = (6π) .* t
x = t .* cos.(θ)
y = t .* sin.(θ)
lines(x,y,color=t,colormap=:colorwheel,linewidth=8,scale_plot= false)
```

![6](https://user-images.githubusercontent.com/28962234/72291310-086a8d00-3647-11ea-8b6e-f364194611a0.png)

## colorrange
A tuple (min, max) where min and max specify the data range to be used for indexing the colormap. <br/>
eg. color = [-2, 4] with colorrange = (-2, 4) will map to the lowest and highest color value of the colormap.

```julia
lines(randn(10),color=LinRange(-1, 1, 10),colormap=:colorwheel,linewidth=8, colorrange = (-1.0,1.0))
```

![7](https://user-images.githubusercontent.com/28962234/72291311-086a8d00-3647-11ea-9e42-35d7bba1a2e6.png)

## fillrange
A Bool toggling range filling in `contour` plots.

```julia
x = LinRange(-1, 1, 20)
y = LinRange(-1, 1, 20)
z = x .* y'
contour(x, y, z, levels = 0, linewidth = 0, fillrange = false)
```

![8](https://user-images.githubusercontent.com/28962234/72291312-086a8d00-3647-11ea-8080-6d7b404f2e4d.png)

```julia
contour(x, y, z, levels = 0, linewidth = 0, fillrange = true)
```

![9](https://user-images.githubusercontent.com/28962234/72291315-086a8d00-3647-11ea-930d-6d5bf6dfabe1.png)

## font
A string specifying the font, which can be chosen from any font available on the system.

```julia
scene = Scene()
scatter!(scene, rand(10), color=:red)
text!(scene,"adding text",textsize = 0.6, align = (:center, :center), font = "Blackchancery")
display(scene)
```

![10](https://user-images.githubusercontent.com/28962234/72291316-09032380-3647-11ea-907d-242cbe83f52a.png)

## glowcolor & glowwidth
`glowcolor` is a color type that specifies the color of the marker glow (outside the border) in `scatter` plots.<br/>
`glowwidth` is a number that specifies the width of the marker glow in `scatter` plots.

```julia
scatter(randn(10),color=:blue, glowcolor = :orange, glowwidth = 10)
```

![11](https://user-images.githubusercontent.com/28962234/72291317-09032380-3647-11ea-949e-84f207635165.png)

## image
An argument to the `image()` specifying the image to be plotted on the plot.

```julia
import FileIO
img = FileIO.load(download("http://makie.juliaplots.org/dev/assets/logo.png"))
image(img, scale_plot = false)
```

![12](https://user-images.githubusercontent.com/28962234/72291318-09032380-3647-11ea-909d-e7c5234879bb.png)

## interpolate
A Bool toggling color interpolation between nearby pixels for `heatmap` and `images`.

```julia
scene = heatmap(rand(50, 50), colormap = :colorwheel) #without interpolation
```

![13](https://user-images.githubusercontent.com/28962234/72291319-09032380-3647-11ea-8be7-119188b960a2.png)

```julia
scene = heatmap(rand(50, 50), colormap = :colorwheel, interpolate = true) #with interpolation
```

![14](https://user-images.githubusercontent.com/28962234/72291320-09032380-3647-11ea-8b3f-960640e69e43.png)

## isorange & isovalue
`isorange` and `isovalue` are Float32 values defining the iso range and value for `volume` plots respectively.

```julia
r = range(-1, stop = 1, length = 100)
matr = [(x.^2 + y.^2 + z.^2) for x = r, y = r, z = r]
volume(matr .* (matr .> 1.4), algorithm = :iso, isorange = 3, isovalue = 1.7)
```

![15](https://user-images.githubusercontent.com/28962234/72291321-09032380-3647-11ea-8389-4b20f1ce3b8a.png)

## levels
An ingeter defining the numer of levels for a `contour`-type plot.

```julia
x = LinRange(-1, 1, 20)
y = LinRange(-1, 1, 20)
z = x .* y'
contour(x, y, z, linewidth = 3, colormap = :colorwheel, levels = 50)
```

![16](https://user-images.githubusercontent.com/28962234/72291322-099bba00-3647-11ea-9e17-188518d4430c.png)

## linestyle
A symbol defining the style of the line for `line` and `linesegments` plots. <br/>
The styles available are `:dash`, `:dot`, `:dashdot`, and `:dashdotdot`.

```julia
lines(rand(10), linewidth = 6, linestyle = :dashdotdot)
```

![17](https://user-images.githubusercontent.com/28962234/72291323-099bba00-3647-11ea-8e7a-47d03e336338.png)

## linewidth
A number that specifies the wdith of the line in `line` and `linesegments` plots.

```julia
scene = Scene()
lines!(scene, randn(20), linewidth = 8)
lines!(scene, rand(20), linewidth = 4)
display(scene)
```

![18](https://user-images.githubusercontent.com/28962234/72291325-099bba00-3647-11ea-9297-a0556907d70c.png)

## markersize
A number or an AbstractVector specifying the size (radius pixels) of the markers.

```julia
scatter(rand(50), color = :orange, markersize = 2)
```

![19](https://user-images.githubusercontent.com/28962234/72291326-099bba00-3647-11ea-8244-e6cc9fbbc136.png)

## position
A `NTuple{2,Float}, (x, y)` that specifies the coordinates to position text at.

```julia
scene = Scene()
scatter!(scene, rand(10), color=:red)
text!(scene,"adding text",textsize = 0.6, position = (5.0, 1.1))
display(scene)
```

![20](https://user-images.githubusercontent.com/28962234/72291327-099bba00-3647-11ea-85b2-011911c359e7.png)

## rotation & rotations
`rotation` is a `Float32` specifying the rotation in radians. <br/>
`rotations` is an `AbstractVector{Float32}` specifying the rotations for each element in the plot.

```julia
text("Hello World", rotation = 1.1)
```

![21](https://user-images.githubusercontent.com/28962234/72291328-099bba00-3647-11ea-97b3-400ddcae72d0.png)

## shading
A Bool specifying whether shading should be on or not for `meshes`.

```julia
mesh(Sphere(Point3f0(0), 1f0), color = :orange, shading = false) #without shading
```

![22](https://user-images.githubusercontent.com/28962234/72291329-099bba00-3647-11ea-83a3-eae0451a3e26.png)

```julia
mesh(Sphere(Point3f0(0), 1f0), color = :orange) #with shading
```

![23](https://user-images.githubusercontent.com/28962234/72291330-0a345080-3647-11ea-92b5-7c9d5a6a2017.png)

## strokecolor & strokewidth
`strokecolor` is a Color Type specifying the color of the marker stroke (ie. the border). <br/>
`strokewidth` is a number specifying the width of the marker stroke in pixels.

```julia
x = LinRange(0, 2pi, 100)
poly(Point2f0.(zip(sin.(x), sin.(2x))), color = :white, strokecolor = :blue, strokewidth = 10)
```

![24](https://user-images.githubusercontent.com/28962234/72291331-0a345080-3647-11ea-8883-4f52e0edb0cb.png)

## textsize
An integer specifying the font pointsize for the `text`.

```julia
scene = Scene()
scatter!(scene, rand(10), color = to_colormap(:colorwheel, 10))
text!(scene, "hello world", textsize = 2)
display(scene)
```

![25](https://user-images.githubusercontent.com/28962234/72291332-0a345080-3647-11ea-8f97-869d41f39877.png)

## visible
A Bool toggling the visibility of the plot.

```julia
scatter(randn(20), color = to_colormap(:deep, 20), markersize = 1) #with visibility
```

![26](https://user-images.githubusercontent.com/28962234/72291333-0a345080-3647-11ea-85df-c5c7adeec4c8.png)

```julia
scatter(randn(20), color = to_colormap(:deep, 20), markersize = 1, visible = false) #without visibility
```

![27](https://user-images.githubusercontent.com/28962234/72291334-0a345080-3647-11ea-99e8-ec5eb1733d1e.png)
