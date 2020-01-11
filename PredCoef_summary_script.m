% clear
% clc

% cSessPath = 'S:\BatchData\batch55\20180906\anm07\test06\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change';
% cd(cSessPath);
% GlmCoefDataPath = fullfile(cSessPath,'SPDataBehavCoefSaveOff.mat');

GlmCoefDataPath = fullfile(cSessPath,'SP_RespField_ana','SPDataBehavCoefSaveOff_191228.mat');
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
OnOffRespThres = repmat(GlmCoefDataStrc.ROIstdThres(:),1,size(OnPeakAll,2));
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

AnsWin = [0,1;0.5,1.5;1,2];  %s
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
LeftTypeNum = sum(~TrTypeInds);
RightTypeNum = sum(TrTypeInds);
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
    cLAnsChoiceData = mean((cAnsFreqData(:,~TrTypeInds) > repmat(GlmCoefDataStrc.ROIstdThres(:),1,LeftTypeNum)),2);
    cRAnsChoiceData = mean((cAnsFreqData(:,TrTypeInds) > repmat(GlmCoefDataStrc.ROIstdThres(:),1,RightTypeNum)),2);
    AnsPeakV(cAnsDelay,:,:) = [cLAnsChoiceData,cRAnsChoiceData];
end
FracThres = 2/min(LeftTypeNum,RightTypeNum);
%% extract Coef information
% since glmnet also can detect the negetive peak of calcium trace, so we
% will excluded those coefficients from detected coefs
ROICoefAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,4));
ROICoefIndsAll = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,1));
ROIFracAlls = cell2mat(GlmCoefDataStrc.ROIAboveThresInds(:,3));
ExtraIncludesInds = ROIFracAlls >= 0.6 & ROICoefAll >= 0.2;
ROICoefIndsAll = ROICoefIndsAll | ExtraIncludesInds;
ROIstdThres = GlmCoefDataStrc.ROIstdThres;
% CoefRespPeakAll = [OnPeakAll,AnsPeakV,OffPeakAll];

RespNegPeakInds = [OnPeakAll < OnOffRespThres,squeeze(AnsPeakV(1,:,:)) < FracThres,OffPeakAll < OnOffRespThres,...
    squeeze(AnsPeakV(2,:,:)) < FracThres,...
    squeeze(AnsPeakV(3,:,:)) < FracThres];
CoefNegInds = ROICoefAll < 0;
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
LRIndsThres = ceil(numel(FreqsAll)/2);
for cROI = 1 : nROIs
    %
    cROICoefInds = ROICoefIndsAll(cROI,:);
    cROICoefAll = ROICoefAll(cROI,:);
    if sum(cROICoefInds)
        % left answer
        ROIRespType(cROI,2) = cROICoefInds(LAnsInds);
        if ROIRespType(cROI,2)
           ROIRespTypeCoef{cROI,2} = [1,abs(cROICoefAll(LAnsInds))];
        end
        % right sndwer
        ROIRespType(cROI,3) = cROICoefInds(RAnsInds);
        if ROIRespType(cROI,3)
           ROIRespTypeCoef{cROI,3} = [1,abs(cROICoefAll(RAnsInds))];
        end
        % % % % consider whether the frequency response was caused by
        % answer response
        
        % onset frequency
        MaxCoefV(cROI) = max(cROICoefAll);
        FreqOnTunCoef = cROICoefInds(FreqOnTunInds);
        if sum(FreqOnTunCoef)
           ROIRespType(cROI,1) = 1;
           ccOnCoefAll = cROICoefAll(FreqOnTunInds);
           SigCoefInds = find(FreqOnTunCoef(:));
           SigCoefValues = abs(ccOnCoefAll(FreqOnTunCoef));
           [SigCoefSort,SortInds] = sort(SigCoefValues(:),'descend');
           ROIRespTypeCoef{cROI,1} = [SigCoefInds(SortInds),SigCoefSort];
           
           UsedCoefsIndex = true(numel(SigCoefSort),1);
           if ROIRespType(cROI,2)
