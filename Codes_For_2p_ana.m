
DataFolder = uigetdir(pwd,'Please select your data savege folder');
cd(DataFolder);
TifFiles = dir(fullfile(DataFolder,'*.tif'));
if isempty(TifFiles)
    fprintf('No tif file found at current folder.\n');
    return;
end

%% define tif tag field names
% default values, no need for modification
TagFields = {'ImageLength',...
    'ImageWidth',...
    'Photometric',...
    'BitsPerSample',...
    'SamplesPerPixel',...
    'RowsPerStrip',...
    'PlanarConfiguration',...
    'Software',...
    'SampleFormat',...
    'Compression',...
    'SubFileType',...
    'ImageDescription',...
    'Orientation'};%,...
%     '',...
%     '',...
%     '',...
%     '',...
%     '',...
nTagNum = length(TagFields);

%% load all frame data
nfiles = length(TifFiles);
Iminfo = imfinfo(TifFiles(1).name);
ImWid = Iminfo.Width;
ImHei = Iminfo.Height;
fBaseName = TifFiles(1).name(1:end-11);

AllLoadIms = zeros(ImWid,ImHei,nfiles);
TagStructs = cell(nfiles,1);
for cf = 1 : nfiles
    cfName = sprintf('%s%03d.ome.tif',fBaseName,cf);
    TiffLinks = Tiff(cfName,'r+');
    TiffLinks.setDirectory(1);
    
    NewTifTag = struct();
    for cfield = 1 : nTagNum
        try
            cfv = TiffLinks.getTag(TagFields{cfield});
            NewTifTag.(TagFields{cfield}) = cfv;
        end
    end
    
    TagStructs{cf} = NewTifTag;
    
    cfData = TiffLinks.read();
    AllLoadIms(:,:,cf) = cfData;
end
%% load reference data
% RefFilePath = fullfile(DataFolder,'References');
% RefFileFullPosPath = dir(fullfile(RefFilePath,'*16bit*.tif'));
% 
% if isempty(RefFileFullPosPath)
%     fprintf('No reference file was found.\n');
%     return;
% end
% % [fn,RefFilePath,fi] = uigetfile('*.tif','Please select your ref image file.');
% 
% % RefFileFullP = fullfile(RefFilePath,fn);
% RefFileFullP = fullfile(RefFilePath,RefFileFullPosPath.name);
% RefTiflink = Tiff(RefFileFullP,'r');
% RefTiflink.setDirectory(1);
% RefData = RefTiflink.read();
% #####################
% select range for reference image calculation
SelectRange = 150:200;
RefData = squeeze(mean(AllLoadIms(:,:,SelectRange),3));


%% aligned all frames to ref frames
RefDataNew = uint16(RefData);
AllDataNew = uint16(AllLoadIms);
[im_dft_reg,shift] = dft_reg(AllDataNew, RefDataNew); 

%% write tif files into one tif file
SavedTifName = 'AlignedFSave2.tif';
% t = Tiff(SavedTifName,'w');
for ctf = 1 : nfiles
%     t.setDirectory(ctf);
    if ctf == 1
        t = Tiff(SavedTifName,'w');
    else
        t = Tiff(SavedTifName,'a');
    end
    t.setTag(TagStructs{ctf});
    t.write(squeeze(im_dft_reg(:,:,ctf)));
    t.close();
end

%%
figure;
for cf = 1 : nfiles
%     imagesc(squeeze(AllLoadIms(cf,:,:)),[200 1200]);
    imagesc(squeeze(im_dft_reg(:,:,cf)),[000 500]);
    colormap gray
    pause(0.1);
end

%% load ROIs from imageJ output
ROIFolder = uigetdir(pwd,'Please select your ROI data saved file');
ROIfiles = dir(fullfile(ROIFolder,'*.roi'));
nfiles = length(ROIfiles);
filenameAll = cell(nfiles,1);
for cf = 1 : nfiles
    filenameAll{cf} = fullfile(ROIFolder,ROIfiles(cf).name);
end

%% following former section
MD_ROIData = ReadImageJROI(filenameAll);
ROIType = cellfun(@(x) isempty(strfind(x.strName,'md')),MD_ROIData); % 1 mean territory ROI, 0 mean md ROI
ROIMasks = cellfun(@(x) poly2mask(x.mnCoordinates(:,1),x.mnCoordinates(:,2),512,512),MD_ROIData,'Uniformoutput',false);
nROIs = length(ROIMasks);
%% calculate the mecdelta and plot
ims=im_mov_avg(im_dft_reg,3);
im_Max=max(ims,[],3);
im_mean = mean(im_dft_reg,3);
max_delta=double(im_Max)-im_mean;

%% using the max-delta image for ROI plots



%% extract ROI data for each ROI 
nROIs = length(ROIMasks);
nFrames = size(im_dft_reg,3);
ROIDataAll = zeros(nROIs,nFrames);
DeltaFROIData = zeros(nROIs,nFrames);
for cROI = 1 : nROIs
    cROImask = ROIMasks{cROI};
    ROIPixelNum = sum(sum(cROImask));
    ExpendMAsk = repmat(cROImask,1,1,nFrames);
    ROIDatas  = double(reshape(im_dft_reg(ExpendMAsk),ROIPixelNum,[]));
    ROIDataAll(cROI,:) = mean(ROIDatas);
    
    BaseF = prctile(ROIDataAll(cROI,:),8);
    DeltaFROIData(cROI,:) = (ROIDataAll(cROI,:) - BaseF)/BaseF;
end


%%
hh = figure;
% imagesc(im_mean,[prctile(im_mean(:),20),prctile(im_mean(:),99)]);
imagesc(max_delta,[prctile(max_delta(:),20),prctile(max_delta(:),90)]);
colormap gray

%% ROI drawing
[RawDataAll,FchangeDataAll,ROI_Struct,BaselineValue] = ROI_extraction_Meg_2p(im_dft_reg,nfiles,hh);
