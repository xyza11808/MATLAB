% find all target mats and load the data path

upperfoldpath = {'/Volumes/Seagate Backup Plus Drive/invivo_imaging_data_xnn_20191224_update20201110/p18_tg'};
NumUpperPath = length(upperfoldpath);
AllTargpathCell = cell(NumUpperPath,1);
for cpath = 1 : NumUpperPath
    ccpath = upperfoldpath{cpath};
    cd(ccpath);
    pathtargetpaths = dir('2021*xsn*done');
    Numtargetfile = length(pathtargetpaths);
    targfilecells = cell(Numtargetfile,3);
    for cNumtargpath = 1 : Numtargetfile
        
        targfilecells{cNumtargpath,1} = pathtargetpaths(cNumtargpath).name;
        targfilecells{cNumtargpath,2} = fullfile(ccpath,...
            targfilecells{cNumtargpath,1});
        if exist(fullfile(targfilecells{cNumtargpath,2},'AllFieldDatasNew_1201.mat'),'file')
            targfilecells{cNumtargpath,3} = 1;
        else
            targfilecells{cNumtargpath,3} = 0;
        end
    end
    AllTargpathCell{cpath} = targfilecells;
end

%%
DatapathCells = cat(1,AllTargpathCell{:});
IsTargPath = cell2mat(DatapathCells(:,3));
if mean(IsTargPath) < 1
    DatapathCells(IsTargPath < 1,:) = [];
end

FolderFullpaths = DatapathCells(:,2);
NumFolders = length(FolderFullpaths);

% %%
% PossDataPath = nameSplit(PossibleInds);
% 
% targetfolds = dir(fullfile(upperfoldpath,'2020*'));
% NumFolders = length(targetfolds);
% FolderFullpaths = cell(NumFolders,1);
% for cf = 1 : NumFolders
%     FolderFullpaths{cf} = fullfile(upperfoldpath,targetfolds(cf).name);
% end


%%
FieldRawDataAlls = cell(NumFolders,1);
for cfff = 1:NumFolders
%     cfName = FolderNames{cfff};
    cfFullPath = FolderFullpaths{cfff};
    
    FieldDatas = load(fullfile(cfFullPath,'AllFieldDatasNew_1201.mat'));
    FieldRawDataAlls{cfff} = FieldDatas.FieldDatas_AllCell(:,1);
    
end

%%
save FieldRawDataSummary_24sess.mat FieldRawDataAlls FolderFullpaths -v7.3

%% for wt and tg co-saved folders
cclr
[DataFn,DataPath,~] = uigetfile('*DataSummary.mat','Select 4M data');
FolderNameStrc = load(fullfile(DataPath,'FNamesSave.mat'));
FolderNameCells = FolderNameStrc.FolderNames;
WTStrInds = cellfun(@(x) ~isempty(strfind(x,'wt')),FolderNameCells);
%%
WTDataEvent = load(fullfile(DataPath,DataFn),'MultiSessEventData');
Data_Raw = load(fullfile(DataPath,'FieldRawDataSummary_24sess.mat'));

WTSess_EventData_Cell = WTDataEvent.MultiSessEventData(WTStrInds,:);
WTData_Raw = Data_Raw.FieldRawDataAlls(WTStrInds);

% TgDataEvent = load(fullfile(TgDataPath,TgDataFn),'MultiSessEventData');
TgSess_EventData_Cell = WTDataEvent.MultiSessEventData(~WTStrInds,:);
TgData_Raw = Data_Raw.FieldRawDataAlls(~WTStrInds);

%% for wt and tg seperated folded saved datas
% cclr
% [WTDataFn,WTDataPath,~] = uigetfile('*wtDataSummary.mat','Select WT data');
% [TgDataFn,TgDataPath,~] = uigetfile('*tgDataSummary.mat','Select Tg data');
% %%
% WTDataEvent = load(fullfile(WTDataPath,WTDataFn),'MultiSessEventData');
% Data_Raw_WT = load(fullfile(WTDataPath,'FieldRawDataSummary_24sess.mat'));
% 
% WTSess_EventData_Cell = WTDataEvent.MultiSessEventData;
% WTData_Raw = Data_Raw_WT.FieldRawDataAlls;
% 
% TgDataEvent = load(fullfile(TgDataPath,TgDataFn),'MultiSessEventData');
% Data_Raw_Tg = load(fullfile(TgDataPath,'FieldRawDataSummary_24sess.mat'));
% 
% % TgDataEvent = load(fullfile(TgDataPath,TgDataFn),'MultiSessEventData');
% TgSess_EventData_Cell = TgDataEvent.MultiSessEventData;
% TgData_Raw = Data_Raw_Tg.FieldRawDataAlls;



