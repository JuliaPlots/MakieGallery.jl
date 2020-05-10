using Makie
using GLFW; GLFW.WindowHint(GLFW.FLOATING, 1)

##
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

