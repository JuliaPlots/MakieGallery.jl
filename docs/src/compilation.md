# Static compilation of Makie


## Compiling into system image

You can compile a binary for Makie and add it to your system image for fast plotting times with no JIT overhead, using [`PackageCompiler.jl`](https://github.com/JuliaLang/PackageCompiler.jl).

To do that, you need to check out the additional packages for precompilation.  Then, you can build a system image using the `compile_incremental` method.

What this will do is generate a list of statements to compile using Makie's tests, which are stored in `test/runtests.jl`.  These tests are exhaustive and use most, if not all, of Makie's functionality.

To do the precompilation, you need only specify which packages you want to precompile, and `PackageCompiler` will do the rest.  First, make sure you have PackageCompiler:


```julia
# add PackageCompiler
Pkg.add("PackageCompiler")
using PackageCompiler
```

### The 'safe' method

Using PackageCompiler is inherently risky, but the chances of it messing up your Julia install if you don't `force` are minimal.  The safe method outlined here will create a new system image in `PackageCompiler`'sdirectory, which you can use with Julia by calling `julia --sysimage path/to/sysimg.so`.  You can also alias this command to something like `juliam` for ease of access.

```julia
nso, cso = PackageCompiler.compile_incremental(:Makie, :AbstractPlotting, force = false) # can take around ~20 minutes
nso # path to new system image
```

### The 'risky' method

There is another approach, which will rewrite your current system image file.  This may brick your Julia install; to revert, consider doing `using PackageCompiler; PackageCompiler.revert()`.  However, note that this is not well tested and you may have to reinstall Julia.

```julia
# Replaces Julia's system image
# please be very careful with the option below, since this can make your Julia stop working.

PackageCompiler.compile_incremental(:Makie, :AbstractPlotting, force = true)
```

## After precompilation

Due to some issues around the precompilation of the display stack, you will have to call `AbstractPlotting.__init__()` after `using AbstractPlotting` to display plots.  Alternatively, you can do `display(AbstractPlotting.PlotDisplay(), scene);` on your `Scene` to get it to display in a plot window.

If you plan to modify or develop Makie, any changes you make to Makie will not propagate normally, since the functions are already in the system image.  You will have to, using Atom (the IDE), `eval` the changed files.
