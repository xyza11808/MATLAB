% this script is used for labeling ROI position at the real imaging figure
clear
clc

[fn,fp,fi]= uigetfile('*.mat','Please select the ROI info mat file');
if ~fi
    return;
end
load(fullfile(fp,'SessionFrameProj.mat'));

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
%%
SessMeanF = squeeze(mean(MaxFrameAll));
SessMaxF = squeeze(max(MaxFrameAll));
MaxDelta = SessMaxF - SessMeanF;
hfgray = figure('position',[500 200 1000 850]);
imagesc(MaxDelta,[0 500]);
colormap gray

%%
cd(fp);
fpath = fullfile(fp,fn);
ROIdata = load(fpath);
nROIs = length(ROIdata.ROIinfoBU.ROIpos);
AllROIpos = ROIdata.ROIinfoBU.ROIpos;
for cROI = 1 : nROIs
    cROIpos = AllROIpos{cROI};
    line(cROIpos(:,1),cROIpos(:,2),'color','r','linewidth',1.4);
    CenterPos = mean(cROIpos);
    text(CenterPos(1),CenterPos(2),num2str(cROI),'color','g','FontSize',12);
end
title(sprintf('nROI = %d',nROIs));
% RespROIinds = input('Please select the ROI responsive ROI inds:\n','s');
% REspROIindex = str2num(RespROIinds);
% for cROI = 1 : length(REspROIindex)
%     cROIpos = AllROIpos{REspROIindex(cROI)};
%     line(cROIpos(:,1),cROIpos(:,2),'color','c','linewidth',1.6);
%     CenterPos = mean(cROIpos);
% %     text(CenterPos(1),CenterPos(2),num2str(cROI),'color','c','FontSize',12);
% end
saveas(hfgray,'ROI position labeling plot');
saveas(hfgray,'ROI position labeling plot','png');
% save ROIREspROIinds.mat REspROIindex -v7.3
close(hfgray);