function OmegaSqr = OmegaSqrStats_typeInds(Datas, GroupTypes, GroupInds, varargin)
% Generalized Eta and Omega Squared Statistics: Measures of Effect Size for Some Common Research Designs.
% calculate the omega square values to indicate variance explained by individual factor
% Datas is the observed datas, labels is the corresponded data labels that
%   used to indiacates group types

Datas = Datas(:);
% labels = labels(:);

NumDatas = numel(Datas);
if nargin > 3
    TotalMean = varargin{1}(1);
    SS_total = varargin{1}(2);
else
    TotalMean = mean(Datas);
    SS_total = sum((Datas - TotalMean).^2);
end

% GroupTypes = unique(labels);
NumGrTypes = numel(GroupTypes);
GrAllInds = GroupInds(:,1);
GrIndsNumbers = GroupInds(:,2);

GroupMean = zeros(NumGrTypes,2);
MSEDatas_Vec = zeros(NumDatas,1);
SS_betGroup_Vec = zeros(NumGrTypes,2);
for cGr = 1 : NumGrTypes
%     cGrInds = labels == GroupTypes(cGr);
    cGrInds = GrAllInds{cGr};
    cGrDatas = Datas(cGrInds);
    GroupMean(cGr,:) = [sum(cGrDatas)/GrIndsNumbers{cGr},GrIndsNumbers{cGr}];
    
    MSEDatas_Vec(cGrInds) = cGrDatas - GroupMean(cGr,1);
    SS_betGroup_Vec(cGr,:) = [GroupMean(cGr,1) - TotalMean,GrIndsNumbers{cGr}];
end
df = NumGrTypes - 1;

SS_BetGroupSum = sum((SS_betGroup_Vec(:,1).^2) .* SS_betGroup_Vec(:,2));

MSEDatasSum = sum(MSEDatas_Vec.^2)/(NumDatas-NumGrTypes);

OmegaSqr = (SS_BetGroupSum - df*MSEDatasSum)/...
    (SS_total + MSEDatasSum);