%%
cclr
[DataFn,DataPath,~] = uigetfile('NewAge_AllDataSummary*.mat','Select M4 data');
FNameData  = load(fullfile(DataPath,DataFn),'FolderNames');
% FolderNameStrc = load(fullfile(DataPath,'FNamesSave.mat'));
% for drug and control analysis
WTStrInds = cellfun(@(x) ~isempty(strfind(x,'wt')) & isempty(strfind(x,'drug')),FNameData.FolderNames); %ctrl
TgStrInds = cellfun(@(x) ~isempty(strfind(x,'wt')) & ~isempty(strfind(x,'drug')),FNameData.FolderNames); %drug
%

WTDataEvent = load(fullfile(DataPath,DataFn),'MultiSessEventData');
Data_Raw = load(fullfile(DataPath,'FieldRawDataSummary_merge.mat'));

WTSess_EventData_Cell = WTDataEvent.MultiSessEventData(WTStrInds,:);
WTData_Raw = Data_Raw.FieldRawDataAlls(WTStrInds);

% TgDataEvent = load(fullfile(TgDataPath,TgDataFn),'MultiSessEventData');
TgSess_EventData_Cell = WTDataEvent.MultiSessEventData(TgStrInds,:);
TgData_Raw = Data_Raw.FieldRawDataAlls(TgStrInds);

%%
WTSess_EventData_all = cat(1,WTSess_EventData_Cell{:});
TgSess_EventData_all = cat(1,TgSess_EventData_Cell{:});

WTSess_EventData_CellType = cat(1,WTSess_EventData_all{:,2});
WTSess_EventData_NeuInds = strcmpi(WTSess_EventData_CellType,'Neu');
TgSess_EventData_CellType = cat(1,TgSess_EventData_all{:,2});
TgSess_EventData_NeuInds = strcmpi(TgSess_EventData_CellType,'Neu');

WTData_Raw_Cell = cat(1,WTData_Raw{:});
TgData_Raw_Cell = cat(1,TgData_Raw{:});

WT_EventPeak_Alls = cellfun(@(x,y) EventPeaks_Fun(x,y),WTSess_EventData_all(:,1),...
    WTData_Raw_Cell,'UniformOutput',0);
Tg_EventPeak_Alls = cellfun(@(x,y) EventPeaks_Fun(x,y),TgSess_EventData_all(:,1),...
    TgData_Raw_Cell,'UniformOutput',0);
%%
WT_EventPeak_AllCell = cellfun(@mean,cat(1,WT_EventPeak_Alls{:}));
WT_naninds = isnan(WT_EventPeak_AllCell);
WT_EventPeak_AllCell(WT_naninds) = [];
WTSess_EventData_NeuInds(WT_naninds) = [];

Tg_EventPeak_AllCell = cellfun(@mean,cat(1,Tg_EventPeak_Alls{:}));
tg_nanInds = isnan(Tg_EventPeak_AllCell);
Tg_EventPeak_AllCell(tg_nanInds) = [];
TgSess_EventData_NeuInds(tg_nanInds) = [];
%%
WTNeu_EventAmp_Min = (WT_EventPeak_AllCell(WTSess_EventData_NeuInds));
WTAst_EventAmp_Min = (WT_EventPeak_AllCell(~WTSess_EventData_NeuInds));
[WTNeu_EventAmpy,WTNeu_EventAmpx] = ecdf(WTNeu_EventAmp_Min);
[WTAst_EventAmpy,WTAst_EventAmpx] = ecdf(WTAst_EventAmp_Min);
[WTNeu_EventAmp_Avgs,WTNeu_EventAmp_SEMs] = AvgSEMCalcu_Fun(WTNeu_EventAmp_Min);
[WTAst_EventAmp_Avgs,WTAst_EventAmp_SEMs] = AvgSEMCalcu_Fun(WTAst_EventAmp_Min);

