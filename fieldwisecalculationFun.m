function [Field_Neu_Avgs,Field_Ast_Avgs,FracSums] = fieldwisecalculationFun(fieldEvents,...
    fieldROItypes,traceTimes,isactiveOnly)
% used for calculate the field-wise response frequency
NeuInds = cellfun(@(x) strcmpi(x,'Neu'),fieldROItypes);
EventNums = cellfun(@(x) size(x,1),fieldEvents);
EventFreqs = EventNums(:) ./ traceTimes(:);

% Neuactivefrac = mean(EventFreqs(NeuInds) > 0);
% Astactivefrac = mean(EventFreqs(~NeuInds) > 0);
Neuactivefrac = mean(EventFreqs(NeuInds));
Astactivefrac = mean(EventFreqs(~NeuInds));
if isactiveOnly
    UsedROIInds = EventFreqs == 0;
    NeuInds(UsedROIInds) = [];
    EventFreqs(UsedROIInds) = [];
end

Neu_eventfreqs = EventFreqs(NeuInds);
Ast_eventfreqs = EventFreqs(~NeuInds);

Field_Neu_Avgs = [mean(Neu_eventfreqs),numel(Neu_eventfreqs),std(Neu_eventfreqs)];
Field_Ast_Avgs = [mean(Ast_eventfreqs),numel(Ast_eventfreqs),std(Ast_eventfreqs)];

FracSums = [Neuactivefrac,Astactivefrac];
