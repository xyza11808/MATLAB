% % summarization scripts
% cclr
% xlsFilePath = 'E:\xnn_data\temp_0915\xsn_imagingmice_inf.xlsx';
% [~,txt,raw] = xlsread(xlsFilePath,1);
% FolderNames_Cell = txt(2:end,1);
% AgeType_Cell = txt(2:end,2);
% GenoType_Cell = txt(2:end,3);

%% load datas for one animal types
cclr
SumSourPath = 'M:\data\xnn\p18_wt';
WithinSourcePaths = dir(fullfile(SumSourPath,'*2019*'));
FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
UsedTargetFolder = WithinSourcePaths(FolderIndex);
NumFolders = length(UsedTargetFolder);
FolderFullpaths = arrayfun(@(x) fullfile(SumSourPath,x.name),UsedTargetFolder,'UniformOutput',false);
FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);

%% cSession correlation analysis
MultiSessCoefData = cell(NumFolders,1);
SepMultiSessCoefData = cell(NumFolders,1);
% MultiSessGenoType = cell(NumFolders,1);
EventSyncFrac = cell(NumFolders,1);
EventSyncFrac_EO = cell(NumFolders,1);
MultiSessEventData = cell(NumFolders,1);
PopuFieldSynchrony_all = cell(NumFolders,2);
EventOnlyFieldSynchrony_all = cell(NumFolders,1);
Sess_eventOnlyCoefData = cell(NumFolders,1);
for cfff = 1:NumFolders
    cfName = FolderNames{cfff};
    cfFullPath = FolderFullpaths{cfff};
    
    cPathFrameIndex = load(fullfile(cfFullPath,'FieldImageFrameNum.mat'));
%     SessionFieldData =  CorrDataProcessFun(cfFullPath,'AllFieldDatasNew_1201.mat','CorrCoefDataNew_0921.mat');
%     MultiSessCoefData{cfff} = SessionFieldData;
    
%     FieldEventDataAlls = EventDataProcessFun(cfFullPath,'AllFieldDatasNew_1201.mat','CorrCoefDataNew_0921.mat');
%     MultiSessEventData{cfff} = FieldEventDataAlls;
%     
%     FieldNum = size(FieldEventDataAlls,1);
%     FieldRealShufIndex = cell(FieldNum,1);
%     for cf = 1 : FieldNum
%         Field1DataRealIndex = mean(FieldEventDataAlls{cf,4});
%         Field1DataShufIndex = FieldEventDataAlls{cf,5};
%         FieldRealShufIndex{cf} = [Field1DataRealIndex(:),Field1DataShufIndex(:)];
%     end
%     EventSyncFrac{cfff} = FieldRealShufIndex;
    
    % processing event-only datas
    FieldEventDataAlls_EO = EventDataProcessFun_EO(cfFullPath,'AllFieldDatasNew_1201.mat','CorrCoefDataNew_0921.mat');
%     MultiSessEventData{cfff} = FieldEventDataAlls_EO;
    
    FieldNum = size(FieldEventDataAlls_EO,1);
    FieldRealShufIndex = cell(FieldNum,1);
    for cf = 1 : FieldNum
        Field1DataRealIndex = mean(FieldEventDataAlls_EO{cf,4});
        Field1DataShufIndex = FieldEventDataAlls_EO{cf,5};
        FieldRealShufIndex{cf} = [Field1DataRealIndex(:),Field1DataShufIndex(:)];
    end
    EventSyncFrac_EO{cfff} = FieldRealShufIndex;
    % end of processing
    
%     cPathROIDataAll = load(fullfile(cfFullPath,'AllFieldDatasNew_1201.mat'));
%     
%     cFieldSynIndex = cellfun(@(x) Popu_synchrony_fun(x),cPathROIDataAll.FieldDatas_AllCell(:,1));
%     PopuFieldSynchrony_all{cfff,1} = cFieldSynIndex;
%     
%     [FieldCoefDataAlls,SessSynchronyIndex_All] = CorrDataProcessFun_FieldSep(cfFullPath,'AllFieldDatasNew_1201.mat','CorrCoefDataNew_0921.mat');
%     PopuFieldSynchrony_all{cfff,2} = SessSynchronyIndex_All;
%     SepMultiSessCoefData{cfff} = FieldCoefDataAlls;
%     
%     [FieldCoef_EventOnly,SessSynchrony_EventOnly] = CorrDataProcessFun_EventOnly(cfFullPath,'AllFieldDatasNew_1201.mat','CorrCoefDataNew_0921.mat');
%     EventOnlyFieldSynchrony_all{cfff,1} = SessSynchrony_EventOnly;
%     Sess_eventOnlyCoefData{cfff} = FieldCoef_EventOnly;
    
