using Test
using BinaryProvider, FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics
_minimal = get(ENV, "MAKIEGALLERY_MINIMAL", "false")

printstyled("Running ", bold = true, color = :blue)
_minimal == "true"  && printstyled("short tests\n", bold = true, color = :yellow)
_minimal == "false" && printstyled("full tests\n", bold = true, color = :green)

database = (_minimal == "true") ? MakieGallery.load_tests() : MakieGallery.load_database()

# THese examples download additional data - don't want to deal with that!
to_skip = ["WorldClim visualization", "Image on Geometry (Moon)", "Image on Geometry (Earth)"]
# # we directly modify the database, which seems easiest for now
# filter!(entry-> !(entry.title in to_skip), database)

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

# rerecord = [
#     "Robot Arm"
# ]
# filter!(x-> x.title in rerecord, database)

printstyled("Recording ", color = :green, bold = true)
println("examples")

examples = MakieGallery.record_examples(test_record_path)
if length(examples) != length(database)
    @warn "Not all examples recorded"
end

printstyled("Running ", color = :green, bold = true)
println("visual regression tests")

MakieGallery.run_comparison(test_record_path, tested_diff_path)
