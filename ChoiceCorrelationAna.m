function [StimDataCorrcell,StimTypes] = ChoiceCorrelationAna(TrStimulus,TrTypes,AnmChoice,PredictChoice)
% this function is specifically used for analysis the corresponded trials
% for each frequency types

[nFoldsType, nTrials] = size(PredictChoice);
StimTypes = unique(TrStimulus);
BehavTrOutcomes = double(TrTypes == AnmChoice);
StimTypeLen = length(StimTypes);

StimDataCorrcell = cell(nFoldsType,StimTypeLen);
for nnn = 1 : nFoldsType
    for cStimType = 1 : StimTypeLen
        cStim = StimTypes(cStimType);
        cStimInds = TrStimulus == cStim;
        cStimAnmChoice = AnmChoice(cStimInds);
        cStimPredChoice = PredictChoice(nnn,cStimInds);
%         cStimTrTypes = TrTypes(cStimInds);
        
        cStimOutcomes = BehavTrOutcomes(cStimInds);
        StimDataCorrcell{nnn,cStimType} = [cStimAnmChoice(:),cStimPredChoice(:),cStimOutcomes(:)];
    end
end
