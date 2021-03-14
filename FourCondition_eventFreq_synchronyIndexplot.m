cclr

WTSyncIndexDataStrc = load('F:\WTDatas\WTSyncIndexDatas.mat');
TgSyncIndexDataStrc = load('F:\TgDatas\TgSyncIndexDatas.mat');
WTSessNameANDfnum = load('F:\WTDatas\WTSessfoldnameANDfnum.mat');
TgSessNameANDfnum = load('F:\TgDatas\TgSessfoldnameANDfnum.mat');
ExFieldsData = load('F:\excludedFields.mat');
UsedDataType = 2; % ROITypeStrs = {'AllROI','AllNeu','ActNeu','AllAst','ActAst','ActROIs'};
ROITypes = WTSyncIndexDataStrc.ROITypeStrs;
%%
% ROITypes = WTSyncIndexDataStrc;
WT_ctrlnames = WTSessNameANDfnum.WTFolderNames;
WT_drugnames = WTSessNameANDfnum.TgFolderNames;
Tg_ctrlnames = TgSessNameANDfnum.WTFolderNames;
Tg_drugnames = TgSessNameANDfnum.TgFolderNames;
%
[WT_ctrl_used,WT_ctrl_NotUsedInds] = ExFielddataSelect(WT_ctrlnames,cat(1,WTSyncIndexDataStrc.WT_popuSynchrony_EveOy{:}),...
    WTSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);

[WT_drug_used,WT_drug_NotUsedInds] = ExFielddataSelect(WT_drugnames,cat(1,WTSyncIndexDataStrc.Tg_popuSynchrony_EveOy{:}),...
    WTSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);

[Tg_ctrl_used,Tg_ctrl_NotUsedInds] = ExFielddataSelect(Tg_ctrlnames,cat(1,TgSyncIndexDataStrc.WT_popuSynchrony_EveOy{:}),...
    TgSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);

[Tg_drug_used,Tg_drug_NotUsedInds] = ExFielddataSelect(Tg_drugnames,cat(1,TgSyncIndexDataStrc.Tg_popuSynchrony_EveOy{:}),...
    TgSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);
%% extract plot data types
DataTypeNums = length(ROITypes);
for cT = 1 : DataTypeNums
    %
    cTDataStr = ROITypes{cT};
    
    WT_ctrl_Das = cell2mat(WT_ctrl_used(:,cT));
    WT_drug_Das = cell2mat(WT_drug_used(:,cT));
    Tg_ctrl_Das = cell2mat(Tg_ctrl_used(:,cT));
    Tg_drug_Das = cell2mat(Tg_drug_used(:,cT));
    
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
        text(ccp+0.3,PlotAvgs(ccp)+0.03,0.6,{num2str(PlotAvgs(ccp),'%.3f');num2str(PlotSEMs(ccp),'%.3f')});
    end
    errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);

    text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Fontsize',8,'color','c');

    GroupSigIndication([1,2],[max(PlotAvgs),max(PlotAvgs)],ctrl_p,hsynf,1.2,[],6);
    GroupSigIndication([3,4],[max(PlotAvgs),max(PlotAvgs)],drug_p,hsynf,1.2,[],6);

    GroupSigIndication([1,3],[max(PlotAvgs),max(PlotAvgs)],wt_p,hsynf,1.4,[],6);
    GroupSigIndication([2,4],[max(PlotAvgs),max(PlotAvgs)],tg_p,hsynf,1.5,[],6);


    set(gca,'xtick',1:4,'xticklabel',{'WTctrl','Tgctrl','WTdrug','Tgdrug'},'xlim',[0 5]);
    ylabel('Synchrony index');
    title(cTDataStr);
    
    saveas(hsynf,['Four condition ',cTDataStr,' SynchronyIndex compare plot']);
    saveas(hsynf,['Four condition ',cTDataStr,' SynchronyIndex compare plot'],'png');
    saveas(hsynf,['Four condition ',cTDataStr,' SynchronyIndex compare plot'],'pdf');
    close(hsynf);

