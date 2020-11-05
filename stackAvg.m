function stackAvg(varargin)
%this function is used to avarage stack imaging result and output a tiff
%file for imageJ to do the threeD reconstruction
FrameInds = [];
if nargin > 0 && ~isempty(varargin{1})
    FrameInds = varargin{1};
end

[filename,filepath,fileindex]=uigetfile('*.tif','Select your stack imaging data file');
if ~fileindex
    return;
else
    cd(filepath);
    disp(['loading file' filename '...']);
    [imdata,imheader]=load_scim_data(filename, FrameInds);
end

framesize=size(imdata);
NumStack=imheader.SI4.stackNumSlices;
FramesPreStack=framesize(3)/NumStack;

NewStackData=zeros(framesize(1),framesize(2),NumStack);
for n=1:NumStack
    SingleStackData=imdata(:,:,((n-1)*FramesPreStack+1):(n*FramesPreStack));
    NewStackData(:,:,n)=sum(SingleStackData,3)/FramesPreStack;
end

imTagStruct = get_tiff_tag_to_struct(filename);    
NewImTag = imTagStruct(1:FramesPreStack:framesize(3));
NewFileName=[filename(1:end-4) '_Avg.tif']; 
savepath=fullfile(pwd,NewFileName);
disp(['The Avg stack file saved to ' savepath]);
write_data_to_tiff(savepath,int16(NewStackData),NewImTag);
