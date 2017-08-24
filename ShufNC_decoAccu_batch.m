clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the task session data path');
if ~fi
    return;
end
ErrorMessStrc = struct('SessPath','','ErrorStrc',[]);
ErrorNum = 1;
SessPath = fullfile(fp,fn);
fid = fopen(SessPath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    cSessPath = tline;
    cd(cSessPath);
    load('CSessionData.mat');
    try
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
                       'isDataOutput',1,'isErCal',0,'TimeLen',1,'TrOutcomeOp',0,'isWeightsave',0);
            MeanTestLoss(niter) = mean(TestLoass);
            PopuNCMean(niter) = mean(PopuNC(logical(tril(ones(size(PopuNC)),-1))));
            if ~(mod(niter,50))
                fprintf('%d out of %d iterations complete.\n',niter,nIters);
            end
        end
        NormTestLoss = TbyTAllROIclassInputParse(data_aligned,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,...
                       'isDataOutput',1,'isErCal',1,'TimeLen',1,'TrOutcomeOp',0,'isWeightsave',0);
        save NCDecodAccuracySave.mat MeanTestLoss PopuNCMean PopuNCAll IterShufROITrIndex IterROIIndex NormTestLoss -v7.3
    catch ME
       ErrorMessStrc(ErrorNum).SessPath = cSessPath;
       ErrorMessStrc(ErrorNum).ErrorStrc = ME;
       ErrorNum = ErrorNum + 1;
    end
    clearvars MeanTestLoss PopuNCMean PopuNCAll IterShufROITrIndex IterROIIndex ShufDataAll data_aligned 
    tline = fgetl(fid);
end
if ErrorNum > 1
    ErrorNum = ErrorNum - 1;
    cd('E:\DataToGo\data_for_xu\Session_NCAccuracy_save');
    save ErrorInfo.mat ErrorMessStrc ErrorNum -v7.3
end