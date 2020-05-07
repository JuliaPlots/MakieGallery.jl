using AbstractPlotting.PlotUtils


function generate_colorschemes_markdown(; GENDIR = joinpath(dirname(@__DIR__), "docs", "src", "generated"))
    md = open(joinpath(GENDIR, "colorschemes.md"), "w")

    for line in readlines(normpath(@__DIR__, "..", "docs", "src", "colorschemes.md"))
        write(md, line)
        write(md, "\n")
    end

    write(md, """
    ## misc
    These colorschemes are not defined or provide different colors in ColorSchemes.jl
    They are kept for compatibility with Plots behavior before v1.1.0.
    """)
    write(md, "```@raw html\n")
    write(
        md,
        generate_colorschemes_table(
            [:default; sort(collect(keys(PlotUtils.MISC_COLORSCHEMES)))]
        )
    )
    write(md, "\n```\n\nThe following colorschemes are defined by ColorSchemes.jl.\n\n")
    for cs in ["cmocean", "scientific", "matplotlib", "colorbrewer", "gnuplot", "colorcet", "seaborn", "general"]
        ks = sort([k for (k, v) in PlotUtils.ColorSchemes.colorschemes if occursin(cs, v.category)])
        write(md, "\n\n## $cs\n\n```@raw html\n")
        write(md, generate_colorschemes_table(ks))
        write(md, "\n```\n\n")
    end

    close(md)
end
