
Data1Path = '/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/NewAge_AllDataSummary_formerSessions.mat';
Data2Path = '/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/NewAge_AllDataSummaryMerge.mat';

Data1Strc = load(Data1Path);
Data2Strc = load(Data2Path);
%%
FinalMergeData = struct();
Datafields = fieldnames(Data1Strc);
NumFields = length(Datafields);
for cf = 1 : NumFields
    FinalMergeData.(Datafields{cf}) = [...
        Data1Strc.(Datafields{cf}); ...
        Data2Strc.(Datafields{cf})];
    eval([Datafields{cf}, '=FinalMergeData.(Datafields{cf});']);
end

%%
% WTNeuNeuCoefDataStrc = ...
%     load('/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/WT_ctrl_drug_com/WTActAstNeu_wtCtrltgDrug.mat');
% TgNeuNeuCoefDataStrc = ...
%     load('/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/TG_ctrl_drug_com/TGActAstNeu_wtCtrltgDrug.mat');
WTNeuNeuCoefDataStrc = ...
    load('/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/WT_ctrl_drug_com/WTNeuNeu_wtCtrltgDrug.mat');
TgNeuNeuCoefDataStrc = ...
    load('/Users/xinyu/Documents/dataAll/Documents/xnnData_20201107/TG_ctrl_drug_com/TGNeuNeu_wtCtrltgDrug.mat');

%%
[WT_ctrlBinMeanSEMData, WT_ctrlBinAllCoef] = All2BinDatas(...
    WTNeuNeuCoefDataStrc.WTSessAllCoef_sum_Vec,...
    WTNeuNeuCoefDataStrc.WTSessAllDiss_sum_Vec,50);
[WT_drugBinMeanSEMData, WT_drugBinAllCoef]  = All2BinDatas(...
    WTNeuNeuCoefDataStrc.TgSessAllCoef_sum_Vec,...
    WTNeuNeuCoefDataStrc.TgSessAllDiss_sum_Vec,50);

[TG_ctrlBinMeanSEMData, TG_ctrlBinAllCoef] = All2BinDatas(...
    TgNeuNeuCoefDataStrc.WTSessAllCoef_sum_Vec,...
    TgNeuNeuCoefDataStrc.WTSessAllDiss_sum_Vec,50);
[TG_drugBinMeanSEMData, TG_drugBinAllCoef]  = All2BinDatas(...
    TgNeuNeuCoefDataStrc.TgSessAllCoef_sum_Vec,...
    TgNeuNeuCoefDataStrc.TgSessAllDiss_sum_Vec,50);
%%
hf = figure;
hold on
hl1 = errorbar(WT_ctrlBinMeanSEMData(:,3),WT_ctrlBinMeanSEMData(:,1),...
    WT_ctrlBinMeanSEMData(:,2),'Color','k','linewidth',1.5);
hl2 = errorbar(WT_drugBinMeanSEMData(:,3),WT_drugBinMeanSEMData(:,1),...
    WT_drugBinMeanSEMData(:,2),'Color','r','linewidth',1.5);
hl3 = errorbar(TG_ctrlBinMeanSEMData(:,3),TG_ctrlBinMeanSEMData(:,1),...
    TG_ctrlBinMeanSEMData(:,2),'Color','k','linewidth',1.5,'linestyle','--');
hl4 = errorbar(TG_drugBinMeanSEMData(:,3),TG_drugBinMeanSEMData(:,1),...
    TG_drugBinMeanSEMData(:,2),'Color','r','linewidth',1.5,'linestyle','--');  

legend([hl1,hl2,hl3,hl4],{'WTCtrl','WTDrug','TgCtrl','TgDrug'},'location','SouthWest','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');
title('p12ActAst-Neu coef')

%%
huf = figure;
hold on
h1 = plot_meanCaTrace(WT_ctrlBinMeanSEMData(:,1),...
    WT_ctrlBinMeanSEMData(:,2),WT_ctrlBinMeanSEMData(:,3),huf,[],...
    {'Color','k','linewidth',1.5});
