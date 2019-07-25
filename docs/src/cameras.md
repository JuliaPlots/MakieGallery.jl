# Cameras

A `Camera` is simply a viewport through which the Scene is visualized.  `Makie` offers 2D and 3D projections, and 2D plots can be projected in 3D!

To specify the camera you want to use for your Scene, you can set the `camera` attribute.  Currently, we offer four types of camera:

```@docs
cam2d!
cam3d!
campixel!
cam3d_cad!
```

which will mutate the camera of the Scene into the specified type.

## Controlling the camera

We offer several functions to control the camera programatically.  
You can rotate, translate, zoom and change the speed of the camera, as well as setting it to "look at" a certain point.

```@docs
translate_cam!
rotate_cam!
zoom!
```

## Updating the camera

Often, when modifying the Scene, the camera can get "out of sync" with the Scene.  To fix this, you can call the `update_cam!` function on the Scene:
```@docs
update_cam!
```
