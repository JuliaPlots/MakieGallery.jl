using Makie

println("  ______   __    _       __       _   _   _______")
println("/ ______| |  \\  | |     /  \\     | | / / |  _____|")
println("| |____   | \\ \\ | |    / /\\ \\    | |/ /  | |____")
println("|_____  \\ | |\\ \\| |   / /__\\ \\   | | \\   |  ____|")
println(" _____| | | | \\ \\ |  / /----\\ \\  | |\\ \\  | |_____")
println("|_______/ |_|  \\__| /_/      \\_\\ |_| \\_\\ |_______|")
println("")
println("use the arrow keys to move and collect the red fruit. The snake gets faster and faster as the game progresses!")
scene = Scene(resolution = (400, 400), raw = true, camera = campixel!)

k = Point2f0[(0, 20), (0, 20), (0, 20), (0, 20)]

on(scene.events.keyboardbuttons) do but
    if ispressed(but, Keyboard.left)
        k[1] = (-20, 0)
    elseif ispressed(but, Keyboard.up)
        k[1] = (0, 20)
    elseif ispressed(but, Keyboard.right)
        k[1] = (20, 0)
    elseif ispressed(but, Keyboard.down)
        k[1] = (0, -20)
    end
end

xy = Point2f0.(10, [70, 50, 30, 10])
fruit = [Point2f0(90, 110)]
game_over = [false]
speed = [0.3]
score = [0]

snake = scatter!(xy, color = :white, marker = :rect, markersize = 25)[end]
fruit_plot = scatter!(fruit, color = :white, marker = :rect, markersize = 25)[end]

display(scene)

while game_over[] == false && isopen(scene)

    for i1 in 0:(length(xy) - 2)
        n1 = length(xy) - i1
        if k[n1 - 1] == (xy[n1 - 1] - xy[n1])
            k[n1] = k[n1 - 1]
        end
    end

    for f in 2:length(xy)
        if xy[f] == xy[1]
            game_over[] = true
        end
    end
    
    if xy[1][1] < 10 || xy[1][1] > 390 || xy[1][2] < 10 || xy[1][2] > 390
        game_over[] = true
    end

    for i in 1:length(xy)
        xy[i] += k[i]
    end
    if xy[1] == fruit[]
        fruit[] = Point2f0(rand(10:20:390), rand(10:20:390))
        push!(xy, xy[end] - k[end])
        push!(k, k[end])
        speed[] -= 0.01
        score[] += 1
    end
    snake[1] = xy
    snake.color = :green
    fruit_plot.color = :red
    fruit_plot[1] = fruit
    sleep(speed[])
end

for i = 1:100
    println("")
end

println("Game Over. Better Luck next time!")
println("Your score was " * string(score[]) * ".")
