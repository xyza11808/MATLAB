nROINum = size(smooth_data,2);
BehavTones = double(behavResults.Stim_toneFreq);
BehavChoice = double(behavResults.Action_choice);
BehavTypes = double(behavResults.Trial_Type);
NMTrInds = BehavChoice(:) ~= 2 & BehavChoice(:) == BehavTypes(:);
NMStimTones = BehavTones(NMTrInds);
NMTrChoice = BehavChoice(NMTrInds);
NMTrTypes = BehavTypes(NMTrInds);
% cROINMdata = cROIdata(NMTrInds,:);
FrameScales = [start_frame+1,start_frame+frame_rate]; % 1s after stimulus onset
ROIsigResp = zeros(nROINum,1);
ROIRespThres = cell(nROINum,1);
ROIRealResp = cell(nROINum,1);
ROImaxTrsRespFrac = cell(nROINum,1);
for cROI = 1 : nROINum
    cROIdata = squeeze(smooth_data(:,cROI,:));
    cROINMdata = cROIdata(NMTrInds,:);
    %
    [nTrials, nFrames] = size(cROINMdata);
    FreqTypes = unique(NMStimTones);
    nFreqs = length(FreqTypes);
    ROIsessTrace = reshape(cROINMdata',[],1);
    nIters = 1000;
    ShufRespVactor = cell(nIters,1);
    parfor cIter = 1 : nIters
        cShufTrace = Vshuffle(ROIsessTrace);
        ShufRespMtx = (reshape(cShufTrace,nFrames,nTrials))';

        cFreqResp = zeros(nFreqs,1);
        for cFreq = 1 : nFreqs
            cFreqInds = NMStimTones == FreqTypes(cFreq);
            cFreqMean = mean(ShufRespMtx(cFreqInds,:));
            RespData = max(cFreqMean(FrameScales(1):FrameScales(2)));
            cFreqResp(cFreq) = RespData;
        end
        ShufRespVactor{cIter} = cFreqResp;
    end
    %
    cFreqRealResp = zeros(nFreqs,1);
    for cFreq = 1 : nFreqs
        cFreqInds = NMStimTones == FreqTypes(cFreq);
        cFreqMeanTrace = mean(cROINMdata(cFreqInds,:));
        cFreqRealResp(cFreq) = max(cFreqMeanTrace(FrameScales(1):FrameScales(2)));
    end
    [cFreqmaxValue, cFreqmaxInds] = max(cFreqRealResp);
    ShufRespMtx = (cell2mat(ShufRespVactor'))';
    MaxIndsShufThre = prctile(ShufRespMtx,95);
    if cFreqmaxValue < MaxIndsShufThre(cFreqmaxInds)
        IsROIsigResp = 0;
    else
        IsROIsigResp = 1;
    end
    ROIRespThres{cROI} = MaxIndsShufThre;
    ROIsigResp(cROI) = IsROIsigResp;
    ROIRealResp{cROI} = cFreqRealResp;
    
    MaxIndsFreq = FreqTypes(cFreqmaxInds);
    MaxFreqTrData = cROINMdata(NMStimTones == MaxIndsFreq,:);
    MaxFreqTrRespData = max(MaxFreqTrData(:,FrameScales(1):FrameScales(2)),[],2);
    TrAboveThrestrs = MaxFreqTrRespData > MaxIndsShufThre(cFreqmaxInds);
    ROImaxTrsRespFrac{cROI} = TrAboveThrestrs;
end
save ROISigResponseSave.mat ROIRespThres ROIsigResp ROIRealResp ROImaxTrsRespFrac -v7.3
