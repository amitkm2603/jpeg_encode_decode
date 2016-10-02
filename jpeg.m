%@author: Amit Mandal
%Reference: http://users.ece.utexas.edu/~ryerraballi/MSB/pdfs/M4L1_HJPEG.pdf
function jpeg(quality_factor)
%define constants%
quant_mat_lum=[16  11  10  16  24  40  51  61;
    12  12  14  19  26  58  60  55;
    14  13  16  24  40  57  69  56;
    14  17  22  29  51  87  80  62;
    18  22  37  56  68 109 103  77;
    24  35  55  64  81 104 113  92;
    49  64  78  87 103 121 120 101;
    72  92  95  98 112 100 103  99
];
quant_mat_color=[17 18 24 47 99 99 99 99,
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99
];
%construct dct matrix
%http://dsp.stackexchange.com/questions/14836/nxm-dct-matrix-generation
global dct_basis_matrix;
n =8;
[cc,rr] = meshgrid(0:n-1);
dct_basis_matrix = sqrt(2 / n) * cos(pi * (2*cc + 1) .* rr / (2 * n)); 
dct_basis_matrix(1,:) = dct_basis_matrix(1,:) / sqrt(2);

%%
%Implement quality
quant_mat_lum = quality(quality_factor,quant_mat_lum);
quant_mat_color = quality(quality_factor,quant_mat_color);
%%
%read image%
OriginalImage = (imread('4.png'));  
    
Image = double(OriginalImage);

% Image_r = Image(:,:,1);
% Image_b = Image(:,:,2);
% Image_g = Image(:,:,3);
 
% convert RGB image into YUV / YCbCr space
Image_YUV = convert_rgb_yuv(Image);
 
Y_comp = Image_YUV(:,:,1); % Y luminance component
U_comp = Image_YUV(:,:,2); % U chrominance component
V_comp = Image_YUV(:,:,3); % V chrominance component
%%
%Implementing 4:2:0 subsampling
U_comp = sample_down(U_comp);
V_comp = sample_down(V_comp);

%%
% x(:,:,1) = Y_comp;
% x(:,:,2) = U_comp;
% x(:,:,3) = V_comp;
% display_image(convert_yuv_rgb(x));

%3 resolution images
f1 = struct('Y_comp',Y_comp,'U_comp',U_comp ,'V_comp'  ,V_comp);
%downsample 2 of f
f2 = struct('Y_comp',sample_down(Y_comp), 'U_comp',sample_down(U_comp),'V_comp',sample_down(V_comp));
%downsample 4 of f
f4 = struct('Y_comp',sample_down(sample_down(Y_comp)),'U_comp',sample_down(sample_down(U_comp)),'V_comp',sample_down(sample_down(V_comp)));


%%
%encode f4
%blkproc:
%https://www.mathworks.com/matlabcentral/newsreader/view_thread/157256
%http://nf.nci.org.au/facilities/software/Matlab/toolbox/images/blkproc.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compress f4 (I/4)-> compressed_f4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
	% apply DCT 
    dct_mat = dct_matrix(f4);    
    % apply Quantization
    % disp(quantized_Y(1,:));
   quantized_mat = quantize_matrix(dct_mat,quant_mat_lum,quant_mat_color);
   compressed_f4 = struct('Y_comp',quantized_mat.Y_comp,'U_comp',quantized_mat.U_comp,'V_comp',quantized_mat.V_comp);

 %%%%%%%%%%%%%%%%%%%%%%%  Decompress f4 -> decompressed_f_4
 %Dequantize
 
    dequantize_mat = dequantize_matrix(quantized_mat,quant_mat_lum,quant_mat_color);
%      disp(dequantize_Y(1,:));
	% apply IDCT
 
    idct_mat = idct_matrix(dequantize_mat);

    decompressed_f_4=struct('Y_comp',idct_mat.Y_comp,'U_comp',idct_mat.U_comp,'V_comp',idct_mat.V_comp);
    
%   display_image(decompressed_f_4);
    %upsample f4' by 2
    %f4_up --> I2''
    f4_up = struct('Y_comp',sample_up(decompressed_f_4.Y_comp),'U_comp',sample_up(decompressed_f_4.U_comp),'V_comp',sample_up(decompressed_f_4.V_comp));
 
% E(I2 - I2'') : difference_4_2 --> difference between decompressed up scaled decompressed f4 i.e I'' and uncompressed f2
    difference_4_2 = struct('Y_comp',(f2.Y_comp) - f4_up.Y_comp,'U_comp',(f2.U_comp) - f4_up.U_comp,'V_comp',(f2.V_comp) - f4_up.V_comp);
%   
% display_image(difference_4_2);
 %Compress the difference   

 	% apply DCT 
 
    dct_mat = dct_matrix(difference_4_2); 
    
    % apply Quantization
 
    quantized_mat = quantize_matrix(dct_mat,quant_mat_lum,quant_mat_color);
   
    compressed_difference_f4_2 = struct('Y_comp',quantized_mat.Y_comp,'U_comp',quantized_mat.U_comp,'V_comp',quantized_mat.V_comp);
    %decompress compressed_difference_f4
%     %Dequantize
 
    dequantize_mat = dequantize_matrix(quantized_mat,quant_mat_lum,quant_mat_color);
	% apply IDCT
 
     idct_mat = idct_matrix(dequantize_mat);
    
    decompressed_f_4_2=struct('Y_comp',idct_mat.Y_comp,'U_comp',idct_mat.U_comp,'V_comp',idct_mat.V_comp);