%     [StartInd,EndInd] = regexp(cfName,'2019\d{4}_xsn');
%     cPosStrName = cfName(StartInd:EndInd);
%     cSessFolderInds = strcmpi(cPosStrName,FolderNames_Cell);
%     MultiSessGenoType{cfff} = GenoType_Cell{cSessFolderInds};
end
%%
save(fullfile(SumSourPath,'p18_wtDataSummary.mat'),'MultiSessCoefData','EventSyncFrac','MultiSessEventData',...
    'PopuFieldSynchrony_all','EventOnlyFieldSynchrony_all','Sess_eventOnlyCoefData','EventSyncFrac_EO','-v7.3');
%% compare all coef values for twe types
% WTSessInds = strcmpi('wt',MultiSessGenoType);
% WTSessData_Cell = MultiSessCoefData(WTSessInds);
% TgSessData_Cell = MultiSessCoefData(~WTSessInds);
cclr
[WTDataFn,WTDataPath,~] = uigetfile('*wtDataSummary.mat','Select WT data');
[TgDataFn,TgDataPath,~] = uigetfile('*tgDataSummary.mat','Select Tg data');
%% load coef datas
WTDataCoef = load(fullfile(WTDataPath,WTDataFn),'MultiSessCoefData','Sess_eventOnlyCoefData');
% WTSessData_Cell = WTDataCoef.MultiSessCoefData;
WTSessData_Cell = WTDataCoef.Sess_eventOnlyCoefData;


TgDataCoef = load(fullfile(TgDataPath,TgDataFn),'MultiSessCoefData','Sess_eventOnlyCoefData');
TgSessData_Cell = TgDataCoef.Sess_eventOnlyCoefData;
% TgSessData_Cell = TgDataCoef.MultiSessCoefData;

%%
WTSessAllCoefData = cellfun(@(x) squeeze(x(:,1,1)),WTSessData_Cell,'uniformoutput',false);
WTSessAllDissData = cellfun(@(x) squeeze(x(:,2,1)),WTSessData_Cell,'uniformoutput',false);

TgSessAllCoefData = cellfun(@(x) squeeze(x(:,1,1)),TgSessData_Cell,'uniformoutput',false);
TgSessAllDissData = cellfun(@(x) squeeze(x(:,2,1)),TgSessData_Cell,'uniformoutput',false);

WTSessAllCoef_sum_cell = cat(1, WTSessAllCoefData{:});
WTSessAllCoef_sum_Vec = cell2mat(WTSessAllCoef_sum_cell);
TgSessAllCoef_sum_cell = cat(1, TgSessAllCoefData{:});
TgSessAllCoef_sum_Vec = cell2mat(TgSessAllCoef_sum_cell);

WTSessAllDiss_sum_cell = cat(1, WTSessAllDissData{:});
WTSessAllDiss_sum_Vec = cell2mat(WTSessAllDiss_sum_cell); 
TgSessAllDiss_sum_cell = cat(1, TgSessAllDissData{:});
TgSessAllDiss_sum_Vec = cell2mat(TgSessAllDiss_sum_cell);

WTMeanCoefValues = cellfun(@mean,WTSessAllCoef_sum_cell);
TgMeanCoefValues = cellfun(@mean,TgSessAllCoef_sum_cell);

[WTBinMeanSEMData, WTBinAllCoef] = All2BinDatas(WTSessAllCoef_sum_Vec,WTSessAllDiss_sum_Vec,50);
[TgBinMeanSEMData, TgBinAllCoef]  = All2BinDatas(TgSessAllCoef_sum_Vec,TgSessAllDiss_sum_Vec,50);
%%
hf = figure('position',[100 100 1100 420]);
subplot(121);
hold on
[WT_y,WT_x] = ecdf(WTSessAllCoef_sum_Vec);
[Tg_y,Tg_x] = ecdf(TgSessAllCoef_sum_Vec);
cl1 = plot(WT_x,WT_y,'k','linewidth',1.4);
cl2 = plot(Tg_x,Tg_y,'r','linewidth',1.4);
Overp = ranksum(WTSessAllCoef_sum_Vec,TgSessAllCoef_sum_Vec);
title(sprintf('p = %.2e',Overp));
legend([cl1,cl2],{'WT','Tg'},'location','NorthWest','box','off');

