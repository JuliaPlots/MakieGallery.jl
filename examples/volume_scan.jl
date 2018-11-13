using Makie, GeometryTypes, Colors
using AbstractPlotting: slider!, playbutton
using Observables
using AbstractPlotting: textslider

cd(@__DIR__)
using Pkg
Pkg.pkg"add NRRD"
using FileIO
p = joinpath(homedir(), "Desktop", "brain.nrrd")
brain_data = Array{Float32}(load(p))
extrema(brain_data)

r = range(-1, stop = 1, length = size(brain_data, 1))
scene3d = contour(
    r, r, r, brain_data,
    colorrange = (10, 255), alpha = 0.2
)
c = scene3d[end]
volume = c[4]
planes = (:xy, :xz, :yz)
sliders = ntuple(3) do i
    s, idx = textslider(1:size(volume[], i), ("x", "y", "z")[i], start = size(volume[], i) ÷ 2)
    plane = planes[i]
    indices = ntuple(3) do j
        planes[j] == plane ? 1 : (:)
    end
    hmap = contour!(
        scene3d, r, r, volume[][indices...],
        raw = true, colorrange = (0.0, 1.0), fillrange = true,
        interpolate = true, linewidth = 0.1
    )[end]
    onany(idx, volume) do _idx, vol
        idx = (i in (1, 2)) ? (size(vol, i) - _idx) + 1 : _idx
        transform!(hmap, (plane, r[_idx]))
        indices = ntuple(3) do j
            planes[j] == plane ? idx : (:)
        end
        if checkbounds(Bool, vol, indices...)
            hmap[3][] = view(vol, indices...)
        end
    end
    s
end


b2 = Scene()
button!(b2, "3d/2d"; dimensions = (60, 40)) do clicks
    if iseven(clicks)
        cam3d!(scene3d)
    else
        cam2d!(scene3d)
        update_cam!(scene3d, FRect(-1.25, -1.25, 2.5, 2.5))
    end
end

display(hbox(
    scene3d,
    vbox(sliders..., b2)
))
