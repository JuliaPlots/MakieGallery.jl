repo = joinpath(homedir(), "ReferenceImages", "gallery")
MakieGallery.generate_thumbnails(repo)

recordings = joinpath(@__DIR__, "test_recordings")
cp(recordings, repo, force = true)
