# Backends

There are three main backends for AbstractPlotting:

- `GLMakie` (Desktop, high performance, 100% features) **default**
- `WGLMakie` (Web, fast drawing, 80% features) **Experimental**
- `CairoMakie` (Print, SVG/PDF, 70% features) **2D-only** (for now)

You can activate any backend by `using` the appropriate package and calling it's `activate!` function; to activate WGLMakie, you would do s`using WGLMakie; WGLMakie.activate!()`.

## GLMakie

GLMakie is the native, desktop-based backend, and is the most feature-complete.  
It requires an OpenGL enabled graphics card with OpenGL version 3.3 or higher.

## WGLMakie

WGLMakie is the Web-based backend, and is still experimental (though relatively feature-complete).
Currently, installing it is not straightforward; see the [`WGLMakie.jl` README](https://github.com/JuliaPlots/WGLMakie.jl) for detailed instructions.

## CairoMakie

CairoMakie uses Cairo to draw vector graphics to SVG and PDF.  
It needs Cairo.jl to build properly, which may be difficult on MacOS.
