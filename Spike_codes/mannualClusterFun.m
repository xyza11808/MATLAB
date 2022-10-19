function [SigCorrAvgData, FinalGrInds, LeftGrTypes, FinalGrUnitIDs, Raw2finalInds] = ...
    mannualClusterFun(UnitPSTHzs,AllDataPoints,UnitInterROI)
% function used to using mannual clustering result to produce final
% clustering results

UnitClusTypes = unique(UnitInterROI);
NumClus = length(UnitClusTypes) - 1;

[SortGrs,GrInds] = sort(UnitInterROI);
RawUnitIDs = 1:numel(UnitInterROI);
Counts = accumarray(UnitInterROI,1);

SortedData = UnitPSTHzs(GrInds,:);
NumPoints = size(SortedData,2);
ClusAvgTraceANDnum = zeros(NumClus,NumPoints);
ClusUnitNums = zeros(NumClus,1);
for cClus = 1 : NumClus
    cClusInds = SortGrs == cClus;
    cClusData = SortedData(cClusInds,:);
    ClusAvgTraceANDnum(cClus,:) = mean(cClusData);
    ClusUnitNums(cClus) = size(cClusData,1);
end

[Corr, ~] = corr(SortedData',ClusAvgTraceANDnum');

[~, MaxCorrInds] = max(Corr,[],2);
[NewClusInds, NewClusSortInds] = sort(MaxCorrInds);
Clus2RawInds = GrInds(NewClusSortInds);

% SortGrPoints = AllDataPoints(Clus2RawInds,:);
% second sort calculation
SecondSortData = SortedData(NewClusSortInds,:);
% Clus2RawInds = GrInds(NewClusSortInds);
NumPoints = size(SecondSortData,2);
ReClusAvgTraceANDnum = zeros(NumClus,NumPoints);
ReClusSEMTraceANDnum = zeros(NumClus,NumPoints);
NumClus = length(Counts);
ReClusUnitNums = zeros(NumClus,1);
for cClus = 1 : NumClus
    cClusInds = NewClusInds == cClus;
    cClusData = SecondSortData(cClusInds,:);
    ReClusAvgTraceANDnum(cClus,:) = mean(cClusData);
    ReClusUnitNums(cClus) = size(cClusData,1);
    ReClusSEMTraceANDnum(cClus,:) = std(cClusData)/sqrt(size(cClusData,1));
end
if any(ReClusUnitNums == 0)
    EmptyClus = ReClusUnitNums == 0;
    ReClusAvgTraceANDnum(EmptyClus,:) = [];
    ReClusUnitNums(EmptyClus) = [];
    ReClusSEMTraceANDnum(EmptyClus,:) = [];
    NumClus = NumClus - sum(EmptyClus);
end

[NewClusCorr,~] = corr(SecondSortData',ReClusAvgTraceANDnum');
% %% loop through and merge groups if there is no difference between corrs
% 
% ClusInds = unique(NewClusInds);
% ClusNum = length(ClusInds);
% 
SigUnitGrInds = nan(NumPoints,1);
% cClus = 4;
for cClus = 1 : NumClus
    OtherGrInds = NewClusInds ~= cClus;
    OtherGr_cGr_corrs = NewClusCorr(OtherGrInds, cClus);
    
    cGr_corrs = NewClusCorr(~OtherGrInds, cClus);
    
    Thres = max(prctile(OtherGr_cGr_corrs,95),0.3);
    IsUnitSigCorr = cGr_corrs > Thres;
    
    SigUnitGrInds(~OtherGrInds) = IsUnitSigCorr;
    
end

%
SigUnitGrInds = logical(SigUnitGrInds);
SigGrIndsAll = NewClusInds(SigUnitGrInds);
SigGrDatas = SecondSortData(SigUnitGrInds,:);
SecondSortUnitID = RawUnitIDs(Clus2RawInds);
SigGrUnitID = SecondSortUnitID(SigUnitGrInds);

% SecondSortErrData = ExistAreaErrorPSTHData_zs(Clus2RawInds,:);
% SigGrErrorData = SecondSortErrData(SigUnitGrInds,:);

SecondSortTsnePoint = AllDataPoints(Clus2RawInds,:);
SigtsnePoints = SecondSortTsnePoint(SigUnitGrInds,:);

s2 = silhouette(SigtsnePoints,SigGrIndsAll,'CityBlock');
sIndexInds = s2 > -0.2;
FinalGrPSTHs = SigGrDatas(sIndexInds,:);
FinalGrInds = SigGrIndsAll(sIndexInds);
FinalGrUnitIDs = SigGrUnitID(sIndexInds);
% FinaltsnePoints = SigtsnePoints(sIndexInds,:);
% FinalGrErrPSTH = SigGrErrorData(sIndexInds,:);

LeftGrTypes = unique(FinalGrInds); % in case some cluster have no points left
% IsClusLefted = zeros(NumClus,1);
% IsClusLefted(LeftGrTypes) = 1;
[SigCorrAvgData, ~, SigCorrGrUnitNum] = DataTypeClassification(FinalGrPSTHs,FinalGrInds);

% [SigErroAvgData, SigErroSEMData, SigErroGrNums] = DataTypeClassification(FinalGrErrPSTH,FinalGrInds);

Raw2finalInds = {Clus2RawInds, NewClusInds, SigUnitGrInds, sIndexInds, SigCorrGrUnitNum};
