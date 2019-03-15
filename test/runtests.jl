using Test
using BinaryProvider, FileIO, Random, Pkg
using MakieGallery
using Makie, AbstractPlotting
using Statistics

database = MakieGallery.load_database()
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
# THese examples download additional data - don't want to deal with that!
examples = MakieGallery.record_examples(test_record_path)
MakieGallery.run_comparison(test_record_path, tested_diff_path)
