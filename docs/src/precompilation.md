# Precompilation

You can compile a binary for Makie and add it to your system image for fast plotting times with no JIT overhead, 
using [`PackageCompiler.jl`](https://github.com/JuliaLang/PackageCompiler.jl). 

To do that, you need to check out the additional packages for precompilation. 
Then, you can build a system image like this:


```julia
# add PackageCompiler
Pkg.add("PackageCompiler")
using PackageCompiler
# This is not well tested, so please be careful - I don't take any responsibilities for a messed up Julia install.

# The safe option:
PackageCompiler.compile_incremental(:Makie, :AbstractPlotting, force = false) # can take around ~20 minutes
# After this, to use the system image, you will have to invoke Julia with the sysimg that PackageCompiler provides.

# Replaces Julia's system image
# please be very careful with the option below, since this can make your Julia stop working.
# If Julia doesn't start for you anymore, consider doing:
# using PackageCompiler; PackageCompiler.revert() # <- not well tested

PackageCompiler.compile_incremental(:Makie, :AbstractPlotting, force = true)
```
Should the display not work after compilation, use `AbstractPlotting.__init__()`, or 
force display by calling `display(AbstractPlotting.PlotDisplay(), scene);` on your `Scene`. 

In some cases, the precompilation process may throw an error.  If this happens, we need to dig a 
little deeper into the 
