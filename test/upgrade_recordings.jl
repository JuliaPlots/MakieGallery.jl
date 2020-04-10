using MakieGallery
MakieGallery.load_database()
function record_selection(
    database, dir;
    selection = MakieGallery.get_unrecorded_examples(MakieGallery.database, dir),
    kwargs...
    )

    db = filter(x -> x.unique_name ∈ selection, MakieGallery.database)

    old_db = copy(database)

    empty!(MakieGallery.database)
    append!(MakieGallery.database, db)

    examples = MakieGallery.record_examples(repo; kwargs...)

    empty!(MakieGallery.database)
    append!(MakieGallery.database, old_db)

    return examples
end

empty!(MakieGallery.plotting_backends)
append!(MakieGallery.plotting_backends, ["Makie"])

# we need to clone the repo - this means git must be installed on the user system.

# load the database.  TODO this is a global and should be changed.
# Here, we reorder the database, to make it easier to see.
database = MakieGallery.load_database([
    "tutorials.jl",
    "layouting.jl",
    "legends.jl",
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
repo = get(ENV, "MAKIEGALLERY_REFIMG_PATH", joinpath(homedir(), ".julia", "dev", "MakieReferenceImages"))
repo = joinpath(homedir(), "MakieReferenceImages")

# clone if not present
isdir(repo) || run(`git clone --depth=1 https://github.com/JuliaPlots/MakieReferenceImages $repo`)

gallery     = joinpath(repo, "gallery")
recordings  = joinpath(@__DIR__, "test_recordings")
differences = joinpath(@__DIR__, "tested_different")

# MakieGallery.generate_preview(recordings, joinpath(recordings, "index.html"))

# Here, we redefine the order of the refimages, to our preferred order.

preferred_order = abspath.(joinpath.(
    dirname(pathof(MakieGallery)),
    "..",
    "examples",
    [
    "tutorials.jl",
    "statsmakie.jl",
    "examples2d.jl",
    "examples3d.jl",
    "layouting.jl",
    "interactive.jl",
    "diffeq.jl",
    "implicits.jl",
    "geomakie.jl",
    "documentation.jl",
    "recipes.jl",
    "bigdata.jl",
    "attributes.jl",
    "intermediate.jl",
    "short_tests.jl",
    ]
))

sort!(database, by = x -> findfirst(==(x.file), preferred_order))

diff_uids  = Symbol.(readdir(differences))
unrec_uids = MakieGallery.get_unrecorded_examples(MakieGallery.database, repo)
recorded_examples = Symbol.(readdir(recordings))
gallery_examples  = Symbol.(readdir(gallery))

to_record = setdiff(unrec_uids, gallery_examples)

record_selection(database, recordings; selection = to_record, generate_thumbnail = true)

for uid in union(diff_uids, unrec_uids)
    if uid ∈ recorded_examples
        mkpath(joinpath(gallery, string(uid)))
        cp(
            joinpath(recordings, string(uid)),
            joinpath(gallery, string(uid));
            force = true
        )
    else
        @warn "Example with unique name $uid was not recorded and not listed."
    end
end

# generate `thumb.jpg` for every directory in `recordings`
MakieGallery.generate_thumbnails(gallery)

# generate HTML pages for the Gallery
MakieGallery.gallery_from_recordings(
    repo * "/gallery",
    joinpath(gallery, "index.html");
    hltheme = MakieGallery.Highlights.Themes.DefaultTheme
)

cd(repo)
run(`git stage -A`)
run(`git commit -am "Reference image update"`)
run(`git push`)
