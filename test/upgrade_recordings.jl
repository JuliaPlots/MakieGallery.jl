repo = joinpath(homedir(), "ReferenceImages", "gallery")
recordings = joinpath(@__DIR__, "test_recordings")
cp(repo, recordings, force = true)
?
