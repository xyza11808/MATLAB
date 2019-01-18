function [AnsPeakV, NMfreqTypes, ChoiceSortAnsData] = AnsResponseSumFun(cSessPath,FRate)
% extract ans wimr response data from given session path

AnsAlignDataPath = fullfile(cSessPath,'AnsTime_Align_plot','AnsAlignData.mat');
AnsAlignDataStrc = load(AnsAlignDataPath);
nROIs = size(AnsAlignDataStrc.AnsAlignData,2);

cAnsFrame = size(AnsAlignDataStrc.AnsAlignData,3);
NMfreqTypes = unique(AnsAlignDataStrc.NMStimFreq);
Numfreq = numel(NMfreqTypes);
ChoiceSortAnsData = zeros(Numfreq,nROIs,cAnsFrame);
for cF = 1 : Numfreq
    
    cffInds = AnsAlignDataStrc.NMStimFreq(:) == NMfreqTypes(cF) & AnsAlignDataStrc.NMOutcome(:) == 1;
    cLeftIndsData = AnsAlignDataStrc.AnsAlignData(cffInds,:,:);
    ChoiceSortAnsData(cF,:,:) = squeeze(mean(cLeftIndsData));
end
% cRIndsData = AnsAlignDataStrc.AnsAlignData(~cLeftInds,:,:);
% ChoiceSortAnsData(2,:,:) = squeeze(mean(cRIndsData));

% end

% AnsWin = [0,1.5];  %s
AnsWin = [0,0.3;0.5,0.8;1,1.3];
nWins = size(AnsWin,1);
AnsFWin = round(AnsWin*FRate);
AnsWinRespALL = cell(nWins,1);
for cAns = 1 : nWins
    cAnsF = AnsFWin(cAns,:);
    if AnsAlignDataStrc.MinAnsF+cAnsF(2) > cAnsFrame
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):end);
%         AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
    else
        AnsWinResp = ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF+cAnsF(1):AnsAlignDataStrc.MinAnsF+cAnsF(2));
%          AnsWinResp = AnsWinResp - repmat(ChoiceSortAnsData(:,:,AnsAlignDataStrc.MinAnsF),1,1,size(AnsWinResp,3));
    end
    AnsWinRespALL{cAns} = AnsWinResp;
end
%%
AnsPeakV = zeros(nWins,nROIs,Numfreq);
for cAnsDelay = 1 : nWins
   cAnsData = AnsWinRespALL{cAnsDelay};
    for cff = 1 : Numfreq
        for cr = 1 : nROIs
            cTrace = squeeze(cAnsData(cff,cr,:));
    %         [~,MaxInds] = max(abs(cTrace));
    %         AnsPeakV(cr,cff) = cTrace(MaxInds);
            AnsPeakV(cAnsDelay,cr,cff) = mean(cTrace);
        end
    end
end
