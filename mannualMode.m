function varargout = mannualMode(data, nbins)
% data should be large enough
if ~exist('nbins','var')
    nbins = 100;
end
MaxData = max(data,[],'all');
MinData = min(data,[],'all');
Steps = linspace(MinData,MaxData,nbins);
Steps = [MinData - 1,Steps];

NumSteps = length(Steps);
Counts = zeros(NumSteps-1,1);
for cStep = 1 : NumSteps-1
    cStepInds = data > Steps(cStep) & data < Steps(cStep+1);
    Counts(cStep) = sum(cStepInds,'all');
end

[MaxCounts, MaxInds] = max(Counts);

if nargout == 1 || nargout == 0
    varargout{1} = mean(Steps([MaxInds,MaxInds+1]));
else
    varargout(:) = {mean(Steps([MaxInds,MaxInds+1])),MaxCounts};
end







