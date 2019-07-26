# MakieGallery

`MakieGallery.jl` is the repo which hosts these docs, as well as the source code for the examples in the Example Gallery.

Docs are built using [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl), and are located in the `docs` folder.  
The raw markdown files from which documentation is generated are located in `docs/src`, but all the pages are not there; some, like `Plotting functions overview`, are generated during documentation build.  
Those markdown pages have a `src-` prefix.

Examples live in the `examples` directory, and are organized into several Julia files.
Each file is structured into several `@block`s which contain `@cell`s.  Each cell contains one example; the syntax is generally:
```julia
@cell "$title" [labels...] begin
    # example code here
end
```
The `@block` is a way to organize many cells which have a common theme or purpose.  The syntax is generally:
```julia
@block FirstnameLastname [labels...] begin
    # cells here
end
```
Blocks are a nice way to preserve authorship and group similar examples.

## Contributing Examples

If you want to add a single example, it's probably best to find a file it fits well in and add a cell.

If you want to add multiple examples, you may want to create a block in the appropriate file.

Adding interactive examples will mean you need to create a serialized file which stores the input events; this can be done by using the `MakieGallery.record_example(title::String)` function, and interacting with (and then closing) the Scene.
