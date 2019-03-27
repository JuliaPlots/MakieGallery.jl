# Troubleshooting

## Installation issues

Here, we assume you are running Julia on the vanilla system image - no PackageCompiler goodness.  If you are using `PackageCompiler`, check out the page on compilation.

### No `Scene` displayed or GLMakie fails to build

If `Makie` builds, but when a plotting, no `Scene` is displayed, as in:

```julia
julia> using Makie

julia> lines([0,1], [0,1])
Scene (960px, 540px):
events:
    window_area: GeometryTypes.HyperRectangle{2,Int64}([0, 0], [0, 0])
    window_dpi: 100.0
    window_open: false
    mousebuttons: Set(AbstractPlotting.Mouse.Button[])
    mouseposition: (0.0, 0.0)
    mousedrag: notpressed
    scroll: (0.0, 0.0)
    keyboardbuttons: Set(AbstractPlotting.Keyboard.Button[])
    unicode_input: Char[]
    dropped_files: String[]
    hasfocus: false
    entered_window: false
plots:
   *Axis2D{...}
   *Lines{...}
subscenes:
   *scene(960px, 540px)
```

then, your backend may not have built correctly.  By default, Makie will try to use GLMakie as a backend, but if it does not build correctly for whatever reason, then scenes will not be displayed.
Ensure that your graphics card supports OpenGL; if it does not (old models, or relatively old integrated graphics cards), then you may want to consider CairoMakie.