subplot(122);
hold on
hl1 = errorbar(WTBinMeanSEMData(:,3),WTBinMeanSEMData(:,1),WTBinMeanSEMData(:,2),'Color','k','linewidth',1.5);
hl2 = errorbar(TgBinMeanSEMData(:,3),TgBinMeanSEMData(:,1),TgBinMeanSEMData(:,2),'Color','r','linewidth',1.5);
yscales = get(gca,'ylim');
PlotNum = min(length(WTBinAllCoef),length(TgBinAllCoef));
pValues = zeros(PlotNum,1);
for cBin = 1 : PlotNum
    [~,pp] = ttest2(WTBinAllCoef{cBin},TgBinAllCoef{cBin});
    if pp >= 0.05
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),num2str(pp,'%.2f'),'HorizontalAlignment','center');
    elseif pp< 0.05 && pp >= 0.01
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'*','FontSize',18,'HorizontalAlignment','center');
    elseif pp< 0.01 && pp >= 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'**','FontSize',18,'HorizontalAlignment','center');
    elseif pp < 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'***','FontSize',18,'HorizontalAlignment','center');
    end
    pValues(cBin) = pp;
end
legend([hl1,hl2],{'WT','Tg'},'location','SouthWest','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');
title('p12 old ')
%%
saveas(hf,'All pair noise correlation changes EventOnly');
saveas(hf,'All pair noise correlation changes EventOnly','png');
saveas(hf,'All pair noise correlation changes EventOnly','pdf');

%% active Ast correlation
% WTSessInds = strcmpi('wt',MultiSessGenoType);
% WTSessData_Cell = MultiSessCoefData(WTSessInds);
% TgSessData_Cell = MultiSessCoefData(~WTSessInds);
%%
WTSessActAst_AllNeuData = cellfun(@(x) squeeze(x(:,1,2)),WTSessData_Cell,'uniformoutput',false);
WTSessActAst_ANDisData = cellfun(@(x) squeeze(x(:,2,2)),WTSessData_Cell,'uniformoutput',false);

TgSessActAst_AllNeuData = cellfun(@(x) squeeze(x(:,1,2)),TgSessData_Cell,'uniformoutput',false);
TgSessActAst_ANDisData = cellfun(@(x) squeeze(x(:,2,2)),TgSessData_Cell,'uniformoutput',false);

WTSessActAst_AllNeu_sum_cell = cat(1, WTSessActAst_AllNeuData{:});
WTSessActAst_AllNeu_sum_Vec = cell2mat(WTSessActAst_AllNeu_sum_cell);
TgSessActAst_AllNeu_sum_cell = cat(1, TgSessActAst_AllNeuData{:});
TgSessActAst_AllNeu_sum_Vec = cell2mat(TgSessActAst_AllNeu_sum_cell);

WTSessActAst_ANDis_sum_cell = cat(1, WTSessActAst_ANDisData{:});
WTSessActAst_ANDis_sum_Vec = cell2mat(WTSessActAst_ANDis_sum_cell); 
TgSessActAst_ANDis_sum_cell = cat(1, TgSessActAst_ANDisData{:});
TgSessActAst_ANDis_sum_Vec = cell2mat(TgSessActAst_ANDis_sum_cell);

WTActAst_AllNeu_MeanCoefValues = cellfun(@mean,WTSessActAst_AllNeu_sum_cell);
TgActAst_AllNeu_MeanCoefValues = cellfun(@mean,TgSessActAst_AllNeu_sum_cell);

[WTBinMeanSEMData, WTBinActAst_AllNeu] = All2BinDatas(WTSessActAst_AllNeu_sum_Vec,WTSessActAst_ANDis_sum_Vec,50);
[TgBinMeanSEMData, TgBinActAst_AllNeu]  = All2BinDatas(TgSessActAst_AllNeu_sum_Vec,TgSessActAst_ANDis_sum_Vec,50);
%%
hf = figure('position',[100 100 1100 420]);
subplot(121);
hold on
[WT_y,WT_x] = ecdf(WTSessActAst_AllNeu_sum_Vec);
[Tg_y,Tg_x] = ecdf(TgSessActAst_AllNeu_sum_Vec);
cl1 = plot(WT_x,WT_y,'k','linewidth',1.4);
cl2 = plot(Tg_x,Tg_y,'r','linewidth',1.4);
Overp = ranksum(WTSessActAst_AllNeu_sum_Vec,TgSessActAst_AllNeu_sum_Vec);
title(sprintf('p = %.2e',Overp));
legend([cl1,cl2],{'WT','Tg'},'location','NorthWest','box','off');

