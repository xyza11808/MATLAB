function hf = ValidCorrPlots(ValidCorrsCell,DataDespStr,AreaNames,TimeWins)
% for TimeWins, the first input must be baseline valid times, and the
% second must be afterResp valid times.


if size(ValidCorrsCell,2) ~= 4
    return;
end

ShadowColors = {[0.2 0.2 0.5],[0.5 0.2 0.2],[.7 .7 .7],[.7 .7 .7]};
lineColors = {'r','b','k','k'};

hf = figure('position',[100 100 700 300]);
LegendObj = {[],[]};
LegendStrs = {{},{}};
axAll = gobjects(2, 1);
axAll(1) = subplot(121);
hold on
axAll(2) = subplot(122);
hold on
yscalesAll = zeros(4, 2);
for cA = 1 : 4
    cA_datas = permute(cat(3,ValidCorrsCell{:,cA}),[3,2,1]); % repeats, frames, components
    NumSessions = size(cA_datas, 1);
    cATypeStr = strrep(DataDespStr{cA},'Valid','');
    
    cPlotInds = 2-mod(cA, 2);
    ax = axAll(cPlotInds);
    
    [~,~,hl1] = MeanSemPlot(double(cA_datas(:,:,1)),TimeWins{cPlotInds},ax,1,ShadowColors{cA},...
        'Color',lineColors{cA},'linewidth',1.4);
    [~,~,hl2] = MeanSemPlot(double(cA_datas(:,:,2)),TimeWins{cPlotInds},ax,1,ShadowColors{cA},...
        'Color',lineColors{cA},'linewidth',1.4,'linestyle','--');
    
    LegendObj{cPlotInds} = [LegendObj{cPlotInds},[hl1,hl2]];
    LegendStrs{cPlotInds} = [LegendStrs{cPlotInds},{[cATypeStr,'-M1'],[cATypeStr,'-M2']}];
    yscalesAll(cA,:) = get(ax,'ylim');
end
ylabel(axAll(1),{AreaNames;'Coefficients'});
CommonYscales = [min(yscalesAll(:,1)),max(yscalesAll(:,2))];
for cAA = 1 : 2
    legend(axAll(cAA),LegendObj{cAA},LegendStrs{cAA},'location','NorthEast','box','off','FontSize',6,'autoupdate','off');
    line(axAll(cAA),[0 0],CommonYscales,'Color','c','linewidth',1,'linestyle','--');
    set(axAll(cAA),'ylim',CommonYscales);
    
end
title(axAll(1),sprintf('N = %d sessions',NumSessions));
