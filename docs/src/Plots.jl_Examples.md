# Basic Examples

These are basic examples of Plots.jl converted to Makie.jl this requires Julia 1.0 or higher. 
## Basic Lines

```Julia
using Makie
x = 1:10
y = rand(10)
scene = lines(x, y)
display(scene)
```

The result will be a zig zag line.

In Makie we can plot multiple lines by plotting a matrix of values and each column is interpreted as a separate line.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = lines(x, y)
display(scene)
```

This will output two separate lines

We can also plot mathematical functions in the form of line graphs. This is an example of the __cos__ funtion.

```Julia
# plotting graph of simple cos function.

using Makie

 x = range(0, stop = 2pi, length = 40)
 f(x) = cos.(x)
 y = f(x)
 scene = lines(x, y, color = :orange, linewidth = 3)

 sc_t = title("cos function graph")
 sc_t
```

## Plot Attributes

Plot attributes are used to style the plots and in Makie.jl these modifiers are called attributes. They are documented on the [attributes page](http://makie.juliaplots.org/dev/plot-attributes.html).

As an example we will change the line width of the line by using the __linewidth__ attribute.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = lines(x, y, linewidth = 2)
display(scene)
```

If we have to add a title to the plot we can add it using the title tag.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = lines(x, y, linewidth = 2)
sc_t = title(scene, "Random lines")
display(sc_t)
```

## Plot Types

At this point you are a master of lines, but don't you want to plot your data in other ways? We have been using the __line__ plot till now and Makie.jl has many types of plots listed in [plot functions](http://makie.juliaplots.org/dev/functions-overview.html).

This is an example for the scatter type plot by replacing _lines_ with _scatter_.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = scatter(x, y, linewidth = 2)
display(scene)
```

here is a slightly more complex example of a scatter plot that plots two different colours on one graph.

```Julia
using Makie

 x1 = rand(10)
 y1 = rand(10)
 x2 = rand(10)
 y2 = rand(10)
 
scene = Scene()
 scatter!(x1, y1, color = :orange)
 scatter!(x2, y2, color = :blue)

sc_t = title(scene, "My Scatter Plot")
sc_t
 
```

## Layouts in Makie.jl

We can build layouts of multiple graphs using the __vbox__ and __hbox__ functions. The following code is a simple example of this.

```Julia
# combining multiple graph plots into a layout using vbox.

using Makie

scene = vbox(
	hbox(lines(rand(10), color = :blue), lines(rand(10), color = :red), lines(rand(10), color = :green)),
	hbox(scatter(rand(10), rand(10), color = :orange) , scatter(rand(10), rand(10), color = :gray))
)

sc_t = title("vbox layout")
sc_t
 
```