end

%%
cclr
WTEventFreqStrc = load('F:\WTDatas\WTEventFreqDatas.mat');
TgEventFreqStrc = load('F:\TgDatas\TgEventFreqDatas.mat');
WTSessNameANDfnum = load('F:\WTDatas\WTSessfoldnameANDfnum.mat');
TgSessNameANDfnum = load('F:\TgDatas\TgSessfoldnameANDfnum.mat');
ExFieldsData = load('F:\excludedFields.mat');
UsedDataType = 2; % ROITypeStrs = {'AllROI','AllNeu','ActNeu','AllAst','ActAst','ActROIs'};
% ROITypes = WTSyncIndexDataStrc.ROITypeStrs;
%%
% ROITypes = WTSyncIndexDataStrc;
WT_ctrlnames = WTSessNameANDfnum.WTFolderNames;
WT_drugnames = WTSessNameANDfnum.TgFolderNames;
Tg_ctrlnames = TgSessNameANDfnum.WTFolderNames;
Tg_drugnames = TgSessNameANDfnum.TgFolderNames;

[WT_ctrl_used,WT_ctrl_NotUsedInds] = ExFielddataSelect(WT_ctrlnames,cat(1,WTEventFreqStrc.WTSess_EventData_Cell{:}),...
    WTSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);

[WT_drug_used,WT_drug_NotUsedInds] = ExFielddataSelect(WT_drugnames,cat(1,WTEventFreqStrc.TgSess_EventData_Cell{:}),...
    WTSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);

[Tg_ctrl_used,Tg_ctrl_NotUsedInds] = ExFielddataSelect(Tg_ctrlnames,cat(1,TgEventFreqStrc.WTSess_EventData_Cell{:}),...
    TgSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);

[Tg_drug_used,Tg_drug_NotUsedInds] = ExFielddataSelect(Tg_drugnames,cat(1,TgEventFreqStrc.TgSess_EventData_Cell{:}),...
    TgSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);

[WT_ctrlNeuEventFreq,WT_ctrlAstEventFreq] = EventFreqCalFun(WT_ctrl_used);
[WT_drugNeuEventFreq,WT_drugAstEventFreq] = EventFreqCalFun(WT_drug_used);
[Tg_ctrlNeuEventFreq,Tg_ctrlAstEventFreq] = EventFreqCalFun(Tg_ctrl_used);
[Tg_drugNeuEventFreq,Tg_drugAstEventFreq] = EventFreqCalFun(Tg_drug_used);

%% IF using fieldwise comparison
WT_ctrlNeuEventFreqDatas = cellfun(@(x) mean(x(x > 0)),WT_ctrlNeuEventFreq);
WT_drugNeuEventFreqDatas = cellfun(@(x) mean(x(x > 0)),WT_drugNeuEventFreq);
Tg_ctrlNeuEventFreqDatas = cellfun(@(x) mean(x(x > 0)),Tg_ctrlNeuEventFreq);
Tg_drugNeuEventFreqDatas = cellfun(@(x) mean(x(x > 0)),Tg_drugNeuEventFreq);

WT_ctrlAstEventFreqDatas = cellfun(@(x) mean(x(x > 0)),WT_ctrlAstEventFreq);
WT_drugAstEventFreqDatas = cellfun(@(x) mean(x(x > 0)),WT_drugAstEventFreq);
Tg_ctrlAstEventFreqDatas = cellfun(@(x) mean(x(x > 0)),Tg_ctrlAstEventFreq);
Tg_drugAstEventFreqDatas = cellfun(@(x) mean(x(x > 0)),Tg_drugAstEventFreq);

