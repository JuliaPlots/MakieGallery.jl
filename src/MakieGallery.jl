module MakieGallery

using AbstractPlotting
using Documenter
using Documenter: Selectors, Expanders
using Markdown
using Markdown: Link, Paragraph
using ImageTransformations, FileIO
using ImageFiltering  # needed for Gaussian-filtering images during resize
using Random
using Documenter.Writers
using Documenter.Writers.HTMLWriter
using Highlights
using Test, Statistics
using FFMPEG
using BinaryProvider
using FixedPointNumbers, Colors, ColorTypes
using SyntaxTree # for prettification of code, removing linenumbernodes

include("documenter_extension.jl")
include("database.jl")
include("io.jl")
include("gallery.jl")
include("visualregression.jl")
include("testruns.jl")

function event_path(entry, ending)
    joinpath(@__DIR__, "..", "examples", "recorded_events", string(entry.unique_name, ".jls"))
end

function assetpath(paths...)
    return normpath(joinpath(@__DIR__, "..", "assets", paths...))
end

function loadasset(paths...)
    return FileIO.load(assetpath(paths...))
end

"""
Loads the full example database and returns it!
"""
function load_database()
    return load_database([
        "tutorials.jl",
        "attributes.jl",
        "intermediate.jl",
        "examples2d.jl",
        "examples3d.jl",
        "interactive.jl",
        "documentation.jl",
        "diffeq.jl",
        "implicits.jl",
        "short_tests.jl",
        "recipes.jl",
        "bigdata.jl",
        "layouting.jl",
        "legends.jl",
        "statsmakie.jl",
        # "geomakie.jl",
    ])
end

"""
    load_tests()
Loads a database of minimal tests and returns it!
"""
function load_tests()
    return load_database([
        "tutorials.jl",
        "short_tests.jl",
        "layouting.jl",
    ])
end

"""
    `load_database(files::Array{String, 1})`

Loads a database with the files given as a String array.
They must be filenames `filename.jl`, and must be located
within `$(dirname(@__DIR__))`.

To get around this assumption, you can pass an absolute path.
"""
function MakieGallery.load_database(files::AbstractVector{<: AbstractString})
    empty!(MakieGallery.unique_names)
    empty!(database)
    nfiles = if !all(isabspath.(files))
            dir = abspath(joinpath(dirname(pathof(MakieGallery)), ".."))
            joinpath.("$dir", "examples", files)
        else
            files
        end

    for file in nfiles
        MakieGallery.eval(:(include($file)))
    end
    database
end


export load_database, eval_example, available_examples, run_example, load

end # module