%  display_image(decompressed_f_4_2);
%   I2' -> I'' (upsample I2'' by 2) 
% adding decompressed f4 and difference between f4 and f2 
   f2_up=struct('Y_comp',sample_up(f4_up.Y_comp+decompressed_f_4_2.Y_comp),'U_comp',sample_up(f4_up.U_comp+decompressed_f_4_2.U_comp),'V_comp',sample_up(f4_up.V_comp+decompressed_f_4_2.V_comp));
%   display_image(f2_up);

    %calculate difference between decompressed f and uncompressed difference_f2
    %E(I - I'')
    difference_2_1 = struct('Y_comp',(f1.Y_comp) - f2_up.Y_comp,'U_comp',(f1.U_comp) - f2_up.U_comp,'V_comp',(f1.V_comp) - f2_up.V_comp);
 
    %Compress the difference   

 	% apply DCT 
 
    dct_mat = dct_matrix(difference_2_1);    
    % apply Quantization
 
    quantized_mat = quantize_matrix(dct_mat,quant_mat_lum,quant_mat_color);
    %compress the difference -(I - I'')) %
    compressed_difference_f2_1 = struct('Y_comp',quantized_mat.Y_comp,'U_comp',quantized_mat.U_comp,'V_comp',quantized_mat.V_comp);
   
    
    
    %%%%%
    % Decode - compressed f4, compressed difference f4-f2, compressed
    % difference f2 - f
    %%%%%
    
    %decompress compressed_f4
    %Dequantize
    dequantize_mat = dequantize_matrix(compressed_f4,quant_mat_lum,quant_mat_color);
	% apply IDCT
    idct_mat = idct_matrix(dequantize_mat);

    decompressed_compressed_f4=struct('Y_comp',idct_mat.Y_comp,'U_comp',idct_mat.U_comp,'V_comp',idct_mat.V_comp);
    %  display_image(decompressed_compressed_f4);
    
    %decompress compressed_difference_f4_2
    %Dequantize
 
    dequantize_mat = dequantize_matrix(compressed_difference_f4_2,quant_mat_lum,quant_mat_color);
	% apply IDCT
 
    idct_mat = idct_matrix(dequantize_mat);
    decompressed_difference_f4_2=struct('Y_comp',idct_mat.Y_comp,'U_comp',idct_mat.U_comp,'V_comp',idct_mat.V_comp);
    
    %decompress compressed_difference_f2_1
    %decompress the difference -(I - I'')) %
    %Dequantize
 
    dequantize_mat = dequantize_matrix(compressed_difference_f2_1,quant_mat_lum,quant_mat_color);
    % apply IDCT
 
    idct_mat = idct_matrix(dequantize_mat);
    decompressed_difference_f2_1=struct('Y_comp',idct_mat.Y_comp,'U_comp',idct_mat.U_comp,'V_comp',idct_mat.V_comp);
    
    %reversing 4:2:0 sampling by sampling up U and V one more step compared to Y% 
    Y_comp=sample_up(sample_up(decompressed_compressed_f4.Y_comp)+decompressed_difference_f4_2.Y_comp)+decompressed_difference_f2_1.Y_comp;
    U_comp=sample_up(sample_up(sample_up(decompressed_compressed_f4.U_comp)+decompressed_difference_f4_2.U_comp)+decompressed_difference_f2_1.U_comp);
    V_comp=sample_up(sample_up(sample_up(decompressed_compressed_f4.V_comp)+decompressed_difference_f4_2.V_comp)+decompressed_difference_f2_1.V_comp);

    decompressed_final=struct('Y_comp',Y_comp,'U_comp',U_comp,'V_comp',V_comp);
    
    figure(1);
    subplot(2,3,1);
    imshow(OriginalImage);
    temp = mat2str(size(OriginalImage));
    title(strcat('Uncompressed Image. Dim:',temp));
    temp = mat2str(size(decompressed_final.Y_comp));
    subplot(2,3,3);
    display_image(decompressed_final);  
    
    title(strcat('Compressed Image ',temp));
    
    decompressed_compressed_f4.U_comp = sample_up(decompressed_compressed_f4.U_comp);
    decompressed_compressed_f4.V_comp = sample_up(decompressed_compressed_f4.V_comp);
    subplot(2,3,4);
    display_image(decompressed_compressed_f4);
    temp = mat2str(size(decompressed_compressed_f4.Y_comp));
    title(strcat('decompressed image of f4. Dim:',temp));

    decompressed_difference_f2_1.U_comp = sample_up(decompressed_difference_f2_1.U_comp);
    decompressed_difference_f2_1.V_comp = sample_up(decompressed_difference_f2_1.V_comp);
    subplot(2,3,6);
    display_image(decompressed_difference_f2_1);
     temp = mat2str(size(decompressed_difference_f2_1.Y_comp));
    title(strcat('decompressed image of difference f2 to f1. Dim:',temp));
    decompressed_difference_f4_2.U_comp = sample_up(decompressed_difference_f4_2.U_comp);
    decompressed_difference_f4_2.V_comp = sample_up(decompressed_difference_f4_2.V_comp);
    subplot(2,3,5);
    display_image(decompressed_difference_f4_2);
     temp = mat2str(size(decompressed_difference_f4_2.Y_comp));
    title(strcat('decompressed image of difference between f4 and f2',temp));
    
    %%print the quantization matrices
    display_matrix(quant_mat_lum,quant_mat_color);
end