%% If not using fieldwise comparison
WT_ctrlNeuEventFreqDatas = cell2mat(WT_ctrlNeuEventFreq);
WT_ctrlNeuEventFreqDatas(WT_ctrlNeuEventFreqDatas < 1e-8) = [];
WT_drugNeuEventFreqDatas = cell2mat(WT_drugNeuEventFreq);
WT_drugNeuEventFreqDatas(WT_drugNeuEventFreqDatas < 1e-8) = [];
Tg_ctrlNeuEventFreqDatas = cell2mat(Tg_ctrlNeuEventFreq);
Tg_ctrlNeuEventFreqDatas(Tg_ctrlNeuEventFreqDatas < 1e-8) = [];
Tg_drugNeuEventFreqDatas = cell2mat(Tg_drugNeuEventFreq);
Tg_drugNeuEventFreqDatas(Tg_drugNeuEventFreqDatas < 1e-8) = [];

WT_ctrlAstEventFreqDatas = cell2mat(WT_ctrlAstEventFreq);
WT_ctrlAstEventFreqDatas(WT_ctrlAstEventFreqDatas < 1e-8) = [];
WT_drugAstEventFreqDatas = cell2mat(WT_drugAstEventFreq);
WT_drugAstEventFreqDatas(WT_drugAstEventFreqDatas < 1e-8) = [];
Tg_ctrlAstEventFreqDatas = cell2mat(Tg_ctrlAstEventFreq);
Tg_ctrlAstEventFreqDatas(Tg_ctrlAstEventFreqDatas < 1e-8) = [];
Tg_drugAstEventFreqDatas = cell2mat(Tg_drugAstEventFreq);
Tg_drugAstEventFreqDatas(Tg_drugAstEventFreqDatas < 1e-8) = [];

%%
hNeuf = FourGroupbarplots(WT_ctrlNeuEventFreqDatas,Tg_ctrlNeuEventFreqDatas,WT_drugNeuEventFreqDatas,...
    Tg_drugNeuEventFreqDatas);
ylabel('Event per Min.');
title('ActiveNeu')
% saveas(hNeuf,['Four condition Neu fieldwise eventFreq plot']);
% saveas(hNeuf,['Four condition Neu fieldwise eventFreq plot'],'png');
% saveas(hNeuf,['Four condition Neu fieldwise eventFreq plot'],'pdf');
saveas(hNeuf,['Four condition Neu eventFreq plot']);
saveas(hNeuf,['Four condition Neu eventFreq plot'],'png');
saveas(hNeuf,['Four condition Neu eventFreq plot'],'pdf');
close(hNeuf);
%%
hAstf = FourGroupbarplots(WT_ctrlAstEventFreqDatas,Tg_ctrlAstEventFreqDatas,WT_drugAstEventFreqDatas,...
    Tg_drugAstEventFreqDatas);
ylabel('Event per Min.');
title('ActiveAst')
% saveas(hAstf,['Four condition Ast fieldwise eventFreq plot']);
% saveas(hAstf,['Four condition Ast fieldwise eventFreq plot'],'png');
% saveas(hAstf,['Four condition Ast fieldwise eventFreq plot'],'pdf');
saveas(hAstf,['Four condition Ast eventFreq plot']);
saveas(hAstf,['Four condition Ast eventFreq plot'],'png');
saveas(hAstf,['Four condition Ast eventFreq plot'],'pdf');
close(hAstf);

%% event amplitude compare plots

cclr
WTEventFreqStrc = load('F:\WTDatas\WTEventAmpDatas.mat');
TgEventFreqStrc = load('F:\TgDatas\TgEventAmpDatas.mat');
WTSessNameANDfnum = load('F:\WTDatas\WTSessfoldnameANDfnum.mat');
TgSessNameANDfnum = load('F:\TgDatas\TgSessfoldnameANDfnum.mat');
ExFieldsData = load('F:\excludedFields.mat');
UsedDataType = 2; % ROITypeStrs = {'AllROI','AllNeu','ActNeu','AllAst','ActAst','ActROIs'};
% ROITypes = WTSyncIndexDataStrc.ROITypeStrs;
%%
% ROITypes = WTSyncIndexDataStrc;
WT_ctrlnames = WTSessNameANDfnum.WTFolderNames;
WT_drugnames = WTSessNameANDfnum.TgFolderNames;
Tg_ctrlnames = TgSessNameANDfnum.WTFolderNames;
Tg_drugnames = TgSessNameANDfnum.TgFolderNames;

