module MakieGallery

using Makie
using Documenter: Selectors, Expanders
using Markdown: Link, Paragraph


include("documenter_extension.jl")
include("database.jl")


function load_database()
    @eval begin
        include("../examples/tutorials.jl")
        include("../examples/examples2d.jl")
        include("../examples/examples3d.jl")
        include("../examples/interactive.jl")
        include("../examples/documentation.jl")
        include("../examples/implicits.jl")
        include("../examples/short_tests.jl")
        include("../examples/recipes.jl")
        include("../examples/bigdata.jl")
        include("../examples/layouting.jl")
    end
end

end
