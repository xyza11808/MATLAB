function max_del_batch
%%
filepath=input('PLease input the smoothed tiff data files path\n','s');
cd(filepath);
files=dir('*.tif');
filesavepath_gif='.\max_delta_png\';
if (isdir(filesavepath_gif))~=1
    mkdir(filesavepath_gif);
end

for j=1:length(files);
    filename=files(j).name;
    file_save_name=[filename(1:end-4),'_max_delta_'];
    
 %this is the old way of tiff file reads   
% InfoImage=imfinfo(filename);
% mImage=InfoImage(1).Width;
% nImage=InfoImage(1).Height;
% Number_Images=length(InfoImage);
% 
% finalImage=zeros(mImage,nImage,Number_Images,'uint16');
% for i=1:Number_Images
%     finalImage(:,:,i)=imread(filename,'Index',i);
% end
[finalImage,header]=load_scim_data(filename);

% finalImage=im2double(finalImage);
[im_out,hfig]=im_max_delta(finalImage,1,[0,500]);
% im_data_max=max(finalImage,[],3);
% im_data_mean=mean(finalImage,3);
% im_out_MD=im_data_max-im_data_mean;
% 
% im_output=im2uint16(im_out_MD);
% % h=figure;
% imshow(im_output,[0,1000],'Border','tight');
cd(filesavepath_gif);
saveas(hfig,[file_save_name,'.png'],'png');
% imwrite(im_out_MD,[file_save_name,'_2','.tif'],'tif');
% print(h,'-dpng',[file_save_name,'.png']);
close;
% imshow(im_out,[0,1000]);
cd ..;
disp('All max_delta file generate successfully!\n');
end