[WT_ctrl_used,WT_ctrl_NotUsedInds] = ExFielddataSelect(WT_ctrlnames,cat(1,WTEventFreqStrc.WTSess_EventData_Cell{:}),...
    WTSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);
WT_ctrl_UsedAmp = WTEventFreqStrc.WT_EventPeak_Alls(WT_ctrl_NotUsedInds < 1);
[WT_drug_used,WT_drug_NotUsedInds] = ExFielddataSelect(WT_drugnames,cat(1,WTEventFreqStrc.TgSess_EventData_Cell{:}),...
    WTSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);
WT_drug_UsedAmp = WTEventFreqStrc.Tg_EventPeak_Alls(WT_drug_NotUsedInds < 1);
[Tg_ctrl_used,Tg_ctrl_NotUsedInds] = ExFielddataSelect(Tg_ctrlnames,cat(1,TgEventFreqStrc.WTSess_EventData_Cell{:}),...
    TgSessNameANDfnum.WTSessFieldNums,ExFieldsData.Excludedfields,[]);
Tg_ctrl_UsedAmp = TgEventFreqStrc.WT_EventPeak_Alls(Tg_ctrl_NotUsedInds < 1);
[Tg_drug_used,Tg_drug_NotUsedInds] = ExFielddataSelect(Tg_drugnames,cat(1,TgEventFreqStrc.TgSess_EventData_Cell{:}),...
    TgSessNameANDfnum.TgSessFieldNums,ExFieldsData.Excludedfields,[]);
Tg_drug_UsedAmp = TgEventFreqStrc.Tg_EventPeak_Alls(Tg_drug_NotUsedInds < 1);

WT_ctrl_CellType = cat(1,WT_ctrl_used{:,2});
WT_ctrl_NeuInds = strcmpi(WT_ctrl_CellType,'Neu');
WT_ctrl_ROIAmp = cellfun(@(x) mean(x),cat(1,WT_ctrl_UsedAmp{:}));

WT_drug_CellType = cat(1,WT_drug_used{:,2});
WT_drug_NeuInds = strcmpi(WT_drug_CellType,'Neu');
WT_drug_ROIAmp = cellfun(@(x) mean(x),cat(1,WT_drug_UsedAmp{:}));

Tg_ctrl_CellType = cat(1,Tg_ctrl_used{:,2});
Tg_ctrl_NeuInds = strcmpi(Tg_ctrl_CellType,'Neu');
Tg_ctrl_ROIAmp = cellfun(@(x) mean(x),cat(1,Tg_ctrl_UsedAmp{:}));

Tg_drug_CellType = cat(1,Tg_drug_used{:,2});
Tg_drug_NeuInds = strcmpi(Tg_drug_CellType,'Neu');
Tg_drug_ROIAmp = cellfun(@(x) mean(x),cat(1,Tg_drug_UsedAmp{:}));

%% not fieldwise
hNeuf = FourGroupbarplots(WT_ctrl_ROIAmp(~isnan(WT_ctrl_ROIAmp) & WT_ctrl_NeuInds),...
    Tg_ctrl_ROIAmp(~isnan(Tg_ctrl_ROIAmp) & Tg_ctrl_NeuInds),...
    WT_drug_ROIAmp(~isnan(WT_drug_ROIAmp) & WT_drug_NeuInds),...
    Tg_drug_ROIAmp(~isnan(Tg_drug_ROIAmp) & Tg_drug_NeuInds));
ylabel('Event per Min.');
title('ActiveNeu')
saveas(hNeuf,['Four condition Neu EventAmp plot']);
saveas(hNeuf,['Four condition Neu EventAmp plot'],'png');
saveas(hNeuf,['Four condition Neu EventAmp plot'],'pdf');
close(hNeuf);

