function [hf, TypeCorrDatas] = ValidCorrPlots(ValidCorrsCell,DataDespStr,AreaNames,TimeWins,CorrThresData, PlotAxess)
% for TimeWins, the first input must be baseline valid times, and the
% second must be afterResp valid times.
if ~exist('PlotAxess','var') || isempty(PlotAxess)
    
    hf = figure('position',[100 100 700 300]);
    axAll = gobjects(2, 1);
    axAll(1) = subplot(121);
    hold on
    axAll(2) = subplot(122);
    hold on
else
    axAll = PlotAxess;
    hf = [];
end
if size(ValidCorrsCell,2) ~= 4
    return;
end

ShadowColors = {[0.2 0.2 0.5],[0.5 0.2 0.2],[.7 .7 .7],[.7 .7 .7]};
lineColors = {'r','b','k','k'};

LegendObj = {[],[]};
LegendStrs = {{},{}};
    
yscalesAll = zeros(4, 2);
TypeCorrDatas = cell(4,2,2);
for cA = 1 : 4
    cA_datas = permute(cat(3,ValidCorrsCell{:,cA}),[3,2,1]); % Sessions, frames, components
    cA_Threshold = permute(cat(3,CorrThresData{:,cA}),[3,2,1]); % Sessions, frames, components
    PlottedThres = mean(cA_Threshold(:,:,1));
    NumSessions = size(cA_datas, 1);
    cATypeStr = strrep(DataDespStr{cA},'Valid','');
    
    TypeCorrDatas(cA,1,:) = {squeeze(mean(cA_datas(:,1:10,:),2)), squeeze(mean(cA_Threshold(:,1:10,:),2))};
    TypeCorrDatas(cA,2,:) = {squeeze(mean(cA_datas(:,11:20,:),2)), squeeze(mean(cA_Threshold(:,11:20,:),2))};
    
    cPlotInds = 2-mod(cA, 2);
    ax = axAll(cPlotInds);
    
    [~,~,hl1] = MeanSemPlot(double(cA_datas(:,:,1)),TimeWins{cPlotInds},ax,1,ShadowColors{cA},...
        'Color',lineColors{cA},'linewidth',1.4);
    [~,~,hl2] = MeanSemPlot(double(cA_datas(:,:,2)),TimeWins{cPlotInds},ax,1,ShadowColors{cA},...
        'Color',lineColors{cA},'linewidth',1.4,'linestyle','--');
    plot(TimeWins{cPlotInds}, PlottedThres,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
    
    LegendObj{cPlotInds} = [LegendObj{cPlotInds},[hl1,hl2]];
    LegendStrs{cPlotInds} = [LegendStrs{cPlotInds},{[cATypeStr,'-M1'],[cATypeStr,'-M2']}];
    yscalesAll(cA,:) = get(ax,'ylim');
end
ylabel(axAll(1),{AreaNames;'Coefficients'});
CommonYscales = [min(yscalesAll(:,1)),max(yscalesAll(:,2))+0.1];
for cAA = 1 : 2
    legend(axAll(cAA),LegendObj{cAA},LegendStrs{cAA},'location','NorthEast','box','off','FontSize',6,'autoupdate','off');
    line(axAll(cAA),[0 0],CommonYscales,'Color','c','linewidth',1,'linestyle','--');
    set(axAll(cAA),'ylim',CommonYscales);
    
end
title(axAll(1),sprintf('N = %d sessions',NumSessions));
