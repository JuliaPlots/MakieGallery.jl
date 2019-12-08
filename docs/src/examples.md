# Basic Examples

Once you have configured Julia and Makie (If you are using Juia 1.0.0 and above then use Makie#master) then
you can do these examples in either your faourite editor or the repl.

## Basic Lines

```Julia
using Makie
x = 1:10
y = rand(10)
scene = lines(x, y)
display(scene)
```

The result will be a zip zag line.

In Makie we can plot multiple lines by plotting a matrix of values and each column is interpreted as a separate line.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = lines(x, y)
display(scene)
```

This will output two separate lines

## Different types of Plot Layouts

In Makie.jl you can use multiple types of plots listed over 
[here](http://makie.juliaplots.org/dev/functions-overview.html). You can either combine multiple plots or display them 
seperately.

## Plotting in Scripts
If you go and try out each example listed here in the interactive Julia terminal/repl then you would not need the 
_display(scene)_ at the end. However if you go and try to do it in script _.jl_ file then you would need the 
_display(scene)_ to display the graph as in the repl Julia automatically called _display_

```Julia
display(scene)
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

At this point you're a master of lines, but don't you want to plot your data in other ways? We have been using the __line__ plot till now and Makie.jl has many types of plots listed in [plot functions](http://makie.juliaplots.org/dev/functions-overview.html).

This is an example for the scatter type plot byt replacing _lines_ with _scatter_.

```Julia
using Makie
x = 1:10
y = rand(10, 2)
scene = scatter(x, y, linewidth = 2)
display(scene)
```

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

display(scene)
```

This will display a line and multiple circles scattered at many points as it uses a line and a scatter type graph.