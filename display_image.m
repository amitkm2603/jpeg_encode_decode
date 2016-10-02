function display_image (image)
	YUV(:,:,1) = image.Y_comp;
	YUV(:,:,2) = image.U_comp;
	YUV(:,:,3) = image.V_comp;
    
	rbg = convert_yuv_rgb(YUV);
	imshow(rbg);
end
