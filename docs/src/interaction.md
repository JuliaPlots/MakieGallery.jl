# Interaction
Makie offers a sophisticated referencing system to share attributes across the Scene
in your plot. This is great for interaction, animations and saving resources -- also if the backend
decides to put data on the GPU you might even share those in GPU memory.

Interaction and animations in Makie are handled by using [`Observables`](https://juliagizmos.github.io/Observables.jl/stable/). An "observable", called `Node` in Makie, is a structure that can have its value updated interactively.
Interaction, animations and more are done using `Node`s and event triggers.

In this page we overview how the `Node`s pipeline works, how event-triggering works, and we give an introduction to the existing "atomic" functions for interaction.
Examples that use interaction can be found in the Examples/`interaction` page (see [Example Gallery](http://juliaplots.org/MakieReferenceImages/gallery/index.html) as well).

Have a peek at [Animation](@ref) for some more information once you're done with this.

## `Node` interaction pipeline
### The `Node` structure
A `Node` is a Julia structure that allows its value to be updated interactively. This means that anything that uses a `Node` could have its behavior updated interactively, as we will showcase in this page.

Let's start by creating a `Node`:
```julia
x = Node(0.0) # set up a Node, and give it a default value of 0.0
```

```
Observable{Float64} with 0 listeners. Value:
0
```

The value of the `x` can be changed simply using `push!`:
```julia
julia> x[] = 3.34;
julia> x
Observable{Float64} with 0 listeners. Value:
3.34
```

Notice that you can access the value of a `Node` by indexing it with nothing, i.e. `x[]`. However, we recommend to use the function [`to_value`](@ref) to get the value of a `Node`, because `to_value` is a general function that works with all types instead of only `Node`s. E.g.:
```julia
to_value(x)
```

```
3.34
```

### `Node`s depending on other `Node`s

You can create a node depending on another node using [`lift`](@ref):

```julia
f(a) = a^2
y = lift(a -> f(a), x)
```

```
Observable{Float64} with 0 listeners. Value:
11.1556
```

Now, for every value of the `Node` `x`, the derived `Node` `y` will hold the value `f(x)`. Updating the value of `x` _will also update_ the value of `y`!

For example:
```julia
x[] = 10.0
for i in (x, y)
    println(to_value(i))
end
```

```
10.0
100.0
```

That is to say, the `Node` `y` maps the function `f` (which is `a -> a^2` in this case) on `x` whenever the `Node` `x` is updated, and updates the corresponding value in `y`.
This is the basis of updating `Node`s, and is used for updating plots in Makie.
Any plot created based on this pipeline system will get updated whenever the nodes it is based on are updated!

*Note: for now, `lift` is just an alias for `Observables.map`,
and `Node` is just an alias for `Observables.Observable`. This allows decoupling of the APIs.*

#### Shorthand macro for `lift`

When using [`lift`](@ref), it can be tedious to reference each participating `Node`
at least three times, once as an argument to `lift`, once as an argument to the closure that
is the first argument, and at least once inside the closure:

```julia
x = Node(rand(100))
y = Node(rand(100))
z = lift((x, y) -> x .+ y, x, y)
```

To circumvent this, you can use the `@lift` macro. You simply write the operation
you want to do with the lifted `Node`s and prepend each `Node` variable
with a dollar sign $. The macro will lift every Node variable it finds and wrap
the whole expression in a closure. The equivalent to the above statement using `@lift` is:

```julia
z = @lift($x .+ $y)
```

This also works with multiline statements and tuple or array indexing:

```julia
multiline_node = @lift begin
    a = $x[1:50] .* $y[51:100]
    b = sum($z)
    a - b
end
```

### Event triggering
Often it is the case that you want an event to be triggered each time a `Node` has its value updated.
This is done using the `on-do` block from `Observables`.
For example, the following code block "triggers" whenever `x`'s value is changed:
```julia
on(x) do val
    println("x just got the value $val")
end
```

```
#29 (generic function with 1 method)
```

As you can see, at we have run this block in Julia, but nothing happened yet.
Instead, a function was defined. However, upon doing:
```julia
push!(x, 5.0);
```

```
x just got the value 5.0
```

Boom! The event of the `on-do` block was triggered!
We will be using this in the following paragraphs to establish interactivity.

For more info please have a look at [`Observables`](https://juliagizmos.github.io/Observables.jl/stable/).

## Atomic interaction functions
This section overviews some simple and specific functions that make interaction much simpler.

_coming soon..._

There are three principal plot elements that you can use to make your plot interactive.  These are `Slider`, `textslider`, and `Button`.

### Slider

Sliders are quite simple to make.  They can be created by a call to the function `slider`, which usually takes the form:

```julia
sl = slider(range::AbstractVector, raw = true, camera = campixel!, start = somevalue)
```

which makes `sl` a Scene with only one `slider`.  The `slider` will go through `range`, and start at `somevalue`.  `range` must be a subtype of `AbstractVector`, meaning an `Array{T, 1}`, a `LinRange`, et cetera.

To access the value of the `slider` as an Observable, we can simply access `sl[end][:value]`, which will return an Observable which will contain the value that the slider is on.  You can then use that `Observable` in a call to `lift`.

A common way to use `slider`s is to `hbox` or `vbox` them with the Scene which depends on them.

### Button

Buttons are clickable markers that can call a function on click, passing to it the number of clicks so far, on each click. A simple exmaple is as follows:

```julia
b1 = button("Test Button")
lift(b1[end].clicks) do clicks
    println("Button was clicked!")
    #Your function goes here
end
```

### Textslider

Textsliders are a special case of sliders, with two key diferences - they automatically `hbox` a label with the slider, and they return a 2-tuple consisting of the `Scene` of the slider, and its value as an `Observable`.  Usually, they will be called like so:

```julia
sl, ol = textslider(-1:0.01:1, "label", start = 0)
```


## Interaction using the mouse
A few default Nodes are already implemented in a `scene`'s Events (see them in `scene.events`), so to use them in your interaction pipeline, you can simply `lift` them.

For example, for interaction with the mouse cursor, `lift` the `mouseposition` signal.

```julia
pos = lift(scene.events.mouseposition) do mpos
    # do stuff
end
```

## Interaction using the keyboard

To listen to keyboard events, you can `lift` `scene.events.keyboardbuttons`, which returns an enum that can be used with some utility functions to implement a keyboard event handler.

```julia
dir = lift(scene.events.keyboardbuttons) do but
    global last_dir
    ispressed(but, Keyboard.left) && return 1
    ispressed(but, Keyboard.up) && return 2
    ispressed(but, Keyboard.right) && time[] += 1
    ispressed(but, Keyboard.down) && return 0
    last_dir
end
```
<!--TODO make an actual example
TODO can we make a keyboard viewer in Makie?-->