%% not fieldwise
hAstf = FourGroupbarplots(WT_ctrl_ROIAmp(~isnan(WT_ctrl_ROIAmp) & ~WT_ctrl_NeuInds),...
    Tg_ctrl_ROIAmp(~isnan(Tg_ctrl_ROIAmp) & ~Tg_ctrl_NeuInds),...
    WT_drug_ROIAmp(~isnan(WT_drug_ROIAmp) & ~WT_drug_NeuInds),...
    Tg_drug_ROIAmp(~isnan(Tg_drug_ROIAmp) & ~Tg_drug_NeuInds));
ylabel('Event per Min.');
title('ActiveAst')
saveas(hAstf,['Four condition Ast EventAmp plot']);
saveas(hAstf,['Four condition Ast EventAmp plot'],'png');
saveas(hAstf,['Four condition Ast EventAmp plot'],'pdf');
close(hAstf);

%%
WT_ctrl_fAmpAvgs = fieldWiseAmpCal(WT_ctrl_UsedAmp,WT_ctrl_used);
WT_drug_fAmpAvgs = fieldWiseAmpCal(WT_drug_UsedAmp,WT_drug_used);
Tg_ctrl_fAmpAvgs = fieldWiseAmpCal(Tg_ctrl_UsedAmp,Tg_ctrl_used);
Tg_drug_fAmpAvgs = fieldWiseAmpCal(Tg_drug_UsedAmp,Tg_drug_used);

%% fieldwise
hNeuf = FourGroupbarplots(WT_ctrl_fAmpAvgs{1},Tg_ctrl_fAmpAvgs{1},...
    WT_drug_fAmpAvgs{1},Tg_drug_fAmpAvgs{1});
ylabel('Event per Min.');
title('ActiveNeu Amp')
saveas(hNeuf,['Four condition Neu EventAmp fieldwise plot']);
saveas(hNeuf,['Four condition Neu EventAmp fieldwise plot'],'png');
saveas(hNeuf,['Four condition Neu EventAmp fieldwise plot'],'pdf');
close(hNeuf);

%% fieldwise
hAstf = FourGroupbarplots(WT_ctrl_fAmpAvgs{2},Tg_ctrl_fAmpAvgs{2},...
    WT_drug_fAmpAvgs{2},Tg_drug_fAmpAvgs{2});
ylabel('Event per Min.');
title('ActiveAst Amp')
saveas(hAstf,['Four condition Ast EventAmp fieldwise plot']);
saveas(hAstf,['Four condition Ast EventAmp fieldwise plot'],'png');
saveas(hAstf,['Four condition Ast EventAmp fieldwise plot'],'pdf');
close(hAstf);


%% Run frequency calculation section before runing the followed section
%% IF using fieldwise comparison
WT_ctrlNeuActiveFrac = cellfun(@(x) mean((x > 0)),WT_ctrlNeuEventFreq);
WT_drugNeuActiveFrac = cellfun(@(x) mean((x > 0)),WT_drugNeuEventFreq);
Tg_ctrlNeuActiveFrac = cellfun(@(x) mean((x > 0)),Tg_ctrlNeuEventFreq);
Tg_drugNeuActiveFrac = cellfun(@(x) mean((x > 0)),Tg_drugNeuEventFreq);

WT_ctrlAstActiveFrac = cellfun(@(x) mean((x > 0)),WT_ctrlAstEventFreq);
WT_drugAstActiveFrac = cellfun(@(x) mean((x > 0)),WT_drugAstEventFreq);
Tg_ctrlAstActiveFrac = cellfun(@(x) mean((x > 0)),Tg_ctrlAstEventFreq);
Tg_drugAstActiveFrac = cellfun(@(x) mean((x > 0)),Tg_drugAstEventFreq);

