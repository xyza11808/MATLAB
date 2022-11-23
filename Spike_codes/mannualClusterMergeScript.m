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
% DataSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
DataSavePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
PosFiles = dir(fullfile(DataSavePath,'Mannual_clustering_data_NewData*.mat'));
load(fullfile(DataSavePath,'AllPSTHData.mat'));

NumFiles = length(PosFiles);

FileDatas = cell(NumFiles,2);

for cf = 1 : NumFiles
    cfName = fullfile(DataSavePath,PosFiles(cf).name);
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
%     figure
%     hold on
    
    rng('shuffle') % for fair comparison
    [Y,loss] = tsne(AllAvgTraces,'Algorithm',Algorithm,'Distance','cosine','Perplexity',Perplexitys,...
        'NumPCAComponents',nPCs,'Exaggeration',Exag);
%     scatter(Y(:,1),Y(:,2),'ko');
%     title('Cosine')
    AllYs(cR,:) = {Y,loss};
end
%%
AlltsneScores = cat(1,AllYs{:,2});
[~,MinInds] = min(AlltsneScores);
BestTsnePoints = AllYs{MinInds,1};

UsedNumClusters = 10:80;
TestClusterNum = length(UsedNumClusters);
AllClusANDsindex = cell(TestClusterNum,2);
for cK = 1 : TestClusterNum
    idx = kmedoids(BestTsnePoints,UsedNumClusters(cK),'Replicates',5);
    s = silhouette(BestTsnePoints,idx,'Cityblock');
    AllClusANDsindex(cK,:) = {idx,s};
end
AllSilIndex = cellfun(@mean,AllClusANDsindex(:,2));
figure;
plot(AllSilIndex)
%%

% [~,MaxInds] = max(AllSilIndex);
MaxInds = 29; % mannually checked cluster number. THIS IS NOT THE REAL CLUSTER NUMBER, THE REAL NUMBER SHOULD BE: UsedNumClusters(MaxInds)
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
%%
[SigCorrAvgData, SigCorrSEMData, SigCorrGrNums] = DataTypeClassification(SortedAvgPSTH,ClusInds);

%%
LeftGrTypes = unique(ClusInds);
NumPoints = size(SigCorrAvgData,2);
h00f = figure('position',[100 100 1020 840]);
hold on

ybase = 5;
ystep = 3;
PlottedClusNum = length(LeftGrTypes);
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
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',LeftGrTypes(:),...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');
title('Correlation threshold, Correct trials');