subplot(122);
hold on
hl1 = errorbar(WTBinMeanSEMData(:,3),WTBinMeanSEMData(:,1),WTBinMeanSEMData(:,2),'Color','k','linewidth',1.5);
hl2 = errorbar(TgBinMeanSEMData(:,3),TgBinMeanSEMData(:,1),TgBinMeanSEMData(:,2),'Color','r','linewidth',1.5);
yscales = get(gca,'ylim');
PlotNum = min(length(WTBinActAst_AllNeu),length(TgBinActAst_AllNeu));
pValuesActAst_AllNeu = zeros(PlotNum,1);
for cBin = 1 : PlotNum
    [~,pp] = ttest2(WTBinActAst_AllNeu{cBin},TgBinActAst_AllNeu{cBin});
    if pp >= 0.05
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),num2str(pp,'%.2f'),'HorizontalAlignment','center');
    elseif pp< 0.05 && pp >= 0.01
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'*','FontSize',18,'HorizontalAlignment','center');
    elseif pp< 0.01 && pp >= 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'**','FontSize',18,'HorizontalAlignment','center');
    elseif pp < 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'***','FontSize',18,'HorizontalAlignment','center');
    end
    pValuesActAst_AllNeu(cBin) = pp;
end
legend([hl1,hl2],{'WT','Tg'},'location','SouthWest','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');
title('p12 old ActAst\_AllNeu')
%%
saveas(hf,'ActAst_AllNeu pair noise correlation changes EventOnly');
saveas(hf,'ActAst_AllNeu pair noise correlation changes EventOnly','png');
saveas(hf,'ActAst_AllNeu pair noise correlation changes EventOnly','pdf');

%% All neurons coef change

WTSessAllNeuData = cellfun(@(x) squeeze(x(:,1,4)),WTSessData_Cell,'uniformoutput',false);
WTSessAllNeu_DisData = cellfun(@(x) squeeze(x(:,2,4)),WTSessData_Cell,'uniformoutput',false);

TgSessAllNeuData = cellfun(@(x) squeeze(x(:,1,4)),TgSessData_Cell,'uniformoutput',false);
TgSessAllNeu_DisData = cellfun(@(x) squeeze(x(:,2,4)),TgSessData_Cell,'uniformoutput',false);

WTSessAllNeu_sum_cell = cat(1, WTSessAllNeuData{:});
WTSessAllNeu_sum_Vec = cell2mat(WTSessAllNeu_sum_cell);
TgSessAllNeu_sum_cell = cat(1, TgSessAllNeuData{:});
TgSessAllNeu_sum_Vec = cell2mat(TgSessAllNeu_sum_cell);

WTSessAllNeu_Dis_sum_cell = cat(1, WTSessAllNeu_DisData{:});
WTSessAllNeu_Dis_sum_Vec = cell2mat(WTSessAllNeu_Dis_sum_cell); 
TgSessAllNeu_Dis_sum_cell = cat(1, TgSessAllNeu_DisData{:});
TgSessAllNeu_Dis_sum_Vec = cell2mat(TgSessAllNeu_Dis_sum_cell);

WTAllNeu_MeanCoefValues = cellfun(@mean,WTSessAllNeu_sum_cell);
TgAllNeu_MeanCoefValues = cellfun(@mean,TgSessAllNeu_sum_cell);

[WTBinMeanSEMData, WTBinAllNeu] = All2BinDatas(WTSessAllNeu_sum_Vec,WTSessAllNeu_Dis_sum_Vec,50);
[TgBinMeanSEMData, TgBinAllNeu]  = All2BinDatas(TgSessAllNeu_sum_Vec,TgSessAllNeu_Dis_sum_Vec,50);
%%
hf = figure('position',[100 100 1100 420]);
subplot(121);
hold on
[WT_y,WT_x] = ecdf(WTSessAllNeu_sum_Vec);
[Tg_y,Tg_x] = ecdf(TgSessAllNeu_sum_Vec);
cl1 = plot(WT_x,WT_y,'k','linewidth',1.4);
cl2 = plot(Tg_x,Tg_y,'r','linewidth',1.4);
Overp = ranksum(WTSessAllNeu_sum_Vec,TgSessAllNeu_sum_Vec);
title(sprintf('p = %.2e',Overp));
legend([cl1,cl2],{'WT','Tg'},'location','NorthWest','box','off');

