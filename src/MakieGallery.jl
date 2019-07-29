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

include("documenter_extension.jl")
include("database.jl")
include("io.jl")
include("gallery.jl")
include("visualregression.jl")
include("testruns.jl")

function event_path(entry, ending)
    joinpath(@__DIR__, "..", "examples", "recorded_events", string(entry.unique_name, ".jls"))
end

"""
Loads the full example database and returns it!
"""
function load_database()
    return load_database([
        "tutorials.jl",
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
        "statsmakie.jl",
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
within `joinpath(dirname(pathof(MakieGallery)), "..")`.
(On Linux, this would translate to `MakieGallery/examples/`).
"""
function load_database(files::AbstractVector{<: AbstractString})
    empty!(unique_names)
    empty!(database)
    dir = abspath(joinpath(dirname(pathof(MakieGallery)), ".."))
    nfiles = joinpath.("$dir", "examples", files)
    for file in nfiles
        MakieGallery.eval(:(include($file)))
    end
    database
end

REFIMGDIR = nothing

function __init__()
    global REFIMGDIR
    REFIMGDIR = get(ENV, "MAKIEGALLERY_REFIMG_PATH", joinpath(homedir(), "ReferenceImages"))
end

export load_database, eval_example, available_examples, run_example

end
