StimRespData = squeeze(mean(data_aligned(:,:,(start_frame+round(frame_rate*0.2)):(start_frame+round(frame_rate*0.7))),3));
% StimRespData = squeeze(mean(nnspike(:,:,start_frame:(start_frame+round(frame_rate*0.5))),3));
% figure;
TrFreqs = double(behavResults.Stim_toneFreq);
[~,FreqInds] = sort(TrFreqs);
% imagesc(StimRespData(FreqInds,:),[0 10]);

%%
FreqTypes = unique(TrFreqs);
FreqTypeMeanResp = zeros(length(FreqTypes),size(StimRespData,2));
for nFreqs = 1 : length(FreqTypes)
    cFreqInds = TrFreqs == FreqTypes(nFreqs);
    cFreqResp = StimRespData(cFreqInds,:);
    FreqTypeMeanResp(nFreqs,:) = mean(cFreqResp);
end
% figure;
% imagesc(FreqTypeMeanResp,[0 10]);
%
MeanAllResp = repmat(mean(FreqTypeMeanResp),length(FreqTypes),1);
MeanAllResp(MeanAllResp == 0) = 1;
NorFreqResp = FreqTypeMeanResp;%(FreqTypeMeanResp./MeanAllResp);
% figure;
% imagesc(NorFreqResp,[0 2])
nROIs = size(NorFreqResp,2);