subplot(122);
hold on
hl1 = errorbar(WTBinMeanSEMData(:,3),WTBinMeanSEMData(:,1),WTBinMeanSEMData(:,2),'Color','k','linewidth',1.5);
hl2 = errorbar(TgBinMeanSEMData(:,3),TgBinMeanSEMData(:,1),TgBinMeanSEMData(:,2),'Color','r','linewidth',1.5);
yscales = get(gca,'ylim');
PlotNum = min(length(WTBinAllNeu),length(TgBinAllNeu));
pValuesAllNeu = zeros(PlotNum,1);
for cBin = 1 : PlotNum
    [~,pp] = ttest2(WTBinAllNeu{cBin},TgBinAllNeu{cBin});
    if pp >= 0.05
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),num2str(pp,'%.2f'),'HorizontalAlignment','center');
    elseif pp< 0.05 && pp >= 0.01
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'*','FontSize',18,'HorizontalAlignment','center');
    elseif pp< 0.01 && pp >= 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'**','FontSize',18,'HorizontalAlignment','center');
    elseif pp < 0.001
        text(WTBinMeanSEMData(cBin,3),0.95*yscales(2),'***','FontSize',18,'HorizontalAlignment','center');
    end
    pValuesAllNeu(cBin) = pp;
end
legend([hl1,hl2],{'WT','Tg'},'location','SouthWest','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');
title('p12 old AllNeu')
%%
saveas(hf,'AllNeu pair noise correlation changes');
saveas(hf,'AllNeu pair noise correlation changes','png');
saveas(hf,'AllNeu pair noise correlation changes','pdf');

%% pcocessing events frequency data for each individual neuron

% %% load datas for one animal types
% SumSourPath = 'E:\xnn_data\4Mdata_summary';
% WithinSourcePaths = dir(fullfile(SumSourPath,'*2019*'));
% FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
% UsedTargetFolder = WithinSourcePaths(FolderIndex);
% NumFolders = length(UsedTargetFolder);
% FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);
% FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
% 
% % cSession event analysis
% MultiSessEventData = cell(NumFolders,1);
% MultiSessGenoType = cell(NumFolders,1);
% EventSyncFrac = cell(NumFolders,1);
% for cfff = 1:NumFolders
%     cfName = FolderNames{cfff};
%     cfFullPath = FolderFullpaths{cfff};
%     FieldEventDataAlls = EventDataProcessFun(cfFullPath);
% %     SessionAllFieldDataStrc = load(fullfile(cfFullPath,'AllFieldDatasNew.mat'));
% %     SessionAllFieldDatas = SessionAllFieldDataStrc.FieldDatas_AllCell;
%     MultiSessEventData{cfff} = FieldEventDataAlls;
%     
%     FieldNum = size(FieldEventDataAlls,1);
%     FieldRealShufIndex = cell(FieldNum,1);
%     for cf = 1 : FieldNum
%         Field1DataRealIndex = mean(FieldEventDataAlls{cf,4});
%         Field1DataShufIndex = FieldEventDataAlls{cf,5};
%         FieldRealShufIndex{cf} = [Field1DataRealIndex(:),Field1DataShufIndex(:)];
%     end
%     EventSyncFrac{cfff} = FieldRealShufIndex;
%     
%     [StartInd,EndInd] = regexp(cfName,'2019\d{4}_xsn');
%     cPosStrName = cfName(StartInd:EndInd);
%     cSessFolderInds = strcmpi(cPosStrName,FolderNames_Cell);
%     MultiSessGenoType{cfff} = GenoType_Cell{cSessFolderInds};
% end

% [WTDataFn,WTDataPath,~] = uigetfile('*wtDataSummary.mat','Select WT data');
WTDataEvent = load(fullfile(WTDataPath,WTDataFn),'MultiSessEventData','EventSyncFrac','PopuFieldSynchrony_all',...
    'EventOnlyFieldSynchrony_all','EventSyncFrac_EO');
WTSess_EventData_Cell = WTDataEvent.MultiSessEventData;
WTEventIndexData_cell = WTDataEvent.EventSyncFrac_EO;
WT_popuSynchrony_All = WTDataEvent.PopuFieldSynchrony_all;
WT_popuSynchrony_EveOnly = WTDataEvent.EventOnlyFieldSynchrony_all;
if size(WT_popuSynchrony_EveOnly,2) == 2
    WT_popuSynchrony_EveOy = WT_popuSynchrony_EveOnly(:,2);
