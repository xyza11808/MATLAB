% % clearvars -except ExistAreaPSTHData_zs ExistAreaErrorPSTHData_zs ExistAreaPSTHAreaInds 
% % load template cluster trace and compute the overall correlations for each
% % unit
% load('finalClusterTemplatefrom11.mat');
% 
% %%
% [Corr, ~] = corr(ExistAreaPSTHData_zs',SigCorrAvgData');
% [~, MaxCorrInds] = max(Corr,[],2);
% [NewClusInds, NewClusSortInds] = sort(MaxCorrInds);
% 
% AllCorrSortData = ExistAreaPSTHData_zs(NewClusSortInds,:);
% 
% [AllCorAvgData, AllCorSEMData, AllCorGrNums] = DataTypeClassification(AllCorrSortData,NewClusInds);
% [NewClusCorr,~] = corr(AllCorrSortData',AllCorAvgData');
% NumPoints = size(AllCorrSortData,2);
% RawUnitIDs = 1:size(AllCorrSortData,1);
% AllCorrSortUnitIDs = RawUnitIDs(NewClusSortInds);
% 
% ClusTypes = unique(NewClusInds);
% NumClus = length(ClusTypes);
% 
% SigUnitGrInds = nan(NumPoints,1);
% % cClus = 4;
% for cClus = 1 : NumClus
%     OtherGrInds = NewClusInds ~= ClusTypes(cClus);
%     OtherGr_cGr_corrs = NewClusCorr(OtherGrInds, cClus);
%     
%     cGr_corrs = NewClusCorr(~OtherGrInds, cClus);
%     
%     Thres = max(prctile(OtherGr_cGr_corrs,95),0.3);
%     IsUnitSigCorr = cGr_corrs > Thres;
%     
%     SigUnitGrInds(~OtherGrInds) = IsUnitSigCorr;
% end
% 
% SigUnitGrInds = logical(SigUnitGrInds);
% 
% SigGrIndsAll = NewClusInds(SigUnitGrInds);
% SigGrDatas = AllCorrSortData(SigUnitGrInds,:);
% SigGrUnitID = AllCorrSortUnitIDs(SigUnitGrInds);

%%
FileNamePrefix = 'Mannual_clustering_data_';
PosFiles = dir('Mannual_clustering_Newdata_*.mat');

NumFiles = length(PosFiles);

FileDatas = cell(NumFiles,6);
SessUnit2ClusInds = zeros(numel(RawUnitIDs),NumFiles);
SessUnittsnePoints = cell(NumFiles,1);
for cf = 1 : NumFiles
    cfName = PosFiles(cf).name;
    cfileData = load(cfName);
    AllCorrSorttsnePoint = cfileData.AllDataPoints(NewClusSortInds,:);
    SigGrTsnePoint = AllCorrSorttsnePoint(SigUnitGrInds,:);
    SessUnittsnePoints(cf) = {cfileData.AllDataPoints};
    
    s2 = silhouette(SigGrTsnePoint,SigGrIndsAll,'CityBlock');
    sIndexInds = s2 > -0.2;
    FinalGrPSTHs = SigGrDatas(sIndexInds,:);
    FinalGrInds = SigGrIndsAll(sIndexInds);
    FinalGrUnitIDs = SigGrUnitID(sIndexInds);
    
    [SigCorrAvgData, SigCorrSEMData, SigCorrGrNums] = DataTypeClassification(FinalGrPSTHs,FinalGrInds);
    FileDatas(cf,:) = {SigCorrAvgData, SigCorrSEMData, SigCorrGrNums,FinalGrUnitIDs,FinalGrPSTHs,FinalGrInds};
    
    SessUnit2ClusInds(FinalGrUnitIDs,cf) = FinalGrInds;
end

