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
using Test, Statistics
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
Loads the example database and returns it!
"""
function load_database()
    empty!(unique_names)
    empty!(database)
    dir = abspath(joinpath(dirname(pathof(MakieGallery)), ".."))
    files = [
        "$dir/examples/tutorials.jl",
        "$dir/examples/examples2d.jl",
        "$dir/examples/examples3d.jl",
        "$dir/examples/interactive.jl",
        "$dir/examples/documentation.jl",
        "$dir/examples/implicits.jl",
        "$dir/examples/short_tests.jl",
        "$dir/examples/recipes.jl",
        "$dir/examples/bigdata.jl",
        "$dir/examples/layouting.jl",
        "$dir/examples/statsmakie.jl",
    ]
    for file in files
        MakieGallery.eval(:(include($file)))
    end
    database
end

end
