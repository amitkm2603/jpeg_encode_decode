function output=idct_matrix(matrix)
    fun = @idct;
    idct_Y = blkproc(matrix.Y_comp, [8 8], fun);
    idct_U = blkproc(matrix.U_comp, [8 8], fun);
    idct_V = blkproc(matrix.V_comp, [8 8], fun);
    
    output=struct('Y_comp',idct_Y,'U_comp',idct_U,'V_comp',idct_V);
end

function output=idct(arg1)
%construct dct matrix
%http://dsp.stackexchange.com/questions/14836/nxm-dct-matrix-generation
% n =8;
% [cc,rr] = meshgrid(0:n-1);
% dct_basis_matrix = sqrt(2 / n) * cos(pi * (2*cc + 1) .* rr / (2 * n)); 
% dct_basis_matrix(1,:) = dct_basis_matrix(1,:) / sqrt(2);
global dct_basis_matrix;
output = dct_basis_matrix' * arg1 * dct_basis_matrix;
end