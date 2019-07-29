if record_reference_images
    cd(homedir()) do
        isdir(dirname(recordpath)) || run(`git clone git@github.com:JuliaPlots/MakieReferenceImages.git`)
        isdir(recordpath) && rm(recordpath, recursive = true, force = true)
        mkdir(recordpath)
    end
end