%% example plots
close
cLus = 47;
cClusInds = ClusInds == cLus;
cClusTraces = SortedAvgPSTH(cClusInds,:);
figure;
plot(cClusTraces','Color',[.7 .7 .7]);

%%
[Corr, p] = corr(ExistAreaPSTHData_zs',SigCorrAvgData');
[UnitNum, PSTHLen] = size(ExistAreaPSTHData_zs);
NumClusters = size(SigCorrAvgData,1);
[MaxCorrValue, MaxCorrInds] = max(Corr,[],2);
[NewClusInds, NewClusSortInds] = sort(MaxCorrInds);
SortedPSTHs = single(ExistAreaPSTHData_zs(NewClusSortInds,:));
SortedMaxCorrs = MaxCorrValue(NewClusSortInds);
hf = figure('position',[50 50 430 400]);
imagesc(SortedPSTHs,[-2 5]);
axesPos = get(gca,'position');
set(gca,'position',axesPos+[-0.015 0 -0.02 -0.02])
hbar = colorbar;
barpos = get(hbar,'position');
set(get(hbar,'label'),'String','Zscored firing rate');
set(hbar,'position',barpos.*[1 1 0.6 0.3]+[0.15 0 0 0]);
Counts = accumarray(NewClusInds,1);
AccumGrCounts = cumsum(Counts);
% for cGr = 1 : numel(AccumGrCounts)
%     line([1 700],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
%         'linewidth',1.5);
% end
line([1 1]*PSTHLen/2,[0.5 UnitNum+0.5],'Color','m','linewidth',2);
set(gca,'xtick',[PSTHLen/4,3*PSTHLen/4],'xticklabel',{'LowBound Block','HighBound Block'},'ytick',[1 UnitNum]);
set(gca,'FontSize',10);

%%
FigSavePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas\FinalClusterResult';
% FigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas\FinalClusterResult';
figAllPSTHsaveName = fullfile(FigSavePath,'All unit PSTH colorplot');
saveas(hf,figAllPSTHsaveName);
print(hf,figAllPSTHsaveName,'-dpng','-r350');
print(hf,figAllPSTHsaveName,'-dpdf','-bestfit');

%% example cluster color plot
cClus = 3;
cClusPSTHs = SortedPSTHs(NewClusInds == cClus,:);
cClusCorrs = SortedMaxCorrs(NewClusInds == cClus);
[SortedCorrs,CorrSortInds] = sort(cClusCorrs);
cClusPSTHs_sorted = cClusPSTHs(CorrSortInds,:);
cClusCorrs_sorted = cClusCorrs(CorrSortInds);

%% using the top 20% correlation units to recalculate the avg tracefor each cluster
NewClusAvgTrace = zeros(size(SigCorrAvgData));
for cClus = 1 : NumClusters
    cClusPSTHs = SortedPSTHs(NewClusInds == cClus,:);
    cClusCorrs = SortedMaxCorrs(NewClusInds == cClus);
    Thres = prctile(cClusCorrs,80);
    UsedUnitInds = cClusCorrs >= Thres;
    UsedUnitPSTHs = cClusPSTHs(UsedUnitInds,:);
    NewClusAvgTrace(cClus,:) = mean(UsedUnitPSTHs);
end

LowClusAvg_AllMean = mean(NewClusAvgTrace(:,1:350),2);
HighClusAvg_AllMean = mean(NewClusAvgTrace(:,351:700),2);
LowByHighDiff = LowClusAvg_AllMean - HighClusAvg_AllMean;
[~,LHsortInds] = sort(LowByHighDiff,'descend');

LHsortAvgTraces = NewClusAvgTrace(LHsortInds,:);

%% recalculate all units cluster and cutting threshold at 0.4 correlation
[Corr, p] = corr(ExistAreaPSTHData_zs',LHsortAvgTraces');
NumClusters = size(LHsortAvgTraces,1);
[MaxCorrValue, MaxCorrInds] = max(Corr,[],2);
[NewClusInds, NewClusSortInds] = sort(MaxCorrInds);
SortedPSTHs = ExistAreaPSTHData_zs(NewClusSortInds,:);
SortedMaxCorrs = MaxCorrValue(NewClusSortInds);
CorrThres = 0.5;
ThresCut_unitInds = SortedMaxCorrs > CorrThres;
CorrThres_SortPSTH = SortedPSTHs(ThresCut_unitInds,:);
CorrThres_MaxCorr = SortedMaxCorrs(ThresCut_unitInds);
CorrThres_ClusInds = NewClusInds(ThresCut_unitInds);


figure;imagesc(CorrThres_SortPSTH,[-1 3])

%%
[SigCorrAvgDataFinal, SigCorrSEMDataFinal, SigCorrGrNumsFinal] = ...
    DataTypeClassification(CorrThres_SortPSTH,CorrThres_ClusInds);

%% Used cluster unit color plot
h0cf = figure('position',[100 100 340 780]);
imagesc(CorrThres_SortPSTH,[-1 3]);
Counts = accumarray(CorrThres_ClusInds,1);
[NumUnits, NumPSTHLen] = size(CorrThres_SortPSTH);
AccumGrCounts = cumsum(Counts);
for cGr = 1 : numel(AccumGrCounts)
    line([1 NumPSTHLen],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','c',...
        'linewidth',0.75);
end
axispos = get(gca,'position');
hbar = colorbar;
Oldpos = get(hbar,'position');
set(hbar,'position',[Oldpos(1)+0.12,Oldpos(2),Oldpos(3)*0.5,Oldpos(4)*0.2]);
set(gca,'position',[axispos(1)-0.02,axispos(2:4)]);
line([NumPSTHLen/2 NumPSTHLen/2],[0.5 NumUnits+0.5],'Color','m','linewidth',0.75);
set(gca,'xtick',[NumPSTHLen/4 3*NumPSTHLen/4],'xticklabel',{'Low boundary block','Low boundary block'},...
    'ytick',[1 NumUnits],'yDir','normal');
ylabel('# Units');

%%
saveName3c = fullfile(FigSavePath,'..','All cluster Used units PSTH color plot');
saveas(h0cf,saveName3c);
print(h0cf,saveName3c,'-dpng','-r350');
print(h0cf,saveName3c,'-dpdf','-bestfit');


%%
LeftGrTypes = unique(CorrThres_ClusInds);
NumPoints = size(SigCorrAvgDataFinal,2);
h00f = figure('position',[100 100 740 700]);
hold on

ybase = 5;
ystep = 3;
PlottedClusNum = length(LeftGrTypes);
TraceTickCent = zeros(PlottedClusNum,1);
for cplot = 1 : PlottedClusNum
    cTraceData = SigCorrAvgDataFinal(cplot,:);
    cTraceData_minSub = cTraceData - min(cTraceData);
    cTraceData_plot = cTraceData_minSub + ybase;
    plot(cTraceData_plot,'k','linewidth',1.5);
    text(NumPoints+10, mean(cTraceData_plot),num2str(SigCorrGrNumsFinal(cplot),'%d'),'Color','m');
    TraceTickCent(cplot) = mean(cTraceData_plot);
    ybase = ybase + ystep + max(cTraceData_minSub);
end

BlockChangePoints = NumPoints/2 + 0.5;
yscales = get(gca,'ylim');
line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',LeftGrTypes(:),...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'Low Boundary Block';'High Boundary Block'},'FontSize',12);
ylabel('Clusters');
title('Correlation threshold, Correct trials');
%% PSTH fig save name
saveName3 = fullfile(FigSavePath,'All cluster Averaged PSTH trace plot');
saveas(h00f,saveName3);
print(h00f,saveName3,'-dpng','-r350');
print(h00f,saveName3,'-dpdf','-bestfit');


%% save results
saveName4 = fullfile(FigSavePath,'FinalClusterData.mat');
save(saveName4,'LHsortAvgTraces','NewClusSortInds','NewClusInds','ThresCut_unitInds',...
    'SigCorrAvgDataFinal','SigCorrGrNumsFinal','SigCorrSEMDataFinal','CorrThres_ClusInds','CorrThres_SortPSTH','-v7.3');

%% resort all clusters based on mannually defined types
ClusTypefile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas\FinalClusterResult\cluster2Type.txt';
% ClusTypefile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas\FinalClusterResult\cluster2Type.txt';

fid = fopen(ClusTypefile,'r');
k = 1;
ClusStrANDInds = {};
Lastline = '';
cLine = fgetl(fid);
while ischar(cLine)
    if ~isempty(str2num(cLine)) % if there are numbers in current line
        ClusStrANDInds(k,:) = {Lastline, str2num(cLine)};
        k = k + 1;
    end
    Lastline = cLine;
    cLine = fgetl(fid);
end
fclose(fid);

%%
dataSaveName = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas\FinalClusterResult',...
    'ClusterTypeDesp.mat');
