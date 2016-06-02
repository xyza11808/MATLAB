function write_data_to_tiff(filename, imdata, tagStruct)
% write_data_to_tiff(filename, imdata, tagStruct)
% filename: target tiff file name. Can contain path strings.
% imdata: height x with x numframes array
% tagStruct: structure array of useful tag for each frame. 
%
%% Write imdata and tag to tiff obj, and save.
tifsaveobj = Tiff(filename,'w');
%%
if nargin > 2
    for i = 1:length(tagStruct)
        tifsaveobj.setTag(tagStruct(i));
        tifsaveobj.write(imdata(:,:,i));
        tifsaveobj.writeDirectory();
    end
end
%%
tifsaveobj.close();