else
    WT_popuSynchrony_EveOy = WT_popuSynchrony_EveOnly;
end

% [TgDataFn,TgDataPath,~] = uigetfile('*tgDataSummary.mat','Select Tg data');
TgDataEvent = load(fullfile(TgDataPath,TgDataFn),'MultiSessEventData','EventSyncFrac','PopuFieldSynchrony_all',...
    'EventOnlyFieldSynchrony_all','EventSyncFrac_EO');
TgSess_EventData_Cell = TgDataEvent.MultiSessEventData;
TgEventIndexData_cell = TgDataEvent.EventSyncFrac_EO;
Tg_popuSynchrony_All = TgDataEvent.PopuFieldSynchrony_all;
Tg_popuSynchrony_EveOnly = TgDataEvent.EventOnlyFieldSynchrony_all;
if size(Tg_popuSynchrony_EveOnly,2) == 2
    Tg_popuSynchrony_EveOy = Tg_popuSynchrony_EveOnly(:,2);
else
    Tg_popuSynchrony_EveOy = Tg_popuSynchrony_EveOnly;
end

% WTSessInds = strcmpi('wt',MultiSessGenoType);
% WTSess_EventData_Cell = MultiSessEventData(WTSessInds);
% TgSess_EventData_Cell = MultiSessEventData(~WTSessInds);
%% compare populational synchrony values

WT_popuSynchronyVec = cell2mat(WT_popuSynchrony_All(:,1));
Tg_popuSynchronyVec = cell2mat(Tg_popuSynchrony_All(:,1));

PopuSynIndexMeanSEM = [mean(WT_popuSynchronyVec),std(WT_popuSynchronyVec)/sqrt(numel(WT_popuSynchronyVec));...
    mean(Tg_popuSynchronyVec),std(Tg_popuSynchronyVec)/sqrt(numel(Tg_popuSynchronyVec))];

[~,p1] = ttest2(WT_popuSynchronyVec,Tg_popuSynchronyVec);

HSynf = figure('position',[100 100 420 300]);
% ax1 = subplot(121);
hold on;
bar(1,PopuSynIndexMeanSEM(1,1),0.5,'FaceColor',[.7 .7 .7],'edgecolor','none');
bar(2,PopuSynIndexMeanSEM(2,1),0.5,'FaceColor','r','edgecolor','none');
errorbar([1 2],PopuSynIndexMeanSEM(:,1),PopuSynIndexMeanSEM(:,2),'k.','linewidth',1.5,'Marker','none');
GroupSigIndication([1,2],PopuSynIndexMeanSEM(:,1),p1,HSynf,1.15);
set(gca,'xlim',[0.4 2.6],'xtick',[1,2],'xticklabel',{'WT','tg'},'box','off');
ylabel('PeakNum');
title('p12 Popu Synchrony');
%%
saveas(HSynf,'PopuSynchrony index compare plots save');
saveas(HSynf,'PopuSynchrony index compare plots save','png');
saveas(HSynf,'PopuSynchrony index compare plots save','pdf');

%% compare populational synchrony using event-only trace

WT_popuSynchronyVecEO = cell2mat(cat(1,WT_popuSynchrony_EveOy{:,1}));
Tg_popuSynchronyVecEO = cell2mat(cat(1,Tg_popuSynchrony_EveOy{:,1}));

EOPopuSynIndexMeanSEM = [mean(WT_popuSynchronyVecEO),std(WT_popuSynchronyVecEO)/sqrt(numel(WT_popuSynchronyVecEO));...
    mean(Tg_popuSynchronyVecEO),std(Tg_popuSynchronyVecEO)/sqrt(numel(Tg_popuSynchronyVecEO))];

[~,p1] = ttest2(WT_popuSynchronyVecEO,Tg_popuSynchronyVecEO);

