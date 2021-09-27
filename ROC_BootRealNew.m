function [AllROC,AllReverInds]=ROC_BootRealNew(OrderData,nIteration,varargin)
%this function will be only used for calculation significant level for
%ROC_check function

if nargin>2
    isParallel = varargin{1};
else
    isParallel = 1;
end
UsedBootOrSubsample = 1; % default using bootstrap method
% if this value is 0, using subsampleing method and sampling fraction is
% 0.8
if nargin > 3
    if isempty(varargin{2})
        UsedBootOrSubsample = varargin{2};
    end
end

RawData = OrderData(:,1);
if sum(isnan(RawData))
    return;
end

if isParallel
    if UsedBootOrSubsample % using bootstrap
        Optstate = statset('UseParallel',true);
        BootRes = bootstrp(nIteration,@(Data)AUC_fast_utest(Data),...
            OrderData,'options',Optstate);
        AllROCresult = BootRes(:,1);
        ReverseLabel = BootRes(:,2);
    else
        AllROCresult = zeros(nIteration,1);
        ReverseLabel = zeros(nIteration,1);
        SampleTrs = round(size(OrderData,1)*0.8);
        parfor NumIter = 1:nIteration
            UsedTrInds = resample(size(OrderData,1),SampleTrs);
            [ROCout,LabelMeanS]=AUC_fast_utest(OrderData(UsedTrInds,:));
            AllROCresult(NumIter) = ROCout;
            ReverseLabel(NumIter) = LabelMeanS;
        end
    end
else
    if UsedBootOrSubsample % using bootstrap
        Optstate = statset('UseParallel',false);
        BootRes = bootstrp(nIteration,@(Data)AUC_fast_utest(Data),...
            OrderData,'options',Optstate);
        AllROCresult = BootRes(:,1);
        ReverseLabel = BootRes(:,2);
    else
        AllROCresult = zeros(nIteration,1);
        ReverseLabel = zeros(nIteration,1);
        SampleTrs = round(size(OrderData,1)*0.8);
        for NumIter = 1:nIteration
            UsedTrInds = resample(size(OrderData,1),SampleTrs);
            [ROCout,LabelMeanS]=AUC_fast_utest(OrderData(UsedTrInds,:));
            AllROCresult(NumIter) = ROCout;
            ReverseLabel(NumIter) = LabelMeanS;
        end
    end
end

if nargout
    AllROC = AllROCresult;
    AllReverInds = ReverseLabel;
end
