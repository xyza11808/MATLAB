% generate the ROI shaped pixel image plot for each ROI
%
clear
clc

[fn,fp,fi]= uigetfile('*.mat','Please select the ROI info mat file');
if ~fi
    return;
end
cd(fp);
load(fullfile(fp,'SessionFrameProj.mat'));
load(fn);
%% generate the maxdelta figure
nTrs = length(FrameProjSave);
FrameSize = size(FrameProjSave(1).MeanFrame);
MeanFrameAll = zeros([nTrs,FrameSize]);
MaxFrameAll = zeros([nTrs,FrameSize]);
for nntr = 1 : nTrs
    cMeanFrame = double(FrameProjSave(nntr).MeanFrame);
    cMaxFrame = double(FrameProjSave(nntr).MaxFrame);
    MeanFrameAll(nntr,:,:) = cMeanFrame;
    MaxFrameAll(nntr,:,:) = cMaxFrame;
end
%
SessMeanF = squeeze(mean(MaxFrameAll));
SessMaxF = squeeze(max(MaxFrameAll));
MaxDelta = SessMaxF - SessMeanF;

%% calculate the ROI display region
nROIs = length(ROIinfoBU.ROIpos);
ROIcenter = round(cell2mat((cellfun(@mean,ROIinfoBU.ROIpos,'uniformOutput',false))'));
FrameSize = size(ROIinfoBU.ROImask{1});
RegionSize = [];
switch FrameSize(1)
    case 256
        RegionSize(1) = 20;
    case 512
        RegionSize(1) = 30;
    otherwise
        CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(1)),'\n'],'s');
        RegionSize(1) = str2num(CusSize);
end
switch FrameSize(2)
    case 256
        RegionSize(2) = 20;
    case 512
        RegionSize(2) = 30;
    otherwise
        CusSize = input([sprintf('cFrame row number is %d, please input the ROI region size.',FrameSize(2)),'\n'],'s');
        RegionSize(2) = str2num(CusSize);
end
%% generate the ROI data for each ROI
% k = 1;
if ~isdir('ROI_morph_plot')
    mkdir('ROI_morph_plot');
end
cd('ROI_morph_plot');
ROIMorphData = cell(nROIs,2);
for cROI = 1 : nROIs
    %
    cROIpos = ROIinfoBU.ROIpos{cROI}; % ROI edge position
    cROICen = ROIcenter(cROI,:);
    %
    xscales = cROICen(1) + ([-1,1]*RegionSize(1));
    ROIedgeShift_x = cROICen(1) - RegionSize(1);
    if xscales(1) < 1
        xscales(1) = 1;
        ROIedgeShift_x = 0;
    elseif xscales(2) > FrameSize(1)
        xscales(2) = FrameSize(1);
%         ROIedgeShift_x = cROICen(1) - RegionSize(1);
    end
    %
    yscales = cROICen(2) + ([-1,1]*RegionSize(2));
    ROIedgeShift_y = cROICen(2) - RegionSize(2);
    if yscales(1) < 1
        yscales(1) = 1;
        ROIedgeShift_y = 0;
    elseif yscales(2) > FrameSize(2)
        yscales(2) = FrameSize(2);
    end
    ROISelectData = MaxDelta(yscales(1):yscales(2),xscales(1):xscales(2));
    ROImaxlim = prctile(ROISelectData(:),90);
    AdjROIpos = cROIpos - repmat([ROIedgeShift_x,ROIedgeShift_y],size(cROIpos,1),1);
    AdjROIcenter = mean(AdjROIpos);
    
%    subplot(4,30,k)
   %
   hf = figure;
   imagesc(ROISelectData,[0 ROImaxlim]);
   line(AdjROIpos(:,1),AdjROIpos(:,2),'Color','r','linewidth',1.6);
   text(AdjROIcenter(1),AdjROIcenter(2),num2str(cROI),'color','g');
   colormap gray;
   axis off
   saveas(hf,sprintf('ROI%d morph plot save',cROI));
   saveas(hf,sprintf('ROI%d morph plot save',cROI),'png');
   close(hf);
   %
%    k = k + 1;
    ROIMorphData{cROI,1} = ROISelectData;
    ROIMorphData{cROI,2} = AdjROIpos;
end
save MorphDataAll.mat ROIMorphData -v7.3
cd ..;

%% merge the ROI morph plot and response plot together
ROImorphPath = uigetdir(pwd,'Please select the ROI morph plot path');
ROIrespPath = uigetdir(pwd,'Please select the ROI response plot path');
MorphFiles = dir([ROImorphPath,'\* morph plot save.png']);
RespFiles = dir([ROIrespPath,'\* all behavType color plot.png']);
if length(MorphFiles) ~= length(RespFiles)
    error('unequal number of ROI plots');
end
%
SavePath = strrep(ROImorphPath,'ROI_morph_plot','ROI_merge_figure');
if ~isdir(SavePath)
    mkdir(SavePath);
end
cd(SavePath);
for cf = 1 : length(MorphFiles)
    %
    morphfn = MorphFiles(cf).name;
    Respfn = RespFiles(cf).name;
    morphfid = imread([ROImorphPath,'\',morphfn]);
    Respfid = imread([ROIrespPath,'\',Respfn]);
    
    hhf = figure('position',[100 120 1700 950]);
    subplot(3,4,1)
    imshow(morphfid);
    axis off
    
    subplot(3,4,[2,3,4,6,7,8,10,11,12])
    imshow(Respfid);
    axis off
    
    ROIstrs = strsplit(morphfn,' ');
    saveas(hhf,sprintf('%s Merged figure save',ROIstrs{1}));
    saveas(hhf,sprintf('%s Merged figure save',ROIstrs{1}),'png');
    close(hhf);
end

