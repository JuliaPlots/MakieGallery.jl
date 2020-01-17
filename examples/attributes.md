## Show the usage of attributes in Makie
Makie has various attributes available for usage. This file intents to show the usage and implementation of those attributes
A full list of attributes can be found [here](http://makie.juliaplots.org/dev/plot-attributes.html#List-of-attributes-1)


### shading

```julia
scene = mesh(
    HyperRectangle(Vec3f0(1, 1, 1), Vec3f0(1, 1, 3)),
    color = (:green, 0.4),
    show_axis = false,
    shading = false,
    center = false,
)
display(scene)
```

### Output
![img1](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p1.png)


### colormap, color, colorrange, linestyle, linewidth, align, pos, textsize, rotation

```julia
scene = Scene()
y = 200 * rand(300)
x = range(0, 600, length = 300)
c = range(1, stop = 0, length = 600)
lines!(
    scene,
    x,
    y,
    colormap = :BuPu,
    color = c,
    colorrange=(1,0.5),
    linestyle = :dashdotdot,
    linewidth = 3.0,
)
text!(
    scene,
    "Red Dead Redemption 2 is the best game ever!",
    align = (:left, :center),
    position = (0, -100),
    color = :red,
    font = "Blackchancery",
    textsize = 70,
    rotation = pi / 6,
)
display(scene)
```

### Output
![img2](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p2.png)


### markersize, strokecolor, strokewidth, glowcolor, glowwidth, marker, marker_offset

```julia
scene = Scene()
points = Point2f0[(i, i) for i = 1:6]
offset = rand(Point2f0, length(points)) ./ 5
scatter!(
    scene,
    points,
    color = :gray,
    markersize = 0.2,
    strokecolor = :pink,
    strokewidth = 8,
    marker = :x,
)
scatter!(
    scene,
    points,
    glowcolor = :red,
    color = :black,
    marker_offset = offset,
    markersize = 1,
    glowwidth = 5.0,
    marker = :+,
)
display(scene)
```

### Output
![img3](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p3.png)


### visible

```julia
scene = Scene()
y = rand(3)
scatter!(scene, y, visible = false)
text!(
    scene,
    "The above plot is not visible!",
)
display(scene)
```

### Output
![img4](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p4.png)


### interpolate

```julia
scene = Scene()

source_img = load(download("https://images-na.ssl-images-amazon.com/images/I/41OEdd1En8L._SX322_BO1,204,203,200_.jpg"))
img = Float32.(channelview(Gray.(source_img)))
heatmap!(scene, img, interpolate = true)
display(scene)
```

### Output
![img5](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p5.png)


### absorption, algorithm

```julia
scene = Scene()
volume!(scene, rand(50, 50, 50), algorithm = :absorption, absorption = 7.0f0)
display(scene)
```

### Output
![img6](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p6.png)


```juila
scene = Scene()
img = Float32.(channelview(source_img))
volume!(scene, img, isorange = 0.012f0, isovalue = 0.3f0)
display(scene)
```

### Output
![img7](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p7.png)


### levels

```julia
N = 20
x = range(-0.5, stop = 0.5, length = N)
y = range(-0.5, stop = 0.5, length = N)
z = x .* y'
a = contour(x, y, z, levels = 100, colormap = :magma, fillrange = true)
display(a)
```

### Output
![img8](https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20attributes/image/p8.png)


---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*
