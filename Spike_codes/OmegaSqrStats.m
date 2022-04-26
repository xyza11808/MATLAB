function [OmegaSqr, p] = OmegaSqrStats(Datas, labels)
% Generalized Eta and Omega Squared Statistics: Measures of Effect Size for Some Common Research Designs.
% calculate the omega square values to indicate variance explained by individual factor
% Datas is the observed datas, labels is the corresponded data labels that
%   used to indiacates group types

Datas = Datas(:);
labels = labels(:);

NumDatas = numel(Datas);
TotalMean = sum(Datas)/NumDatas;
SS_total = var(Datas) * (NumDatas - 1);

GroupTypes = unique(labels);
NumGrTypes = numel(GroupTypes);

GroupMean = zeros(NumGrTypes,2);
MSEDatas_Vec = zeros(NumDatas,1);
SS_betGroup_Vec = zeros(NumGrTypes,2);
for cGr = 1 : NumGrTypes
    cGrInds = labels == GroupTypes(cGr);
    cIndsData = Datas(cGrInds);
    NumOfTrials = sum(cGrInds);
    GroupMean(cGr,:) = [sum(cIndsData)/NumOfTrials,NumOfTrials];
    
    MSEDatas_Vec(cGrInds) = cIndsData - GroupMean(cGr,1);
    SS_betGroup_Vec(cGr,:) = [GroupMean(cGr,1) - TotalMean,NumOfTrials];
end
dfGroup = NumGrTypes - 1;

SS_BetGroupSum = sum((SS_betGroup_Vec(:,1).^2) .* SS_betGroup_Vec(:,2));

dfError = NumDatas-NumGrTypes;
MSEDatasSum = sum(MSEDatas_Vec.^2)/(dfError);

OmegaSqr = (SS_BetGroupSum - dfGroup*MSEDatasSum)/...
    (SS_total + MSEDatasSum);

F = SS_BetGroupSum/MSEDatasSum;
p = 1 - fcdf(F, dfGroup, dfError);


