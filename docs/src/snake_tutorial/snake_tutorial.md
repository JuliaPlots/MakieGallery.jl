In this tutorial, we're going to build a small snake game in Makie. This is a good example to learn about Observables and the basic `Scene` and plotting workflow (even though a snake game is not a "plot", it is sort of an interactive visualization).

This is how the game will look in the end:

![video](snake.mp4)

## Observables

Makie's plotting system is built on `Observables.jl`. An `Observable` is just a container or wrapper for a value. In addition to that value, it also stores a list of functions, the listeners. Whenever the `Observable`'s value is changed, the listeners are called in the order they were registered in, with the new value as an argument. A change in one `Observable` can trigger a whole chain reaction of other changes, if its listeners update other `Observable`s in turn. So it lends itself to building causal chains. If A changes, B changes as well. C depends on B, therefore C changes if A changes. Or in a specific example, if a slider A changes its value, this changes the result B of a computation depending on that value, which in turn updates a line plot C.

The nice thing about the `Observable` system is therefore that updating a plot is very simple. In most cases you just change the `Observable` containing the plotted value and the backend handles everything for you including updating buffers on the GPU (if you use `GLMakie`, the default GPU based backend).

Most plotting functions in Makie take either `Observable`s or normal objects as inputs, and react to changes to the `Observable`s immediately. For our snake game, we should therefore think about the chain of elements that determine the game logic and visualization, and decide what observables we need based on that.

Speaking of "chain", that is not quite the correct term, as a chain is a sequence of links, while one `Observable` can both listen to or be triggered by multiple other `Observables`, as well as trigger multiple other `Observable`s itself. Therefore, the causal effects of one `Observable` can kind of "fan out" and get quite complex. (You can even create circular dependencies, although you will probably get a nice stack overflow error if you do that, so beware...)

## Basic game components

So let's think about what elements our game has and how they are causally connected. There is the playing field, which consists of a number of square cells. There is the snake, which consists of a sequence of adjacent cells. Then there is the food item, which occupies one cell. And a score, that counts the number of links in the snake, or items that have been eaten so far.

How are these parts causally connected? A change in the playing field doesn't change the snake, a change in the snake doesn't change the food item, and the position of the food item neither changes the snake nor the playing field. But the score changes when the length of the snake changes, so there we have our first causal connection. Let's make the actual observables. By the way, in Makie they are called `Node`s, although they're identical to `Observable`s.

Let's start with the snake. We just store a vector of integer positions that denote which cells are occupied. We'll worry about the rectangles on the screen later.
We also decide that the playing field is always supposed to be square, so we only store the number of cells along one side.

```julia
using Makie


cells_per_side = Node(15)
snakecells = Node([Point(8, 8)]) # place the first cell in the middle
```

The food position is just one cell, or one point. We hardcode the start position for simplicity.

```julia
foodcell = Node(Point(4, 5))
```

Now, for the score, we can make our first chained observable. The score is the length of the snake, so we specify it exactly like that.

```julia
score = lift(length, snakecells)
```

The function `lift` takes a function as the first argument and any number of observables after. The function is evaluated once with the current observable values and the result stored in another observable, which is then returned. Whenever one of the input observables changes, it updates the returned new observable. We can check out what the score is:

```
julia> score
Observable{Int64} with 0 listeners. Value:
1
```

The type parameter of the observable is set to the type of the first evaluated value, if you want to set it yourself, you can pass it with the `typ` keyword argument to `lift`. Sometimes that is useful if you want to allow more types than the one of the first value.

## The Scene

So far this hasn't been too exciting, we actually want to show things on the screen. Let's create our first `Scene`. In Makie, a visualization consists of one main `Scene`, in which plot objects or child `Scene`s can be placed. There is a small list of primitive visual objects like `Lines`, `Scatter`, `Heatmap` or `Text`, and then there are more complex ones that are combinations of the primitives (a `Poly` for example is a `Mesh` bundled together with a `Wireframe`).

Creating a scene is very simple.

```julia
scene = Scene(resolution = (800, 800), camera = campixel!, raw = true)
```

You don't have to specify any keywords in general, but we want to start with a square resolution. Also, we want a specific `camera` for the `Scene`, which determines the projection with which plots are rendered. As we're making a pixel-perfect 2D game here, the `campixel!` function tells the `Scene` to interpret coordinates of our plot objects as pixel values. Setting `raw = true` means that we're disabling the automatic creation of an `Axis` when we add plot objects into the scene, as we're not actually "plotting" anything here. We're just using "raw" plot objects.

If you run only this line in the REPL, the scene will actually show up directly. If you run it as part of a script, it won't, unless you call `display(scene)`.

Now we need to specify the square playing field in which our snake action will happen. We could just hardcode it for our chosen scene resolution, but that would not be as much fun. Instead, we'll make it so the playing field adjusts to whatever scene resolution we set (for example when we drag and resize the window). Therefore, we'll `lift` the observable telling us about the `Scene`'s current pixel area and return the coordinates of the largest square we can fit inside it. The `do` syntax comes in handy to create the anonymous function that calculates the rectangle.

