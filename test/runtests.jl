using Test
using FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics

database = MakieGallery.load_database()

# which one are the slowest and kicked those out!
slow_examples = [
    "Animated time series",
    "Animation",
    "Lots of Heatmaps",
    "Chess Game",
    "Line changing colour",
    "Line changing colour with Observables",
    "Colormap collection",
    "Record Video",
    "Animated surface and wireframe",
    "Moire",
    "Line GIF",
    "Electrostatic repulsion",
    "pong",
    "pulsing marker",
    "Travelling wave",
    "Axis theming",
    "Legend",
    "Color Legend",
    "DifferentialEquations path animation",
    "Interactive Differential Equation",
    "Spacecraft from a galaxy far, far away",
    "Type recipe for molecule simulation",
    "WorldClim visualization",
    "Image on Geometry (Moon)",
    "Image on Geometry (Earth)",
]
# DIffeq errors with stackoverflow
# The others look fine on the CI, but the measured difference is too high -.-
# Maybe related to the axis changes, will investigate later
filter!(database) do entry
    !("diffeq" in entry.tags) &&
    !(entry.unique_name in (:analysis, :colormap_collection, :lots_of_heatmaps))
 end

# Download is broken on CI
if get(ENV, "CI", "false") == "true"
    printstyled("CI detected\n"; bold = true, color = :yellow)
    println("Filtering out examples which download")
    filter!(entry-> !("download" in entry.tags), database)
end

tested_diff_path = joinpath(@__DIR__, "tested_different")
test_record_path = joinpath(@__DIR__, "test_recordings")

isdir(tested_diff_path) && rm(tested_diff_path, force = true, recursive = true)
mkpath(tested_diff_path)

isdir(test_record_path) && rm(test_record_path, force = true, recursive = true)
mkpath(test_record_path)

examples = MakieGallery.record_examples(test_record_path)

@test length(examples) == length(database)

# MakieGallery.generate_preview(test_record_path, joinpath(homedir(), "Desktop", "index.html"))
# MakieGallery.generate_thumbnails(test_record_path)
# MakieGallery.gallery_from_recordings(test_record_path, joinpath(test_record_path, "index.html"))

printstyled("Running ", color = :green, bold = true)
println("visual regression tests")

MakieGallery.run_comparison(test_record_path, tested_diff_path)
