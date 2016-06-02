function rfRespInds = RF_resp_check(RawData,TrialFreq,StimOnFrame,ConsiderScale,varargin)
% this function will be used for test whether ROIs is significantly
% responsive during RF test, using t-test for discrimination

DataSize = size(RawData);
FreqType = unique(TrialFreq);
FreqNum = length(FreqType);
rfRespInds = zeros(DataSize(2),FreqNum);

for nROI = 1 : DataSize(2)
    cROIdata = squeeze(RawData(:,nROI,:));
    for nfreq = 1 : FreqNum
        cFreq = FreqType(nfreq); %#ok<PFBNS>
        cFreqTrial = TrialFreq == cFreq;
        cFreqData = cROIdata(cFreqTrial,:);
        BeforeStimData = cFreqData(:,1:StimOnFrame);
        AfterStimData = cFreqData(:,(StimOnFrame+1):(StimOnFrame+ConsiderScale));
        MeanTrace = mean(cFreqData);
        STDThres = mad(reshape(cROIdata',[],1),1)*1.4826;  %session std
        [h,~] = ttest2(BeforeStimData(:),AfterStimData(:),'tail','left','Alpha',0.01);
        if h
            if max(MeanTrace((StimOnFrame+1):(StimOnFrame+ConsiderScale))) > 3*STDThres && MeanTrace(StimOnFrame) < 0.2 * max(MeanTrace((StimOnFrame+1):(StimOnFrame+ConsiderScale)))
                rfRespInds(nROI,nfreq) = 1;
            end
        end
        
    end
end

save rfSigROis.mat rfRespInds -v7.3



%%
% this analysis method is too sensitive, not care about the value
% difference between two distribution
%for analysis based on AUC 
% BeforedataForROC = [BeforeStimData(:),zeros(numel(BeforeStimData),1)];
% AfterDataforROC = [AfterStimData(:),ones(numel(AfterStimData),1)];
% [dataBIN,LMMean]=rocOnlineFoff([BeforedataForROC;AfterDataforROC]);
% if LMMean
%     dataBIN = 1 - dataBIN;
% end
% [~,~,sigvalue]=ROCSiglevelGene([BeforedataForROC;AfterDataforROC],1000,1,0.05);
% if dataBIN > sigvalue
%     rfRespInds(nROI,nfreq) = 1;
% end