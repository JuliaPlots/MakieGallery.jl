<div align="center">
<img src="https://raw.githubusercontent.com/JuliaPlots/Makie.jl/sd/abstract/docs/src/assets/logo.png" alt="Makie.jl" width="480">
</div>

Build status: [![][gitlab-img]][gitlab-url] [![Build Status](https://travis-ci.com/JuliaPlots/MakieGallery.jl.svg?branch=master)](https://travis-ci.com/JuliaPlots/MakieGallery.jl)

[gitlab-img]: https://gitlab.com/JuliaGPU/MakieGallery-jl/badges/master/pipeline.svg
[gitlab-url]: https://gitlab.com/JuliaGPU/MakieGallery-jl/pipelines

[travis-img]: https://gitlab.com/JuliaGPU/MakieGallery-jl/badges/master/pipeline.svg
[travis-url]: https://gitlab.com/JuliaGPU/MakieGallery-jl/pipelines

[Makie example gallery generated with this package](http://juliaplots.org/MakieReferenceImages/gallery/index.html)

## Mouse interaction:

[<img src="https://user-images.githubusercontent.com/1010467/31519651-5992ca62-afa3-11e7-8b10-b66e6d6bee42.png" width="489">](https://vimeo.com/237204560 "Mouse Interaction")

## Animating a surface:

[<img src="https://user-images.githubusercontent.com/1010467/31519521-fd67907e-afa2-11e7-8c43-5f125780ae26.png" width="489">](https://vimeo.com/237284958 "Surface Plot")


## Complex examples
<a href="https://github.com/JuliaPlots/Makie.jl/blob/master/examples/bigdata.jl#L2"><img src="https://user-images.githubusercontent.com/1010467/48002153-fc15a680-e10a-11e8-812d-a5d717c47288.gif" width="480"/></a>

## Running examples in the REPL:
```julia
julia> using MakieGallery
julia> database = MakieGallery.load_database();
julia> database[1].title # can be used e.g. for filter(x-> x.title == "...", database)
"Tutorial simple scatter"
julia> database[1] # pretty printing :)
...
 x = rand(10)
 y = rand(10)
 colors = rand(10)
 scene = scatter(x, y, color = colors)
...
julia> using Makie
julia> MakieGallery.eval_example(database[1]) # run it!
```

# Developing this package

## Adding an example

MakieGallery hosts a lot of examples describing how to use Makie.jl.  
To add a standalone example, find the file where it fits best, and add a new `@cell` entry
(or a new `@block` entry if you want to add more examples in the future).  
If you want to add multiple examples, you probably want to add a new `@block`, or even a new file.

## Building the documentation

`MakieGallery` hosts documentation for Makie.jl.  
However, this documentation requires the reference images to be downloaded in the home directory
(configurability via an environment variable is planned).  
You can get the reference images from https://github.com/JuliaPlots/MakieReferenceImages -
it's a large repository, so you may want to shallow clone.
