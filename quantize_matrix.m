function output=quantize_matrix(data_matrix,quant_mat_lum,quant_mat_color)

    fun = @quantize;
	quantized_Y=round(blkproc(data_matrix.Y_comp,[8 8],fun,quant_mat_lum));
	quantized_U=round(blkproc(data_matrix.U_comp,[8 8],fun,quant_mat_color));
	quantized_V=round(blkproc(data_matrix.V_comp,[8 8],fun,quant_mat_color));
    
    output=struct('Y_comp',quantized_Y,'U_comp',quantized_U,'V_comp',quantized_V);
end

function output=quantize(mat,quant)
A = quant;
B = mat;
output = mat./quant;
end
