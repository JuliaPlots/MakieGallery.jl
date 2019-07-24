# Animation

`Makie.jl` has extensive support for animations; you can create arbitrary plots, and save them to:
- `.mkv`  (the default, doesn't need to convert)
- `.mp4`  (good for Web, most supported format)
- `.webm` (smallest file size)
- `.gif`  (largest file size for the same quality)

This is all made possible through the use of the `ffmpeg` tool, wrapped by [`FFMPEG.jl`](https://github.com/JuliaIO/FFMPEG.jl).

Have a peek at [Interaction](@ref) for some more information once you're done with this.

## A simple example

Simple animations are easy to make; all you need to do is wrap your changes in the `record` function.

When recording, you can make changes to any aspect of the Scene or its plots.  

Below is a small example of using `record`.

@example_database("Line changing colour")

```@docs
record
```

In both cases, the returned value is a path pointing to the location of the recorded file.

## Animation using time
To animate a scene, you can also create a `Node`, e.g.:

```julia
time = Node(0.0)
```

and use `lift` on the Node to set up a pipeline to access its value. For example:

```julia
scene = Scene()
time = Node(0.1)
myfunc(v, t) = sin.(v .* t)
positions = lift(t -> myfunc.(range(0, stop=2pi, length=50), t), time)
scene = lines!(scene, positions)
```

now, whenever the Node `time` is updated (e.g. when you `push!` to it), the plot will also be updated.

```julia
push!(time, Base.time())
```

You can also set most attributes equal to `Observable`s, so that you need only update
a single variable (like time) during your animation loop.  A translation of the first
example to this `Observables` paradigm is below:

@example_database("Line changing colour with Observables")

A more complicated example:

@example_database("Record Video")

## Appending data to a plot

If you're planning to append to a plot, like a `lines` or `scatter` plot (basically, anything that's point-based),
you will want to pass an `Observable` Array of [`Point`](@ref)s to the plotting function, instead of passing `x`, `y`
(and `z`) as separate Arrays.
This will mean that you won't run into dimension mismatch issues (since Observables are synchronously updated).

TODO add more tips here

## Animating a plot "live"
You can animate a plot in a `for` loop:

```julia
for i = 1:length(r)
    s[:markersize] = r[i]
    # AbstractPlotting.force_update!() is no longer needed
    sleep(1/24)
end
```

Similarly, for plots based on functions:

```julia
scene = Scene()
v = range(0, stop=4pi, length=50)
f(v, t) = sin(v + t) # some function
s = lines!(
    scene,
    lift(t -> f.(v, t), time),
)[end];

for i = 1:length(v)
    time[] = i
    sleep(1/24)
end
```

If you want to animate a plot while interacting with it, check out the `async_latest` function,
and the [Interaction](@ref) section.

## More complex examples

@example_database("Animated surface and wireframe")

You can see yet more complicated examples in the [Example Gallery](index.html)!
