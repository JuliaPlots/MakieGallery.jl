using Test
using BinaryProvider, FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics

database = (ENV["MAKIEGALLERY_MINIMAL"] == "true") ? MakieGallery.load_tests() : MakieGallery.load_database()
    
# THese examples download additional data - don't want to deal with that!
# to_skip = ["WorldClim visualization", "Image on Geometry (Moon)", "Image on Geometry (Earth)"]
# # we directly modify the database, which seems easiest for now
# filter!(entry-> !(entry.title in to_skip), database)
tested_diff_path = joinpath(@__DIR__, "tested_different")
test_record_path = joinpath(@__DIR__, "test_recordings")
rm(tested_diff_path, force = true, recursive = true)
mkpath(tested_diff_path)
rm(test_record_path, force = true, recursive = true)
mkpath(test_record_path)
# rerecord = [
#     "Orthographic Camera",
#     "Violin and box plot",
#     "Box plot"
    # "Explicit frame rendering"
# ]
# filter!(x-> x.title in rerecord, database)
examples = MakieGallery.record_examples(test_record_path)
# MakieGallery.generate_preview(test_record_path, joinpath(homedir(), "Desktop", "index.html"))
# MakieGallery.generate_thumbnails(test_record_path)
# MakieGallery.gallery_from_recordings(test_record_path, joinpath(test_record_path, "index.html"))
MakieGallery.run_comparison(test_record_path, tested_diff_path)
