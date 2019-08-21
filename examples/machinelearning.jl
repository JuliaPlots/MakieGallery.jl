@block AnshulSinghvi "UMAP" begin

    @cell "Basic UMAP visualization" [2d, scatter, umap, ml] begin
        using MLDatasets, UMAP
        mnist_x = MNIST.convert2features(MNIST.traintensor(Float64))
        mnist_y = MNIST.trainlabels(1:size(mnist_x, 2));
        res_jl = UMAP.umap(mnist_x; n_neighbors=10, min_dist=0.001, n_epochs=200)
        scatter(res_jl[1, :], res_jl[2, :]; color = mnist_y, colormap = :magma) # as in repo
    end

    @cell "3D UMAP visualization" [3d, scatter, umap, ml] begin
        using MLDatasets, UMAP
        mnist_x = MNIST.convert2features(MNIST.traintensor(Float64))
        mnist_y = MNIST.trainlabels(1:size(mnist_x, 2));
        res_jl = UMAP.umap(mnist_x, 3; n_neighbors=10, min_dist=0.001, n_epochs=200)
        scatter(eachrow(res)...; color = mnist_y, colormap = :magma) # 3D, Makie style!
    end

    # @cell "3D UMAP visualization with mouse highlighting" [3d, scatter, umap, ml] begin
    #     using MLDatasets, UMAP
    #     mnist_x = MNIST.convert2features(MNIST.traintensor(Float64))
    #     mnist_y = MNIST.trainlabels(1:size(mnist_x, 2));
    #     res_jl = UMAP.umap(mnist_x, 3; n_neighbors=10, min_dist=0.001, n_epochs=200)
    #     sc = scatter(eachrow(res)...; color = mnist_y, colormap = :magma) # 3D, Makie style!
    #     ju
    # end
end
