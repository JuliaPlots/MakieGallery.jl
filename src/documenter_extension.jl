struct DatabaseLookup <: Expanders.ExpanderPipeline end

Selectors.order(::Type{DatabaseLookup}) = 0.5
Selectors.matcher(::Type{DatabaseLookup}, node, page, doc) = match_kw(node)

const regex_pattern = r"\@example_database\(([\"a-zA-Z_0-9.+ ]+)(?:, )?(\d+|plot|code|stepperplot)?\)"


match_kw(x::String) = occursin(regex_pattern, x)
match_kw(x::Paragraph) = any(match_kw, x.content)
match_kw(x::Any) = false

# ============================================= Simon's implementation
function look_up_source(database_key)
    entries = findall(x-> lowercase(x.title) == lowercase(database_key), database)
    # current implementation finds titles, but we can also search for tags too
    isempty(entries) && error("No entry found for database reference $database_key")
    length(entries) > 1 && error("Multiple entries found for database reference $database_key")
    sprint() do io
        idx = entries[1]
        print_code(
            io, database[entries[1]],
            scope_start = "",
            scope_end = "",
            indent = "",
            resolution = (entry)-> "resolution = (500, 500)",
            outputfile = (entry, ending)-> string(entry.unique_name, ending)
        )
    end
end

function Selectors.runner(::Type{DatabaseLookup}, x, page, doc)
    matched = nothing
    for elem in x.content
        if isa(elem, AbstractString)
            matched = match(regex_pattern, elem)
            matched != nothing && break
        end
    end
    matched == nothing && error("No match: $x")
    capture = matched[1]
    embed = matched[2]

    subidx = nothing
    # we also allow to reference a subsection annotated with @substep with an
    # inter: @example_database("Title", 2)
    if embed isa AbstractString && all(isnumeric, embed)
        subidx = parse(Int, embed)
        embed = nothing
    end
    # The sandboxed module -- either a new one or a cached one from this page.
    database_keys = lowercase.(filter(x-> !(x in ("", " ")), split(capture, '"')))
    # info("$database_keys with embed option $embed")
    map(database_keys) do database_key
        is_stepper = false

        # buffer for content
        content = []

        # bibliographic stuff
        idx = findall(x-> lowercase(x.title) == database_key, database)
        isempty(idx) && error("can't find example $database_key")
        entry = database[idx[1]]
        uname = string(entry.unique_name)
        lines = entry.file_range
        tags = entry.tags
        # print source code for the example
        if embed == nothing || isequal(embed, "code")
            source = look_up_source(database_key)
            if subidx != nothing
                source = split(source, "@substep", keepempty = false)[subidx]
            end
            src_code = Markdown.MD(Markdown.Code("julia", source))
            push!(content, src_code)
        end
        # TODO figure out a better way to not hardcode this
        media_root = joinpath(homedir(), "ReferenceImages/gallery")
        # embed plot for the example
        if (embed == nothing) || isequal(embed, "plot")
            # print to buffer
            str = sprint() do io
                mpath = joinpath(media_root, uname, "media")
                files = readdir(mpath)
                if subidx !== nothing
                    idx = findfirst(files) do file
                        num = match(r"\d+", file)
                        num === nothing && return false
                        subidx == parse(Int, num.match)
                    end
                    if idx !== nothing
                        embed_media(io, [master_url(media_root, joinpath(mpath, files[idx]))])
                    end
                else
                    embed_media(io, master_url.(media_root, joinpath.(mpath, files)))
                end
            end
            # print code for embedding plot
            src_plot = Documenter.Documents.RawHTML(str)
            push!(content, src_plot)
        end
        # finally, map the content back to the page
        page.mapping[x] = content
    end
end




"""
    print_table(io::IO, dict::Dict)

Print a Markdown-formatted table with the entries from `dict` to specified `io`.
"""
function print_table(io::IO, dict::Dict)
    # get max length of the keys
    k = string.("`", collect(keys(dict)), "`")
    maxlen_k = max(length.(k)...)

    # get max length of the values
    v = string.(collect(values(dict)))
    maxlen_v = max(length.(v)...)

    j = sort(collect(dict), by = x -> x[1])

    # column labels
    labels = ["Symbol", "Description"]

    # print top header
    print(io, "|")
    print(io, "$(labels[1])")
    print(io, " "^(maxlen_k - length(labels[1])))
    print(io, "|")
    print(io, "$(labels[2])")
    print(io, " "^(maxlen_v - length(labels[2])))
    print(io, "|")
    print(io, "\n")

    # print second line (toprule)
    print(io, "|")
    print(io, "-"^maxlen_k)
    print(io, "|")
    print(io, "-"^maxlen_v)
    print(io, "|")
    print(io, "\n")

    for (idx, entry) in enumerate(j)
        print(io, "|")
        print(io, "`$(entry[1])`")
        print(io, " "^(maxlen_k - length(string(entry[1])) - 2))
        print(io, "|")
        print(io, "$(entry[2])")
        print(io, " "^(maxlen_v - length(entry[2])))
        print(io, "|")
        print(io, "\n")
    end
end



"""
    get_video_duration(path::AbstractString)

Returns the duration of the video in seconds (Float32).
Accepted file types: mp4, mkv, and gif.

Requires `ffprobe` (usually comes installed with `ffmpeg`).

Note that while this accepts gif, it will not work to get duration of the gif
(`ffprobe` doesn't support that), so it will just fallback to return 0.5 sec.
"""
function get_video_duration(path::AbstractString)
    !isfile(path) && error("input is not a file!")
    accepted_exts = ("mp4", "gif", "mkv")
    filename = basename(path)
    file_ext = split(filename, ".")[2]
    !(file_ext in accepted_exts) && error("accepted file types are mp4 and gif! Found: $file_ext")
    try
        dur = read(`ffprobe -loglevel quiet -print_format compact=print_section=0:nokey=1:escape=csv -show_entries format=duration -i "$(path)"`, String)
        dur = parse(Float32, dur)
    catch e
        @warn("`get_video_duration` on $filename did not work, using fallback video duration of 0.5 seconds")
        dur = 0.5
    end
end
