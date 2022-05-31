function [AllROC,AllReverInds,sigvalue]=ROCSiglevelGeneNew(OrderData,nIteration,varargin)
%this function will be only used for calculation significant level for
%ROC_check function

if nargin>2
    isParallel = varargin{1};
else
    isParallel = 1;
end

RawData = OrderData(:,1);
if sum(isnan(RawData))
    return;
end
Labels = OrderData(:,2);
NumLabels = length(Labels);
ShufRandInds = rand(nIteration, NumLabels);

AllROCresult = zeros(nIteration,1);
ReverseLabel = zeros(nIteration,1);
if isParallel
    parfor NumIter = 1:nIteration
        [~,shufInds] = sort(ShufRandInds(NumIter,:));
        Svector = Labels(shufInds);
%         Svector=Vshuffle(Labels);
        [ROCout,LabelMeanS]=AUC_fast_utest(RawData,Svector);
        AllROCresult(NumIter) = ROCout;
        ReverseLabel(NumIter) = LabelMeanS;
    end
else
    for NumIter = 1:nIteration
        [~,shufInds] = sort(ShufRandInds(NumIter,:));
        Svector = Labels(shufInds);
%         Svector=Vshuffle(Labels);
        [ROCout,LabelMeanS]=AUC_fast_utest(RawData,Svector);
        AllROCresult(NumIter) = ROCout;
        ReverseLabel(NumIter) = LabelMeanS;
    end
end

if nargin > 3
    SigPrc = 100 * (1 - varargin{2});
    SigValue = prctile(AllROCresult,SigPrc);
else
    SigValue = prctile(AllROCresult,99); % default using alpha value of 0.01
end

if nargout
    AllROC = AllROCresult;
    AllReverInds = ReverseLabel;
    sigvalue = SigValue;
end
