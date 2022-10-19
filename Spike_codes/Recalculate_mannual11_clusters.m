
UnitIDs = 1 : numel(Clus2RawInds);
finalSortUnitID = UnitIDs(Clus2RawInds);
finalSigUnitID = finalSortUnitID(SigUnitGrInds);
finalSilUnitID = finalSigUnitID(sIndexInds); 

finalSortPoints = AllDataPoints(Clus2RawInds,:);
finalSigPoints = finalSortPoints(SigUnitGrInds,:);
finalSilPoints = finalSigPoints(sIndexInds,:);

finalSortPSTH = ExistAreaPSTHData_zs(Clus2RawInds,:);
finalSigPSTH = finalSortPSTH(SigUnitGrInds,:);
finalSilPSTH = finalSigPSTH(sIndexInds,:);

finalClusInds = NewClusInds(SigUnitGrInds);
finalSilGrs = finalClusInds(sIndexInds);

s = silhouette(finalSilPoints, finalSilGrs, 'cityblock');
%%
% close
ViewdCluss = [30];

hf = figure;
hold on
scatter(AllDataPoints(:,1),AllDataPoints(:,2),6,'o','MarkerEdgeColor',[.7 .7 .7]);

ViewClusInds = ismember(finalSilGrs,ViewdCluss);

ViewClusSilPoint = finalSilPoints(ViewClusInds,:);

ViewClusSilIndex = s(ViewClusInds);

scatter(ViewClusSilPoint(:,1),ViewClusSilPoint(:,2),8,ViewClusSilIndex,'o','filled');
ViewSilSigInds = ViewClusSilIndex > 0;
scatter(ViewClusSilPoint(ViewSilSigInds,1),ViewClusSilPoint(ViewSilSigInds,2),8,ViewClusSilIndex(ViewSilSigInds),'r*');

%% re calcualte the cluser unit for each cluster
[ClusTypes, ~, ClusReInds] = unique(finalSilGrs);
NumClus = length(ClusTypes);
FinalUsedClus = zeros(numel(Clus2RawInds), 1);
for cClus = 1 : NumClus
    ViewClusInds = ismember(finalSilGrs,ClusTypes(cClus));
    ViewClusSilPoint = finalSilPoints(ViewClusInds,:);
    ViewClusSilIndex = s(ViewClusInds);
    ViewClusUnitIDs = finalSilUnitID(ViewClusInds);
    ViewSilSigInds = ViewClusSilIndex > 0;
    if mean(ViewSilSigInds) < 0.2
        ViewSilSigInds = true(numel(ViewClusSilIndex),1);
    end
    ViewSilSigUnitIDs = ViewClusUnitIDs(ViewSilSigInds);
    FinalUsedClus(ViewSilSigUnitIDs) = cClus;
end

SigFinalClusInds = FinalUsedClus > 0;
SigFinalUnitIDs = find(SigFinalClusInds);
SigFinalClusPSTH = ExistAreaPSTHData_zs(SigFinalClusInds,:);
SigFinalClusIndex = FinalUsedClus(SigFinalClusInds);

[SigErroAvgData, SigErroSEMData, SigErroGrNums] = DataTypeClassification(SigFinalClusPSTH,SigFinalClusIndex,1);

%%
ExcludeClusInds = [12,16,19,27,29];
ExClusInds = ismember(SigFinalClusIndex,ExcludeClusInds);
SigFinalClusIndex(ExClusInds) = [];
SigFinalClusPSTH(ExClusInds,:) = [];
SigFinalUnitIDs(ExClusInds) = [];
[UniqueClus, ~, SigFinalReClusInds] = unique(SigFinalClusIndex);

%%
[SigCorrAvgData, SigCorrSEMData, SigCGrNums] = DataTypeClassification(SigFinalClusPSTH,SigFinalReClusInds,1);

%%
cGr = 15;
cGrInds = finalSilGrs == cGr;
GrDatas = finalSilPSTH(cGrInds,:);
GrSilIndex = s(cGrInds);
[Corr,~] = corr(GrDatas',SigCorrAvgData(cGr,:)');

hf = figure;
hold on
scatter(AllDataPoints(:,1),AllDataPoints(:,2),6,'o','MarkerEdgeColor',[.7 .7 .7]);
scatter(finalSilPoints(cGrInds,1),finalSilPoints(cGrInds,2),15,Corr,'o','filled');
colorbar







