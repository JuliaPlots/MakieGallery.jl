function save_media(entry, x::Scene, path::String)
    path = joinpath(path, "image.jpg")
    save(path, x)
    [path]
end

function save_media(entry, x::String, path::String)
    out = joinpath(path, basename(x))
    if out != x
        mv(x, out, force = true)
    end
    [out]
end

function save_media(entry, x::Makie.Stepper, path::String) # TODO: this breaks thumbnail generation
    # return a list of all file names
    images = filter(x-> endswith(x, ".jpg"), readdir(x.folder))
    return map(images) do img
        p = joinpath(x.folder, img)
        out = joinpath(path, basename(p))
        mv(p, out, force = true)
        out
    end
end


function save_media(example, events::RecordEvents, path::String) #TODO: this breaks thumbnail generation
    # the path is fixed at record time to be stored relative to the example
    epath = event_path(example, "")
    isfile(epath) || error("Can't find events for example: $(example.unique_name). Please run `record_example_events()`")
    # the current path of RecordEvents is where we now actually want to store the video
    video_path = joinpath(path, "video.mp4")
    record(events.scene, video_path) do io
        replay_events(events.scene, epath) do
            recordframe!(io)
        end
    end
    return [video_path]
end

"""
    embed_image(path::AbstractString)
Returns the html to embed an image
"""
function embed_image(path::AbstractString, alt = "")
    """
    <img src=$(repr(path)) alt=$(repr(alt))>
    """
end

"""
    embed_video(path::AbstractString)

Generates a html formatted string for embedding video into Documenter Markdown files
(since `Documenter.jl` doesn't support directly embedding mp4's using ![]() syntax).
"""
function embed_video(path::AbstractString, alt = "")
    """
    <video controls autoplay loop muted>
      <source src=$(repr(path)) type="video/mp4">
      Your browser does not support mp4. Please use a modern browser like Chrome or Firefox.
    </video>
    """
end

"""
Embeds the most common media types as html
"""
function embed_media(path::String, alt = "")
    file, ext = splitext(path)
    if ext in (".png", ".jpg", ".jpeg", ".JPEG", ".JPG", ".gif")
        return embed_image(path, alt)
    elseif ext == ".mp4"
        return embed_video(path, alt)
    else
        error("Unknown media extension: $ext")
    end
end


"""
Embeds a vector of media files as HTML
"""
function embed_media(io::IO, paths::AbstractVector{<: AbstractString}, caption = "")
    for (i, path) in enumerate(paths)
        println(io, """
        <div style="display:inline-block">
            <p style="display:inline-block; text-align: center">
                $(embed_media(path, caption))
            </p>
        </div>
        """)
    end
end

"""
Replaces raw html code nodes with an actual RawHTML node.
"""
function preprocess!(md)
    map!(md.content, md.content) do c
        if c isa Markdown.Code && c.language == "@raw html"
            Documenter.Documents.RawHTML(c.code)
        else
            c
        end
    end
    md
end
function md2html(md_path)
    open(joinpath(dirname(md_path), "index.html"), "w") do io
        md = preprocess!(Markdown.parse_file(md_path))
        println(io, """
        <!doctype html>
        <html>
          <head>
            <meta charset="UTF-8">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/JuliaDocs/Documenter.jl/assets/html/documenter.css">
          </head>
          <body>
            $(string(HTMLWriter.mdconvert(md)))
          </body>
        </html>
        """)
    end
end

"""
    save_markdown(mdpath::String, example::CellEntry, media::Vector{String})

Creates a Markdown representation from an example at `mdpath`.
`media` is a vector of media output files belonging to the example
"""
function save_markdown(mdpath::String, example::CellEntry, media::Vector{String})
    src = example2source(
        example,
        scope_start = "",
        scope_end = "",
        indent = "",
        outputfile = (entry, ending)-> string("output", ending)
    )
    open(mdpath, "w") do io
        println(io, "## ", example.title, "\n")
        println(io, "```julia\n$src\n```")
        println(io, "```@raw html\n")
        embed_media(io, media)
        println(io, "```")
    end
end


const last_evaled = Ref{Symbol}()


"""
    record_examples(folder = ""; resolution = (500, 500), resume = false)

Records all examples in the database. If error happen, you can fix them and
start record with `resume = true`, to start at the last example that errored.
"""
function record_examples(folder = ""; resolution = (500, 500), resume = false)
    function output_path(entry, ending)
        joinpath(folder, "tmp", string(entry.unique_name, ending))
    end
    ispath(joinpath(folder, "tmp")) || mkdir(joinpath(folder, "tmp"))
    result = []
    start = if resume && isassigned(last_evaled)
        idx = findfirst(e-> e.unique_name == last_evaled[], database)
        idx === nothing ? 1 : min(idx + 1, length(database))
    else
        1
    end
    @info("starting from index $start")
    AbstractPlotting.set_theme!(resolution = resolution)
    eval_examples(outputfile = output_path, start = start) do example, value
        Random.seed!(42)
        uname = example.unique_name
        subfolder = joinpath(folder, string(uname))
        outfolder = joinpath(subfolder, "media")
        ispath(outfolder) || mkpath(outfolder)
        paths = save_media(example, value, outfolder)
        mdpath = joinpath(subfolder, "index.md")
        save_markdown(mdpath, example, master_url.(paths))
        md2html(mdpath)
        push!(result, subfolder)
        last_evaled[] = uname
        AbstractPlotting.set_theme!(resolution = resolution) # reset befor next example
    end
    rm(joinpath(folder, "tmp"), recursive = true, force = true)
    result
end

"""
Creates a Gallery in `html_out` from already recorded examples in `folder`.
"""
function gallery_from_recordings(
        folder::String,
        html_out::String = abspath(joinpath(pathof(MakieGallery), "..", "..", "index.html"));
        tags = [string.(AbstractPlotting.atomic_function_symbols)..., "interaction"]
    )
    items = map(MakieGallery.database) do example
        base_path = joinpath(folder, string(example.unique_name))
        media_path = joinpath(base_path, "media")
        media = master_url.(joinpath.(media_path, readdir(media_path)))
        mdpath = joinpath(base_path, "index.md")
        save_markdown(mdpath, example, media)
        md2html(mdpath)
        MediaItem(base_path, example)
    end
    open(html_out, "w") do io
        println(io, create_page(items, tags))
    end
end
