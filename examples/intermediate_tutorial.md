# Makie Tutorial (Intermediate)

## Initialize

```julia
using Makie, StatsMakie
```

## Lines
A simple line plot of the columns.

```julia
scene = Scene()
lines!(scene, rand(10), linewidth=3.0, color=:blue)
lines!(scene, rand(10), linewidth=3.0, color=:red)
lines!(scene, rand(10), linewidth=3.0, color=:green)
lines!(scene, rand(10), linewidth=3.0, color=:purple)
lines!(scene, rand(10), linewidth=3.0, color=:orange)
display(scene)
```

![1](https://user-images.githubusercontent.com/28962234/72225315-28814a00-357c-11ea-9d3e-a159e80d6cd9.png)

## Functions
Plot multiple functions.

```julia
scene = Scene()
x = range(0, stop = 3pi, step = 0.01)
lines!(scene, x, sin.(x), color = :black)
lines!(scene, x, cos.(x), color = :blue)
display(scene)
```

![2](https://user-images.githubusercontent.com/28962234/72225317-3505a280-357c-11ea-893f-78f80e0c6a47.png)

## Animations
Easily build animations.
`ffmpeg` (wrapped by `FFMPEG.jl`) must be available to generate the animation.
Use command `record(func, scene, path, iter; framerate = 24)` to save the animation.

```julia
scene = Scene()
mytime = Node(0.0)
f(v, t) = sin(v + t)
g(v, t) = cos(v + t)
lines!(scene,lift(t -> f.(range(0, stop = 2pi, length = 50), t), mytime),color = :blue)
lines!(scene,lift(t -> g.(range(0, stop = 2pi, length = 50), t), mytime),color = :orange)
record(scene, "mygraph.gif", range(0, stop = 4pi, length = 100)) do i
    mytime[] = i
end
```

![3](https://user-images.githubusercontent.com/28962234/72225321-4058ce00-357c-11ea-8e7f-09619a1281df.gif)

## Parametric plots
Plot function pair (x(u), y(u)).

```julia
x = LinRange(0, 2pi, 100)
poly(Point2f0.(zip(sin.(x), sin.(2x))), color = "orange", strokecolor = "blue", strokewidth = 4)
```

![4](https://user-images.githubusercontent.com/28962234/72225327-58c8e880-357c-11ea-8408-c680af379ca4.png)

## Colors
Access predefined colormaps. Line/marker colors are auto-generated from the plot's colormap, unless overridden.
Click [here](http://makie.juliaplots.org/dev/colors.html) to find out more about the colormaps.

```julia
lines(1:50, 1:1, linewidth = 20, color = to_colormap(:viridis, 50))
```

![5](https://user-images.githubusercontent.com/28962234/72225332-65e5d780-357c-11ea-91ab-63b5176bcdad.png)

## Images
Plot an image.

```julia
import FileIO
path = download("http://makie.juliaplots.org/dev/assets/logo.png")
img = FileIO.load(path)
image(img, scale_plot = false)
```

![6](https://user-images.githubusercontent.com/28962234/72225335-70a06c80-357c-11ea-94cb-865e2805b7cb.png)

## Attributes
Plot multiple series with different numbers of points. You can specify [some attributes](http://makie.juliaplots.org/dev/functions-overview.html#AbstractPlotting.lines) to customize your graph.

```julia
scene = Scene()
lines!(scene, rand(10), color = to_colormap(:viridis, 10), linewidth = 5)
lines!(scene, rand(20), color = :red, alpha = 0.5)
display(scene)
```

![7](https://user-images.githubusercontent.com/28962234/72225340-7e55f200-357c-11ea-9805-68f07af741a3.png)

## Build plot in pieces
Start with a base plot...

```julia
scene = Scene()
lines!(scene, rand(50)/3, color = :purple, linewidth = 5)
```
![8](https://user-images.githubusercontent.com/28962234/72225349-8d3ca480-357c-11ea-8c40-3aa724af9f47.png)

and add to it later.

```julia
scatter!(scene, rand(50), color = :orange, markersize = 1)
```

![9](https://user-images.githubusercontent.com/28962234/72225352-96c60c80-357c-11ea-9942-0344edacd470.png)

## Histogram2D
From StatsMakie

```julia
plot(histogram(nbins = 20), randn(10000), randn(10000))
```

![10](https://user-images.githubusercontent.com/28962234/72225358-a180a180-357c-11ea-9cf8-e02f6c2b04fd.png)

## Bar

```julia
barplot(randn(99))
```

![11](https://user-images.githubusercontent.com/28962234/72225365-ad6c6380-357c-11ea-905a-85f00a39bdfd.png)

## Histogram
From StatsMakie

```julia
plot(histogram, randn(1000))
```

![12](https://user-images.githubusercontent.com/28962234/72225371-bcebac80-357c-11ea-9ea4-d2d06ca78a81.png)

## Subplots

```julia
scene1, scene2, scene3, scene4 = Scene(), Scene(), Scene(), Scene()
lines!(scene1, rand(10), color=:red)
lines!(scene1, rand(10), color=:blue)
lines!(scene1, rand(10), color=:green)
scatter!(scene2, rand(10), color=:red)
scatter!(scene2, rand(10), color=:blue)
scatter!(scene2, rand(10), color=:orange)
barplot!(scene3, randn(99))
plot!(scene4, histogram, randn(1000))
display(vbox(hbox(scene2,scene1),hbox(scene4,scene3)))
```

![13](https://user-images.githubusercontent.com/28962234/72225387-dd1b6b80-357c-11ea-8951-200119816903.png)

## Text
Add text to your scene. You can specify [some attributes](http://makie.juliaplots.org/dev/functions-overview.html#text-1) to customize your graph, eg. its position.

```julia
scene = Scene()
scatter!(scene, rand(10), color=:red)
text!(scene,"adding text",textsize = 0.6, position = (5.0, 1.1))
display(scene)
```

![14](https://user-images.githubusercontent.com/28962234/72225392-ec9ab480-357c-11ea-8e33-a625ad91d279.png)

## Contours
[More attributes](http://makie.juliaplots.org/dev/functions-overview.html#contour-1) can be specified.

```julia
x = LinRange(-1, 1, 20)
y = LinRange(-1, 1, 20)
z = x .* y'

vbox(
    contour(x, y, z, levels = 50, linewidth =3),
    contour(x, y, z, levels = 0, linewidth = 0, fillrange = true)
     )
```

![15](https://user-images.githubusercontent.com/28962234/72225396-f91f0d00-357c-11ea-9021-aa4ba5edb221.png)

## 3D

```julia
x = [2 .* (i/3) .* cos(i) for i in range(0, stop = 4pi, length = 30)]
y = [2 .* (i/3) .* sin(i) for i in range(0, stop = 4pi, length = 30)]
z = range(0, stop = 5, length = 30)
meshscatter(x, y, z, markersize = 0.5, color = to_colormap(:blues, 30))
```

![16](https://user-images.githubusercontent.com/28962234/72225398-050acf00-357d-11ea-9230-bb29d4e4570d.png)

## Heatmap
```julia
x = LinRange(-1, 1, 40)
y = LinRange(-1, 1, 40)
z = x .* y'
heatmap(x, y, z)
```

![17](https://user-images.githubusercontent.com/28962234/72225406-12c05480-357d-11ea-8cb3-ef6d867ac050.png)

## Label rotation, title location
```julia
scene = Scene()
line = lines!(scene, rand(10), linewidth=3.0, color=:red)
scene[Axis][:names, :axisnames] = ("text","")
scene[Axis][:names, :rotation] = (1.5pi)
leg = legend([scene[2]], ["line"], position = (1, -1))
display(vbox(line,leg))
```

![18](https://user-images.githubusercontent.com/28962234/72225412-1fdd4380-357d-11ea-95a1-0084e181b69b.png)

## Lines with varying colors
```julia
t = range(0, stop=1, length=100)
θ = (6π) .* t
x = t .* cos.(θ)
y = t .* sin.(θ)
p1 = lines(x,y,color=t,colormap=:colorwheel,linewidth= 8,scale_plot= false)
p2 = scatter(x,y,color=t,colormap=:colorwheel,linewidth= 8,scale_plot= false)
display(vbox(p1, p2))
```

![19](https://user-images.githubusercontent.com/28962234/72225419-34b9d700-357d-11ea-9ad1-9bdbe47c4d68.png)
