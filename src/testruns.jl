"""
Downloads the reference images from ReferenceImages for a specific version
"""
function download_reference(version)
    download_dir = joinpath(@__DIR__, "..", "test", "testimages")
    tarfile = joinpath(download_dir, "gallery.zip")
    url = "https://github.com/SimonDanisch/ReferenceImages/archive/v$(version).tar.gz"
    refpath = joinpath(download_dir, "ReferenceImages-$(version)", "gallery")
    # function url2hash(url::String)
    #     path = download(url)
    #     open(io-> bytes2hex(BinaryProvider.sha256(io)), path)
    # end
    # url2hash(url) |> println

    if !isdir(refpath) # if not yet downloaded
        download_images() = BinaryProvider.download_verify(
            url, "6f950d5124369b77b234251c68160c1bfa08524902e2cb2d81966b56accc56e1",
            tarfile
        )
        try
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
    path = joinpath(frame_folder, "frames%04d.jpg")
    run(`ffmpeg -loglevel quiet -i $video -y $path`)
end

function compare_media(a, b; sigma = [1,1], eps = 0.02)
    file, ext = splitext(a)
    if ext in (".png", ".jpg", ".jpeg", ".JPEG", ".JPG")
        imga = load(a)
        imgb = load(b)
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
function run_comparison(test_record_path, reference, test_diff_path)
    @testset "Reference Image Tests" begin
        folders = readdir(test_record_path)
        for folder in folders
            if isdir(folder)
                media = joinpath(folder, "media")
                ref_folder = joinpath(reference, media)
                test_folder = joinpath(test_record_path, media)
                ref_media = sort(readdir(ref_folder))
                test_media = sort(readdir(test_folder))
                maxdiff = 0.08
                @testset "$folder" begin
                    if length(ref_media) != length(test_media)
                        @warn("recodings are missing for $folder - skipping test")
                    else
                        for (ref, test) in zip(ref_media, test_media)
                            ref = joinpath(ref_folder, ref)
                            test = joinpath(test_folder, test)
                            diff = compare_media(ref, test)
                            if diff >= maxdiff
                                refdiff = joinpath(test_diff_path, folder, string("ref_", basename(ref)))
                                testdiff = joinpath(test_diff_path, folder, string("test_", basename(test)))
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
    end
end
