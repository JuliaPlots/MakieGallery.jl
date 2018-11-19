using Flux, Flux.Data.MNIST, Statistics
using Flux: onehotbatch, onecold, crossentropy, throttle
using Base.Iterators: repeated, partition
using CuArrays
using Colors, FileIO, ImageShow
using Makie, GLMakie
scatter(rand(10)) |> display

function imgviz!(scene, img)
  image!(scene, 0..16, 0..1, img, show_axis = false, scale_plot = false)
end
function d3tod2(input3d)
  rotr90(hcat((input3d[ :, :, i] for i in 1:size(input3d, 3))...))
end
function squeeze(A)
  dims = ((i for i in 1:ndims(A) if size(A, i) == 1)..., )
  dropdims(A, dims = dims)
end

Point2f0(0) in FRect2D((0f0, 0f0), (1f0, 1f0))

function drawto!(scene, img_obs, imgviz)
  bb = FRect2D(boundingbox(imgviz))
  img = img_obs[]
  imsize = (size(img, 1), size(img, 2))
  on(scene.events.mouseposition) do mpos
    if ispressed(scene, Mouse.left)
      pos = to_world(scene, Point2f0(mpos))
      if pos in bb
        pos01 = (pos .- minimum(bb)) ./ widths(bb)
        idx = round.(Int, (pos01 .* Point2f0(imsize .- 1)) .+ 1)
        img[(size(img, 1) - idx[2]) + 1, idx[1]] = 1f0
        img_obs[] = img
      end
    end
  end
end

function create_viz(m, input)
  scene = Scene(camera = cam2d!, raw = true)
  input_img = lift(rotr90 ∘ squeeze ∘ collect, input)
  image!(scene, (-1)..(-8), (0.0)..7, input_img, show_axis = false, scale_plot = false)
  drawto!(scene, input, scene[end])
  layer = async_latest(input)
  lastof = 0.0
  for i in 1:4
    layer = lift(x-> m[i](x), layer)
    img = lift(d3tod2 ∘ collect, layer)
    imgviz!(scene, img)
    im = scene[end]
    translate!(im, 0, lastof, 0)
    lastof += 2
  end
  # lay = vcat((hcat((collect(reshape(W[1:10, ((j-1)*36 + 1):(j*36)][x, :], (6,6))*lay4[:, :, j]) for x in 1:10)...) for j in 1:8)...)
  heatmap!(scene, 0..16, 0..1, lift(x-> collect(m[6].W'), layer))
  translate!(scene[end], 0, lastof, 0)
  lastof += 2
  height = lift(layer) do layer
    (collect(layer |>  m[5] |> m[6])[:, 1] .+ 10) ./ 10
  end
  xrange = range(1, stop = 15, length = 10)
  annotations!(scene,
    string.(0:9), Point2f0.(xrange, lastof - 0.6),
    textsize = 0.5
  )
  barplot!(scene, xrange, height, color = height, colormap = Reverse(:Spectral))
  translate!(scene[end], 0, lastof, 0)
  center!(scene)
  display(scene)
  scene
end

# Classify MNIST digits with a convolutional network
imgs = MNIST.images()
labels = onehotbatch(MNIST.labels(), 0:9)

# Partition into batches of size 1,000
train = [(cat(float.(imgs[i])..., dims = 4), labels[:,i])
         for i in partition(1:60_000, 1000)]

use_gpu = true # helper to easily switch between gpu/cpu

todevice(x) = use_gpu ? gpu(x) : x

train = todevice.(train)

# Prepare test set (first 1,000 images)
tX = cat(float.(MNIST.images(:test)[1:1000])..., dims = 4) |> todevice
tY = onehotbatch(MNIST.labels(:test)[1:1000], 0:9) |> todevice

m = Chain(
  Conv((2,2), 1=>16, relu),
  x -> maxpool(x, (2,2)),
  Conv((2,2), 16=>8, relu),
  x -> maxpool(x, (2,2)),
  x -> reshape(x, :, size(x, 4)),
  Dense(288, 10), softmax
) |> todevice

loss(x, y) = crossentropy(m(x), y)

accuracy(x, y) = mean(onecold(m(x)) .== onecold(y))
using Observables
img_node = Node(tX[:, :, 1:1, 1:1])
scene = create_viz(m, img_node)

evalcb = throttle(0.01) do
  img_node[] = img_node[] # update image
end

opt = ADAM(Flux.params(m));

for i in 1:10
    Flux.train!(loss, train, opt, cb = evalcb)
end