NeuFracCells = {WT_ctrlNeuActiveFrac,WT_drugNeuActiveFrac,Tg_ctrlNeuActiveFrac,Tg_drugNeuActiveFrac};
Plotfieldnums = [numel(WT_ctrlNeuActiveFrac),numel(WT_drugNeuActiveFrac),...
        numel(Tg_ctrlNeuActiveFrac),numel(Tg_drugNeuActiveFrac)];
NeuFracAvgs = cellfun(@mean,NeuFracCells);
NeuFracStack = [NeuFracAvgs;1-NeuFracAvgs];
AstFracCells = {WT_ctrlAstActiveFrac,WT_drugAstActiveFrac,Tg_ctrlAstActiveFrac,Tg_drugAstActiveFrac};
AstFracAvgs = cellfun(@mean,AstFracCells);
AstFracStack = [AstFracAvgs;1-AstFracAvgs];

% Neu resp fraction plot
[~,ctrl_p] = ttest2(WT_ctrlNeuActiveFrac,Tg_ctrlNeuActiveFrac);
[~,drug_p] = ttest2(WT_drugNeuActiveFrac,Tg_drugNeuActiveFrac);

[~,wt_p] = ttest2(WT_ctrlNeuActiveFrac,WT_drugNeuActiveFrac);
[~,tg_p] = ttest2(Tg_ctrlNeuActiveFrac,Tg_drugNeuActiveFrac);

