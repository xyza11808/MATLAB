function varargout = InfoCalPlotFun(Areawise_Info, BrainAreasStr, TypeStr, cA, PlotAxes)
if ~exist('PlotAxes','var') || isempty(PlotAxes)
    hf = figure('position',[100 100 580 160]);
    ax1 = subplot(131);
    hold on
    ax2 = subplot(132);
    hold on
    ax3 = subplot(133);
    hold on
    IsFigCreate = 1;
else
    IsFigCreate = 0;
   [ax1, ax2, ax3] = deal(PlotAxes{:}); 
end
UsedplsColNum = 5;
AreaDataInfos = cell(1, 5);

cA_RawDataInfo = cat(2, Areawise_Info{:,cA,1});
if ~isempty(cA_RawDataInfo)
    cA_RawShufInfo = cat(2, Areawise_Info{:,cA,2});
    cA_BaseSubInfo = cat(2, Areawise_Info{:,cA,3});
    cA_BaseSubShufInfo = cat(2, Areawise_Info{:,cA,4});
%     cA_AllUnitNums = cat(1, Areawise_Info{:,cA,5});
    
    NumSess = size(cA_RawDataInfo,2);
    %
    if NumSess >= 5 % enough sessions for comparison
        cA_RawDataInfo_used = cA_RawDataInfo(UsedplsColNum,:);
        cA_RawShufInfo_used = cA_RawShufInfo(UsedplsColNum,:);
        cA_BaseSubInfo_used = cA_BaseSubInfo(UsedplsColNum,:);
        cA_BaseSubShufInfo_used = cA_BaseSubShufInfo(UsedplsColNum,:);
        
        [~, p_RawComp] = ttest(cA_RawDataInfo_used, cA_BaseSubInfo_used);
        [~, p_ShufComp] = ttest(cA_RawShufInfo_used, cA_BaseSubShufInfo_used);
        [~, p_RatioComp] = ttest(cA_RawDataInfo_used./cA_BaseSubInfo_used, 1);
        
        cA_str = BrainAreasStr{cA};
        MaxInfoValue = max(max(cA_RawDataInfo_used),max(cA_BaseSubInfo_used));
        MaxShufInfoValue = max(max(cA_RawShufInfo_used),max(cA_BaseSubShufInfo_used));
        
        
%         ax1 = subplot(131);
%         hold on
        plot(ax1,[cA_RawDataInfo_used;cA_BaseSubInfo_used],'Color',[.7 .7 .7],'linewidth',0.8);
        plot(ax1,[1,2],[mean(cA_RawDataInfo_used),mean(cA_BaseSubInfo_used)],'Color','k','linewidth',1.5);
        %         yscales = get(ax1,'ylim');
        text(ax1,1.5, MaxInfoValue*1.1,num2str(p_RawComp,'p = %.2e'),'HorizontalAlignment','center','FontSize',6);
        set(ax1,'xlim',[0.5 2.5],'xticklabel',{'Raw','BaseSub'},'xtick',[1 2],'ylim',[0 MaxInfoValue*1.2],'FontSize',8);
        ylabel(ax1,sprintf('%s info (N = %d)',TypeStr, NumSess));
        title(ax1,sprintf('Area %s',cA_str));
        
        % center plot
        plot(ax2, [cA_RawShufInfo_used;cA_BaseSubShufInfo_used],'Color',[.7 .7 .7],'linewidth',0.8);
        plot(ax2, [1,2],[mean(cA_RawShufInfo_used),mean(cA_BaseSubShufInfo_used)],'Color','k','linewidth',1.5);
        %         yscales = get(ax2,'ylim');
        text(ax2, 1.5, MaxShufInfoValue*1.1,num2str(p_ShufComp,'p = %.2e'),'HorizontalAlignment','center','FontSize',6);
        set(ax2,'xlim',[0.5 2.5],'xticklabel',{'RawShuf','BSshuf'},'xtick',[1 2],'ylim',[0 MaxShufInfoValue*1.3],'FontSize',8);
        %         ylabel(ax2,sprintf('Choice info (N = %d)',NumSess));
        %         title(ax2,sprintf('Area %s',cA_str));
        
        Raw2BaseSubRatio = cA_RawDataInfo_used./cA_BaseSubInfo_used;
        RatioMeanSEM = [mean(Raw2BaseSubRatio),std(Raw2BaseSubRatio)/sqrt(NumSess)];
%         ax3 = subplot(133);
%         hold on
        plot(ax3, 1,Raw2BaseSubRatio,'o','MarkerEdgeColor',[.7 .7 .7],'MarkerSize',8,'MarkerFaceColor','none','linewidth',0.75);
        errorbar(ax3, 1.2 ,RatioMeanSEM(1),RatioMeanSEM(2),'ko','linewidth',1.2);
        %         yscales = get(ax3,'ylim');
        text(ax3, 1.3, max(Raw2BaseSubRatio)*1.1,num2str(p_RatioComp,'p = %.2e'),'HorizontalAlignment','left','FontSize',6);
        text(ax3, 1.3, max(Raw2BaseSubRatio)*0.9,sprintf('%.3f/%.4f',RatioMeanSEM(1),RatioMeanSEM(2)),...
            'HorizontalAlignment','left','FontSize',6);
        set(ax3,'xtick',1,'xticklabel',{'Raw2BSinfoRatio'},'xlim',[0.5 2],...
            'ylim',[min(Raw2BaseSubRatio)-0.1 max(Raw2BaseSubRatio)*1.15],'FontSize',8);
        %         ylabel(ax3,sprintf('Choice info (N = %d)',NumSess));
        title(ax3, sprintf('Info Ratio'));
        %
        %             cfigSavePath = fullfile(figSavePath16,sprintf('Area %s ChoiceInfo compare RawANDSub', cA_str));
        %             saveas(hf16, cfigSavePath);
        %             print(hf16, cfigSavePath, '-dpng','-r350');
        %             print(hf16, cfigSavePath, '-dpdf','-bestfit');
        %             close(hf16);
        
        AreaDataInfos = {cA_RawDataInfo_used, cA_BaseSubInfo_used, cA_RawShufInfo_used, ...
            cA_BaseSubShufInfo_used, Raw2BaseSubRatio};
    end
    
end

if IsFigCreate
    varargout = {AreaDataInfos, hf};
else
    varargout = {AreaDataInfos};
end