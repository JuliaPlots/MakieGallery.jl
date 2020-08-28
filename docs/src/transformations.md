# Transformations

Plots, Scenes and Subscenes are all `Transformable`, meaning that `Transformation`s can be applied to transform them.

There are three main convenience functions provided for transformation:

```@docs
translate!
rotate!
scale!
```

```@example
using Makie
data = rand(10)
scene = Scene()
st = Stepper(scene, "output_folder")
# same thing but the last defined plot is scatter
scatplot = scatter!(scene, data)[end]  
step!(st)

rotate!(lineplot, 0.025π) # only the lines are rotated, not the scatter
step!(st)
st
```