```julia
playingfield = lift(scene.px_area) do area
    shorter_side = minimum(widths(area))
    squareorigin = (widths(area) .- shorter_side) ./ 2
    squarewidths = (shorter_side, shorter_side)
    FRect2D(squareorigin, squarewidths)
end
```

Now we have the coordinates of a square playing field that fits nicely into whatever the current size of the scene is. Let's actually show this rectangle with our first plot object! We'll use the `poly!` function to add a `Poly` to the scene. One of its possible input argument options is a `Rect` like we just created, so it fits the bill.

```julia
background = poly!(scene, playingfield, color = :gray)[end]
```

The `[end]` is necessary to save the actual `Poly` object because all plotting functions with a `!` return the scene, not the plotting object. Indexing into the scene accesses the vector of plot objects and the last plotting function always creates the object at the `end`.

The `color` keyword sets the color `Attribute` of the `Poly` object with an `Observable` containing the value `:gray` that is automatically created for us. We could have chosen to pass an `Observable` we created ourselves, but in this case that we don't need to. All attributes of Makie plots are `Observable`s so that the plots can react to their changes.

Let's `display` the scene and resize the window to check that everything worked and our playing field is always square and centered.

![video](background.mp4)

## The Snake

Nice, now we can add the snake.

We have the snake stored as a vector of cell indices, but we want to display it as multiple squares. We can use `poly!` to draw a list of rectangles, so we need to create that observable with rectangles now.

```julia
function cell_to_rect(playingfield, cells_per_side, cell)
    sidelengths = widths(playingfield) ./ cells_per_side
    origin = AbstractPlotting.origin(playingfield) .+ (cell .- (1, 1)) .* sidelengths
    FRect2D(origin, sidelengths)
end

snakesquares = lift(playingfield, cells_per_side, snakecells) do playingfield, cells_per_side, snakecells
    map(snakecells) do cell
        cell_to_rect(playingfield, cells_per_side, cell)
    end
end
```

Here we've made `snakesquares` depend on the size of the playing field, the number of cells per side and the actual cells making up the snake. Whenever one of these changes, the snake visualization will as well, so they will never go out of sync. Pretty nifty!

Let's actually display the snake squares (for now it's just one anyway).

```julia
poly!(scene, snakesquares, color = :green, strokewidth = 1, strokecolor = :white)
```

![snake](snake.png)

## The Food

Now let's do the same logic for the food. We calculate the position of the food and the marker size dynamically, depending on the field size, the number of cells and the food cell. For the actual display we use the `scatter!` function because we want our snake to hunt something actually looking like snake food, a mouse.

```julia
foodposition = lift(foodcell, cells_per_side, playingfield) do foodcell, cells_per_side, playingfield
    sidelengths = widths(playingfield) ./ cells_per_side
    foodpoint = AbstractPlotting.origin(playingfield) .+ (foodcell .- (0.5, 0.5)) .* sidelengths
    # currently, the scatter function expects an array of points
    [foodpoint]
end

scatter!(scene, foodposition, marker = '🐭',
    markersize = @lift((widths($playingfield) ./ $cells_per_side)[1]))
```

The `markersize` is created with the `@lift` macro, which rewrites the expression in parentheses to a `lift` call where every variable with a `$` is treated as an observable. For expressions like this the macro can be shorter to write than the function.

![food](food.png)

## The score

The score is very simple, we just lift the `score` observable to create a score string and place that wherever the upper right corner of the playing field is.

```julia
text!(scene, @lift("Score: $($score)"),
    position = @lift(maximum($playingfield) .- Point(20, 20)),
    textsize = 30, align = (:right, :top), color = :white)
```

![score](score.png)

## Keyboard input

For now, everything is still static. In order to play the game, we will need to react to the player pressing the arrow buttons. We can react to the `scene.events.keyboardbuttons` observable which fires every time a key is pressed. We don't another observable, a `Ref` keeping track of the last pressed direction is enough. In the snake game, the movement happens in fixed time intervals, not when the player presses a button. So we use `on` instead of `lift` as it doesn't create an observable. It simply calls the given function.

```julia
lastdirection = Ref(:right)

on(scene.events.keyboardbuttons) do but
    if ispressed(but, Keyboard.left)
        lastdirection[] = :left
    elseif ispressed(but, Keyboard.up)
        lastdirection[] = :up
    elseif ispressed(but, Keyboard.down)
        lastdirection[] = :down
    elseif ispressed(but, Keyboard.right)
        lastdirection[] = :right
    end
end
```

## Game logic

The actual game logic is not so important here, so I'll just show it. The gist is that the snake is moved in the last direction by `circshift`ing the array of cells. The snake grows if its head lands on the food. In that case, a new food position is generated which cannot be on the snake. The function returns if the snake bites itself and is `:dead`, or if it has `:eaten` or is simply still `:alive`.

