data_path=uigetdir;
cd(data_path);
files=dir('*.tif');
if ~isdir('./maxdelta/')
    mkdir('./maxdelta/');
end
[imintdata,imintheader]=load_scim_data(files(1).name);
frame_size=size(imintdata);
MaxDeltaAll=zeros(frame_size(1),frame_size(2),length(files));
MeanAll=zeros(frame_size(1),frame_size(2),length(files));
for n=1:length(files)
    filename=files(n).name;
    [imdata,imheader]=load_scim_data(filename);
    mean_im=mean(imdata,3);
    data_smoothed=filter_design(double(imdata),3);
    max_pixel=max(data_smoothed,[],3);
    maxdelta=int16(max_pixel-mean_im);
    MaxDeltaAll(:,:,n)=max_pixel;
    MeanAll(:,:,n)=mean_im;
    
    h=figure;
    imagesc(maxdelta,[0 500]);
    colormap(gray);
    axis off;
    box off;
%     pause(2);
    imTagStruct = get_tiff_tag_to_struct(filename);
    savepath=fullfile(data_path,'maxdelta',[filename(1:end-4) '_Mdelta.tif']);
    write_data_to_tiff(savepath,maxdelta,imTagStruct(1));
    close(h);
end



%%
maxdelta_path=uigetdir;
cd(maxdelta_path);
files=dir('*.tif');
for n=1:length(files)
    filename=files(n).name;
    [imdata,imheader]=load_scim_data(filename);
    if n>1
        MeanMaxDelta=(MeanMaxDelta+imdata)/2;
    else
        MeanMaxDelta=imdata;
    end
end

    MeanMaxDelta=int16(MeanMaxDelta);
    h=figure;
    imagesc(MeanMaxDelta,[0 500]);
    colormap(gray);
    axis off;
    box off;
    
    MeanMaxDelta2=int16(max(MaxDeltaAll,[],3)-mean(MeanAll,3));
    h2=figure;
    imagesc(MeanMaxDelta2,[0 600]);
    colormap(gray);
    axis off;
    box off;
    
    write_data_to_tiff('testMeanMaxdelta.tif',MeanMaxDelta,imTagStruct(1));
    write_data_to_tiff('testMaxMeandelta.tif',MeanMaxDelta2,imTagStruct(1));
    
    