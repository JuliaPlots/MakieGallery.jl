# # Basic Ploting Tutorial
# This tutorial lists the examples done in the basic Plots tutorial
# **Note**: it is possible that the functionality available in plots might not be available yet in Makie.
# The orignal tutorial can be found [here](http://docs.juliaplots.org/latest/tutorial/)

# Importing required packages
using Makie
using DataFrames
using StatsMakie

# ## Basic Plotting: Line Plots
scene = Scene()
lines!(scene, rand(10), color=:blue)
lines!(scene, rand(10), color=:orange)
lines!(scene, rand(10), color=:green)

display(scene)

# The `Scene` object holds everything in a plot. We can think of it like a container for everything.
# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot1.png]
#
# ## Plot Attributes
# In Makie.jl, the modifiers to plots are called attributes.
# These are documented at the [attributes page](http://makie.juliaplots.org/dev/plot-attributes.html)
# Here, we are using the attribute `linewidth` which contols the thickness of the line.
# We are also adding `legend` and `axisnames` to the scene.
# legend is not a ! function i.e. it needs to be concatinated to the scene using hbox/vbox
# We can edit the axis name and other attributes by just passing `Axis` as index to scene.

scene = Scene()
lines!(scene, rand(10), linewidth=3.0, color=:red)
lines!(scene, rand(10), linewidth=3.0, color=:green)
lines!(scene, rand(10), linewidth=3.0, color=:orange)

leg = legend([scene[i] for i in 2:length(scene)], ["line $(jk-1)" for jk in 2:length(scene)])

axis = scene[Axis]
axis[:names, :axisnames] = ("x label", "", "")

title_plot = title(scene,"Three Lines")
s = vbox(title_plot, leg)

display(s)
#
# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot2.png]
#
# ## Changing the Plotting Type
# Here we are introducting a new way of plotting data, a scatter plot
# We can easily generate scatter plots by using `scatter` or `scatter!`, if we want to add it to an existing scene
# In Makie a rule of thumb is that whenever a plotting function ends with a bang, a scene can be passed into that to plot on it.

scene = Scene()
scatter!(scene,rand(10), color=:red)
scatter!(scene, rand(10), color=:blue)

leg = legend([scene[i] for i in 2:length(scene)], ["point $(jk-1)" for jk in 2:length(scene)])

tit = title(scene,"My Scatter Plot")

s = hbox(leg, tit)
display(s)

# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot3.png]

# ## Combining Multiple Plots as Subplots
# We can combine multiple plots together as subplots using hbox/vbox. There are many methods for doing this, and we will show two simple methods for generating simple layouts
# hbox places the plots on top of each other and vbox places them side by side
# Example 1:
l1 = lines(rand(10), linewidth=3.0, color=:red)
l2 = lines(rand(10), linewidth=3.0, color=:green)
l3 = lines(rand(10), linewidth=3.0, color=:orange)

s = hbox(l1,l2,l3)
display(s)

# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot4.png]
# In the next way, we will create 4 diffrent scenes and place them in a 4x4 box
scene1 = Scene()
lines!(scene1, rand(10), color=:red)
lines!(scene1, rand(10), color=:blue)
lines!(scene1, rand(10), color=:green)
t = title(scene1,"subtitle")

scene2 = Scene()
lines!(scene2, rand(10), linewidth=3.0, color=:red)
lines!(scene2, rand(10), linewidth=3.0, color=:blue)
lines!(scene2, rand(10), linewidth=3.0, color=:green)
text!(scene2,"This one is labelled",textsize = 1)

scene3 = Scene()
scatter!(scene3, rand(10), color=:red)
scatter!(scene3, rand(10), color=:blue)

scene4 = Scene()
plot!(scene4,histogram, rand(10), color=:blue)
plot!(scene4,histogram, rand(10), color=:red)
plot!(scene4,histogram, rand(10), color=:green)

s = vbox(hbox(scene2,t),hbox(scene4,scene3))
display(s)

# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot5.png]
#
# ## Reading data from DataFrame
# We can use the `StatsMakie` package to help us with this

df = DataFrame(a = 1:10, b = 10*rand(10), c = 10 * rand(10))
scene = Scene()
lines!(scene, Data(df), :a, :b, color=:orange)
lines!(scene, Data(df), :a, :c, color=:blue)
display(scene)

# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot6.png]
#
# Scatter plotting the data from DataFrame
scene = Scene()
scatter!(scene, Data(df), :a, :b, color=:blue)
display(scene)
# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot7.png]
#

# Violin and Box Plots of data from DataFrames
using RDatasets
scene = Scene()

d = dataset("Ecdat", "Fatality");

violin!(scene,Data(d), :Year, :Perinc, color=:gray)

display(scene)

# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot8.png]
#
boxplot!(d.Year, d.Perinc, color = :black)
display(scene)
# ### OUTPUT:
# ()[https://github.com/Akshat-mehrotra/codein/blob/master/JULIA/Makie%20Images/plot9.png]
