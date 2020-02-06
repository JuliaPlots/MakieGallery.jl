using MakieGallery

# load the database.  TODO this is a global and should be changed.
# Here, we reorder the database, to make it easier to see.
database = MakieGallery.load_database([
    "tutorials.jl",
    "layouting.jl",
    "statsmakie.jl",
    "geomakie.jl",
    "examples2d.jl",
    "examples3d.jl",
    "interactive.jl",
    "documentation.jl",
    "diffeq.jl",
    "implicits.jl",
    "recipes.jl",
    "bigdata.jl",
    "short_tests.jl",
    "attributes.jl",
    "intermediate.jl",
]);

# where is the refimage repo?
repo = joinpath(get(ENV, "MAKIEGALLERY_REFIMG_PATH", joinpath(homedir(), "ReferenceImages")), "gallery")

recordings = joinpath(@__DIR__, "test_recordings")

# MakieGallery.generate_preview(recordings, joinpath(recordings, "index.html"))

# generate `thumb.jpg` for every directory in `recordings`
MakieGallery.generate_thumbnails(recordings)

# generate HTML pages for the Gallery and
MakieGallery.gallery_from_recordings(
    recordings,
    joinpath(recordings, "index.html");
    hltheme = MakieGallery.Highlights.Themes.DefaultTheme
)

# move this content to the repo
cp(recordings, repo, force = true)
