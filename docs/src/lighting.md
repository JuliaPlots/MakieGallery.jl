# Lighting

For 3-D scenes, GLMakie offers several attributes to control the lighting of the scene.  These are set per plot.

- `ambient::Vec3f0`: Objects should never be completely dark; we use an ambient light to simulate background lighting, and give the object some color.  Each element of the vector represents the intensity of color in R, G or B respectively.
- `diffuse::Vec3f0`: Simulates the directional impact which the light source has on the plot object. This is the most visually significant component of the lighting model; the more a part of an object faces the light source, the brighter it becomes.  Each element of the vector represents the intensity of color in R, G or B respectively.
- `specular::Vec3f0`: Simulates the bright spot of a light that appears on shiny objects. Specular highlights are more inclined to the color of the light than the color of the object.  Each element of the vector represents the intensity of color in R, G or B respectively.


- `shininess::Float32`: Controls the shininess of the object.   This value must be positive. 
- `lightposition::Vec3f0`: The location of the main light source; by default, the light source is at the location of the camera.

You can find more information on how these were implemented [here](https://learnopengl.com/Lighting/Basic-Lighting).

## SSAO

GLMakie also implements [_screen-space ambient occlusion_](https://learnopengl.com/Advanced-Lighting/SSAO), which is an algorithm to more accurately simulate the scattering of light.  There are a couple of controllable attributes nested within the `SSAO` toplevel attribute:

- `radius` sets the range of SSAO. You may want to scale this up or
  down depending on the limits of your coordinate system
- `bias` sets the minimum difference in depth required for a pixel to
  be occluded. Increasing this will typically make the occlusion
  effect stronger.
- `blur` sets the range of the blur applied to the occlusion texture.
  The texture contains a (random) pattern, which is washed out by
  blurring. Small `blur` will be faster, sharper and more patterned.
  Large `blur` will be slower and smoother. Typically `blur = 2` is
  a good compromise.

## Examples

@example_database("Lighting")
@example_database("Ambient Occlusion")
