% clear
% clc

% cSessPath = 'S:\BatchData\batch55\20180906\anm07\test06\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change';
% cd(cSessPath);
% GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');

GlmCoefDataPath = fullfile(cSessPath,'SP_RespField_ana','SPDataBehavCoefSaveOff.mat');
try
    GlmCoefDataStrc = load(GlmCoefDataPath);
catch
    GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');
    GlmCoefDataStrc = load(GlmCoefDataPath);
end
    
SoundAlignDataPath = fullfile(cSessPath,'All BehavType Colorplot','PlotRelatedData.mat');
SoundAlignDataStrc = load(SoundAlignDataPath);

AnsAlignDataPath = fullfile(cSessPath,'AnsTime_Align_plot','AnsAlignData.mat');
AnsAlignDataStrc = load(AnsAlignDataPath);

%%

[nROIs,nFreqs,TrOutcomeTypes] = size(SoundAlignDataStrc.ROIMeanTraceData);
CorrROIMeanTrace = squeeze(SoundAlignDataStrc.ROIMeanTraceData(:,:,1));
% extract stim alignment peak value
[OnPeakAll,OffPeakAll] = cellfun(@(x) OnOffPeakValueExtract(x,round(SoundAlignDataStrc.AlignedFrame),SoundAlignDataStrc.Frate),CorrROIMeanTrace);
% % check the STD data also
% try
%     SessTunData = load(fullfile(cSessPath,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','CorrTunningFunSTD');
%     SessTunLowThresInds = (SessTunData.CorrTunningFun <= SessTunData.CorrTunningFunSTD)';
% catch
%     SessTunANDColorPlotFun(cSessPath,[]);
%     SessTunData = load(fullfile(cSessPath,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'CorrTunningFun','CorrTunningFunSTD');
%     SessTunLowThresInds = (SessTunData.CorrTunningFun <= SessTunData.CorrTunningFunSTD)';
% end
% OnPeakAll(SessTunLowThresInds) = 0;
% OffPeakAll(SessTunLowThresInds) = 0;
%% extract answer alignment peak value
cAnsFrame = size(AnsAlignDataStrc.AnsAlignData,3);

NMfreqTypes = unique(AnsAlignDataStrc.NMStimFreq);
Numfreq = numel(NMfreqTypes);
ChoiceSortAnsData = zeros(Numfreq,nROIs,cAnsFrame);
for cf = 1 : Numfreq
    cffInds = AnsAlignDataStrc.NMStimFreq(:) == NMfreqTypes(cf) & AnsAlignDataStrc.NMOutcome(:) == 1;
    cLeftIndsData = AnsAlignDataStrc.AnsAlignData(cffInds,:,:);
    if size(cLeftIndsData,1) == 1
        ChoiceSortAnsData(cf,:,:) = squeeze(cLeftIndsData);
    else
        ChoiceSortAnsData(cf,:,:) = squeeze(mean(cLeftIndsData));
    end
end
% cRIndsData = AnsAlignDataStrc.AnsAlignData(~cLeftInds,:,:);
% ChoiceSortAnsData(2,:,:) = squeeze(mean(cRIndsData));

% end

AnsWin = [0,0.3;0.5,0.8;1,1.3];  %s
nWins = size(AnsWin,1);
AnsFWin = round(AnsWin*SoundAlignDataStrc.Frate);
AnsWinRespALL = cell(nWins,1);
BeforeAnsWin = round(0.2*SoundAlignDataStrc.Frate);
for cAns = 1 : nWins
    cAnsF = AnsFWin(cAns,:);
    if AnsAlignDataStrc.MinAnsF+cAnsF(2) > cAnsFrame
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):end);
        AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF-BeforeAnsWin),1,1,size(AnsWinResp,3));
    else
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):AnsAlignDataStrc.MinAnsF+cAnsF(2));
         AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF-BeforeAnsWin),1,1,size(AnsWinResp,3));
    end
    AnsWinRespALL{cAns} = AnsWinResp;
end
%%
TrTypeInds = NMfreqTypes > min(NMfreqTypes)*2;
AnsPeakFreqV = zeros(nWins,nROIs,Numfreq);
AnsPeakV = zeros(nWins,nROIs,2);
for cAnsDelay = 1 : nWins
    %
   cAnsData = AnsWinRespALL{cAnsDelay};
    for cff = 1 : Numfreq
        for cr = 1 : nROIs
            cTrace = squeeze(cAnsData(cff,cr,:));
    %         [~,MaxInds] = max(abs(cTrace));
    %         AnsPeakV(cr,cff) = cTrace(MaxInds);
            AnsPeakFreqV(cAnsDelay,cr,cff) = mean(cTrace);
        end
    end
    %
    cAnsFreqData = squeeze(AnsPeakFreqV(cAnsDelay,:,:));
    cLAnsChoiceData = mean((cAnsFreqData(:,~TrTypeInds) > 15),2);
    cRAnsChoiceData = mean((cAnsFreqData(:,TrTypeInds) > 15),2);
    AnsPeakV(cAnsDelay,:,:) = [cLAnsChoiceData,cRAnsChoiceData];
end

%% extract Coef information
% since glmnet also can detect the negetive peak of calcium trace, so we
% will excluded those coefficients from detected coefs
ROICoefAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,4));
ROICoefIndsAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,1));

% CoefRespPeakAll = [OnPeakAll,AnsPeakV,OffPeakAll];

RespNegPeakInds = [OnPeakAll < 10,squeeze(AnsPeakV(1,:,:)) < 0.7,OffPeakAll < 10,squeeze(AnsPeakV(2,:,:)) < 0.8,...
    squeeze(AnsPeakV(3,:,:)) < 0.8];
CoefNegInds = ROICoefAll <= 0.4;
% CoefPosInds = ROICoefAll >= 1;
NegPeakInds = RespNegPeakInds | CoefNegInds;
% NegPeakInds(CoefPosInds) = false;
%%
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
if ~isdir('./SP_RespField_ana/')
    mkdir('./SP_RespField_ana/');
end
cd('./SP_RespField_ana/');
save CoefSummarySave.mat ROIRespTypeCoef ROIRespType MaxCoefV -v7.3
cd ..;