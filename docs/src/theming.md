# Config file

A configuration file can be used to save theming options. The config file can be
global (in `joinpath(homedir(), ".config", "makie", "theme.jl")`) or local
(a `theme.jl` in the current directory). The local config file has precedence
over the global one. This allows for per-project config files and thus making
it easier to have a common style for multiple plots without explicitly giving
the desired options each time.

A config file must return an `Attributes` object. For example, if the contents of
`theme.jl` is the following:
```julia
Attributes(
    font = "Chilanka",
    backgroundcolor = :gray,
    color = :blue,
    linestyle = :dot,
    linewidth = 3
)
```
then Makie will start with this theme.

There are other things that you can configure in this file before returning the Attributes, though.  

## Resolution setting

You can set the default resolution, at which Scenes will be displayed, by adding the statement:
```julia
reasonable_resolution() = (800, 800)
```
before the attributes' declaration.

You can also configure your primary resolution, by:
```julia
primary_resolution() = (1920, 1080)
```
