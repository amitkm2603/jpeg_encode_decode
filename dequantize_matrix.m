function output=dequantize_matrix(data_matrix,quant_mat_lum,quant_mat_color)
    fun = @dequant;
	dequantized_Y=round(blkproc(data_matrix.Y_comp,[8 8],fun,quant_mat_lum));
	dequantized_U=round(blkproc(data_matrix.U_comp,[8 8],fun,quant_mat_color));
	dequantized_V=round(blkproc(data_matrix.V_comp,[8 8],fun,quant_mat_color));
    
    output=struct('Y_comp',dequantized_Y,'U_comp',dequantized_U,'V_comp',dequantized_V);
end

function output=dequant(mat,quant)
output = mat.*quant;
end