HSynf_EO = figure('position',[100 100 420 300]);
% ax1 = subplot(121);
hold on;
bar(1,EOPopuSynIndexMeanSEM(1,1),0.5,'FaceColor',[.7 .7 .7],'edgecolor','none');
bar(2,EOPopuSynIndexMeanSEM(2,1),0.5,'FaceColor','r','edgecolor','none');
errorbar([1 2],EOPopuSynIndexMeanSEM(:,1),EOPopuSynIndexMeanSEM(:,2),'k.','linewidth',1.5,'Marker','none');
GroupSigIndication([1,2],EOPopuSynIndexMeanSEM(:,1),p1,HSynf_EO,1.15);
set(gca,'xlim',[0.4 2.6],'xtick',[1,2],'xticklabel',{'WT','tg'},'box','off');
ylabel('PeakNum');
title('p12 EventOnly Popu Synchrony');
%% compare populational synchrony using event-only trace
saveas(HSynf_EO,'EventOnly PopuSynchrony index compare plots save');
saveas(HSynf_EO,'EventOnly PopuSynchrony index compare plots save','png');
saveas(HSynf_EO,'EventOnly PopuSynchrony index compare plots save','pdf');


%%
WTSess_EventData_all = cat(1,WTSess_EventData_Cell{:});
TgSess_EventData_all = cat(1,TgSess_EventData_Cell{:});

WTSess_EventData_CellVec = cat(1,WTSess_EventData_all{:,1});
WTSess_EventData_CellType = cat(1,WTSess_EventData_all{:,2});
WTSess_EventData_NeuInds = strcmpi(WTSess_EventData_CellType,'Neu');
WTSess_EventData_EventNum = cellfun(@(x) size(x,1),WTSess_EventData_CellVec);

TgSess_EventData_CellVec = cat(1,TgSess_EventData_all{:,1});
TgSess_EventData_CellType = cat(1,TgSess_EventData_all{:,2});
TgSess_EventData_NeuInds = strcmpi(TgSess_EventData_CellType,'Neu');
TgSess_EventData_EventNum = cellfun(@(x) size(x,1),TgSess_EventData_CellVec);

WTSess_EventData_FrameTime = cat(1,WTSess_EventData_all{:,3});
TgSess_EventData_FrameTime = cat(1,TgSess_EventData_all{:,3});
WTSess_EventData_FreqMin = WTSess_EventData_EventNum(:) ./ WTSess_EventData_FrameTime(:);
TgSess_EventData_FreqMin = TgSess_EventData_EventNum(:) ./ TgSess_EventData_FrameTime(:);

% processing WT data
% EventNum = 
WTNeu_EventFreq_Min = WTSess_EventData_FreqMin(WTSess_EventData_NeuInds);
WTAst_EventFreq_Min = WTSess_EventData_FreqMin(~WTSess_EventData_NeuInds);
[WTNeu_EventFreqy,WTNeu_EventFreqx] = ecdf(WTNeu_EventFreq_Min);
[WTAst_EventFreqy,WTAst_EventFreqx] = ecdf(WTAst_EventFreq_Min);

TgNeu_EventFreq_Min = TgSess_EventData_EventNum(TgSess_EventData_NeuInds);
TgAst_EventFreq_Min = TgSess_EventData_EventNum(~TgSess_EventData_NeuInds);
[TgNeu_EventFreqy,TgNeu_EventFreqx] = ecdf(TgNeu_EventFreq_Min);
[TgAst_EventFreqy,TgAst_EventFreqx] = ecdf(TgAst_EventFreq_Min);
%%
WT_Tg_Neu_p = ranksum(WTNeu_EventFreq_Min,TgNeu_EventFreq_Min);
hEventfreq = figure('position',[100 100 460 380]);
hold on
hwtl1 = plot(WTNeu_EventFreqx,WTNeu_EventFreqy,'Color','k','linewidth',1.4);
hwtl2 = plot(WTAst_EventFreqx,WTAst_EventFreqy,'Color','k','linewidth',1.4,'linestyle','--');
hwtl3 = plot(TgNeu_EventFreqx,TgNeu_EventFreqy,'Color','r','linewidth',1.4);
hwtl4 = plot(TgAst_EventFreqx,TgAst_EventFreqy,'Color','r','linewidth',1.4,'linestyle','--');
legend([hwtl1,hwtl2,hwtl3,hwtl4],{'WTNeu','WTAst','TgNeu','TgAst'},'location','southwest','box','off');
set(gca,'xlim',[-0.2 15],'ylim',[-0.05 1.05],'box','off');
xlabel('Events frequency (per Min.)');
ylabel('Fraction');
title(sprintf('p12 WT-Tg-Neu-p = %.2e',WT_Tg_Neu_p));
%%
saveas(hEventfreq,'Events frequency plots save');
saveas(hEventfreq,'Events frequency plots save','png');
saveas(hEventfreq,'Events frequency plots save','pdf');

