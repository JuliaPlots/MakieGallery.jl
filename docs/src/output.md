# Output

Makie overloads the `FileIO` interface, so it is simple to save Scenes as images.


## Static plots

To save a `scene` as an image, you can just write e.g.:

```julia
Makie.save("plot.png", scene)
Makie.save("plot.jpg", scene)
```

where `scene` is the scene handle.

In the backend, `ImageMagick` is used for the image format conversions.

## Stepper plots

A `Stepper` is a scene type that simplifies the cumulative plotting, modifying of an existing scene, and saving of scenes.
These are great for showing off progressive changes in plots, such as demonstrating the effects of theming or changing data.

You can initialize a `Stepper` by doing:

```julia
st = Stepper(scene, @replace_with_a_path)
```

and save the scene content & increment the stepper by using:
```julia
step!(st)
```

@example_database("Stepper demo")

For more info, consult the [Example Gallery](https://simondanisch.github.io/ReferenceImages/gallery/index.html).
