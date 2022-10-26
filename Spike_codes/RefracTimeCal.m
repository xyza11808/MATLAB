function RefracBin = RefracTimeCal(ccgcorrlogram,ControlBins)

NumClusters = size(ccgcorrlogram,1);
RefracBin = zeros(NumClusters,NumClusters);
RefracThres = zeros(NumClusters,NumClusters);
for cCtrClus = 1 : NumClusters
    for cClus = 1 : NumClusters
        % calculate self refrac period
        ClusSelfData = squeeze(ccgcorrlogram(cCtrClus,cClus,:));
        CtrlCounts = mean(ClusSelfData((end-ControlBins+1):end));
        if CtrlCounts > 5
            SelfRecoveryBin = find(ClusSelfData >= (CtrlCounts*2)/3,1,'first');
            RefracBin(cCtrClus,cClus) = SelfRecoveryBin;
            RefracThres(cCtrClus,cClus) = (CtrlCounts*2)/3;
        else
            RefracBin(cCtrClus,cClus) = -1;
%             RefracThres(cCtrClus,cClus) = 0;
        end
    end
end
for cClus = 1 : NumClusters
    if RefracThres(cClus,cClus) == 0 || RefracBin(cClus,cClus)  >  25
        RefracBin(cClus,:) = 1;
        RefracBin(:,cClus) = 1;
    end
    
end
        