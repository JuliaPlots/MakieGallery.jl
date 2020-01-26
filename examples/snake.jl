# Simple snake game using Makie.jl, made by Nand Vinchhi for GCI'19
using Makie

score = 0
println("  ______   __    _       __       _   _   _______")
println("/ ______| |  \\  | |     /  \\     | | / / |  _____|")
println("| |____   | \\ \\ | |    / /\\ \\    | |/ /  | |____")
println("|_____  \\ | |\\ \\| |   / /__\\ \\   | | \\   |  ____|")
println(" _____| | | | \\ \\ |  / /----\\ \\  | |\\ \\  | |_____")
println("|_______/ |_|  \\__| /_/      \\_\\ |_| \\_\\ |_______|")
println("")
println("use the arrow keys to move and collect the red fruit. The snake gets faster and faster as the game progresses!")
scene = Scene(resolution = (400, 400), raw = true, camera = campixel!)
display(scene)

k = [[0, 20], [0, 20], [0, 20], [0, 20]]
dir = lift(scene.events.keyboardbuttons) do but
    
    if ispressed(but, Keyboard.left)
        global k[1] = [-20, 0]

    elseif ispressed(but, Keyboard.up)
        global k[1] = [0, 20]
        
    elseif ispressed(but, Keyboard.right)
        global k[1] = [20, 0]
        
    elseif ispressed(but, Keyboard.down)
        global k[1] = [0, -20]
        
    end
    
end

y = [70, 50, 30, 10]
x = [10, 10, 10, 10]
fruit_x = 90
fruit_y = 110
game_over = false
speed = 0.3
scene = scatter!([fruit_x], [fruit_y], color = :red, marker = :rect, markersize = 20)


function iter()
    
    global scene = scatter!(x, y, color = :white, marker = :rect, markersize = 25)
    

    for i1 = 0:(length(x) - 2)
        global n1 = length(x) - i1
        if k[n1 - 1] == [(x[n1 - 1] - x[n1]), (y[n1 - 1] - y[n1])]
            global k[n1] = k[n1 - 1]
        end
    end
    
    

    for f = 2:length(x)
        if x[f] == x[1] && y[f] == y[1]
            global game_over = true
        end
    end
    
    if x[1] < 10 || x[1] > 390 || y[1] < 10 || y[1] > 390
        global game_over = true
    end

    for i = 1:length(x)
        global x[i] += k[i][1]
        global y[i] += k[i][2]
    end

    if x[1] == fruit_x && y[1] == fruit_y
        global scene = scatter!([fruit_x], [fruit_y], color = :white, marker = :rect, markersize = 25)
        global fruit_x = rand([10, 30, 50, 70, 90, 110, 130, 150, 170, 190, 210, 230, 250, 270, 290, 310, 330, 350, 370, 390])
        global fruit_y = rand([10, 30, 50, 70, 90, 110, 130, 150, 170, 190, 210, 230, 250, 270, 290, 310, 330, 350, 370, 390])
        global scene = scatter!([fruit_x], [fruit_y], color = :red, marker = :rect, markersize = 20)
        push!(x, x[end] - k[end][1])
        push!(y, y[end] - k[end][2])
        push!(k, k[end])
        global speed -= 0.01
        global score += 1
    end
    global scene = scatter!(x, y, color = :green, marker = :rect, markersize = 20)
    
    sleep(speed)

end


while game_over == false
    iter()
end

for i = 1:100
    println("")
end

println("Game Over. Better Luck next time!")
println("Your score was " * string(score) * ".")
for i3 = 1:3
    scene = scatter!(x, y, color = :white, marker = :rect, markersize = 25)
    sleep(0.5)
    scene = scatter!(x, y, color = :green, marker = :rect, markersize = 20)
    sleep(0.5)
end
