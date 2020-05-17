# MakieGallery

`MakieGallery.jl` is the repo which hosts these docs, as well as the source code for the examples in the Example Gallery.

Docs are built using [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl), and are located in the `docs` folder.
The raw markdown files from which documentation is generated are located in `docs/src`, but not all the pages are there; some, like [`Plotting functions overview`](@ref), are generated during the documentation build.
Those markdown pages have a `src-` prefix.

## Tests

MakieGallery contains the test suite for the Makie ecosystem; this can be accessed by running `Pkg.test("MakieGallery")`.

The test suite can be configured by setting some environment variables:

- `MAKIEGALLERY_MINIMAL` to control whether only short tests or all examples are run.  Defaults to `"false"`.
- `MAKIEGALLERY_RESUME` to resume recording from the last example.  Defaults to `"false"`.
- `MAKIEGALLERY_FAST` to control whether the time-consuming examples run or not.  Defaults to `"false"`.
- `MAKIEGALLERY_REFIMG_DIR` to control where reference images are taken from.  Defaults to using the default version downloaded by MakieGallery, or downloading that if not present.

## Structure

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

Adding interactive examples will mean you need to create a serialized file which stores the input events.
This can be done using MakieGallery. First, load the database of examples using `MakieGallery.load_database()`. Next, call `MakieGallery.record_example(title::String)` (where title is the string following `\@cell` in the example), wait for the scene to appear and interact with it. All interactions will be recorded while the scene is open and, after closing, saved to an appropriate file.