%%
% event synchrony analysis
% EventSyncFrac
% WTSessInds = strcmpi('wt',MultiSessGenoType);

WTEventIndexData_FieldCell = cat(1,WTEventIndexData_cell{:});

TgEventIndexData_FieldCell = cat(1,TgEventIndexData_cell{:});

[WTAllPeak,WTAlllocs] = cellfun(@(x) EventIndexSyncPeakNum(x,180),WTEventIndexData_FieldCell,'UniformOutput',false);
[TgAllPeaks,TgAlllocs] = cellfun(@(x) EventIndexSyncPeakNum(x,180),TgEventIndexData_FieldCell,'UniformOutput',false);

WTFieldLocsNum = cellfun(@numel,WTAlllocs);
WTFieldPeakValue = cellfun(@mean,WTAllPeak);
TgFieldLocsNum = cellfun(@numel,TgAlllocs);
TgFieldPeakValue = cellfun(@mean,TgAllPeaks);

[~,p1] = ttest2(WTFieldLocsNum,TgFieldLocsNum);
[~,p2] = ttest2(WTFieldPeakValue,TgFieldPeakValue);

LocsNumMeanSEM = [mean(WTFieldLocsNum),std(WTFieldLocsNum)/sqrt(numel(WTFieldLocsNum));...
    mean(TgFieldLocsNum),std(TgFieldLocsNum)/sqrt(numel(TgFieldLocsNum))];
PeakFracValueMeanSEM = [mean(WTFieldPeakValue),std(WTFieldPeakValue)/sqrt(numel(WTFieldPeakValue));...
    mean(TgFieldPeakValue),std(TgFieldPeakValue)/sqrt(numel(TgFieldPeakValue))];

HHf = figure('position',[100 100 710 320]);
ax1 = subplot(121);
hold on;
bar(1,LocsNumMeanSEM(1,1),0.5,'FaceColor',[.7 .7 .7],'edgecolor','none');
bar(2,LocsNumMeanSEM(2,1),0.5,'FaceColor','r','edgecolor','none');
errorbar([1 2],LocsNumMeanSEM(:,1),LocsNumMeanSEM(:,2),'k.','linewidth',1.5,'Marker','none');
GroupSigIndication([1,2],LocsNumMeanSEM(:,1),p1,ax1,1.15);
set(gca,'xlim',[0.4 2.6],'xtick',[1,2],'xticklabel',{'WT','tg'},'box','off');
ylabel('PeakNum');
title('p12 Peak number');

ax2 = subplot(122);
hold on;
bar(1,PeakFracValueMeanSEM(1,1),0.5,'FaceColor',[.7 .7 .7],'edgecolor','none');
bar(2,PeakFracValueMeanSEM(2,1),0.5,'FaceColor','r','edgecolor','none');
errorbar([1 2],PeakFracValueMeanSEM(:,1),PeakFracValueMeanSEM(:,2),'k.','linewidth',1.5,'Marker','none');
GroupSigIndication([1,2],PeakFracValueMeanSEM(:,1),p2,ax2,1.15);
set(gca,'xlim',[0.4 2.6],'xtick',[1,2],'xticklabel',{'WT','tg'});
ylabel('PeakFrac');
title('p12 Peak sync fraction');
%%
% saveas(HHf,'P12 Sync Peak number and fraction compare plot');
% saveas(HHf,'P12 Sync Peak number and fraction compare plot','png');
% saveas(HHf,'P12 Sync Peak number and fraction compare plot','pdf');

saveas(HHf,'P12 EventOnly Sync Peak number and fraction compare plot');
saveas(HHf,'P12 EventOnly Sync Peak number and fraction compare plot','png');
saveas(HHf,'P12 EventOnly Sync Peak number and fraction compare plot','pdf');

%%
cfield = 9;
close;
IndexData = TgEventIndexData_FieldCell{cfield};
RealIndex = IndexData(:,1);
BaseValue = mean(IndexData(:,2));
% RealIndex(RealIndex < BaseValue) = BaseValue;
% RealIndex = smooth(RealIndex,5);
[Peaks,locs] = findpeaks(RealIndex,'MinPeakDistance',240,'MinPeakHeight',BaseValue*1.1);

hf = figure;
hold 
plot(IndexData(:,1),'c')
plot(RealIndex,'k');
text(locs,Peaks,'o','Color','r','linewidth',2);