hsynf = figure('position',[100 100 960 320]);
ax1 = subplot(121);
hold on
% colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
% for ccp = 1 : 4
%     bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
%     text(ccp+0.3,PlotAvgs(ccp)+0.02,0.6,{num2str(PlotAvgs(ccp),'%.3f');num2str(PlotSEMs(ccp),'%.3f')});
% end
% errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);
bar(NeuFracStack','stack');
text(1:4,ones(4,1)*0.3,cellstr(num2str(Plotfieldnums(:),'%d')),...
    'HorizontalAlignment','center','Fontsize',8,'color','r');

GroupSigIndication([1,2],[1 1],ctrl_p,ax1,1.2,[],6);
GroupSigIndication([3,4],[1 1],drug_p,ax1,1.2,[],6);

GroupSigIndication([1,3],[1 1],wt_p,ax1,1.4,[],6);
GroupSigIndication([2,4],[1 1],tg_p,ax1,1.6,[],6);

set(gca,'xtick',1:4,'xticklabel',{'WTctrl','WTdrug','Tgctrl','Tgdrug'},'xlim',[0 5],'ylim',[0 1.8]);
title('Neu');

% Neu resp fraction plot
[~,Astctrl_p] = ttest2(WT_ctrlAstActiveFrac,Tg_ctrlAstActiveFrac);
[~,Astdrug_p] = ttest2(WT_drugAstActiveFrac,Tg_drugAstActiveFrac);

[~,Astwt_p] = ttest2(WT_ctrlAstActiveFrac,WT_drugAstActiveFrac);
[~,Asttg_p] = ttest2(Tg_ctrlAstActiveFrac,Tg_drugAstActiveFrac);
ax2 = subplot(122);
hold on
% colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
% for ccp = 1 : 4
%     bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
%     text(ccp+0.3,PlotAvgs(ccp)+0.02,0.6,{num2str(PlotAvgs(ccp),'%.3f');num2str(PlotSEMs(ccp),'%.3f')});
% end
% errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);
bar(AstFracStack','stack');
text(1:4,ones(4,1)*0.3,cellstr(num2str(Plotfieldnums(:),'%d')),...
    'HorizontalAlignment','center','Fontsize',8,'color','r');

GroupSigIndication([1,2],[1 1],Astctrl_p,ax2,1.2,[],6);
GroupSigIndication([3,4],[1 1],Astdrug_p,ax2,1.2,[],6);

GroupSigIndication([1,3],[1 1],Astwt_p,ax2,1.4,[],6);
GroupSigIndication([2,4],[1 1],Asttg_p,ax2,1.6,[],6);

set(gca,'xtick',1:4,'xticklabel',{'WTctrl','WTdrug','Tgctrl','Tgdrug'},'xlim',[0 5],'ylim',[0 1.8]);
title('Ast');
%%
saveas(hsynf,['Four condition active frac plot']);
saveas(hsynf,['Four condition active frac plot'],'png');
set(hsynf,'paperpositionmode','manual');
print('-dpdf','Four condition active frac plot.pdf','-painters')
% saveas(hsynf,['Four condition active frac plot'],'pdf');
close(hsynf);

%% distance wise correlation averaged plot
cclr
CoefTypeStrs = {'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
WTNeuNeuCoefDataStrc = ...
    load('F:\wt_coefPlots\adultWTCoefDatasNew.mat');
TgNeuNeuCoefDataStrc = ...
    load('F:\tg_coefplots\adultTGCoefDatasNew.mat');

%% added excluded fields if exists
ExFieldsData = load('F:\excludedFields.mat');
UsedDataType = 2; %2 indicates All Asts, 3 indicates All neurons
TypeStrs = CoefTypeStrs{UsedDataType};
WTDatas = WTNeuNeuCoefDataStrc.plotfieldWiseDatas(UsedDataType,:);
TgDatas = TgNeuNeuCoefDataStrc.plotfieldWiseDatas(UsedDataType,:);

WT_ctrlnames = WTNeuNeuCoefDataStrc.WTFolderNames;
WT_drugnames = WTNeuNeuCoefDataStrc.TgFolderNames;
Tg_ctrlnames = TgNeuNeuCoefDataStrc.WTFolderNames;
Tg_drugnames = TgNeuNeuCoefDataStrc.TgFolderNames;

[WT_ctrl_used,WT_ctrl_NotUsedInds] = ExFielddataSelect(WT_ctrlnames,WTDatas{1},...
    WTNeuNeuCoefDataStrc.WTSessFieldNums,ExFieldsData.Excludedfields,WTDatas{2});

[WT_drug_used,WT_drug_NotUsedInds] = ExFielddataSelect(WT_drugnames,WTDatas{3},...
    WTNeuNeuCoefDataStrc.TgSessFieldNums,ExFieldsData.Excludedfields,WTDatas{4});

[Tg_ctrl_used,Tg_ctrl_NotUsedInds] = ExFielddataSelect(Tg_ctrlnames,TgDatas{1},...
    TgNeuNeuCoefDataStrc.WTSessFieldNums,ExFieldsData.Excludedfields,TgDatas{2});

[Tg_drug_used,Tg_drug_NotUsedInds] = ExFielddataSelect(Tg_drugnames,TgDatas{3},...
    TgNeuNeuCoefDataStrc.TgSessFieldNums,ExFieldsData.Excludedfields,TgDatas{4});

%% not field wise
WT_ctrl_Coefs = cell2mat(WT_ctrl_used(:,1));
WT_ctrl_Dis = cell2mat(WT_ctrl_used(:,2));
WT_ctrl_UsedCoefs = WT_ctrl_Coefs(WT_ctrl_Dis < 100);

WT_drug_Coefs = cell2mat(WT_drug_used(:,1));
WT_drug_Dis = cell2mat(WT_drug_used(:,2));
WT_drug_UsedCoefs = WT_drug_Coefs(WT_drug_Dis < 100);

Tg_ctrl_Coefs = cell2mat(Tg_ctrl_used(:,1));
Tg_ctrl_Dis = cell2mat(Tg_ctrl_used(:,2));
Tg_ctrl_UsedCoefs = Tg_ctrl_Coefs(Tg_ctrl_Dis < 100);

Tg_drug_Coefs = cell2mat(Tg_drug_used(:,1));
Tg_drug_Dis = cell2mat(Tg_drug_used(:,2));
Tg_drug_UsedCoefs = Tg_drug_Coefs(Tg_drug_Dis < 100);
%% fieldwise calculation
WT_ctrl_UsedCoefs = cellfun(@(x,y) mean(x(y < 100)),WT_ctrl_used(:,1),WT_ctrl_used(:,2));
WT_drug_UsedCoefs = cellfun(@(x,y) mean(x(y < 100)),WT_drug_used(:,1),WT_drug_used(:,2));
Tg_ctrl_UsedCoefs = cellfun(@(x,y) mean(x(y < 100)),Tg_ctrl_used(:,1),Tg_ctrl_used(:,2));
Tg_drug_UsedCoefs = cellfun(@(x,y) mean(x(y < 100)),Tg_drug_used(:,1),Tg_drug_used(:,2));

% DataTypeNums = length(CoefTypeStrs);
% for cT = 1 : DataTypeNums
%     %
%     cTDataStr = CoefTypeStrs{cT};
    hsynf = FourGroupbarplots(WT_ctrl_UsedCoefs,Tg_ctrl_UsedCoefs,...
    WT_drug_UsedCoefs,Tg_drug_UsedCoefs);
    ylabel('Correlation coefficient');
    
    title(TypeStrs);
    
%     saveas(hsynf,['Four condition ',TypeStrs,' within 100um coef plot']);
%     saveas(hsynf,['Four condition ',TypeStrs,' within 100um coef plot'],'png');
%     saveas(hsynf,['Four condition ',TypeStrs,' within 100um coef plot'],'pdf');
%     close(hsynf);

% end

%% anova comparison of age, type, distance, genotype effects
WT_ctrl_Coefs = cell2mat(WT_ctrl_used(:,1));
WT_ctrl_Dis = cell2mat(WT_ctrl_used(:,2));
WTCtrlStrs = repmat({'WTctrl'},numel(WT_ctrl_Coefs),1);

WT_drug_Coefs = cell2mat(WT_drug_used(:,1));
WT_drug_Dis = cell2mat(WT_drug_used(:,2));
WTdrugStrs = repmat({'WTdrug'},numel(WT_drug_Coefs),1);

Tg_ctrl_Coefs = cell2mat(Tg_ctrl_used(:,1));
Tg_ctrl_Dis = cell2mat(Tg_ctrl_used(:,2));
TgctrlStrs = repmat({'Tgctrl'},numel(Tg_ctrl_Coefs),1);

Tg_drug_Coefs = cell2mat(Tg_drug_used(:,1));
Tg_drug_Dis = cell2mat(Tg_drug_used(:,2));
TgdrugStrs = repmat({'Tgdrug'},numel(Tg_drug_Coefs),1);

WTGroupstr = repmat({'WT'},numel(WT_drug_Coefs)+numel(WT_ctrl_Coefs),1);
TgGroupStrs = repmat({'Tg'},numel(Tg_drug_Coefs)+numel(Tg_ctrl_Coefs),1);


% AgeStrs = repmat()
% GenoTypeStr and values 
GenoTypeStrs = [WTGroupstr;TgGroupStrs];

% Treatment strs
TreatStrs = [repmat({'ctrl'},numel(WT_ctrl_Coefs),1);repmat({'drug'},numel(WT_drug_Coefs),1);...
    repmat({'ctrl'},numel(Tg_ctrl_Coefs),1);repmat({'drug'},numel(Tg_drug_Coefs),1)];

% Distance Values
Distances = [WT_ctrl_Dis;WT_drug_Dis;Tg_ctrl_Dis;Tg_drug_Dis];

% coef Values
Coefs = [WT_ctrl_Coefs;WT_drug_Coefs;Tg_ctrl_Coefs;Tg_drug_Coefs];

TermMtx = [1 0 0;...
    0 1 0;...
    0 0 1;...
    1 1 0];
%%
[p,tbl,stats,terms] = anovan(Coefs,{GenoTypeStrs,TreatStrs,Distances},'varnames',{'GenoType','Treatment','Distance'},...
    'continuous',[3],'model',TermMtx);





