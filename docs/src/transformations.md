# Transformations

Plots, Scenes and Subscenes are all `Transformable`, meaning that `Transformation`s can be applied to transform them.

There are three main convenience functions provided for transformation:

```@docs
translate!
rotate!
scale!
```

```julia
data = RNG.rand(10)

scene = Scene()
st = Stepper(scene, @replace_with_a_path)
lineplot = lines!(scene, data)[end]    # gets the last defined plot for the Scene
scatplot = scatter!(scene, data)[end]  # same thing but the last defined plot is scatter
step!(st)

rotate!(lineplot, 0.025π) # only the lines are rotated, not the scatter
step!(st)
st
```