%%
NonEmptyUnitInds = mean(SessUnit2ClusInds > 0, 2) > 0.5;
NonEmptyUnitIDs = find(NonEmptyUnitInds);
NumNonEmptyUnits = length(NonEmptyUnitIDs);
NonEmUnitFinalClus = zeros(NumNonEmptyUnits,1);
for cU = 1 : NumNonEmptyUnits
    cUAssignedClus = SessUnit2ClusInds(NonEmptyUnitIDs(cU),:);
    ValidAssign = cUAssignedClus(cUAssignedClus > 0);
    NonEmUnitFinalClus(cU) = mode(ValidAssign);
end
%%
FinalGrPSTHs = ExistAreaPSTHData_zs(NonEmptyUnitIDs,:);
FinalGrInds = NonEmUnitFinalClus;
[FSigCorrAvgData, FSigCorrSEMData, FSigCorrGrNums] = DataTypeClassification(FinalGrPSTHs,FinalGrInds,1);
ClusTypes = unique(FinalGrInds);


%%
% figure;
% hold on
% scatter(AllDataPoints(:,1),AllDataPoints(:,2),6,'o','MarkerEdgeColor',[.7 .7 .7]);


%%
summaryDataPath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
savefilePath = fullfile(summaryDataPath,'MannualClusterfinalsave.mat');
save(savefilePath,'FileDatas','SessUnit2ClusInds','SessUnittsnePoints','SigGrUnitID','SigGrIndsAll','SigGrDatas',...
    'ExistAreaPSTHData_zs','FinalGrPSTHs','FinalGrInds','FSigCorrAvgData','FSigCorrGrNums','NonEmptyUnitIDs','-v7.3');

%% find all the averaged cluster trace and unique them

% FileNamePrefix = 'Mannual_clustering_data_';
DataSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
PosFiles = dir(fullfile(DataSavePath,'Mannual_clustering_data_NewData*.mat'));

NumFiles = length(PosFiles);

FileDatas = cell(NumFiles,2);

for cf = 1 : NumFiles
    cfName = PosFiles(cf).name;
    cfileData = load(cfName);
    cf_CorrAvgDatas = cfileData.SigCorrAvgData;
    FileDatas(cf,:) = {cf_CorrAvgDatas,cf*ones(size(cf_CorrAvgDatas,1),1)};
end

%%
AllAvgTraces = cat(1,FileDatas{:,1});
AllTraceSessIDs = cat(1,FileDatas{:,2});

Perplexitys = 50;
nPCs = 150;
Algorithm = 'barneshut'; %'barneshut' for N > 1000 % 'exact' for small N
Exag = 12;


AllYs = cell(5,2);
for cR = 1 : 5
    figure
%     hold on
    
    rng('shuffle') % for fair comparison
    [Y,loss] = tsne(AllAvgTraces,'Algorithm',Algorithm,'Distance','cosine','Perplexity',Perplexitys,...
        'NumPCAComponents',nPCs,'Exaggeration',Exag);
    scatter(Y(:,1),Y(:,2),'ko');
    title('Cosine')
    AllYs(cR,:) = {Y,loss};
end
%%
AlltsneScores = cat(1,AllYs{:,2});
[~,MinInds] = min(AlltsneScores);
BestTsnePoints = AllYs{MinInds,1};

UsedNumClusters = 5:100;
TestClusterNum = length(UsedNumClusters);
AllClusANDsindex = cell(TestClusterNum,2);
for cK = 1 : TestClusterNum
    idx = kmedoids(BestTsnePoints,UsedNumClusters(cK),'Replicates',5);
    s = silhouette(BestTsnePoints,idx,'cityblock');
    AllClusANDsindex(cK,:) = {idx,s};
end

%%
AllSilIndex = cellfun(@mean,AllClusANDsindex(:,2));
[~,MaxInds] = max(AllSilIndex);
UsedAvgTraceClusInds = AllClusANDsindex{MaxInds,1};
UsedAvgClusSilIndex = AllClusANDsindex{MaxInds,2};

UsedClusInds = UsedAvgClusSilIndex > 0.1;
UsedClus_clusIndex = UsedAvgTraceClusInds(UsedClusInds);
UsedClus_clusAvgTraces = AllAvgTraces(UsedClus_clusIndex,:);

