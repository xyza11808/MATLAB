TrFreqAll = double(behavResults.Stim_toneFreq);
FreqTypes = unique(TrFreqAll);
ShuffleFrac = 0.8;
RespWin = 1;
[nTrs,nROIs,nFrames] = size(data_aligned);
DefaultTrInds = 1:nTrs;

nIters = 500;
SampleROINum = round(ShuffleFrac*nROIs);
IterROIIndex = cell(SampleROINum,1);
IterShufROITrIndex = cell(SampleROINum,1);
PopuNCAll = cell(nIters,1);
PopuNCMean = zeros(nIters,1);
MeanTestLoss = zeros(nIters,1);
for niter = 1 : nIters
    cShufROIs = randsample(nROIs,SampleROINum);
    IterROIIndex{niter} = cShufROIs;
    cROIsTrs = zeros(SampleROINum,nTrs);
    cROIdata = data_aligned(:,cShufROIs,:);
    ShufcROIdata = zeros(size(cROIdata));
    
    for nROI = 1 : SampleROINum    
        ShufTrInds = 1:nTrs;
        for cfreqInds = 1 : length(FreqTypes)
            cfreq = TrFreqAll == FreqTypes(cfreqInds);
            cFreqTrInds = DefaultTrInds(cfreq);
            cFreqIndsShuf = Vshuffle(cFreqTrInds);
            ShufTrInds(cfreq) = cFreqIndsShuf;
        end
        cROIsTrs(nROI,:) = ShufTrInds;
    end
    IterShufROITrIndex{niter} = cROIsTrs;
    
    for nROI = 1 : SampleROINum
        ShufcROIdata(:,nROI,:) = cROIdata(cROIsTrs(nROI,:),nROI,:);
    end
    ShufDataAll = data_aligned;
    ShufDataAll(:,cShufROIs,:) = ShufcROIdata;
    DataObj = DataAnalysisSum(ShufDataAll,TrFreqAll,start_frame,frame_rate,1);
    PopuNC = DataObj.popuZscoredCorr(1,'Mean',[],[],0);
    PopuNCAll{niter} = PopuNC;
    
    TestLoass = TbyTAllROIclassInputParse(ShufDataAll,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,...
               'isDataOutput',1,'isErCal',0,'TimeLen',1,'TrOutcomeOp',1,'isWeightsave',0);
    MeanTestLoss(niter) = mean(TestLoass);
    PopuNCMean(niter) = mean(PopuNC(logical(tril(ones(size(PopuNC)),-1))));
    if ~(mod(niter,5))
        fprintf('%d out of %d iterations complete.\n',niter,nIters);
    end
end

%%
