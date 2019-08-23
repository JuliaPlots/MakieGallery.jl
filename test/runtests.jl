using Test
using FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics
_minimal = get(ENV, "MAKIEGALLERY_MINIMAL", "false")

printstyled("Running ", bold = true, color = :blue)
_minimal == "true"  && printstyled("short tests\n", bold = true, color = :yellow)
_minimal == "false" && printstyled("full tests\n", bold = true, color = :green)

database = (_minimal == "true") ? MakieGallery.load_tests() : MakieGallery.load_database()
# We have lots of redundant examples, so no need to test all of them every time
# (We should before a tag + deploy docs though)
# Since there is no super good way to trim the examples, I just measured
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
# # we directly modify the database, which seems easiest for now
# filter!(entry-> !(entry.title in slow_examples), database)

exclude = (
    "Cobweb plot", # has some weird scaling issue on CI
    "Colormap collection", # has one size different...
)

# Download is broken on CI
filter!(entry-> !("download" in entry.tags) && !(entry.title in exclude), database)

printstyled("Creating ", color = :green, bold = true)

println("recording folders")

tested_diff_path = joinpath(@__DIR__, "tested_different")
test_record_path = joinpath(@__DIR__, "test_recordings")

println("Diff path  : $tested_diff_path")
println("Record path: $test_record_path")

rm(tested_diff_path, force = true, recursive = true)
mkpath(tested_diff_path)

rm(test_record_path, force = true, recursive = true)
mkpath(test_record_path)


printstyled("Recording ", color = :green, bold = true)
println("examples")
examples = MakieGallery.record_examples(test_record_path)
if length(examples) != length(database)
    @warn "Not all examples recorded"
end

# MakieGallery.generate_preview(test_record_path, joinpath(homedir(), "Desktop", "index.html"))
# MakieGallery.generate_thumbnails(test_record_path)
# MakieGallery.gallery_from_recordings(test_record_path, joinpath(test_record_path, "index.html"))
#

printstyled("Running ", color = :green, bold = true)
println("visual regression tests")

MakieGallery.run_comparison(test_record_path, tested_diff_path)
