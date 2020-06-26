# Makie.jl

![Makie.jl](assets/logo.png)

Hi! Welcome to [`Makie`](https://github.com/JuliaPlots/Makie.jl/), a high-performance, extendable, and multi-platform plotting package for [Julia](https://julialang.org/).

## Installation & tutorial

Install Makie by running `]add Makie` (in the REPL) or `Pkg.add("Makie")`.  

If installing the master branch, be sure to also add `AbstractPlotting#master` and `GLMakie#master`

See the [Tutorial](@ref) for how to plot, or the Example Gallery below for examples.

## Example Gallery

```@raw html
 <iframe src="https://juliaplots.org/MakieReferenceImages/gallery/index.html" style = "height:800px;width:100%" frameborder="0"></iframe>
```

## I'm an expert!

Head straight to the [Plotting functions overview](@ref).

## The Ecosystem

What makes up the Makie Ecosystem? `Makie.jl` is the metapackage for a rich ecosystem, which consists of [`GLMakie.jl`](https://github.com/JuliaPlots/GLMakie.jl), [`CairoMakie.jl`](https://github.com/JuliaPlots/CairoMakie.jl) and [`WGLMakie.jl`](https://github.com/JuliaPlots/WGLMakie.jl) (the backends); [`AbstractPlotting.jl`](https://github.com/JuliaPlots/AbstractPlotting.jl) (the bulk of the package); and [`StatsMakie.jl`](https://github.com/JuliaPlots/StatsMakie.jl) (statistical plotting support, as in [`StatsPlots.jl`](https://github.com/JuliaPlots/StatsPlots.jl)).

There are also a number of packages that are being built to extend and enable more customizability within Makie. While these are not part of Makie currently, if you are looking to go a little deeper into what is possible, it is worth looking into them: [MakieThemes.jl](https://github.com/JuliaPlots/MakieThemes.jl)

## Getting Help

If you run into any issues or have questions that you cannot solve on your own by using the help mode in the REPL, here are your options:

1) Open an issue in this repo or the main [Makie.jl](https://github.com/JuliaPlots/Makie.jl) repo.
2) Join the [Julia Slack](https://slackinvite.julialang.org) and look for the `#makie` channel.
