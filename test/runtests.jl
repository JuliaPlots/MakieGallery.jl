using Test
using FileIO, Random, Pkg
using MakieGallery
using AbstractPlotting, GLMakie
using Statistics

database = MakieGallery.load_test_database()
database = MakieGallery.load_database()
# filter!(database) do x
#     x.title == "Axis theming"
# end
# function has_no_recording(x)
#     isempty(readdir(joinpath(test_record_path, string(x.unique_name), "media")))
# end
# filter!(has_no_recording, database)

tested_diff_path = joinpath(@__DIR__, "tested_different")
test_record_path = joinpath(@__DIR__, "test_recordings")

isdir(tested_diff_path) && rm(tested_diff_path, force = true, recursive = true)
mkpath(tested_diff_path)

isdir(test_record_path) && rm(test_record_path, force = true, recursive = true)
mkpath(test_record_path)

examples = MakieGallery.record_examples(test_record_path)

@test length(examples) == length(database)

printstyled("Running ", color = :green, bold = true)
println("visual regression tests")

MakieGallery.run_comparison(test_record_path, tested_diff_path)
#
# cd(test_record_path) do
#   MakieGallery.generate_preview(test_record_path, "index.html")
# end
# MakieGallery.generate_thumbnails(test_record_path)
# MakieGallery.gallery_from_recordings(test_record_path, joinpath(test_record_path, "index.html"))