h2 = plot_meanCaTrace(WT_drugBinMeanSEMData(:,1),...
    WT_drugBinMeanSEMData(:,2),WT_drugBinMeanSEMData(:,3),huf,[],...
    {'Color','r','linewidth',1.5});
h3 = plot_meanCaTrace(TG_ctrlBinMeanSEMData(:,1),...
    TG_ctrlBinMeanSEMData(:,2),TG_ctrlBinMeanSEMData(:,3),huf,[],...
    {'Color',[0.3 0.3 0.7],'linewidth',1.5});
h4 = plot_meanCaTrace(TG_drugBinMeanSEMData(:,1),...
    TG_drugBinMeanSEMData(:,2),TG_drugBinMeanSEMData(:,3),huf,[],...
    {'Color','m','linewidth',1.5});


legend([h1.meanPlot,h2.meanPlot,h3.meanPlot,h4.meanPlot],...
    {'WTCtrl','WTDrug','TgCtrl','TgDrug'},...
    'location','SouthWest','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');


% title('p12ActAst-Neu coef')
title('p12Neu-Neu coef (errorbar 1*SEM)')

%%

saveas(huf,'Four condition NeuNeu 1SEM coef shadow plot');
saveas(huf,'Four condition NeuNeu 1SEM coef shadow plot','png');
saveas(huf,'Four condition NeuNeu 1SEM coef shadow plot','pdf');

