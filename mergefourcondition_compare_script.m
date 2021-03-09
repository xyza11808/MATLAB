
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
%
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
CoefTypeStrs = {'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
WTNeuNeuCoefDataStrc = ...
    load('F:\wt_coefPlots\adultWTCoefDatas.mat');
TgNeuNeuCoefDataStrc = ...
    load('F:\tg_coefplots\adultTGCoefDatas.mat');
UsedDataType = 6; %2 indicates All Asts, 3 indicates All neurons
TypeStrs = CoefTypeStrs{UsedDataType};
WTDatas = WTNeuNeuCoefDataStrc.plotdatas(UsedDataType,:);
TgDatas = TgNeuNeuCoefDataStrc.plotdatas(UsedDataType,:);
%
[WT_ctrlBinMeanSEMData, WT_ctrlBinAllCoef] = All2BinDatas(...
    WTDatas{1},...
    WTDatas{2},50);
[WT_drugBinMeanSEMData, WT_drugBinAllCoef]  = All2BinDatas(...
    WTDatas{3},...
    WTDatas{4},50);

[TG_ctrlBinMeanSEMData, TG_ctrlBinAllCoef] = All2BinDatas(...
    TgDatas{1},...
    TgDatas{2},50);
[TG_drugBinMeanSEMData, TG_drugBinAllCoef]  = All2BinDatas(...
    TgDatas{3},...
    TgDatas{4},50);
%
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
title([TypeStrs,' coef'])
%%

saveas(hf,['Four condition ',TypeStrs,' 1SEM coef shadow plot']);
saveas(hf,['Four condition ',TypeStrs,' 1SEM coef shadow plot'],'png');
saveas(hf,['Four condition ',TypeStrs,' 1SEM coef shadow plot'],'pdf');

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
UsedDataTypes = 2; %{'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
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
Colors = [0,0,0;0.3,0.3,0.3;0.7,0.7,.7;1,0,0;0.8,0.3,0;0.7,0.3,0.3];
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
title('Astcoef')

%%

saveas(hfall,'Across group 1SEM coef plot');
saveas(hfall,'Across group 1SEM coef plot','png');
saveas(hfall,'Across group 1SEM coef plot','pdf');

%% event only population synchrony index plot

WTDatas = load('F:\wt_coefPlots\WTsynchronyDataEveO.mat');
TgDatas = load('F:\tg_coefplots\TgsynchronyDataEveO.mat');
%%
ROITypes = WTDatas.ROITypeStrs;
UsedTypeInds = 6;
TypeStr = ROITypes{UsedTypeInds};

WT_ctrl_Das = WTDatas.WT_popuSynchronyVecEO(:,UsedTypeInds);
WT_drug_Das = WTDatas.Tg_popuSynchronyVecEO(:,UsedTypeInds);

Tg_ctrl_Das = TgDatas.WT_popuSynchronyVecEO(:,UsedTypeInds);
Tg_drug_Das = TgDatas.Tg_popuSynchronyVecEO(:,UsedTypeInds);
Tg_drug_Das(isnan(Tg_drug_Das)) = [];

PlotAvgs = [mean(WT_ctrl_Das),mean(Tg_ctrl_Das),...
    mean(WT_drug_Das),mean(Tg_drug_Das)];
Plotfieldnums = [numel(WT_ctrl_Das),numel(Tg_ctrl_Das),...
    numel(WT_drug_Das),numel(Tg_drug_Das)];

PlotSEMs = [std(WT_ctrl_Das)/sqrt(Plotfieldnums(1)),...
    std(Tg_ctrl_Das)/sqrt(Plotfieldnums(2)),...
    std(WT_drug_Das)/sqrt(Plotfieldnums(3)),...
    std(Tg_drug_Das)/sqrt(Plotfieldnums(4))];

[~,ctrl_p] = ttest2(WT_ctrl_Das,Tg_ctrl_Das);
[~,drug_p] = ttest2(WT_drug_Das,Tg_drug_Das);

[~,wt_p] = ttest2(WT_ctrl_Das,WT_drug_Das);
[~,tg_p] = ttest2(Tg_ctrl_Das,Tg_drug_Das);

hsynf = figure('position',[100 100 450 320]);
hold on
colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
for ccp = 1 : 4
    bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
end
errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);

text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
    'HorizontalAlignment','center','Fontsize',8,'color','c');

GroupSigIndication([1,2],PlotAvgs(1:2),ctrl_p,hsynf,1.2,[],6);
GroupSigIndication([3,4],PlotAvgs(3:4),drug_p,hsynf,1.2,[],6);

GroupSigIndication([1,3],PlotAvgs([1,3]),wt_p,hsynf,1.4,[],6);
GroupSigIndication([2,4],PlotAvgs([2,4]),tg_p,hsynf,1.6,[],6);


set(gca,'xtick',1:4,'xticklabel',{'WTctrl','Tgctrl','WTdrug','Tgdrug'},'xlim',[0 5]);
ylabel('Synchrony index');
title(TypeStr);

%
saveas(hsynf,['Four condition ',TypeStr,' SynchronyIndex compare plot']);
saveas(hsynf,['Four condition ',TypeStr,' SynchronyIndex compare plot'],'png');
saveas(hsynf,['Four condition ',TypeStr,' SynchronyIndex compare plot'],'pdf');



