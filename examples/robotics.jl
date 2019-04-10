using Makie
using AbstractPlotting: textslider

"""
    example by @pbouffard from JuliaPlots/Makie.jl#307
    https://github.com/pbouffard/miniature-garbanzo/
"""

struct Joint
    angle::Float32
    axis::Vec3f0
    offset::Vec3f0
end
function AbstractPlotting.plot!(p::Plot(Joint))
    triad = linesegments!(
        p, [Point3f0(0) => unit(Point3f0, i) for i in 1:3],
        color = [:red, :green, :blue],
        linewidth = 3
    ).plots[end]
    on(p[1]) do joint
        translate!(triad, joint.offset)
        rotate!(triad, joint.axis, joint.angle)
        return
    end
    return
end


function Joint(j::Joint; offset::Point3f0 = (0,0,0), axis=(0, 1, 0), angle=0)
    jnew = Joint(j.scene)
    translate!(jnew.scene, j.offset)
    linesegments!(jnew.scene, [Point3f0(0) => offset], linewidth=4, color=:magenta, show_axis=false)
    jnew.axis = axis
    jnew.offset = offset
    setangle!(jnew, angle)
    return jnew
end

scene = Scene(camera = cam3d!)

joints = Node([
    Joint(0, (0,0,1), (0, 0, 1)),
    Joint(-pi/4, (0,1,0), (3,0,0)),
    Joint(pi/2, (0,1,0), (3,0,0)),
    Joint(-pi/4, (0,1,0), (3,0,0)),
    Joint(0, (0,1,0), (3,0,0)),
    Joint(0, (0,1,0), (3,0,0)),
])


[]
sliders = map(1:length(joints)) do i
    slider, val = textslider(-180.0:1.0:180.0, "Joint $(i)", start=rad2deg(joints[i].angle))
    on(val) do x
        setangle!(joints[i], deg2rad(x))
    end
    slider
end

# Add sphere to end effector:
mesh!(joints[end].scene, Sphere(Point3f0(0.5, 0, 0), 0.25f0), color=:cyan, show_axis=false)
center!(s)
