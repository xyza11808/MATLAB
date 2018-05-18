% this script is used for labeling ROI position at the real imaging figure
% clear
% clc
cPath = pwd;
cd(SessPath);
% [fn,fp,fi]= uigetfile('*.mat','Please select the ROI info mat file');
% if ~fi
%     return;
% end
load(fullfile(SessPath,'SessionFrameProj.mat'));
IsROIStatePlot = 0;
if isfield(CaTrials,'ROIstateIndic')
    ROIstate = CaTrials.ROIstateIndic;
    IsROIStatePlot = 1;
    ROIstateColorStr = {'r','g','m'};
end
if ~isempty(TrExcludedInds)
    UsedFrameProj = FrameProjSave(TrExcludedInds);
else
    UsedFrameProj = FrameProjSave;
end
    
nTrs = length(UsedFrameProj);
FrameSize = size(UsedFrameProj(1).MeanFrame);
MeanFrameAll = zeros([nTrs,FrameSize]);
MaxFrameAll = zeros([nTrs,FrameSize]);
for nntr = 1 : nTrs
    cMeanFrame = double(UsedFrameProj(nntr).MeanFrame);
    cMaxFrame = double(UsedFrameProj(nntr).MaxFrame);
    MeanFrameAll(nntr,:,:) = cMeanFrame;
    MaxFrameAll(nntr,:,:) = cMaxFrame;
end
%%
SessMeanF = squeeze(mean(MaxFrameAll));
SessMaxF = squeeze(max(MaxFrameAll));
MaxDelta = SessMaxF - SessMeanF;
hfgray = figure('position',[50 200 800 680]);
imagesc(MaxDelta,[0 500]);
colormap gray

%%
% cd(fp);
% fpath = fullfile(fp,fn);
% ROIdata = load(fpath);
% nROIs = length(ROIinfo(1).ROIpos);
% AllROIpos = ROIinfo(1).ROIpos;
%%
UsedROIs = 1:length(ROIinfo(1).ROIpos);
nROIs = length(UsedROIs);
AllROIpos = ROIinfo(1).ROIpos(UsedROIs);
for cROI = 1 : nROIs
    cROIpos = AllROIpos{cROI};
    if IsROIStatePlot
        cROIstate = ROIstate(cROI,:);
        line(cROIpos(:,1),cROIpos(:,2),'color',ROIstateColorStr{logical(cROIstate)},'linewidth',1.4);
    else
        line(cROIpos(:,1),cROIpos(:,2),'color','r','linewidth',1.4);
    end
    CenterPos = mean(cROIpos);
    text(CenterPos(1),CenterPos(2),num2str(UsedROIs(cROI)),'color','g','FontSize',12);
end
%% RespROIinds = input('Please select the ROI responsive ROI inds:\n','s');
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
cd(cPath);
