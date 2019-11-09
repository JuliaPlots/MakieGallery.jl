################################################################################
#                  MakieGallery.jl documentation build script                  #
################################################################################
##############################
#      Generic imports       #
##############################

using Documenter, Markdown, Pkg, Random, FileIO, JSON, HTTP, GitHub

##############################
#      Specific imports      #
##############################

using MakieGallery, AbstractPlotting

import AbstractPlotting: to_string

using MakieGallery: eval_examples, generate_thumbnail, master_url,
                    print_table, download_reference,
                    @cell, @block, @substep


################################################################################
#                              Utility functions                               #
################################################################################


"""
    isPR()::Bool

Detects whether the commit being built is in a pull request or not.
"""
function isPR()::Bool
    if haskey(ENV, "CI")
        if haskey(ENV, "TRAVIS")
            @info "Travis CI detected"
            return get(ENV, "TRAVIS_PULL_REQUEST", "false") != "false"
        end
    end
    if haskey(ENV, "GITHUB_TOKEN")
        @info "Github Actions detected"
        return !occursin("master", get(ENV, "GITHUB_REF", "nothing"))
    end
    return false
end

function isGHActions(user::GitHub.Owner)
    return (
        user.login    == "github-actions[bot]" &&
        user.id       == 41898282 &&
        user.url      == HTTP.URI("https://api.github.com/users/github-actions%5Bbot%5D") &&
        user.html_url == HTTP.URI("https://github.com/apps/github-actions")
    )
end

function hasGHAPRComment(cs::Vector{GitHub.Comment}, msg::AbstractString)
    return any(cs) do comment
        isGHActions(comment.user) && occursin(msg, comment.body)
    end
end

function hasGHAPRComment(repo::AbstractString, pr::Int, msg::AbstractString)
    return hasGHAPRComment(
        GitHub.comments(repo, pr, :pr)[1],
        msg
    )
end

function getPR(repo, commit_sha; ind = 1)
    r = HTTP.get(
            "https://api.github.com/repos/$repo/commits/$commit_sha/pulls",
            [
                # necessary because this is a preview feature
                "Accept" => "application/vnd.github.groot-preview+json",
                # Github needs a User-Agent
                "User-Agent" => "GitHub-jl"
            ]
        )

    url = JSON.parse(String(r.body))[ind]["html_url"] # get the URL of the PR
    return splitpath(url)[end] # get the PR number
end

function push_PR_preview_docs(deploy_url)

    repo       = ENV["GITHUB_REPOSITORY"]
    commit_sha = ENV["GITHUB_SHA"]

    @info "Pushing preview docs."

    # Find the latest PR associated with the commit, from its SHA
    PR = parse(Int, getPR(repo, commit_sha))

    # Overwrite Documenter's function for generating the versions.js file
    foreach(
        Base.delete_method,
        methods(Documenter.Writers.HTMLWriter.generate_version_file)
    )
    @eval Documenter.Writers.HTMLWriter.generate_version_file(_, _) = nothing

    # Force Documenter to deploy by SSH, to circumvent the bug with Github not
    # deploying documentation when an application pushes to `gh-pages`
    @eval Documenter.authentication_method(::Documenter.GitHubActions) = Documenter.SSH

    # Overwrite necessary environment variables to trick Documenter to deploy
    ENV["GITHUB_EVENT_NAME"] = "push"
    ENV["GITHUB_REF"] = "refs/heads/master"
    ENV["GITHUB_REPOSITORY"] = deploy_url

    Base.invokelatest(deploydocs,
        devurl = "preview-PR$(PR)",
        repo = deploy_url,
    )

    # Add a comment on the PR with a link to the preview, if it doesn't already exist
    # or if the
    msg = """
        Documentation built successfully.
        A preview can be found here: $deploy_url/preview-PR$(PR)
        """

    if hasGHAPRComment(repo, PR, msg)
        @info "No previous comment detected - commenting with doc URL!"
        cmd = `curl -X POST`
        push!(cmd.exec, "-H", "Authorization: token $(ENV["GITHUB_TOKEN"])")
        push!(cmd.exec, "-H", "Content-Type: application/json")
        push!(cmd.exec, "-d", "{\"body\":\"$(msg)\"}")
        push!(cmd.exec, "https://api.github.com/repos/JuliaPlots/MakieGallery.jl/issues/$(PR)/comments")
        try
            success(cmd)
        catch e
            @warn "Curl errored when pushing comment!" exception=e
        end
    end

    exit(0)
