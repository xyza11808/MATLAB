function [AvgNeuEvent_All, AvgAstEvent_All] = ...
    SessEventAvgFun(DataCell, NeuType, SessTime)

% ROINum = length(DataCell);
ROIEvents = cellfun(@(t)  size(t,1), DataCell) ./ SessTime;
NeuInds = strcmpi(NeuType, 'Neu');

NeuEventRates = ROIEvents(NeuInds);
AstEventRates = ROIEvents(~NeuInds);

AvgROIEvent_All = [mean(NeuEventRates), mean(AstEventRates)]; % Average across all neurons

if ~isempty(find(AstEventRates > 0, 1))
    AvgROIEvent_active = [mean(NeuEventRates(NeuEventRates > 0)), ...
        mean(AstEventRates(AstEventRates > 0))]; % Average across active neurons
else
    AvgROIEvent_active = [mean(NeuEventRates(NeuEventRates > 0)), ...
        0]; % Average across active neurons
end

AvgNeuEvent_All = [AvgROIEvent_All(1), AvgROIEvent_active(1)];
AvgAstEvent_All = [AvgROIEvent_All(2), AvgROIEvent_active(2)];