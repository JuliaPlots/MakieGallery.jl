repo = joinpath(homedir(), "ReferenceImages", "gallery")

recordings = joinpath(@__DIR__, "test_recordings")

cp(recordings, repo, force = true)

MakieGallery.generate_thumbnails(repo)