end


################################################################################
#                                    Setup                                     #
################################################################################

MakieGallery.current_ref_version[] = "master"

cd(@__DIR__)
database = MakieGallery.load_database()

pathroot = normpath(@__DIR__, "..")
docspath = joinpath(pathroot, "docs")
srcpath = joinpath(docspath, "src")
buildpath = joinpath(docspath, "build")
mediapath = download_reference()


################################################################################
#                      Automatic Markdown page generation                      #
################################################################################

########################################
#     Plotting functions overview      #
########################################

@info("Generating functions overview")
path = joinpath(srcpath, "functions-overview.md")
srcdocpath = joinpath(srcpath, "src-functions.md")

plotting_functions = (
    AbstractPlotting.atomic_functions..., contour, arrows,
    barplot, poly, band, slider, vbox, hbox
)

open(path, "w") do io
    !ispath(srcdocpath) && error("source document doesn't exist!")
    println(io, "# Plotting functions overview")
    src = read(srcdocpath, String)
    println(io, src, "\n")
    for func in plotting_functions
        fname = to_string(func)
        println(io, "## `$fname`\n")
        println(io, "```@docs")
        println(io, "$fname")
        println(io, "```\n")
        # add previews of all tags related to function
        for example in database
            fname in example.tags || continue
            base_path = joinpath(mediapath, string(example.unique_name))
            thumb = master_url(mediapath, joinpath(base_path, "media", "thumb.jpg"))
            code = master_url(mediapath, joinpath(base_path, "index.html"))
            src_lines = example.file_range
            println(io, """[![library lines $src_lines]($thumb)]($code)""")
        end
        println(io, "\n")
    end
end


cd(docspath)

########################################
#       Plot attributes overview       #
########################################

# automatically generate an overview of the plot attributes (keyword arguments), using a source md file
@info("Generating attributes page")
include("../src/plot_attr_desc.jl")
path = joinpath(srcpath, "plot-attributes.md")
srcdocpath = joinpath(srcpath, "src-plot-attributes.md")
open(path, "w") do io
    !ispath(srcdocpath) && error("source document doesn't exist!")
    println(io, "# Plot attributes")
    src = read(srcdocpath, String)
    println(io, src)
    print(io, "\n")
    println(io, "## List of attributes")
    print_table(io, plot_attr_desc)
end

########################################
#       Axis attributes overview       #
########################################

# automatically generate an overview of the axis attributes, using a source md file
@info("Generating axis page")
path = joinpath(srcpath, "axis.md")
srcdocpath = joinpath(srcpath, "src-axis.md")
include("../src/Axis2D_attr_desc.jl")
include("../src/Axis3D_attr_desc.jl")

open(path, "w") do io
    !ispath(srcdocpath) && error("source document doesn't exist!")
    src = read(srcdocpath, String)
    println(io, src)
    print(io)
    # Axis2D section
    println(io, "## `Axis2D`")
    println(io, "### `Axis2D` attributes groups")
    print_table(io, Axis2D_attr_desc)
    print(io)
    for (k, v) in Axis2D_attr_groups
        println(io, "#### `:$k`\n")
        print_table(io, v)
        println(io)
    end
    # Axis3D section
    println(io, "## `Axis3D`")
    println(io, "### `Axis3D` attributes groups")
    print_table(io, Axis3D_attr_desc)
    print(io)
    for (k, v) in Axis3D_attr_groups
        println(io, "#### `:$k`\n")
        print_table(io, v)
        println(io)
    end

    # Examples on the bottom of the page
    println(io, """

    ### Examples

    @example_database("Unicode Marker")

    @example_database("Axis + Surface")

    @example_database("Axis theming")
    """)
