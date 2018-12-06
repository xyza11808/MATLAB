% clear
% clc

% cSessPath = 'S:\BatchData\batch55\20180906\anm07\test06\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change';
% cd(cSessPath);
% GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');
GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');
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

AnsWin = [0,0.3;0.5,0.8;1,1.3];  %s
AnsFWin = round(AnsWin*SoundAlignDataStrc.Frate);
AnsWinRespALL = cell(3,1);
for cAns = 1 : 3
    cAnsF = AnsFWin(cAns,:);
    if AnsAlignDataStrc.MinAnsF+AnsFWin(2) > cAnsFrame
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):end);
        AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
    else
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):AnsAlignDataStrc.MinAnsF+cAnsF(2));
         AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
    end
    AnsWinRespALL{cAns} = AnsWinResp;
end
%%
AnsPeakV = zeros(3,nROIs,2);
for cAnsDelay = 1 : 3
   cAnsData = AnsWinRespALL{cAnsDelay};
    for cff = 1 : 2
        for cr = 1 : nROIs
            cTrace = squeeze(cAnsData(cff,cr,:));
    %         [~,MaxInds] = max(abs(cTrace));
    %         AnsPeakV(cr,cff) = cTrace(MaxInds);
            AnsPeakV(cAnsDelay,cr,cff) = mean(cTrace);
        end
    end
end
%% extract Coef information
% since glmnet also can detect the negetive peak of calcium trace, so we
% will excluded those coefficients from detected coefs
ROICoefAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,4));
ROICoefIndsAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,1));

% CoefRespPeakAll = [OnPeakAll,AnsPeakV,OffPeakAll];

NegPeakInds = [OnPeakAll,squeeze(AnsPeakV(1,:,:)),OffPeakAll,squeeze(AnsPeakV(2,:,:)),squeeze(AnsPeakV(3,:,:))] < 10;

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
LAnsDelayInds = SigRespInds;
LAnsDelayInds(nFreqs*2+2+[1,3]) = true;
RAnsDelayInds = SigRespInds;
RAnsDelayInds(nFreqs*2+2+[2,4]) = true;

%%
ROIRespType = zeros(nROIs,6); % each column indicates whether ROI significantly response to 
                              % Stim_on, LeftAns, RightAns,Stim_off,
                              % LeftAns Delay and RightAns delay
ROIRespTypeCoef = cell(nROIs,6); % store the tuning freq/freqs index 
MaxCoefV = zeros(nROIs,1);
FreqsAll = NMfreqTypes; % all frequency types
for cROI = 1 : nROIs
    %
    cROICoefInds = ROICoefIndsAll(cROI,:);
    cROICoefAll = ROICoefAll(cROI,:);
    if sum(cROICoefInds)
        MaxCoefV(cROI) = max(cROICoefAll);
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
        
        LAnsDelayIndex = cROICoefInds(LAnsDelayInds);
        if sum(LAnsDelayIndex)
            ROIRespType(cROI,5) = 1;
            cIndsCoef = cROICoefAll(LAnsDelayInds);
            [SortCoefs,SortInds] = sort(cIndsCoef(:),'descend');
            MergeMtx = [SortInds,SortCoefs];
            MergeMtx(SortCoefs == 0,:) = [];
            ROIRespTypeCoef{cROI,5} = MergeMtx;
        end
        
        RAnsDelayIndex = cROICoefInds(RAnsDelayInds);
        if sum(RAnsDelayIndex)
            ROIRespType(cROI,6) = 1;
            cIndsCoefR = cROICoefAll(RAnsDelayInds);
            [SortCoefsR,SortIndsR] = sort(cIndsCoefR(:),'descend');
            MergeMtxR = [SortIndsR,SortCoefsR];
            MergeMtxR(SortCoefsR == 0,:) = [];
            ROIRespTypeCoef{cROI,6} = MergeMtxR;
        end
    end
end 
%%
save CoefSummarySave.mat ROIRespTypeCoef ROIRespType MaxCoefV -v7.3
