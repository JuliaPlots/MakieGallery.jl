gyroid(v) = cos(v[1])*sin(v[2])+cos(v[2])*sin(v[3])+cos(v[3])*sin(v[1])
gyroid_shell(v) = max(gyroid(v)-0.4,-gyroid(v)-0.4)
xr,yr,zr = ntuple(_->LinRange(0,pi*4,50),3)
A = [gyroid_shell((x,y,z)) for x in xr, y in yr, z in zr]
A[1,:,:] .= 1e10
A[:,1,:] .= 1e10
A[:,:,1] .= 1e10
A[end,:,:] .= 1e10
A[:,end,:] .= 1e10
A[:,:,end] .= 1e10

volume(A, algorithm=:iso, isovalue=0.5, isorange=0.05)


using FFTW
using LinearAlgebra
using Random
# Fourier synthesis of an isosurface using 1/f^α noise
function one_on_f_noise(T, α, f)
    # 2α needed to convert powers to amplitudes here
    ϵ = sqrt(eps(real(T)))
    A = RNG.randn(T)
    return convert(T, A / (ϵ + norm(f))^2α)
end

N = 200
α = 1.2f0
Random.seed!(2)
# symmetric frequency space
fx = range(-1,1,length=N)
fy = reshape(fx,1,:)
fz = reshape(fx,1,1,:)
spectrum = one_on_f_noise.(ComplexF32, α, Vec3f0.(fx, fy, fz))
iso = real.(fft(fftshift(spectrum)))
mini, maxi = extrema(iso)
iso_norm = (iso .- mini) ./ (maxi - mini)
volume(iso_norm, algorithm=:iso, isovalue=0.5, isorange=0.05)
