function ROIFIDatas = NeuFisherInfoCalFun(InputVars,UsedROIInds)
% refed from Yong Gu's paper
% ##############

if ischar(InputVars)
    % input is session path, load data and cakculate fisher information for
    % each neuron
    SessionDataPath = fullfile(InputVars,'CSessionData.mat');
    AlignedDataStrc = load(SessionDataPath,'data_aligned','frame_rate','start_frame','behavResults');
elseif isstruct(InputVars)
    AlignedDataStrc = InputVars;
end

if isempty(UsedROIInds)
    AlignedDatas = AlignedDataStrc.data_aligned;
else
    AlignedDatas = AlignedDataStrc.data_aligned(:,UsedROIInds,:);
end
NumROIs = size(AlignedDatas,2);
RespTimeWin = 1; % seconds
ExcludeTrials = AlignedDataStrc.behavResults.Action_choice == 2;
RespFrameScale = AlignedDataStrc.start_frame + (1:round(RespTimeWin*AlignedDataStrc.frame_rate));
RespValues = squeeze(mean(AlignedDatas(~ExcludeTrials,:,RespFrameScale),3))/100; % not in percent format

UsedTrFreqs = AlignedDataStrc.behavResults.Stim_toneFreq(~ExcludeTrials);
FreqTypes = double(unique(UsedTrFreqs));
NumFreqs = numel(FreqTypes);
FreqTypeDatas = zeros(NumFreqs,NumROIs);
for cf = 1 : NumFreqs
    cfInds = UsedTrFreqs == FreqTypes(cf);
    cf_Resp_Data = RespValues(cfInds,:);
    FreqTypeDatas(cf,:) = mean(cf_Resp_Data);
end

FreqOctaves = log2(FreqTypes/min(FreqTypes));
FreqIntep_octs = FreqOctaves(1) : 0.01 : FreqOctaves(end);
WithExtraXPoints = [FreqIntep_octs(1)-0.01,FreqIntep_octs,FreqIntep_octs(end)+0.01];
%%
WinDataNums = 5;
std = 30;
alphas = (WinDataNums - 1)/(2*std);
SmoothWin = gausswin(WinDataNums,alphas);
SmoothWin = SmoothWin / sum(SmoothWin);
%%
% interpolation
IntepoData = zeros(numel(FreqIntep_octs),NumROIs);
ROIFIDatas = zeros(numel(FreqIntep_octs),NumROIs);
for cROI = 1 : NumROIs
    cROITunDatas = FreqTypeDatas(:,cROI);
    
    TunDataIntep = spline(FreqOctaves,cROITunDatas,WithExtraXPoints);
    
    if sum(TunDataIntep < 0.01)
        TunDataIntep(TunDataIntep < 0.01) = 0.01;
        TunDataIntep = filtfilt(SmoothWin,1,TunDataIntep);
    end
    IntepoData(:,cROI) = TunDataIntep(2:end-1); 
%     IntepDevDatas = zeros(numel(FreqIntep_octs),1);
    DiffDatas = diff(TunDataIntep);
    IntepDevDatas = DiffDatas(1:end-1)/0.01;
    
    % calculate single neuron information under possion distribution
    % assumption, that is variance equals mean
    cRInfos = (IntepDevDatas.^2) ./ TunDataIntep(2:end-1);
    ROIFIDatas(:,cROI) = cRInfos;
end


    