%                AllCoef = ROIRespTypeCoef{cROI,1}(:,2);
               if sum(ROIRespTypeCoef{cROI,1}(:,1) <= LRIndsThres)
                   LeftSig_CoefInds = ROIRespTypeCoef{cROI,1}(:,1) <= LRIndsThres;
                   LeftSig_CoefValues = ROIRespTypeCoef{cROI,1}(LeftSig_CoefInds,2);
                   LAnsCoef = ROIRespTypeCoef{cROI,2}(2);
                   L_CoefInds = LeftSig_CoefValues > LAnsCoef/2;
                   UsedCoefsIndex(LeftSig_CoefInds) = L_CoefInds;
               end
           end
           if ROIRespType(cROI,3)
               if sum(ROIRespTypeCoef{cROI,1}(:,1) > LRIndsThres)
                   RightSig_CoefInds = ROIRespTypeCoef{cROI,1}(:,1) > LRIndsThres;
                   RSig_CoefValues = ROIRespTypeCoef{cROI,1}(RightSig_CoefInds,2);
                   RAnsCoefInds = ROIRespTypeCoef{cROI,3}(2);
                   R_CoefInds = RSig_CoefValues > RAnsCoefInds/2;
                   UsedCoefsIndex(RightSig_CoefInds) = R_CoefInds;
               end
           end
           if sum(UsedCoefsIndex) ~= numel(UsedCoefsIndex)
               ccOnsetCoefs = ROIRespTypeCoef{cROI,1};
               ROIRespTypeCoef{cROI,1} = ccOnsetCoefs(UsedCoefsIndex,:);
               if isempty(ROIRespTypeCoef{cROI,1})
                   ROIRespType(cROI,1) = 0;
               end
           end
        end
        
        % offset frequency response
        FreqOffTunCoef = cROICoefInds(FreqOffTunInds);
        if sum(FreqOffTunCoef)
           ROIRespType(cROI,4) = 1;
           SigCoefInds = find(FreqOffTunCoef(:));
           ccOffCoefAll = cROICoefAll(FreqOffTunInds);
           SigCoefValues = abs(ccOffCoefAll(FreqOffTunCoef));
           [SigCoefSort,SortInds] = sort(SigCoefValues(:),'descend');
           ROIRespTypeCoef{cROI,4} = [SigCoefInds(SortInds),SigCoefSort];
           
           % exclude answer caused sound response
           UsedCoefsIndex = true(numel(SigCoefSort),1);
           if ROIRespType(cROI,2)
%                AllCoef = ROIRespTypeCoef{cROI,1}(:,2);
               if sum(ROIRespTypeCoef{cROI,4}(:,1) <= LRIndsThres)
                   LeftSig_CoefInds = ROIRespTypeCoef{cROI,4}(:,1) <= LRIndsThres;
                   LeftSig_CoefValues = ROIRespTypeCoef{cROI,4}(LeftSig_CoefInds,2);
                   LAnsCoef = ROIRespTypeCoef{cROI,2}(2);
                   L_CoefInds = LeftSig_CoefValues > LAnsCoef/2;
                   UsedCoefsIndex(LeftSig_CoefInds) = L_CoefInds;
               end
           end
           if ROIRespType(cROI,3)
               if sum(ROIRespTypeCoef{cROI,4}(:,1) > LRIndsThres)
                   RightSig_CoefInds = ROIRespTypeCoef{cROI,4}(:,1) > LRIndsThres;
                   RSig_CoefValues = ROIRespTypeCoef{cROI,4}(RightSig_CoefInds,2);
                   RAnsCoefInds = ROIRespTypeCoef{cROI,3}(2);
                   R_CoefInds = RSig_CoefValues > RAnsCoefInds/2;
                   UsedCoefsIndex(RightSig_CoefInds) = R_CoefInds;
               end
           end
           if sum(UsedCoefsIndex) ~= numel(UsedCoefsIndex)
               ccOnsetCoefs = ROIRespTypeCoef{cROI,4};
               ROIRespTypeCoef{cROI,4} = ccOnsetCoefs(UsedCoefsIndex,:);
               if isempty(ROIRespTypeCoef{cROI,4})
                   ROIRespType(cROI,4) = 0;
               end
           end
           
        end
        % Left answer delay response 
        LAnsDelayIndex = cROICoefInds(LAnsDelayInds);
        if sum(LAnsDelayIndex)
            ROIRespType(cROI,5) = 1;
            cIndsCoef = cROICoefAll(LAnsDelayInds);
            [SortCoefs,SortInds] = sort(cIndsCoef(:),'descend');
            MergeMtx = [SortInds,SortCoefs];
            MergeMtx(SortCoefs == 0,:) = [];
            ROIRespTypeCoef{cROI,5} = MergeMtx;
        end
        % Right answer delay response 
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