using Test
using FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics

# Environment variables for configuration:
# - `MAKIEGALLERY_MINIMAL` to control whether only short tests or all examples are run.
# - `MAKIEGALLERY_RESUME` to resume recording from the last example.
# - `MAKIEGALLERY_FAST` to control whether the time-consuming examples run or not.
# - `MAKIEGALLERY_REFIMG_DIR` to control where reference images are taken from.

_minimal = get(ENV, "MAKIEGALLERY_MINIMAL", "false") == "true"
_resume  = get(ENV, "MAKIEGALLERY_RESUME",  "false") == "true"
_fast    = get(ENV, "MAKIEGALLERY_FAST",    "false") == "true"
refdir   = get(ENV, "MAKIEGALLERY_REFIMG_DIR", MakieGallery.download_reference());

printstyled("Running ", bold = true, color = :blue)
database  = if _minimal
                printstyled("short tests\n", bold = true, color = :yellow)
                MakieGallery.load_tests()
            elseif _minimal == "false"
                printstyled("full tests\n", bold = true, color = :green)
                MakieGallery.load_database()
            else
                printstyled("full tests\n", bold = true, color = :red)
                @warn("""
                ENV["MAKIEGALLERY_MINIMAL"] = "$_minimal" not one of "true" or "false".
                Assuming true!
                """)
                MakieGallery.load_database()
            end

# Setup MakieGallery's pre-eval and post-eval hooks

MakieGallery.preeval_hook[]  = _ -> begin preeval_cache[] = AbstractPlotting.use_display[]; global display; AbstractPlotting.inline!(!display) end
MakieGallery.posteval_hook[] = _ -> AbstractPlotting.use_display[] = last

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
if _fast
    printstyled("Filtering "; color = :light_cyan, bold = true)
    println("slow examples")
    filter!(entry-> !(entry.title in slow_examples), database)
else
    printstyled("Running "; color = :light_cyan, bold = true)
    println("slow examples")
end

if haskey(ENV, "CI")
    exclude = (
        "Cobweb plot",         # has some weird scaling issue on CI
        "Colormap collection", # has one size different, is also vulnerable to upstream updates.
    )

    filter!(entry-> !(entry.title in exclude), database)
end

# Download is broken on CI
if get(ENV, "CI", "false") == "true"
    printstyled("CI detected\n"; bold = true, color = :yellow)
    println("Filtering out examples which download")
    filter!(entry-> !("download" in entry.tags), database)
end

tested_diff_path = joinpath(@__DIR__, "tested_different")
test_record_path = joinpath(@__DIR__, "test_recordings")

println("Diff path  : $tested_diff_path")
println("Record path: $test_record_path")

# If we are not recording minimally,
# then we remove the recording folders on the path
if !_minimal

    printstyled("Creating ", color = :green, bold = true)

    println("recording folders")

    rm(tested_diff_path, force = true, recursive = true)
    mkpath(tested_diff_path)

    rm(test_record_path, force = true, recursive = true)
    mkpath(test_record_path)

end

printstyled("Recording ", color = :green, bold = true)
println("examples")
examples = MakieGallery.record_examples(test_record_path; resume = _resume)
if length(examples) != length(database)
    @warn "Not all examples recorded"
end

# MakieGallery.generate_preview(test_record_path, joinpath(homedir(), "Desktop", "index.html"))
# MakieGallery.generate_thumbnails(test_record_path)
# MakieGallery.gallery_from_recordings(test_record_path, joinpath(test_record_path, "index.html"))

printstyled("Running ", color = :green, bold = true)
println("visual regression tests")

MakieGallery.run_comparison(test_record_path, tested_diff_path; reference = refdir)