TgNeu_EventAmp_Min = (Tg_EventPeak_AllCell(TgSess_EventData_NeuInds));
TgAst_EventAmp_Min = (Tg_EventPeak_AllCell(~TgSess_EventData_NeuInds));
[TgNeu_EventAmpy,TgNeu_EventAmpx] = ecdf(TgNeu_EventAmp_Min);
[TgAst_EventAmpy,TgAst_EventAmpx] = ecdf(TgAst_EventAmp_Min);
[TgNeu_EventAmp_Avgs,TgNeu_EventAmp_SEMs] = AvgSEMCalcu_Fun(TgNeu_EventAmp_Min);
[TgAst_EventAmp_Avgs,TgAst_EventAmp_SEMs] = AvgSEMCalcu_Fun(TgAst_EventAmp_Min);

EventAmpAvgAlls = [WTNeu_EventAmp_Avgs,TgNeu_EventAmp_Avgs,WTAst_EventAmp_Avgs,TgAst_EventAmp_Avgs];
EventAmpSEMAlls = [WTNeu_EventAmp_SEMs,TgNeu_EventAmp_SEMs,WTAst_EventAmp_SEMs,TgAst_EventAmp_SEMs];
TypeStrs = {'WTNeu','TgNeu','WTAst','TgAst'};

% WT_Tg_Neu_p = ranksum(WTNeu_EventAmp_Min,TgNeu_EventAmp_Min);
% WT_Tg_Ast_p = ranksum(WTAst_EventAmp_Min,TgAst_EventAmp_Min);
[~,WT_Tg_Neu_p] = ttest2(WTNeu_EventAmp_Min,TgNeu_EventAmp_Min);
[~,WT_Tg_Ast_p] = ttest2(WTAst_EventAmp_Min,TgAst_EventAmp_Min);

% save(fullfile(savepath,'p12EventAmpsave.mat'),'WTNeu_EventAmp_Min','TgNeu_EventAmp_Min',...
%     'WTAst_EventAmp_Min','TgAst_EventAmp_Min');
hEventAmp = figure('position',[100 100 460 380]);
hold on
hwtl1 = plot(WTNeu_EventAmpx,WTNeu_EventAmpy,'Color','k','linewidth',1.4);
hwtl2 = plot(WTAst_EventAmpx,WTAst_EventAmpy,'Color','k','linewidth',1.4,'linestyle','--');
hwtl3 = plot(TgNeu_EventAmpx,TgNeu_EventAmpy,'Color','r','linewidth',1.4);
hwtl4 = plot(TgAst_EventAmpx,TgAst_EventAmpy,'Color','r','linewidth',1.4,'linestyle','--');
legend([hwtl1,hwtl2,hwtl3,hwtl4],{'WTNeu','WTAst','TgNeu','TgAst'},'location','southwest','box','off');
% set(gca,'xlim',[-0.2 15],'ylim',[-0.05 1.05],'box','off');
xlabel('Events Peak Amplitude');
ylabel('Fraction');
title(sprintf('p12 WT-Tg-p = %.2e',WT_Tg_Neu_p));

GcaPos = get(gca,'position');
AxInsert = axes('position',[GcaPos(1)+GcaPos(3)*2/3,GcaPos(2)+0.1,GcaPos(3)/3,GcaPos(4)/2]);
hold(AxInsert, 'on');
Colors = {[.4 .4 .4],[1 0 0],[.7 .7 .7],[0.7 0.4 0.4]};
for cBar = 1 : 4
    bar(cBar,EventAmpAvgAlls(cBar),0.6,'EdgeColor','none','FaceColor',Colors{cBar});
end
errorbar(1:4,EventAmpAvgAlls,EventAmpSEMAlls,'k.','linewidth',1.4,'Marker','none');
set(AxInsert,'xtick',1:4,'xticklabel',TypeStrs','box','off','FontSize',8);
% xtickangle(AxInsert,-45);
ylabel(AxInsert,'\DeltaF/F');
GroupSigIndication([1,2],EventAmpAvgAlls(1:2),WT_Tg_Neu_p,AxInsert,1.1,[],6);
GroupSigIndication([3,4],EventAmpAvgAlls(3:4),WT_Tg_Ast_p,AxInsert,1.6,[],6);

%%

saveas(hEventAmp,'Cellwise Events peak amplitude plots save');
saveas(hEventAmp,'Cellwise Events peak amplitude plots save','png');
saveas(hEventAmp,'Cellwise Events peak amplitude plots save','pdf');