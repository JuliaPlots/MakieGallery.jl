using Makie, GeometryTypes, Colors
using AbstractPlotting: slider!, playbutton
using Observables
using AbstractPlotting: textslider
using FileIO, NIfTI

cd(@__DIR__)
#using Pkg
#Pkg.pkg"add NRRD"
# p = download("http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_asym_09a_nifti.zip")
p = joinpath(homedir(), "Desktop", "brain.nii.gz")
brain_data = Array{Float32}(niread(p))

r = range(-1, stop = 1, length = size(brain_data, 1))

scene3d = Scene(show_axis = false)

contour!(
    scene3d,
    r, r, r, brain_data,
    alpha = 0.1, colorrange = (1, 93), transparency = true, levels = 5
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
    hmap = heatmap!(
        scene3d, r, r, volume[][indices...],
        colorrange = (1, 93),
        interpolate = true
    )[end]
    onany(idx, volume) do idx, vol
        transform!(hmap, (plane, r[idx]))
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

reverse!(scene3d.plots)
display(hbox(
    scene3d,
    vbox(sliders..., b2)
))