%%
p12Datastrc = load('p12CoefDisData.mat');
p18Datastrc = load('p18CoefDisData.mat');
M4Datastrc = load('4MCoefDisData.mat');
UsedDataTypes = 3; 
TypeStrAll = {'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
UsedTypeStr = TypeStrAll{UsedDataTypes};
%%
prefixs = {'p12','p18','M4'};
for cf = 1 : 3
    eval([prefixs{cf},'PlotData = ',prefixs{cf},'Datastrc.plotdatas(UsedDataTypes,:);']);
end

%%
prefix_WTAll = {'p12WT','p18WT','M4WT'};
prefix_TgAll = {'p12Tg','p18Tg','M4Tg'};

for cfix = 1 : 3
    eval(sprintf('[%sCoefBin,%sDisBin] = All2BinDatas(%sPlotData{1},%sPlotData{2},50);',...
        prefix_WTAll{cfix},prefix_WTAll{cfix},prefixs{cfix},prefixs{cfix}));
    eval(sprintf('[%sCoefBin,%sDisBin] = All2BinDatas(%sPlotData{3},%sPlotData{4},50);',...
        prefix_TgAll{cfix},prefix_TgAll{cfix},prefixs{cfix},prefixs{cfix}));
end

%%
AllPrefix = [prefix_WTAll,prefix_TgAll];
% Colors = linspecer(length(AllPrefix));
 
hlAll = [];
hfall = figure;
hold on
for cf = 1 : length(AllPrefix)
    mergestr = sprintf('hl1 = errorbar(%sCoefBin(:,3),%sCoefBin(:,1),%sCoefBin(:,2));',...
        AllPrefix{cf},AllPrefix{cf},AllPrefix{cf});
    eval(mergestr);
    set(hl1,'Color',Colors(cf,:),'linewidth',1.4);
    hlAll = [hlAll,hl1];
end
legend(hlAll,...
    AllPrefix,...
    'location','Northeast','box','off');
xlabel('Distance (um)');
ylabel('Noise coefficient');
title(UsedTypeStr)

%%

saveas(hfall,'Across group 1SEM coef plot');
saveas(hfall,'Across group 1SEM coef plot','png');
saveas(hfall,'Across group 1SEM coef plot','pdf');

%% three age group cumulative plot

[p12WT_y,p12WT_x] = ecdf(p12PlotData{1});
[p12Tg_y,p12Tg_x] = ecdf(p12PlotData{3});
[p18WT_y,p18WT_x] = ecdf(p18PlotData{1});
[p18Tg_y,p18Tg_x] = ecdf(p18PlotData{3});
[M4WT_y,M4WT_x] = ecdf(M4PlotData{1});
[M4Tg_y,M4Tg_x] = ecdf(M4PlotData{3});

prefix_WTAll = {'p12WT','p18WT','M4WT','p12Tg','p18Tg','M4Tg'};

Colors = [0,0,0;0.3,0.3,0.3;0.7,0.7,.7;1,0,0;1,0.6,0.4;0.5,0,0];
hf = figure('position',[100,200,420,340]);
hold on
hhl = [];
for cf = 1 : 6
    eval(sprintf('hl1 = plot(%s_x,%s_y,''Color'',Colors(cf,:),''linewidth'',1.2);',...
        prefix_WTAll{cf},prefix_WTAll{cf}));
    hhl = [hhl,hl1];
end
legend(hhl,prefix_WTAll','box','off','location','SouthEast');
set(gca,'ylim',[-0.02 1.02])
xlabel('Correlation coeeficient');
ylabel('Cumulative fraction');
title(UsedTypeStr);

%%

saveas(hf,sprintf('Cumulative correlation plot %s',UsedTypeStr));

saveas(hf,sprintf('Cumulative correlation plot %s',UsedTypeStr),'png');
saveas(hf,sprintf('Cumulative correlation plot %s',UsedTypeStr),'pdf');

%%
GrDataInds = [ones(numel(p12PlotData{1}),1);ones(numel(p18PlotData{1}),1)+1;ones(numel(M4PlotData{1}),1)+2];
GrDatas = [p12PlotData{1};p18PlotData{1};M4PlotData{1}];
figure;
boxplot(GrDatas,GrDataInds,'Labels',{'p12WT','p18WT','M4WT'})



%% p12 drug field corf cumulative plots
cclr
p12WTDataStrc = load('p12drugWTCoefDatas.mat');
p12TgDataStrc = load('p12drugTgCoefDatas.mat');
%%
CellTypeStrs = p12WTDataStrc.CoefTypeStrs;
PlotTypeIndex = 2; %2 indicates All Asts, 3 indicates All neurons
UsedTypeStr = CellTypeStrs{PlotTypeIndex};

%
p12WTData = p12WTDataStrc.plotdatas(PlotTypeIndex,:);
p12TgData = p12TgDataStrc.plotdatas(PlotTypeIndex,:);

p12WT_ctrlData = p12WTData{1};
p12WT_drugData = p12WTData{3};

p12Tg_ctrlData = p12TgData{1};
p12Tg_drugData = p12TgData{3};

%%

[p12WTctrl_y,p12WTctrl_x] = ecdf(p12WT_ctrlData);
[p12Tgctrl_y,p12Tgctrl_x] = ecdf(p12Tg_ctrlData);
[p12WTdrug_y,p12WTdrug_x] = ecdf(p12WT_drugData);
[p12Tgdrug_y,p12Tgdrug_x] = ecdf(p12Tg_drugData);


prefix_WTAll = {'WTctrl','WTdrug','Tgctrl','Tgdrug'};

Colors = [0,0,0;0.7,0.7,.7;1,0,0;0.5,0,0];
huf = figure('position',[100,200,420,340]);
hold on
hhl = [];
for cf = 1 : 4
    eval(sprintf('hl1 = plot(p12%s_x,p12%s_y,''Color'',Colors(cf,:),''linewidth'',1.2);',...
        prefix_WTAll{cf},prefix_WTAll{cf}));
    hhl = [hhl,hl1];
end
legend(hhl,prefix_WTAll','box','off','location','SouthEast');
set(gca,'ylim',[-0.02 1.02])
xlabel('Correlation coeeficient');
ylabel('Cumulative fraction');
title(UsedTypeStr);

%%
saveas(huf,sprintf('p12drug Cumulative correlation plot %s',UsedTypeStr));

saveas(huf,sprintf('p12drug Cumulative correlation plot %s',UsedTypeStr),'png');
saveas(huf,sprintf('p12drug Cumulative correlation plot %s',UsedTypeStr),'pdf');