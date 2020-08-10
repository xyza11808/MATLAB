% field-wise events frequency plot
WTSess_EventData_all = cat(1,WTSess_EventData_Cell{:});
TgSess_EventData_all = cat(1,TgSess_EventData_Cell{:});

[WTAllNeu_EventFreqC, WTAllAst_EventFreqC] = ...
    cellfun(@(x,y,z) SessEventAvgFun(x,y,z), WTSess_EventData_all(:,1),...
    WTSess_EventData_all(:,2), WTSess_EventData_all(:,3), ...
    'UniformOutput', false);
[TgAllNeu_EventFreqC, TgAllAst_EventFreqC] = ...
    cellfun(@(x,y,z) SessEventAvgFun(x,y,z), TgSess_EventData_all(:,1),...
    TgSess_EventData_all(:,2), TgSess_EventData_all(:,3), ...
    'UniformOutput', false);

% for all the four mtx, the first col is all ROI average, the second col is
% active neuron average
WTAllNeu_EventFreq = cell2mat(WTAllNeu_EventFreqC);
WTAllAst_EventFreq = cell2mat(WTAllAst_EventFreqC);

TgAllNeu_EventFreq = cell2mat(TgAllNeu_EventFreqC);
TgAllAst_EventFreq = cell2mat(TgAllAst_EventFreqC);

GroupIndex = [ones(size(WTAllNeu_EventFreq,1),1) ;...
    ones(size(WTAllAst_EventFreq,1),1) * 3; ...
    ones(size(TgAllNeu_EventFreq,1),1) * 2; ...
    ones(size(TgAllAst_EventFreq,1),1) * 4];
EventDatas = [WTAllNeu_EventFreq; WTAllAst_EventFreq;...
   TgAllNeu_EventFreq; TgAllAst_EventFreq];
%%
TypeStrs = {'WTNeu','TgNeu','WTAst','TgAst'};
[~,WT_Tg_Neu_p] = ttest2(WTAllNeu_EventFreq(:,1),TgAllNeu_EventFreq(:,1));
[~,WT_Tg_Ast_p] = ttest2(WTAllAst_EventFreq(:,1),TgAllAst_EventFreq(:,1));

[~,WT_Tg_Neu_Activep] = ttest2(WTAllNeu_EventFreq(:,2),TgAllNeu_EventFreq(:,2));
[~,WT_Tg_Ast_Activep] = ttest2(WTAllAst_EventFreq(:,2),TgAllAst_EventFreq(:,2));

hf = figure('position', [100 200 1400 420]);
Colors = [[.2 .2 .2];[1 0 0];[.7 .7 .7];[0.7 0.3 0.3]];
ax1 = subplot(121);
hold on
boxplot(EventDatas(:,1),GroupIndex,'widths',0.2,...
    'Colors',Colors,'Whisker',5); 
ylabel(ax1, 'Event Per. min');
Gr1MaxV = [max(WTAllNeu_EventFreq(:,1)),max(TgAllNeu_EventFreq(:,1))];
Gr2MaxV = [max(WTAllAst_EventFreq(:,1)),max(TgAllAst_EventFreq(:,1))];
GroupSigIndication([1,2], Gr1MaxV,...
    WT_Tg_Neu_p,ax1,1.1,[],6);
GroupSigIndication([3,4], Gr2MaxV,...
    WT_Tg_Ast_p,ax1,1.1,[],6);
Maxy_value = max(max(Gr1MaxV), max(Gr2MaxV));
set(ax1,'ylim',[0 Maxy_value*1.15+0.3])
set(ax1,'xtick',1:4,'xticklabel',TypeStrs','box','off','FontSize',12);
title('All ROI average');


ax2 = subplot(122);
hold on
boxplot(EventDatas(:,2),GroupIndex,'widths',0.2,...
    'Colors',Colors,'Whisker',5); 
ylabel(ax2, 'Event Per. min');
Gr1MaxV = [max(WTAllNeu_EventFreq(:,2)),max(TgAllNeu_EventFreq(:,2))];
Gr2MaxV = [max(WTAllAst_EventFreq(:,2)),max(TgAllAst_EventFreq(:,2))];
GroupSigIndication([1,2], Gr1MaxV,...
    WT_Tg_Neu_Activep,ax2,1.1,[],6);
GroupSigIndication([3,4], Gr2MaxV,...
    WT_Tg_Ast_Activep,ax2,1.1,[],6);
Maxy_value = max(max(Gr1MaxV), max(Gr2MaxV));
set(ax2,'ylim',[0 Maxy_value*1.15+0.3])
set(ax2,'xtick',1:4,'xticklabel',TypeStrs','box','off','FontSize',12);
title('Active ROI average');





