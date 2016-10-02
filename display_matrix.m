%display the chroma and luma matrix in a separate figure using uitable% 
function display_matrix(lum_mat,chroma_mat)
 
f = figure('position',[0,0,900,500]);
b = uicontrol('Style','text');
set(b,'String','The Luminance Quantization Table');
set(b,'Position',[50 450 300 20]);

t = uitable('Position',[50 250 400 100],'data', lum_mat)
% Set width and height
tableextent = get(t,'Extent');
oldposition = get(t,'Position');
newposition = [oldposition(1) oldposition(2) tableextent(3) tableextent(4)];
set(t, 'Position', newposition);
set(t,'ColumnWidth',{75});

b1 = uicontrol('Style','text');
set(b1,'String','The Chrominance Quantization Table');
set(b1,'Position',[50 220 300 20]);


u = uitable('Position',[50 30 400 100],'data', chroma_mat)
% Set width and height
tableextent = get(u,'Extent');
oldposition = get(u,'Position');
newposition = [oldposition(1) oldposition(2) tableextent(3) tableextent(4)];
set(u, 'Position', newposition);
set(u,'ColumnWidth',{75});

end