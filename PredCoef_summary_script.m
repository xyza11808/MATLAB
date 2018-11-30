% clear
% clc

% cSessPath = 'S:\BatchData\batch55\20180906\anm07\test06\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change';
% cd(cSessPath);
% GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');
GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOffFlick.mat');
GlmCoefDataStrc = load(GlmCoefDataPath);

SoundAlignDataPath = fullfile(cSessPath,'All BehavType Colorplot','PlotRelatedData.mat');
SoundAlignDataStrc = load(SoundAlignDataPath);

AnsAlignDataPath = fullfile(cSessPath,'AnsTime_Align_plot','AnsAlignData.mat');
AnsAlignDataStrc = load(AnsAlignDataPath);

%%

[nROIs,nFreqs,TrOutcomeTypes] = size(SoundAlignDataStrc.ROIMeanTraceData);
CorrROIMeanTrace = squeeze(SoundAlignDataStrc.ROIMeanTraceData(:,:,1));
% extract stim alignment peak value
[OnPeakAll,OffPeakAll] = cellfun(@(x) OnOffPeakValueExtract(x,round(SoundAlignDataStrc.AlignedFrame),SoundAlignDataStrc.Frate),CorrROIMeanTrace);

%% extract answer alignment peak value
cAnsFrame = size(AnsAlignDataStrc.AnsAlignData,3);
ChoiceSortAnsData = zeros(2,nROIs,cAnsFrame);
NMfreqTypes = unique(AnsAlignDataStrc.NMStimFreq);
% for cf = 1 : nFreqs
cLeftInds = AnsAlignDataStrc.NMChoice == 0;
cLeftIndsData = AnsAlignDataStrc.AnsAlignData(cLeftInds,:,:);
ChoiceSortAnsData(1,:,:) = squeeze(mean(cLeftIndsData));

cRIndsData = AnsAlignDataStrc.AnsAlignData(~cLeftInds,:,:);
ChoiceSortAnsData(2,:,:) = squeeze(mean(cRIndsData));

% end

AnsWin = [0,1];  %s
AnsFWin = round(AnsWin*SoundAlignDataStrc.Frate);
if AnsAlignDataStrc.MinAnsF+AnsFWin(2) > cAnsFrame
    AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+AnsFWin(1):end);
    AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
else
    AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+AnsFWin(1):AnsAlignDataStrc.MinAnsF+AnsFWin(2));
     AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
end

%%
AnsPeakV = zeros(nROIs,2);
for cff = 1 : 2
    for cr = 1 : nROIs
        cTrace = squeeze(AnsWinResp(cff,cr,:));
%         [~,MaxInds] = max(abs(cTrace));
%         AnsPeakV(cr,cff) = cTrace(MaxInds);
        AnsPeakV(cr,cff) = mean(cTrace);
    end
end

%% extract Coef information
% since glmnet also can detect the negetive peak of calcium trace, so we
% will excluded those coefficients from detected coefs
ROICoefAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,4));
ROICoefIndsAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,1));

% CoefRespPeakAll = [OnPeakAll,AnsPeakV,OffPeakAll];

NegPeakInds = [OnPeakAll < 10,AnsPeakV < 10,OffPeakAll < 10];

ROICoefAll(NegPeakInds) = 0;
ROICoefIndsAll(NegPeakInds) = 0;

SigRespInds = false(nFreqs*2+2,1);

FreqOnTunInds = SigRespInds;
FreqOnTunInds(1:nFreqs) = true;
FreqOffTunInds = SigRespInds;
FreqOffTunInds(end-nFreqs+1:end) = true;

LAnsInds = SigRespInds;
LAnsInds(nFreqs+1) = true;
RAnsInds = SigRespInds;
RAnsInds(nFreqs+2) = true;
%%
ROIRespType = zeros(nROIs,4); % each column indicates whether ROI significantly response to 
                              % Stim_on, LeftAns, RightAns,and Stim_off
ROIRespTypeCoef = cell(nROIs,4); % store the tuning freq/freqs index 
FreqsAll = NMfreqTypes; % all frequency types
for cROI = 1 : nROIs
    cROICoefInds = ROICoefIndsAll(cROI,:);
    cROICoefAll = ROICoefAll(cROI,:);
    if sum(cROICoefInds)
        FreqOnTunCoef = cROICoefInds(FreqOnTunInds);
        if sum(FreqOnTunCoef)
           ROIRespType(cROI,1) = 1;
           ccOnCoefAll = cROICoefAll(FreqOnTunInds);
           SigCoefInds = find(FreqOnTunCoef(:));
           SigCoefValues = abs(ccOnCoefAll(FreqOnTunCoef));
           [SigCoefSort,SortInds] = sort(SigCoefValues(:),'descend');
           ROIRespTypeCoef{cROI,1} = [SigCoefInds(SortInds),SigCoefSort];
        end
        
        ROIRespType(cROI,2) = cROICoefInds(LAnsInds);
        if ROIRespType(cROI,2)
           ROIRespTypeCoef{cROI,2} = [1,abs(cROICoefAll(LAnsInds))];
        end

        ROIRespType(cROI,3) = cROICoefInds(RAnsInds);
        if ROIRespType(cROI,3)
           ROIRespTypeCoef{cROI,3} = [1,abs(cROICoefAll(RAnsInds))];
        end
        
        FreqOffTunCoef = cROICoefInds(FreqOffTunInds);
        if sum(FreqOffTunCoef)
           ROIRespType(cROI,4) = 1;
           SigCoefInds = find(FreqOffTunCoef(:));
           ccOffCoefAll = cROICoefAll(FreqOffTunInds);
           SigCoefValues = abs(ccOffCoefAll(FreqOffTunCoef));
           [SigCoefSort,SortInds] = sort(SigCoefValues(:),'descend');
           ROIRespTypeCoef{cROI,4} = [SigCoefInds(SortInds),SigCoefSort];
        end
    end
end 
%%
save CoefSummarySave.mat ROIRespTypeCoef ROIRespType -v7.3
