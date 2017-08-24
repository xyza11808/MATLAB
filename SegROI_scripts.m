clear
clc
[fn,fp,fi] = uigetfile('*.tif','Please select the tif file used for aegmental ROIs');

if fi
    fpath = fullfile(fp,fn);
    [Selectim,header] = load_scim_data(fpath);
    nFrame = size(Selectim,3);
    FrameSize = size(Selectim,1);
    nSegNum = 16;
    nSegLen = FrameSize/nSegNum;
    nSegIndex = 1:nSegLen:(FrameSize+1);
    RawMask = zeros(FrameSize,FrameSize);
    
    nROInum = nSegNum*nSegNum;
    ROImaskCell = cell(nROInum,1);
    ROIcenter = zeros(nROInum,2);  % row by col
    cROIindex = 1;
    for crowROI = 1 : nSegNum
        for ccolROI = 1 : nSegNum
            crowRange = nSegIndex(crowROI):nSegIndex(crowROI+1)-1;
            ccolRange = nSegIndex(ccolROI):nSegIndex(ccolROI+1)-1;
            ROIcenter(cROIindex,:) = [(nSegIndex(crowROI)+nSegIndex(crowROI+1))/2,...
                (nSegIndex(ccolROI)+nSegIndex(ccolROI+1))/2];
            cROImask = RawMask;
            cROImask(crowRange,ccolRange) = 1;
            ROImaskCell{cROIindex} = logical(cROImask);
            cROIindex = cROIindex + 1;
        end
    end
end
FrameRate = round(header.SI4.scanFrameRate);
%
cd(fp);
AllFiles = dir('*.tif');
nfiles = length(AllFiles);
 nROIs = length(ROImaskCell);
ROIdata = zeros(nfiles,nROInum,nFrame);
parfor nf = 1 : nfiles
    cfilename = AllFiles(nf).name;
    [im,h] = load_scim_data(cfilename);

    cFileData = zeros(nROInum,nFrame);
    for cROI = 1 : nROIs
        cROImask = ROImaskCell{cROI};
        FileMask = repmat(cROImask,1,1,nFrame);
        cROIpixelnum = sum(sum(cROImask));
        ROI_im_data = double(reshape(im(FileMask),cROIpixelnum,[]));
        cFileData(cROI,:) = mean(ROI_im_data);
    end
    ROIdata(nf,:,:) = cFileData;
end
save SegROIdata.mat ROIdata ROImaskCell -v7.3
%%
FrawData = zeros(size(ROIdata)); % swltf/F data set
for n = 1 : nROIs
    cROIdata = squeeze(ROIdata(:,n,:));
    cROIbase = mean(cROIdata,2);
    cROIbaseData = repmat(cROIbase,1,size(cROIdata,2));
    cROIFF = (cROIdata - cROIbaseData)./ cROIbaseData*100;
    FrawData(:,n,:) = cROIFF;
end
%
[Stimfn,Stimfp,~] = uigetfile('*.txt','Please select the stim text file');
SoundArray = textread(fullfile(Stimfp,Stimfn));
%
ExcludeInds = SoundArray(:,3) < 10 | SoundArray(:,3) > 240;
UsedROIData = FrawData(~ExcludeInds,:,:);
UsedSounds = SoundArray(~ExcludeInds,1);
[~,SortInds] = sort(UsedSounds);

if ~isdir('./ROI_resp_plot/')
    mkdir('./ROI_resp_plot/');
end
cd('./ROI_resp_plot/');

for cROI = 1 : nROIs
    cROIData = squeeze(UsedROIData(:,cROI,:));
    MaxScale = max(cROIData(:));
    hf = figure;
    imagesc(cROIData(SortInds,:),[0,min(300,MaxScale)]);
    colorbar;
    xlim([0.5 nFrame+0.5]);
    ylim([0.5  length(SortInds)+0.5]);
    title(sprintf('ROI%d colorplot',cROI));
    xlabel('Frames');
    ylabel('Trials');
    set(gca,'FontSize',18);
    saveas(hf,sprintf('ROI%d color plot',cROI));
    saveas(hf,sprintf('ROI%d color plot',cROI),'png');
    close(hf);
end

%%
SelectNum = input('Please input the ROI index to show:\n','s');
ROIinds = str2num(SelectNum);
% [Colnum,Rownum] = ind2sub([nSegNum,nSegNum],ROIinds);
MeanImage = squeeze(mean(double(Selectim),3));
%%
hhf = figure;
imagesc(MeanImage,[0 300])
colormap gray
text(ROIcenter(ROIinds,2),ROIcenter(ROIinds,1),cellstr(num2str(ROIinds')),'Color','g')
saveas(hhf,'Segmental ROI response to sound labeling');
saveas(hhf,'Segmental ROI response to sound labeling','png');
saveas(hhf,'Segmental ROI response to sound labeling','pdf');
save ROIindex.mat ROIinds -v7.3
cd ..;