[ClusInds, ClusSortInds] = sort(UsedClus_clusIndex);
SortedAvgPSTH = UsedClus_clusAvgTraces(ClusSortInds,:);
Corrs = corrcoef(SortedAvgPSTH');
figure;
imagesc(Corrs,[0.5 1]);
Counts = accumarray(ClusInds,1);
AccumGrCounts = cumsum(Counts);
for cGr = 1 : numel(AccumGrCounts)
    line([1 numel(ClusInds)],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
        'linewidth',1.5);
    line([AccumGrCounts(cGr) AccumGrCounts(cGr)],[1 numel(ClusInds)],'Color','m',...
        'linewidth',1.5);
end


% hf = figure;
% hold on
% % gscatter(BestTsnePoints(:,1),BestTsnePoints(:,2),UsedAvgTraceClusInds);
% scatter(BestTsnePoints(:,1),BestTsnePoints(:,2),20,UsedAvgClusSilIndex);
% scatter(BestTsnePoints(UsedAvgClusSilIndex > 0.1,1),BestTsnePoints(UsedAvgClusSilIndex > 0.1,2),18,'r*');

%% Following parts only used for test usage
%% loop across maximum cluster numbers

fileClusNums = cellfun(@(x) size(x,1),FileDatas(:,1));
UsedfilesInds = fileClusNums > 20;

UsedfileData = FileDatas(UsedfilesInds,:);
UsedfileClusNums = fileClusNums(UsedfilesInds);

[MaxClusNums, MAxInds] = max(UsedfileClusNums);
ControlSess = UsedfileData(MAxInds,:);
LeftSesses = UsedfileData;
LeftSesses(MAxInds,:) = [];

UsedFileNum = sum(UsedfilesInds);
ControlSessAvgPSTH = ControlSess{1};
Sess2ControlClusInds = cell(NumFiles - 1,2);
for cs = 1 : UsedFileNum-1
    cSAvgData = LeftSesses{cs,1};
    
    [Corr, pps] = corr(ControlSessAvgPSTH',cSAvgData');
    ReClusCorrANDInds = zeros(MaxClusNums,2);
    for cClus = 1 : MaxClusNums
        cClusCorr = Corr(cClus,:);
        [MaxCorr, Max2ClusInds] = max(cClusCorr);
        ReClusCorrANDInds(cClus,:) = [MaxCorr, Max2ClusInds];
    end
    
    Sess2ControlClusInds(cs,:) = {ReClusCorrANDInds, cSAvgData(ReClusCorrANDInds(:,2),:)};
    
%     figure;
%     imagesc(cSAvgData(ReClusCorrANDInds(:,2),:),[-0.5 1])
end

%% loop across minimum cluster numbers

fileClusNums = cellfun(@(x) size(x,1),FileDatas(:,1));
UsedfilesInds = fileClusNums > 20;

UsedfileData = FileDatas(UsedfilesInds,:);
UsedfileClusNums = fileClusNums(UsedfilesInds);

[MaxClusNums, MAxInds] = min(UsedfileClusNums);
ControlSess = UsedfileData(MAxInds,:);
LeftSesses = UsedfileData;
LeftSesses(MAxInds,:) = [];

UsedFileNum = sum(UsedfilesInds);
ControlSessAvgPSTH = ControlSess{1};
Sess2ControlClusInds = cell(NumFiles - 1,2);
Unit2Clus_repeatassign = zeros(TotalUnitNums,UsedFileNum);
for cs = 1 : UsedFileNum-1
    cSAvgData = LeftSesses{cs,1};
    cSClusInds = LeftSesses{cs,2};
    cSUnitIDs = LeftSesses{cs,4};
    
    cSessClusNum = size(cSAvgData,1);
    [Corr, pps] = corr(ControlSessAvgPSTH',cSAvgData');
    
    ReClusCorrANDInds = zeros(cSessClusNum,2);
    cSessClus2CtrlClusNum = zeros(MaxClusNums,1);
    for cClus = 1 : cSessClusNum
        cClusCorr = Corr(:,cClus);
        [MaxCorr, Max2ClusInds] = max(cClusCorr);
        ReClusCorrANDInds(cClus,:) = [MaxCorr, Max2ClusInds];
        cSessClus2CtrlClusNum(Max2ClusInds) = cSessClus2CtrlClusNum(Max2ClusInds) + 1;
    end
    
    Sess2ControlClusInds(cs,:) = {ReClusCorrANDInds, cSAvgData(ReClusCorrANDInds(:,2),:)};
    
    % check and merge clusters
    Unit2CtrlClusInds = zeros(TotalUnitNums, 1);
    cClusIndex = 1 : cSessClusNum;
    for cClus = 1 : MaxClusNums
        match2CtrlClusInds = ReClusCorrANDInds(:,2) == cClus;
        match2CtrlCluss = cClusIndex(match2CtrlClusInds);
        if ~isempty(match2CtrlCluss)
            CtrlMatchInds = ismember(cSClusInds, match2CtrlCluss);
            CtrlMatchUnitIDs = cSUnitIDs(CtrlMatchInds);
            Unit2CtrlClusInds(CtrlMatchUnitIDs) = cClus;
        end
    end
    Unit2Clus_repeatassign(:,cs) = Unit2CtrlClusInds;
    
%     figure;
%     imagesc(cSAvgData(ReClusCorrANDInds(:,2),:),[-0.5 1])
end

%%
Unit2Clus_repeatassign(ControlSess{4},end) = ControlSess{2};

%%
NonEmptyUnitInds = mean(Unit2Clus_repeatassign > 0, 2) > 0.5;
NonEmptyUnitIDs = find(NonEmptyUnitInds);
NumNonEmptyUnits = length(NonEmptyUnitIDs);
NonEmUnitFinalClus = zeros(NumNonEmptyUnits,1);
for cU = 1 : NumNonEmptyUnits
    cUAssignedClus = Unit2Clus_repeatassign(NonEmptyUnitIDs(cU),:);
    ValidAssign = cUAssignedClus(cUAssignedClus > 0);
    NonEmUnitFinalClus(cU) = mode(ValidAssign);
end

%%
FinalGrPSTHs = ExistAreaPSTHData_zs(NonEmptyUnitIDs,:);
FinalGrInds = NonEmUnitFinalClus;
[SigCorrAvgData, SigCorrSEMData, SigCorrGrNums] = DataTypeClassification(FinalGrPSTHs,FinalGrInds);
ClusTypes = unique(FinalGrInds);
%%
RearrangeInds = [1,2,4,5,7,6,3,13,14,15,16,20,21,22,23,24,26,12,8,9,11,18,19,25,17];
SigCorrAvgData = FSigCorrAvgData;
SigCorrAvgData = SigCorrAvgData(RearrangeInds,:);
SigCorrGrNums = FSigCorrGrNums(RearrangeInds);
h3f = figure('position',[100 100 1020 840]);
hold on
NumPoints = size(SigCorrAvgData,2);
PlottedClusNum = size(SigCorrAvgData,1);
ybase = 5;
ystep = 3;

TraceTickCent = zeros(PlottedClusNum,1);
for cplot = 1 : PlottedClusNum
    cTraceData = SigCorrAvgData(cplot,:);
    cTraceData_minSub = cTraceData - min(cTraceData);
    cTraceData_plot = cTraceData_minSub + ybase;
    plot(cTraceData_plot,'k','linewidth',1.5);
    text(NumPoints+10, mean(cTraceData_plot),num2str(SigCorrGrNums(cplot),'%d'),'Color','m');
    TraceTickCent(cplot) = mean(cTraceData_plot);
    ybase = ybase + ystep + max(cTraceData_minSub);
end

BlockChangePoints = NumPoints/2 + 0.5;
yscales = get(gca,'ylim');
line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',(1:PlottedClusNum)',...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');
% title('Correlation threshold, Correct trials');



