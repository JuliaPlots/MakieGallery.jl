# Scenes

## What is a `Scene`?

A `Scene` is basically a container for `Plot`s and other `Scene`s.  `Scenes` have `Plot`s (including an `Axis` if `show_axis = true`) and `Subscenes` associated with them.  Every Scene has a transformation, made up of _scale_, _translation_, and _rotation_.

Plots associated with a Scene can be accessed through `scene.plots`, which returns an Array of the plots associated with the `Scene`.  Note that if `scene` has no plots (if it was created by layouting, or is an empty scene), then `scene.plots` will be a _0-element array_!

A Scene's subscenes (also called children) can be accessed through `scene.children`.  This will return an Array of the `Scene`'s child scenes.  A child scene can be created by `childscene = Scene(parentscene)`.

Any `Scene` with an axis also has a `camera` associated with it; this can be accessed through `scene.camera`, and its controls through `scene.camera.cameracontrols`.  More documentation about these is in the [Cameras](@ref) section.

## Subscenes

A subscene is no different than a normal Scene, except that it is linked to a "parent" Scene.  It inherits the transformations of the parent Scene, but can then be transformed independently of it.

<!--TODO add universe example here-->

## Modifying the Scene

Makie offers mutation functions to scale, translate and rotate your Scenes on the fly.

```@docs
translate!
rotate!
scale!
```