save(dataSaveName,'ClusStrANDInds','-v7.3');

%%
cType = 1;
cTypeClusInds = ClusStrANDInds{cType,2};
cTypeStr = ClusStrANDInds{cType,1};
NumClusInds = length(cTypeClusInds);


%% 

PerplexitysAll = 10:20:150;
nPCs = 150;
Algorithm = 'barneshut'; %'barneshut' for N > 1000 % 'exact' for small N
Exag = 12;

NumPerplex = length(PerplexitysAll);
AllNumTsnePoints = cell(NumPerplex,5,2);
for cP = 1 : NumPerplex
    cPerplex = PerplexitysAll(cP);
    AllYs = cell(5,2);
    for cR = 1 : 5
        rng('shuffle') % for fair comparison
        [Y,loss] = tsne(ExistAreaPSTHData_zs,'Algorithm',Algorithm,'Distance','cosine','Perplexity',cPerplex,...
            'NumPCAComponents',nPCs,'Exaggeration',Exag);
        AllYs(cR,:) = {Y,loss};
    end
    AllNumTsnePoints(cP,:,:) = AllYs;
end

%%
AllTsnePoints = AllNumTsnePoints(:,:,1);
AllPlexiSilIndex = cell(NumPerplex,2);
for cP = 1 : NumPerplex
    TestPoints = AllTsnePoints{cP,1};
    % hf = figure;
    % hold on
    % plot(TestPoints(:,1),TestPoints(:,2),'o','Color',[.7 .7 .7]);
    cTsneSortPoints = TestPoints(NewClusSortInds,:);
    cTsne_thresPoints = cTsneSortPoints(ThresCut_unitInds,:);
    % CorrThres_ClusInds
    % scatter(cTsne_thresPoints(:,1),cTsne_thresPoints(:,2),15,CorrThres_ClusInds,'filled');
    cRealIndex = silhouette(cTsne_thresPoints,CorrThres_ClusInds,'cityblock');

    NumIncludedInds = numel(CorrThres_ClusInds);
    TotalPoints = size(cTsneSortPoints,1);
    ShufNum = 200;
    RandInds = single(rand(ShufNum,NumIncludedInds));
    ShufSilIndex = zeros(ShufNum,1);
    parfor cshuf = 1 : ShufNum
%         cShufInds = randsample(TotalPoints,NumIncludedInds);
        [~,SortInds] = sort(RandInds(cshuf,:));
%         cShufPoints = cTsneSortPoints(cShufInds,:);
        sShufSilIndexAll = silhouette(cTsne_thresPoints,CorrThres_ClusInds(SortInds),'cityblock');
        ShufSilIndex(cshuf) = mean(sShufSilIndexAll);
    end
    
    AllPlexiSilIndex(cP,:) = {cRealIndex,ShufSilIndex};
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