end

########################################
#     Function signatures overview     #
########################################

# automatically generate an overview of the function signatures, using a source md file
@info("Generating signatures page")
path = joinpath(srcpath, "signatures.md")
srcdocpath = joinpath(srcpath, "src-signatures.md")
open(path, "w") do io
    !ispath(srcdocpath) && error("source document doesn't exist!")
    println(io, "# Plot function signatures")
    src = read(srcdocpath, String)
    println(io, src)
    print(io, "\n")
    println(io, "```@docs")
    println(io, "convert_arguments")
    println(io, "```\n")

    println(io, "See [Plot attributes](@ref) for the available plot attributes.")
end


################################################################################
#                 Building HTML documentation with Documenter                  #
################################################################################

@info("Running `makedocs` with Documenter.")

makedocs(
    modules = [AbstractPlotting],
    doctest = false, clean = true,
    format = Documenter.HTML(prettyurls = false),
    sitename = "Makie.jl",
    expandfirst = [
        "basic-tutorials.md",
        "statsmakie.md",
        "animation.md",
        "interaction.md",
        "functions-overview.md",
        "scenes.md",
        "signatures.md",
        "plot-attributes.md",
        "colors.md",
        "theming.md",
        "cameras.md",
        "backends.md",
        "axis.md",
        "recipes.md",
        "output.md"
    ],
    pages = Any[
        "Home" => "index.md",
        "Basics" => [
            "basic-tutorials.md",
            "statsmakie.md",
            "animation.md",
            "interaction.md",
            "functions-overview.md",
            "animation.md",
        ],
        "Documentation" => [
            "scenes.md",
            "signatures.md",
            "plot-attributes.md",
            "colors.md",
            "theming.md",
            "cameras.md",
            "backends.md",
            "axis.md",
            "recipes.md",
            "output.md",
            "troubleshooting.md"
        ],
        "Developer Documentation" => [
            "why-makie.md",
            "devdocs.md",
            "gallery.md",
            "AbstractPlotting Reference" => "abstractplotting_api.md",
            "Type Trees" => "typetrees.md"
        ],
    ]
)

################################################################################
#                           Deploying documentation                            #
################################################################################

using Documenter, Base64

ENV["DOCUMENTER_DEBUG"] = "true"

# do this only if local, otherwise let Documenter handle it
if !haskey(ENV, "CI") && !haskey(ENV, "GITHUB_TOKEN")
    @info "Manually deploying - setting environment variables!"
    # Workaround for when deploying locally and silly Windows truncating the env variable
    # on the CI these should be set!
    ENV["CI"] = "no"
    ENV["TRAVIS"] = :lolno
    ENV["TRAVIS_BRANCH"] = "master"
    ENV["TRAVIS_PULL_REQUEST"] = "false"
    ENV["TRAVIS_REPO_SLUG"] = "github.com/JuliaPlots/MakieGallery.jl"
    ENV["TRAVIS_TAG"] = ""
    ENV["TRAVIS_OS_NAME"] = ""
    ENV["TRAVIS_JULIA_VERSION"] = ""
    # ENV["PATH"] = string(ENV["PATH"], Sys.iswindows() ? ";" : ":", Conda.SCRIPTDIR)
    ENV["DOCUMENTER_KEY"] = get(ENV, "DOCUMENTER_KEY", readchomp(joinpath(homedir(), "documenter.key")))
end

############################################
# Set up for pushing preview docs from PRs #
############################################

cd(@__DIR__)

if isPR()
    @info "Pull request detected, pushing preview documentation"
    push_PR_preview_docs(get(ENV, "DOCUMENTER_DEPLOY_URL", "github.com/asinghvi17/MakiePreviewDocs"))
end

deploydocs(
    repo = get(ENV, "DOCUMENTER_DEPLOY_URL", "github.com/JuliaPlots/MakieGallery.jl")
)
