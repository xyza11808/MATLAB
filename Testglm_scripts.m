% scripts for testing linear fitting model
[nTrs,nROIs,nFrames] = size(data_aligned);
RespWin = [0.2,0.7];
FreqAll = double(behavResults.Stim_toneFreq);
ChiceAll = double(behavResults.Action_choice);
TrTypes = double(behavResults.Trial_Type);
MissTr = ChiceAll == 2;
RewardTAll = double(behavResults.Time_reward);
FreqTypes = unique(FreqAll);
nFres = length(FreqTypes);

% using Non-miss trials for analysis
NMData = data_aligned(~MissTr,:,:);
NMspData = nnspike(~MissTr,:,:);
NMfreqs = FreqAll(~MissTr);
NMChoice = ChiceAll(~MissTr);
NMReward = RewardTAll(~MissTr);
NMTypes = TrTypes(~MissTr);
NMTrs = size(NMData,1);
FreqTypeMask = repmat(FreqTypes,NMTrs,1);
TrFreqMask = repmat(NMfreqs(:),1,nFres);

FreqParaInds = double(TrFreqMask == FreqTypeMask);
RewardPara = double(NMReward(:) > 0);
ChoicePara = NMChoice(:);
InputPara = [FreqParaInds,ChoicePara,NMTypes(:),RewardPara];

FreqStrs = cellstr(num2str(FreqTypes(:)/100,'F%.f'));
ParaStrs = {FreqStrs{:},'Choice','TrType','Reward','Resp'};
%% calculathe response value using given time window
RespFrame = round(RespWin*frame_rate);
RespData = mean(NMData(:,:,(start_frame+RespFrame(1)):(start_frame+RespFrame(2))),3);
SPRespData = mean(NMspData(:,:,(start_frame+RespFrame(1)):(start_frame+RespFrame(2))),3);
ZSrespData = zscore(RespData);
RawRespData = RespData/100; % not in percent type data
%%
% UnitSPData = zeros(size(NMspData));
% ROIthresAll = zeros(nROIs,1);
% for cROI = 1 : nROIs
%     cROIdata = squeeze(NMspData(:,cROI,:));
%     RespStd = mad(reshape(cROIdata',[],1),1)*1.4826;
%     ROIthresAll(cROI) = RespStd;
%     UnitData = double(cROIdata > 10);
%     UnitSPData(:,cROI,:) = UnitData;
% end
% UnitRespData = sum(UnitSPData(:,:,(start_frame+RespFrame(1)):(start_frame+RespFrame(2))),3);
UnitRespData = SPRespData > 10;
%% calculate the linear regression data
mdlResp = fitglm(InputPara,SPRespData(:,4),'linear','Distribution','normal','VarNames',ParaStrs);
UnitRespmdl = fitglm(InputPara,UnitRespData(:,4),'linear','Distribution','Binomial','VarNames',ParaStrs);