```julia
function move_snake!(dir)
    shift = Point(
        dir == :left ? -1 : dir == :right ? 1 : 0,
        dir == :down ? -1 : dir == :up ? 1 : 0)

    tailpos = snakecells[][end]
    new_headpos = mod.(snakecells[][1] .+ shift, Base.OneTo.(cells_per_side[]))

    if new_headpos in snakecells[][1:end-1]
        return :dead
    end

    # mutating the array in snakecells doesn't trigger the observable
    snakecells[][end] = new_headpos
    # but assigning snakecells a new value does
    snakecells[] = circshift(snakecells[], 1)

    if snakecells[][1] == foodcell[]
        
        push!(snakecells[], tailpos)
        snakecells[] = snakecells[]

        foodcell[] = let
            while (p = Point2(rand(1:cells_per_side[]), rand(1:cells_per_side[]))) in snakecells[]
            end
            p
        end

        return :eaten
    else
        return :alive
    end
end
```

Note that we are not doing anything specific with the visual part of the game here. That all happens automatically whenever `snakecells` or `foodcell` are changed, through the magic of observables.

## The Game Loop

The game is still not running, because we don't actually call `move_snake!` yet. Let's make a small loop that runs as long as the `scene` is open. At every interval we move the snake in the last recorded direction. We also increase the speed of the game a bit, every time a food item is eaten. And when the snake finally bites itself, we break out of the loop and color the background `:red`. Remember how we gave the background poly the attribute `color = :gray` in the beginning? Here we can see that it still reacts to a change of the attribute, even if we don't pass an observable ourselves.

```julia
frames_per_second = Ref(5.0)

while isopen(scene)
    sleep(1/frames_per_second[])
    state = move_snake!(lastdirection[])
    if state == :eaten
        frames_per_second[] += 0.2
        score[] += 1
    elseif state == :dead
        background.color = :red
        break
    end
end
```

## Summary

That's it! Here's the full code of the game if you don't want to copy paste all the small parts. I hope you enjoyed it and feel equipped to handle more complex interactive visualizations with Makie!

```julia
using Makie


cells_per_side = Node(15)
snakecells = Node([Point(8, 8)])
foodcell = Node(Point(4, 5))
score = lift(length, snakecells)

scene = Scene(resolution = (800, 800), raw = true, camera = campixel!)

playingfield = lift(scene.px_area) do area
    w = minimum(widths(area))
    origin = (widths(area) .- w) ./ 2
    ws = (w, w)
    FRect2D(origin, ws)
end

function cell_to_rect(playingfield, cells_per_side, cell)
    sidelengths = widths(playingfield) ./ cells_per_side
    origin = AbstractPlotting.origin(playingfield) .+ (cell .- (1, 1)) .* sidelengths
    FRect2D(origin, sidelengths)
end

snakesquares = lift(playingfield, cells_per_side, snakecells) do playingfield, cells_per_side, snakecells
    map(snakecells) do cell
        cell_to_rect(playingfield, cells_per_side, cell)
    end
end

foodposition = lift(foodcell, cells_per_side, playingfield) do foodcell, cells_per_side, playingfield
    sidelengths = widths(playingfield) ./ cells_per_side
    [AbstractPlotting.origin(playingfield) .+ (foodcell .- (0.5, 0.5)) .* sidelengths]
end

background = poly!(scene, playingfield, color = :gray)[end]

poly!(scene, snakesquares, color = :green, strokewidth = 1, strokecolor = :white)

scatter!(scene, foodposition, marker = '🐭',
    markersize = @lift((widths($playingfield) ./ $cells_per_side)[1]))

text!(scene, @lift("Score: $($score)"),
    position = @lift(maximum($playingfield) .- Point(20, 20)),
    textsize = 30, align = (:right, :top), color = :white)


lastdirection = Ref(:right)

on(scene.events.keyboardbuttons) do but
    if ispressed(but, Keyboard.left)
        lastdirection[] = :left
    elseif ispressed(but, Keyboard.up)
        lastdirection[] = :up
    elseif ispressed(but, Keyboard.down)
        lastdirection[] = :down
    elseif ispressed(but, Keyboard.right)
        lastdirection[] = :right
    end
end

function move_snake!(dir)
    shift = Point(
        dir == :left ? -1 : dir == :right ? 1 : 0,
        dir == :down ? -1 : dir == :up ? 1 : 0)

    tailpos = snakecells[][end]
    new_headpos = mod.(snakecells[][1] .+ shift, Base.OneTo.(cells_per_side[]))

    if new_headpos in snakecells[][1:end-1]
        return :dead
    end

    # mutating the array in snakecells doesn't trigger the observable
    snakecells[][end] = new_headpos
    # but assigning snakecells a new value does
    snakecells[] = circshift(snakecells[], 1)

    if snakecells[][1] == foodcell[]
        push!(snakecells[], tailpos)
        snakecells[] = snakecells[]

        foodcell[] = let
            while (p = Point2(rand(1:cells_per_side[]), rand(1:cells_per_side[]))) in snakecells[]
            end
            p
        end

        return :eaten
    else
        return :alive
    end
end

display(scene)

frames_per_second = Ref(5.0)

while isopen(scene)
    sleep(1/frames_per_second[])
    state = move_snake!(lastdirection[])
    if state == :eaten
        frames_per_second[] += 0.2
        score[] += 1
    elseif state == :dead
        background.color = :red
        break
    end
end
```