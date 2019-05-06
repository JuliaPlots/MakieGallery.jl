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

function save_media(entry, x::AbstractPlotting.Stepper, path::String)
    # return a list of all file names
    images = filter(x-> endswith(x, ".jpg"), readdir(x.folder))
    return map(images) do img
        p = joinpath(x.folder, img)
        out = joinpath(path, basename(p))
        mv(p, out, force = true)
        out
    end
end

function save_media(entry, results::AbstractVector, path::String)
    paths = String[]
    for (i, res) in enumerate(results)
        if res isa Scene
            img = joinpath(path, "image$i.jpg")
            save(img, res)
            push!(paths, img)
        end
    end
    paths
end


function save_media(example, events::RecordEvents, path::String)
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
        occursin("thumb", path) && continue
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


const last_evaled = Ref{Int}()

"""
    set_last_evaled!(database_idx::Int)
Set's last evaled for resume
"""
function set_last_evaled!(database_idx::Int)
    last_evaled[] = database_idx - 1
    database_idx
end

"""
    set_last_evaled!(database_idx::Int)
Set's last evaled for resume
"""
function set_last_evaled!(unique_name::Symbol)
    idx = findfirst(e-> e.unique_name == unique_name, database)
    if idx === nothing
        error("Unique name $unique_name not found in database")
    end
    last_evaled[] = idx - 1 # minus one, because record_example will start at idx + 1
end

"""
    record_examples(folder = ""; resolution = (500, 500), resume = false)

Records all examples in the database. If error happen, you can fix them and
start record with `resume = true`, to start at the last example that errored.
"""
function record_examples(
        folder = "";
        resolution = (500, 500), resume::Union{Bool, Integer} = false,
        generate_thumbnail = false
    )
    last = AbstractPlotting.use_display[]
    AbstractPlotting.inline!(true)
    function output_path(entry, ending)
        joinpath(folder, "tmp", string(entry.unique_name, ending))
    end
    ispath(folder) || mkpath(folder)
    ispath(joinpath(folder, "tmp")) || mkdir(joinpath(folder, "tmp"))
    result = []
    start = if resume isa Int
        start = resume
    elseif (resume isa Bool) && resume && last_evaled[] >= 0 && last_evaled[] < length(database)
        last_evaled[] + 1
    else
        1
    end
    @info("starting from index $start")
    AbstractPlotting.set_theme!(resolution = resolution)
    eval_examples(outputfile = output_path, start = start) do example, value
        uname = example.unique_name
        println("running $(uname)")
        subfolder = joinpath(folder, string(uname))
        outfolder = joinpath(subfolder, "media")
        ispath(outfolder) || mkpath(outfolder)
        save_media(example, value, outfolder)
        push!(result, subfolder)
        set_last_evaled!(uname)
        AbstractPlotting.set_theme!(resolution = resolution) # reset befor next example
    end
    rm(joinpath(folder, "tmp"), recursive = true, force = true)
    gallery_from_recordings(folder, joinpath(folder, "index.html"))
    generate_thumbnail && generate_thumbnails(folder)
    AbstractPlotting.use_display[] = last
    result
end

"""
Creates a Gallery in `html_out` from already recorded examples in `folder`.
"""
function gallery_from_recordings(
        folder::String,
        html_out::String = abspath(joinpath(pathof(MakieGallery), "..", "..", "index.html"));
        tags = [
            string.(AbstractPlotting.atomic_function_symbols)...,
            "interaction",
            "record",
            "statsmakie",
            "vbox",
            "layout",
            "legend",
            "colorlegend",
            "vectorfield",
            "poly",
            "camera",
            "recipe",
            "theme",
            "annotations"
        ]
    )
    items = map(MakieGallery.database) do example
        base_path = joinpath(folder, string(example.unique_name))
        media_path = joinpath(base_path, "media")
        media = master_url.(folder, joinpath.(media_path, readdir(media_path)))
        mdpath = joinpath(base_path, "index.md")
        save_markdown(mdpath, example, media)
        md2html(mdpath)
        MediaItem(base_path, example)
    end
    open(html_out, "w") do io
        println(io, create_page(items, tags))
    end
end




function rescale_image(path::AbstractString, target_path::AbstractString, sz::Int = 200)
    !isfile(path) && error("Input argument must be a file!")
    img = FileIO.load(path)
    # calculate new image size `newsz`
    (height, width) = size(img)
    (scale_height, scale_width) = sz ./ (height, width)
    scale = min(scale_height, scale_width)
    newsz = round.(Int, (height, width) .* scale)

    # filter image + resize image
    gaussfactor = 0.4
    σ = map((o,n) -> gaussfactor*o/n, size(img), newsz)
    kern = KernelFactors.gaussian(σ)   # from ImageFiltering
    imgf = ImageFiltering.imfilter(img, kern, NA())
    newimg = ImageTransformations.imresize(imgf, newsz)
    # save image
    FileIO.save(target_path, newimg)
end


"""
    generate_thumbnail(path::AbstractString, target_path, thumb_size::Int = 200)

Generates a (proportionally-scaled) thumbnail with maximum side dimension `sz`.
`sz` must be an integer, and the default value is 200 pixels.
"""
function generate_thumbnail(path, thumb_path, thumb_size = 128)
    if any(ext-> endswith(path, ext), (".png", ".jpeg", ".jpg"))
        rescale_image(path, thumb_path, thumb_size)
    elseif any(ext-> endswith(path, ext), (".gif", ".mp4", ".webm"))
        seektime = get_video_duration(path) / 2
        run(`ffmpeg -loglevel quiet -ss $seektime -i $path -vframes 1 -vf "scale=$(thumb_size):-2" -y -f image2 $thumb_path`)
    else
        @warn("Unsupported return file format in $path")
    end
end

function generate_thumbnails(media_root)
    for folder in readdir(media_root)
        media = joinpath(media_root, folder, "media")
        if !isfile(media) && ispath(media)
            sample = joinpath(media, first(readdir(media)))
            generate_thumbnail(sample, joinpath(media, "thumb.jpg"))
        end
    end
end

"""
Embedds all produced media in one big html file
"""
function generate_preview(media_root, path = joinpath(@__DIR__, "preview.html"))
    open(path, "w") do io
        for folder in readdir(media_root)
            media = joinpath(media_root, folder, "media")
            if !isfile(media) && ispath(media)
                medias = joinpath.(media, readdir(media))
                println(io, "<h1> $folder </h1>")
                MakieGallery.embed_media(io, medias)
            end
        end
    end
end