% %%
% % calculate the BCD and WCD
% GrNum = size(NorFreqResp,1)/2;
% GrNorRespData = zeros(2,GrNum,size(NorFreqResp,2));
% GrNorRespData(1,:,:) = NorFreqResp(1:GrNum,:);
% GrNorRespData(2,:,:) = NorFreqResp((GrNum+1):end,:); 
% ROI_CI_sum = zeros(nROIs,1);
% for cROI = 1 : nROIs
%     %
%     LeftGrData = squeeze(GrNorRespData(1,:,cROI));
%     RightGrData = squeeze(GrNorRespData(2,:,cROI));
%     LeftGeMtx = repmat(LeftGrData,GrNum,1);
%     RightGeMtx = repmat(RightGrData',1,GrNum);
%     LRGrDiff = abs(LeftGeMtx - RightGeMtx);
%     LeftGrDiff = repmat(LeftGrData,GrNum,1) - repmat(LeftGrData',1,GrNum);
%     LeftGrDiffVec = abs(LeftGrDiff(logical(triu(ones(size(LeftGrDiff)),1))));
%     RightGrDiff = repmat(RightGrData,GrNum,1) - repmat(RightGrData',1,GrNum);
%     RightGrDiffVec = abs(RightGrDiff(logical(triu(ones(size(RightGrDiff)),1))));
%     
%     cROIBCD = mean(LRGrDiff(:));
%     cROIWCD = mean([LeftGrDiffVec;RightGrDiffVec]);
%     cROI_CI = (cROIBCD - cROIWCD)/(cROIBCD + cROIWCD);
%     ROI_CI_sum(cROI) = cROI_CI;
% end
% figure;
% plot(sort(ROI_CI_sum),'ro')

%% calculate the difference belongs to same stim-diff
GrNum = size(NorFreqResp,1)/2;
if mod(size(NorFreqResp,1),2)
    NorFreqResp(ceil(GrNum),:) = [];
    GrNum = floor(GrNum);
end
GrNorRespData = zeros(2,GrNum,size(NorFreqResp,2));
GrNorRespData(1,:,:) = NorFreqResp(1:GrNum,:);
GrNorRespData(2,:,:) = NorFreqResp((GrNum+1):end,:);
ROI_CI_sum = zeros(nROIs,1);
ROI_CD_All = zeros(nROIs,2);
for cROI = 1 : nROIs
    %
    LeftGrData = squeeze(GrNorRespData(1,:,cROI));
    RightGrData = squeeze(GrNorRespData(2,:,cROI));
    LeftGeMtx = repmat(LeftGrData,GrNum,1);
    LeftGeMtxInds = repmat(1:GrNum,GrNum,1);
    RightGeMtx = repmat(RightGrData',1,GrNum);
    RightGeMtxInds = repmat((1:GrNum)'+GrNum,1,GrNum);
    LRGrDiff = abs(LeftGeMtx - RightGeMtx);
    LRGrDiffInds = abs(LeftGeMtxInds - RightGeMtxInds);
    
    LeftGrDiff = abs(repmat(LeftGrData,GrNum,1) - repmat(LeftGrData',1,GrNum));
    LeftGrDiffInds = repmat(1:GrNum,GrNum,1) - repmat((1:GrNum)',1,GrNum);
%     LeftGrDiffVec = abs(LeftGrDiff(logical(triu(ones(size(LeftGrDiff)),1))));
    RightGrDiff = abs(repmat(RightGrData,GrNum,1) - repmat(RightGrData',1,GrNum));
    RightGrDiffInds = LeftGrDiffInds;
%     RightGrDiffVec = abs(RightGrDiff(logical(triu(ones(size(RightGrDiff)),1))));
    %
    ConsdMaxStimDiff = GrNum - 1;
    DisDiffVData = zeros(ConsdMaxStimDiff,2);
    % calculate WCD
    for cStimDiff = 1 : ConsdMaxStimDiff
        cDisDiffVBet = mean(LRGrDiff(LRGrDiffInds == cStimDiff));
        cDisDiffVWin = mean([LeftGrDiff(LeftGrDiffInds == cStimDiff);RightGrDiff(LeftGrDiffInds == cStimDiff)]);
        DisDiffVData(cStimDiff,:) = [cDisDiffVBet,cDisDiffVWin];
    end
    %
    cROICD = mean(DisDiffVData);
    ROI_CD_All(cROI,:) = cROICD;
    cROI_CI = (-1)*diff(cROICD)/sum(cROICD);
    ROI_CI_sum(cROI) = cROI_CI;
end
%%
hhf = figure;
hold on
% SelectInds = ROI_CD_All(:,1) > 10 | ROI_CD_All(:,2) > 10;
scatter(ROI_CD_All(:,1),ROI_CD_All(:,2),'ro');
[~,p] = ttest(ROI_CD_All(:,1),ROI_CD_All(:,2));
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
maxscale = max([xscales(2),yscales(2)]);
line([0 maxscale],[0 maxscale],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
text(ROI_CD_All(:,1),ROI_CD_All(:,2),cellstr(num2str((1:nROIs)')));
title(sprintf('p = %.2e',p));
set(gca,'FontSize',18)
xlabel('BCD');
ylabel('WCD');
% scatter(ROI_CD_All(TunROIInds,1),ROI_CD_All(TunROIInds,2),50,'b*','linewidth',1.5)
% scatter(ROI_CD_All(CategROiinds,1),ROI_CD_All(CategROiinds,2),50,'k*','linewidth',1.5)
%%
if ~isdir('./Fluo_cd_data/')
    mkdir('./Fluo_cd_data/');
end
cd('./Fluo_cd_data/');

save RespCDSave.mat ROI_CD_All ROI_CI_sum -v7.3
saveas(hhf,'CD scatter plot save All');
saveas(hhf,'CD scatter plot save All','pdf');
saveas(hhf,'CD scatter plot save All','png');
close(hhf);
%%
% % calculate the BCD and WCD
% GrNum = size(NorFreqResp,1)/2;
% GrNorRespData = zeros(2,GrNum,size(NorFreqResp,2));
% GrNorRespData(1,:,:) = NorFreqResp(1:GrNum,:);
% GrNorRespData(2,:,:) = NorFreqResp((GrNum+1):end,:); 
% ROI_CI_sum = zeros(nROIs,1);
% ROIDratio = zeros(nROIs,1);
% CDvalues = zeros(nROIs,2);
% %
% for cROI = 1 : nROIs
%     %
%     LeftGrData = squeeze(GrNorRespData(1,:,cROI));
%     RightGrData = squeeze(GrNorRespData(2,:,cROI));
% %     LeftGeMtx = repmat(LeftGrData,GrNum,1);
% %     RightGeMtx = repmat(RightGrData',1,GrNum);
%     LRGrDiff = abs(fliplr(RightGrData) - LeftGrData);
%     LeftGrDiff = repmat(LeftGrData,GrNum,1) - repmat(LeftGrData',1,GrNum);
%     LeftGrDiffVec = abs(LeftGrDiff(logical(triu(ones(size(LeftGrDiff)),1))));
%     RightGrDiff = repmat(RightGrData,GrNum,1) - repmat(RightGrData',1,GrNum);
%     RightGrDiffVec = abs(RightGrDiff(logical(triu(ones(size(RightGrDiff)),1))));
%     
%     cROIBCD = mean(LRGrDiff);
%     cROIWCD = mean([LeftGrDiffVec;RightGrDiffVec]);
%     cROI_CI = (cROIBCD - cROIWCD)/(cROIBCD + cROIWCD);
%     ROIDratio(cROI) = cROIBCD/cROIWCD;
%     ROI_CI_sum(cROI) = cROI_CI;
%     CDvalues(cROI,:) = [cROIBCD,cROIWCD];
% end
% figure;
% subplot(1,2,1)
% plot(sort(ROI_CI_sum),'ro')
% subplot(1,2,2)
% hist(ROIDratio,20)
% title(sprintf('Mean Ratio = %.2f',mean(ROIDratio)));
% 
% figure;
% scatter(CDvalues(:,1),CDvalues(:,2),'ro')
% line([0 max(CDvalues(:))],[0 max(CDvalues(:))],'Color',[.7 .7 .7],'linestyle','--','linewidth',1.6)
% text(CDvalues(:,1),CDvalues(:,2),cellstr(num2str((1:nROIs)')));

% %%
% clear
% clc
% 
% [fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
% if ~fi
%     return;
% end
% fpath = fullfile(fp,fn);
% fid = fopen(fpath);
% tline = fgetl(fid);
% while ischar(tline)
%     if isempty(strfind(tline,'\mode_f_change'))
%         tline = fgetl(fid);
%         continue;
%     end
%     if ~isempty(strfind(tline,'All BehavType Colorplot'))
%         SessPath = strrep(tline,'\All BehavType Colorplot','\');
%     else
%         SessPath = tline;
%     end
%     clearvars data_aligned ROI_CD_All ROI_CI_sum 
%     load(fullfile(SessPath,'CSessionData.mat'));
%     cd(SessPath);
%     
%     Resp_CI_script;
%     tline = fgetl(fid);
% end
% %%%%%############################################################################################################
% Example Tuning position data saved at E:\DataToGo\data_for_xu\AllTrialPlot_save\TunPosWCDBCDV
% 
% %% Tuning position affects CD value
%     Tun32KResp = sROIMeanResp; % raw tunning at 32K position
%     Tun24KResp = [sROIMeanResp(1:4),sROIMeanResp(end),sROIMeanResp(end-1)];
%     Tun18KResp = [sROIMeanResp(1:3),sROIMeanResp(end:-1:end-2)];
%     Tun8KResp = fliplr(sROIMeanResp);
%     Tun10KResp = fliplr(Tun24KResp);
%     Tun14KResp = fliplr(Tun18KResp);
%     NewTun18KResp = [Tun14KResp(1),Tun14KResp(4),Tun14KResp(3),Tun14KResp(2),Tun14KResp(end-1:end)];
% %     LeftGrData = squeeze(GrNorRespData(1,:,cROI));
% %     RightGrData = squeeze(GrNorRespData(2,:,cROI));
%     GrNum = 3;
%     TunRespData = NewTun18KResp;
%     
%     LeftGrData = TunRespData(1:GrNum);
%     RightGrData = TunRespData(GrNum+1:end);
%     LeftGeMtx = repmat(LeftGrData,GrNum,1);
%     LeftGeMtxInds = repmat(1:GrNum,GrNum,1);
%     RightGeMtx = repmat(RightGrData',1,GrNum);
%     RightGeMtxInds = repmat((1:GrNum)'+GrNum,1,GrNum);
%     LRGrDiff = abs(LeftGeMtx - RightGeMtx);
%     LRGrDiffInds = abs(LeftGeMtxInds - RightGeMtxInds);
%     
%     LeftGrDiff = abs(repmat(LeftGrData,GrNum,1) - repmat(LeftGrData',1,GrNum));
%     LeftGrDiffInds = repmat(1:GrNum,GrNum,1) - repmat((1:GrNum)',1,GrNum);
% %     LeftGrDiffVec = abs(LeftGrDiff(logical(triu(ones(size(LeftGrDiff)),1))));
%     RightGrDiff = abs(repmat(RightGrData,GrNum,1) - repmat(RightGrData',1,GrNum));
%     RightGrDiffInds = LeftGrDiffInds;
% %     RightGrDiffVec = abs(RightGrDiff(logical(triu(ones(size(RightGrDiff)),1))));
%     %
%     ConsdMaxStimDiff = GrNum - 1;
%     DisDiffVData = zeros(ConsdMaxStimDiff,2);
%     % calculate WCD
%     for cStimDiff = 1 : ConsdMaxStimDiff
%         cDisDiffVBet = mean(LRGrDiff(LRGrDiffInds == cStimDiff));
%         cDisDiffVWin = mean([LeftGrDiff(LeftGrDiffInds == cStimDiff);RightGrDiff(LeftGrDiffInds == cStimDiff)]);
%         DisDiffVData(cStimDiff,:) = [cDisDiffVBet,cDisDiffVWin];
%     end
%     %
%     cROICD = mean(DisDiffVData);
%     figure;
%     plot(TunRespData,'r-o');
%     title({'New18kHz Tun Resp',sprintf('BCD = %.3f, WCD = %.3f',cROICD(1),cROICD(2))});
%     ylabel('\DeltaF/F_0 (%)');
%     xlabel('Octaves');
%     set(gca,'FontSize',18);
%     