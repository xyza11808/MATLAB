function [AllROC,AllReverInds,sigvalue]=ROCSiglevelGene(OrderData,nIteration,varargin)
%this function will be only used for calculation significant level for
%ROC_check function

if nargin>2
    isParallel = varargin{1};
else
    isParallel = 1;
end

RawData = OrderData(:,1);
Labels = OrderData(:,2);
AllROCresult = zeros(nIteration,1);
ReverseLabel = zeros(nIteration,1);
if isParallel
    parfor NumIter = 1:nIteration
        Svector=Vshuffle(Labels);
        [ROCout,LabelMeanS]=rocFoffBstrap([RawData,Svector]);
        AllROCresult(NumIter) = ROCout;
        ReverseLabel(NumIter) = LabelMeanS;
    end
else
    for NumIter = 1:nIteration
        Svector=Vshuffle(Labels);
        [ROCout,LabelMeanS]=rocFoffBstrap([RawData,Svector]);
        AllROCresult(NumIter) = ROCout;
        ReverseLabel(NumIter) = LabelMeanS;
    end
end

if nargin > 3
    SigPrc = 100 * (1 - varargin{2});
    SigValue = prctile(AllROCresult,SigPrc);
else
    SigValue = [];
end

if nargout
    AllROC = AllROCresult;
    AllReverInds = ReverseLabel;
    sigvalue = SigValue;
end
