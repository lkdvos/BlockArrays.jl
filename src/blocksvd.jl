#=
SVD on blockmatrices:
Interpret the matrix as a linear map acting on vector spaces with a direct sum structure, which is reflected in the structure of U and V.
In the generic case, the SVD does not preserve this structure, and can mix up the blocks, so S becomes a single block.
(Implementation-wise, also most efficiently done by first mapping to a `BlockedArray`)
=#

LinearAlgebra.eigencopy_oftype(A::AbstractBlockMatrix, S) = BlockedArray(Array{S}(A), blocksizes(A, 1), blocksizes(A, 2))

function LinearAlgebra.svd!(A::BlockedMatrix; full::Bool=false, alg::LinearAlgebra.Algorithm=default_svd_alg(A))
    USV = svd!(parent(A); full, alg)

    # restore block pattern
    m = length(USV.S)
    bsz1, bsz2, bsz3 = blocksizes(A, 1), [m], blocksizes(A, 2)

    u = BlockedArray(USV.U, bsz1, bsz2)
    s = BlockedVector(USV.S, bsz2)
    vt = BlockedArray(USV.Vt, bsz2, bsz3)
    return SVD(u, s, vt)
end
