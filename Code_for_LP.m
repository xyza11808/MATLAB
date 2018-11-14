
DataFolder = uigetdir(pwd,'Please select your data savege folder');
cd(DataFolder);
TifFiles = dir(fullfile(DataFolder,'*.tif'));
if isempty(TifFiles)
    fprintf('No tif file found at current folder.\n');
    return;
end
%% load all frame data
nfiles = length(TifFiles);
Iminfo = imfinfo(TifFiles(1).name);
ImWid = Iminfo.Width;
ImHei = Iminfo.Height;
fBaseName = TifFiles(1).name(1:end-11);

AllLoadIms = zeros(ImWid,ImHei,nfiles);
for cf = 1 : nfiles
    cfName = sprintf('%s%03d.ome.tif',fBaseName,cf);
    TiffLinks = Tiff(cfName,'r');
    TiffLinks.setDirectory(1);
    
    cfData = TiffLinks.read();
    AllLoadIms(:,:,cf) = cfData;
end
%% load reference data
RefFilePath = fullfile(DataFolder,'References');
RefFileFullPosPath = dir(fullfile(RefFilePath,'*16bit*.tif'));
if isempty(RefFileFullPosPath)
    fprintf('No reference file was found.\n');
    return;
end
RefFileFullP = fullfile(RefFilePath,RefFileFullPosPath.name);
RefTiflink = Tiff(RefFileFullP,'r');
RefTiflink.setDirectory(1);
RefData = RefTiflink.read();

%% aligned all frames to ref frames
RefDataNew = uint16(RefData);
AllDataNew = uint16(AllLoadIms);
[im_dft_reg,shift] = dft_reg(AllDataNew, RefDataNew); 


%%
figure;
for cf = 1 : nfiles
%     imagesc(squeeze(AllLoadIms(cf,:,:)),[200 1200]);
    imagesc(squeeze(im_dft_reg(:,:,cf)),[200 1200]);
    colormap gray
    pause(0.1);
end

%% calculate the mecdelta and plot
ims=im_mov_avg(im_dft_reg,3);
im_Max=max(ims,[],3);
im_mean = mean(im_dft_reg,3);
max_delta=double(im_Max)-im_mean;
%%
hh = figure;
% imagesc(im_mean,[prctile(im_mean(:),20),prctile(im_mean(:),99)]);
imagesc(max_delta,[prctile(max_delta(:),20),prctile(max_delta(:),99)]);
colormap gray

%% ROI drawing
[RawDataAll,FchangeDataAll,ROI_Struct,BaselineValue] = ROI_extraction_Meg_2p(im_dft_reg,nfiles,hh);

