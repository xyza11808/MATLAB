function [f_raw,ExcludeInds] = get_rawF_roi(CaTrials)
% roiNo = 15;
nROIs = CaTrials(1).nROIs;
nTrials = length(CaTrials);
nFrames = CaTrials(1).nFrames;

SessionDataSum = zeros(nTrials,nROIs,nFrames);
ExcludeInds = [];
for TriNo = 1 : nTrials
    TempTrialData = CaTrials(TriNo).f_raw;
    if size(TempTrialData,2) ~=  nFrames
        ExcludeInds = [ExcludeInds TriNo];
        TempTrialData = NaN;
    end
    SessionDataSum(TriNo,:,:) = TempTrialData;
end

if ~isempty(ExcludeInds)
    SessionDataSum(ExcludeInds,:,:)=[];
end

f_raw = cell(1,nTrials);
for roiNo = 1:nROIs
    f_raw{roiNo} = squeeze(SessionDataSum(:,roiNo,:));
end

