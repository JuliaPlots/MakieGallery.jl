# Config file

One can store a config file in `joinpath(homedir(), ".config", "makie", "theme.jl")`
E.g. store this in theme.jl:
```julia
Attributes(
    font = "Chilanka",
    backgroundcolor = :gray,
    color = :blue,
    linestyle = :dot,
    linewidth = 3
)
```
To start Makie always with this theme!
