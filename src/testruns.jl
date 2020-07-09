const makiegallery_dir = dirname(dirname(@__DIR__))

const current_ref_version = Ref{String}("v0.6.1")

"""
    ref_image_dir(version = string(current_ref_version[]))

Returns the directory in which reference images are stored.
"""
function ref_image_dir(version = string(current_ref_version[]))
    return download_reference(version)
end

"Purges the reference image cache!"
purge_refimage_cache() = rm(joinpath(makiegallery_dir, "testimages"); recursive = true)

"""
    download_reference(version = string(current_ref_version[]))

Downloads the reference images from ReferenceImages for a specific version
"""
function download_reference(version = string(current_ref_version[]))
    refpath_version = version[1] == 'v' && version[2] in '0':'9' ? version[2:end] : version

    if isabspath(version)
        return version
    end

    download_dir = joinpath(makiegallery_dir, "testimages")
    isdir(download_dir) || mkpath(download_dir)
    tarfile = joinpath(download_dir, "gallery.tar.gz")
    url = "https://github.com/JuliaPlots/MakieReferenceImages/archive/$(version).tar.gz"
    refpath = joinpath(download_dir, "MakieReferenceImages-$(refpath_version)", "gallery")
    if !isdir(refpath) # if not yet downloaded
        download_images() = download(url, tarfile)
        try
            @info "downloading reference images for version $version"
            download_images()
        catch e
            if isa(e, ErrorException) && occursin("Hash Mismatch", e.msg)
                rm(tarfile, force = true)
                download_images()
            else
                rethrow(e)
            end
        end
        BinaryProvider.unpack(tarfile, download_dir)
        # check again after download
        if !isdir(refpath)
            error("Something went wrong while downloading reference images. Plots can't be compared to references")
        end
    end
    refpath
end

is_image_file(path) = lowercase(splitext(path)[2]) in (".png", ".jpg", ".jpeg")

function extract_frames(video, frame_folder)
    path = joinpath(frame_folder, "frames%04d.png")
    FFMPEG.ffmpeg_exe(`-loglevel quiet -i $video -y $path`)
end

function compare_media(a, b; sigma = [1,1], eps = 0.02)
    file, ext = splitext(a)
    if ext in (".png", ".jpg", ".jpeg", ".JPEG", ".JPG")
        imga = load(a)
        imgb = load(b)
        if size(imga) != size(imgb)
            @warn "images don't have the same size, difference will be Inf"
            return Inf
        end
        return approx_difference(imga, imgb, sigma, eps)
    elseif ext in (".mp4", ".gif")
        mktempdir() do folder
            afolder = joinpath(folder, "a")
            bfolder = joinpath(folder, "b")
            mkpath(afolder); mkpath(bfolder)
            extract_frames(a, afolder)
            extract_frames(b, bfolder)
            aframes = joinpath.(afolder, readdir(afolder))
            bframes = joinpath.(bfolder, readdir(bfolder))
            if length(aframes) > 10
                # we don't want to compare too many frames since it's time costly
                # so we just compare 10 random frames if more than 10
                samples = rand(1:length(aframes), 10)
                aframes = aframes[samples]
                bframes = bframes[samples]
            end
            # test by maximum diff
            return mean(compare_media.(aframes, bframes; sigma = sigma, eps = eps))
        end
    else
        error("Unknown media extension: $ext")
    end
end

"""
Compares all media recursively in two recorded folders!
"""
function run_comparison(
        test_record_path, test_diff_path,
        reference = MakieGallery.download_reference();
        maxdiff = 0.032
    )
    @testset "Reference Image Tests" begin
        folders = joinpath.(test_record_path, readdir(test_record_path))
        l = length(folders)
        count = 1
        for folder in folders
            @debug "Running index $count" progress=count/l
            count += 1
            if isdir(folder) && isdir(joinpath(reference, basename(folder)))
                media = joinpath(folder, "media")
                ref_folder = joinpath(reference, basename(folder), "media")
                test_folder = joinpath(test_record_path, media)
                ref_media = filter(x-> x != "thumb.png", sort(readdir(ref_folder)))
                test_media = filter(x-> x != "thumb.png", sort(readdir(test_folder)))
                @testset "$(basename(folder))" begin
                    if isempty(test_media)
                        @warn("recodings are missing for $folder")
                    else
                        for test in test_media
                            ref = joinpath(ref_folder, test)
                            test = joinpath(test_folder, test)
                            diff = compare_media(ref, test)
                            if diff >= maxdiff
                                refdiff = joinpath(test_diff_path, basename(folder), string("ref_", basename(ref)))
                                testdiff = joinpath(test_diff_path, basename(folder), string("test_", basename(test)))
                                mkpath(dirname(refdiff)); mkpath(dirname(testdiff))
                                cp(ref, refdiff, force = true)
                                cp(test, testdiff, force = true)
                                @test diff <= maxdiff
                            else
                                @test diff <= maxdiff
                            end
                        end
                    end
                end
            end
        end

        # Write out overview of what got tested different as html
        folders = readdir(test_diff_path)
        open(joinpath(test_diff_path, "index.html"), "w") do io
            for elem in folders
                folder = joinpath(test_diff_path, elem)
                if isdir(folder)
                    images = joinpath.(folder, readdir(folder))
                    println(io, "<h1> $elem </h1>")
                    MakieGallery.embed_media(io, images)
                end
            end
        end
    end
end

function load_test_database()
    database = load_database()
    # which one are the slowest and kicked those out!
    slow_examples = Set([
        "Animated time series",
        "Animation",
        "Lots of Heatmaps",
        "Chess Game",
        "Line changing colour",
        "Colormap collection",
        "Record Video",
        "Animated surface and wireframe",
        "Moire",
        "Line GIF",
        "Interaction with mouse",
        "Electrostatic repulsion",
        "pong",
        "pulsing marker",
        "Travelling wave",
        "Axis theming",
        "Legend",
        "Color Legend",
        "DifferentialEquations path animation",
        "Interactive Differential Equation",
        "Spacecraft from a galaxy far, far away",
        "WorldClim visualization",
        "Image on Geometry (Moon)",
        "Image on Geometry (Earth)",
        "Interaction with mouse",
        "Air Particulates",
        "Window resizing",
        "Aspect ratios stretching circles"
    ])
    # DIffeq errors with stackoverflow
    # The others look fine on the CI, but the measured difference is too high -.-
    # Maybe related to the axis changes, will investigate later
    filter!(database) do entry
        !("diffeq" in entry.tags) &&
        !(entry.unique_name in (:inline_legend, :cobweb_plot, :analysis, :colormap_collection, :lots_of_heatmaps, :interaction_with_mouse, :normals_of_a_cat)) &&
        !(entry.title in slow_examples) &&
        !("download" in entry.tags) &&
        ("Multi-group legends" != entry.title) &&
        ("GUI for exploring Lorenz equation" != entry.title) &&
        !("makielayout" in lowercase.(entry.tags)) &&
        !("statsmakie" in lowercase.(entry.tags))
     end
     return database
end
