
AllPairInfoDatapath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\AreaCrossCorrPlots\PairedAreaCorrPlots';
% AllPairInfoDatapath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\AreaCrossCorrPlots\PairedAreaCorrPlots';
AllPairInfoDatafile = fullfile(AllPairInfoDatapath,'ResidueCCAAndInfoSummaryDatas.mat');
PairInfoDataStrc = load(AllPairInfoDatafile,'PairAllInfos', 'PairAllRawDatas', ...
    'PairAreaStrs','IsPairWithExcludeArea');
UsedPairInfos = PairInfoDataStrc.PairAllInfos(~PairInfoDataStrc.IsPairWithExcludeArea,[2,3,5,6]);
UsedPairBoundShifts = PairInfoDataStrc.PairAllInfos(~PairInfoDataStrc.IsPairWithExcludeArea,7);
% PairAllInfos(cPair, :) = {AllColorplotDatas,AllBaseInfo_avgData_basewin,AllBaseInfo_avgData_Afwin,...
%             AllColorplotDatas_Af,AllAfInfo_avgData_basewin,AllAfInfo_avgData_Afwin};
% DataDespStr = {'BTBVar A1','BTBVar A2','BTTrVar A1','BTTrVar A2',...
%             'ChBVar A1','ChBVar A2','ChTrVar A1','ChTrVar A2'};
UsedPairCorrs = PairInfoDataStrc.PairAllRawDatas(~PairInfoDataStrc.IsPairWithExcludeArea,:);
UsedPairStrs = PairInfoDataStrc.PairAreaStrs(~PairInfoDataStrc.IsPairWithExcludeArea,:);

NumUsedPairs = size(UsedPairInfos,1);

%%
cfigSaveFolder = fullfile(AllPairInfoDatapath,'Info_Avgtrace_plots');
if ~isfolder(cfigSaveFolder)
    mkdir(cfigSaveFolder)
end

%%
AllPairInfoDatas = cell(NumUsedPairs,4,2,2);
%%
AddInds = [0, 1];
DataAddedInds = [0, 2];
Typeprefix = {'Base','Af'};
    
for cP = 1 : NumUsedPairs
    hf = figure('position',[100 100 600 560]);
    
    BTBVar_Infos = cell(4,2);% base kernal and after response kernal
    ChoiceBVar_Infos = cell(4,2);
    cPair_boundsShift = UsedPairBoundShifts{cP};
    for cType = 1 : 2
        cP_base_BVarCorr = UsedPairCorrs{cP,1+DataAddedInds(cType)};
        cP_base_TrVarCorr = UsedPairCorrs{cP,2+DataAddedInds(cType)};
        [NumSess, NumComponents] = size(cP_base_BVarCorr);
        
        ax1 = subplot(3,2,1+AddInds(cType));
        hold on
        [~,~,hl1] = MeanSemPlot(cP_base_BVarCorr,[],ax1,[],[.7 .2 .2],...
            'linewidth',1.2,'Color','r');
        [~,~,hl2] = MeanSemPlot(cP_base_TrVarCorr,[],ax1,[],[.7 .7 .7],...
            'linewidth',1.2,'Color','k');
        set(ax1,'xlim',[0.5 NumComponents+0.5]);
        legend(ax1, [hl1 hl2],{sprintf('%sBVar',Typeprefix{cType}),sprintf('%sTrVar',Typeprefix{cType})},...
            'location','northeast','box','off','fontSize',8);
        if cType == 1
            title(ax1,sprintf('Area %s-%s CCA',UsedPairStrs{cP,1},UsedPairStrs{cP,2}));
        else
            title(ax1,sprintf('N = %d sessions',NumSess));
        end
        ylabel(ax1,'Coefficient');
        
        ax2 = subplot(3,2,3+AddInds(cType));
        hold on
        cP_baseinfo_BTBVar_basewin_A1 = UsedPairInfos{cP,1+DataAddedInds(cType)}{1};
        cP_baseinfo_BTBVar_basewin_A2 = UsedPairInfos{cP,1+DataAddedInds(cType)}{2};
        % cP_baseinfo_BTTrVar_basewin_A1 = UsedPairInfos{cP,1}{3};
        % cP_baseinfo_BTTrVar_basewin_A2 = UsedPairInfos{cP,1}{4};
        cP_baseinfo_BTBVar_Afwin_A1 = UsedPairInfos{cP,2+DataAddedInds(cType)}{1};
        cP_baseinfo_BTBVar_Afwin_A2 = UsedPairInfos{cP,2+DataAddedInds(cType)}{2};
        [~,~,hl1_1] = MeanSemPlot(cP_baseinfo_BTBVar_basewin_A1',[],ax2,0.25,[.7 .2 .2],...
            'linewidth',1.4,'Color','r');
        [~,~,hl2_1] = MeanSemPlot(cP_baseinfo_BTBVar_basewin_A2',[],ax2,0.25,[.7 .7 .7],...
            'linewidth',1.4,'Color','k');
        [~,~,hl1_2] = MeanSemPlot(cP_baseinfo_BTBVar_Afwin_A1',[],ax2,0.25,[.7 .2 .2],...
            'linewidth',1.4,'Color','r','linestyle','--');
        [~,~,hl2_2] = MeanSemPlot(cP_baseinfo_BTBVar_Afwin_A2',[],ax2,0.25,[.7 .7 .7],...
            'linewidth',1.4,'Color','k','linestyle','--');
        line(ax2,[0.5 NumComponents+0.5],[1 1],'Color',[.6 .6 .6],'linewidth',1,'linestyle','--');
        set(ax2,'xlim',[0.5 NumComponents+0.5]);
        legend(ax2, [hl1_1 hl2_1 hl1_2 hl2_2],{'BaseWinA1','BaseWinA2','AfWinA1','AfWinA2'},...
            'location','northeast','box','off','fontSize',8);
        ylabel(ax2,'Info (norm.)');
        title(ax2,sprintf('%sKernal BTinfo',Typeprefix{cType}));
        BTBVar_Infos(:,cType) = {cP_baseinfo_BTBVar_basewin_A1,cP_baseinfo_BTBVar_basewin_A2,...
            cP_baseinfo_BTBVar_Afwin_A1,cP_baseinfo_BTBVar_Afwin_A2};
        [~, BTinfo_maxInds] = cellfun(@(x) max(mean(x,2)),BTBVar_Infos(:,cType),'un',0);
        BTinfo_maxIndsInfo = cellfun(@(x,y) x(y,:),BTBVar_Infos(:,cType),BTinfo_maxInds,'un',0);
        BTinfo_maxIndsInfoMtx = cat(1,BTinfo_maxIndsInfo{:});
        
        ax3 = subplot(3,2,5+AddInds(cType));
        hold on
        cP_Chinfo_BTBVar_basewin_A1 = UsedPairInfos{cP,1+DataAddedInds(cType)}{5};
        cP_Chinfo_BTBVar_basewin_A2 = UsedPairInfos{cP,1+DataAddedInds(cType)}{6};
        % cP_baseinfo_BTTrVar_basewin_A1 = UsedPairInfos{cP,1}{3};
        % cP_baseinfo_BTTrVar_basewin_A2 = UsedPairInfos{cP,1}{4};
        cP_Chinfo_BTBVar_Afwin_A1 = UsedPairInfos{cP,2+DataAddedInds(cType)}{5};
        cP_Chinfo_BTBVar_Afwin_A2 = UsedPairInfos{cP,2+DataAddedInds(cType)}{6};
        [~,~,hl1_1] = MeanSemPlot(cP_Chinfo_BTBVar_basewin_A1',[],ax3,0.25,[.7 .2 .2],...
            'linewidth',1.4,'Color','r');
        [~,~,hl2_1] = MeanSemPlot(cP_Chinfo_BTBVar_basewin_A2',[],ax3,0.25,[.7 .7 .7],...
            'linewidth',1.4,'Color','k');
        [~,~,hl1_2] = MeanSemPlot(cP_Chinfo_BTBVar_Afwin_A1',[],ax3,0.25,[.7 .2 .2],...
            'linewidth',1.4,'Color','r','linestyle','--');
        [~,~,hl2_2] = MeanSemPlot(cP_Chinfo_BTBVar_Afwin_A2',[],ax3,0.25,[.7 .7 .7],...
            'linewidth',1.4,'Color','k','linestyle','--');
        % line(ax3,[0.5 NumComponents+0.5],[1 1],'Color',[.6 .6 .6],'linewidth',1,'linestyle','--');
        set(ax3,'xlim',[0.5 NumComponents+0.5]);
        legend(ax3, [hl1_1 hl2_1 hl1_2 hl2_2],{'BaseWinA1','BaseWinA2','AfWinA1','AfWinA2'},...
            'location','northeast','box','off','fontSize',8);
        xlabel(ax3,'# Components');
        ylabel(ax3,'Info (norm.)');
        title(ax3,sprintf('%sKernal Choiceinfo',Typeprefix{cType}));
        
        ChoiceBVar_Infos(:,cType) = {cP_Chinfo_BTBVar_basewin_A1,cP_Chinfo_BTBVar_basewin_A2,...
            cP_Chinfo_BTBVar_Afwin_A1,cP_Chinfo_BTBVar_Afwin_A2};
    end
    
%     figSavefile = fullfile(cfigSaveFolder,sprintf('Area %s-%s CCA and info trace',...
%         UsedPairStrs{cP,1},UsedPairStrs{cP,2}));
%     saveas(hf,figSavefile);
%     print(hf,figSavefile,'-dpng','-r300');
%     close(hf);
    
    AllPairInfoDatas(cP,:,:,1) = BTBVar_Infos;
    AllPairInfoDatas(cP,:,:,2) = ChoiceBVar_Infos;
    
end

%%
SumDataSavePath2 = fullfile(cfigSaveFolder,'AreaPair_infoTraceplot.mat');
save(SumDataSavePath2,'AllPairInfoDatas','UsedPairStrs','UsedPairCorrs','UsedPairBoundShifts','-v7.3');

%%
AllPairInfoDatas = cellfun(@single,AllPairInfoDatas,'un',0);
AllPairInfo_sessAvgs = cellfun(@(x) single(mean(x,2)),AllPairInfoDatas,'un',0);
[AllPairMaxInfoCell, AllPairMaxInds] = cellfun(@max,AllPairInfo_sessAvgs,'un',0);
AllPairMaxInfo = cell2mat(AllPairMaxInfoCell);
[~, AllPairIsSigp] = cellfun(@(x, y) ttest(x(y,:), 1, 'Tail','right'),AllPairInfoDatas, AllPairMaxInds);
AllPair_MaxBTInfo_BK = AllPairMaxInfo(:,:,1,1);
AllPair_MaxBTInfo_AK = AllPairMaxInfo(:,:,2,1);
AllPair_MaxChoiceInfo_BK = AllPairMaxInfo(:,:,1,2);
AllPair_MaxChoiceInfo_AK = AllPairMaxInfo(:,:,2,2);

%%
FourDataTypeStrs = {'Basekernal_BTinfo','Afkernal_BTinfo',...
    'Basekernal_Chinfo','Afkernal_Chinfo'};
FourTypeData = {AllPair_MaxBTInfo_BK,AllPair_MaxBTInfo_AK,...
    AllPair_MaxChoiceInfo_BK,AllPair_MaxChoiceInfo_AK};
FourTypeDataIsSig = {AllPairIsSigp(:,:,1,1),AllPairIsSigp(:,:,2,1),...
    AllPairIsSigp(:,:,1,2),AllPairIsSigp(:,:,2,2)};
AllnodeStr = unique(UsedPairStrs(:));
AllTypeStrs = {'BaseWinBTA1','BaseWinBTA2',...
    'AfterWinBTA1','AfterWinBTA2'};
InfoWeightScale = 1.5;
% RawPairStrs = cellfun(@(x,y) [x,'_',y],UsedPairStrs(:,1),UsedPairStrs(:,2),'un',0);

for cDataType = 1% : 4
    Baseh = figure('position',[100 100 800 640]);
    AllPair_MaxInfoData = FourTypeData{cDataType};
    AllPair_InfoIsSig = FourTypeDataIsSig{cDataType};
    for cA = 1 : 4
        ax1 = subplot(2,2,cA);
        
        AllPair_MaxBTinfo_BTBVar_BWA1 = AllPair_MaxInfoData(:,cA);
        AllPair_cTypeInfo_isSig = AllPair_InfoIsSig(:,cA);
        %     largeWeightsInds = AllPair_MaxBTinfo_BTBVar_BWA1>InfoWeightScale;
        largeWeightsInds = AllPair_MaxBTinfo_BTBVar_BWA1>0; % use all connections
        AFG1_sig = graph(UsedPairStrs(largeWeightsInds,1),UsedPairStrs(largeWeightsInds,2),...
        AllPair_MaxBTinfo_BTBVar_BWA1(largeWeightsInds));
        %     IsNodeExists = ismember(AllnodeStr,table2cell(AFG1_sig.Nodes));
        %     AFG1_sig = addnode(AFG1_sig,AllnodeStr(~IsNodeExists));
        AFG1_sig = rmnode(AFG1_sig,{'cc','aco'});
        graphNodeStrs = AFG1_sig.Edges.EndNodes;
        graphStr2RawIndex = cellfun(@(x,y) find(strcmpi(UsedPairStrs(:,1),x) & strcmpi(UsedPairStrs(:,2),y)|...
            strcmpi(UsedPairStrs(:,2),x) & strcmpi(UsedPairStrs(:,1),y)),...
            graphNodeStrs(:,1),graphNodeStrs(:,2));
        EdgeWeightsIsSig = AllPair_cTypeInfo_isSig(graphStr2RawIndex);
        AFhg_sig = plot(AFG1_sig,'layout','circle');
        GraphWeights = double(AFG1_sig.Edges.Weight); % this weights is not the same sequence as the raw input weights
        AFhg_sig.LineWidth = (GraphWeights - min(GraphWeights))/2+0.4;
%         if any(GraphWeights>InfoWeightScale)
        if any(EdgeWeightsIsSig < 0.05)
            deg_ranks = centrality(AFG1_sig,'degree','Importance',...
                double(EdgeWeightsIsSig < 0.05)); % pagerank,degree,eigenvector  {,'MaxIterations',1000}
        else
            deg_ranks = centrality(AFG1_sig,'degree','Importance',...
                GraphWeights); % pagerank,degree,eigenvector  {,'MaxIterations',1000}
        end
        rankRatio1 = 10/max(deg_ranks);
        AFhg_sig.MarkerSize = deg_ranks*rankRatio1+5;
        title(AllTypeStrs{cA});
%         if any(GraphWeights>InfoWeightScale)
        if any(EdgeWeightsIsSig < 0.05)
%             highlight(AFhg_sig,'Edges',find(GraphWeights > InfoWeightScale),'edgeColor','r');
            highlight(AFhg_sig,'Edges',find(EdgeWeightsIsSig < 0.05),'edgeColor','r');
        end
%         highlight(AFhg_sig,'Edges',find(GraphWeights <= InfoWeightScale),'linestyle','--');
        highlight(AFhg_sig,'Edges',find(EdgeWeightsIsSig >= 0.05),'linestyle','--');
        set(ax1,'box','off','xcolor','w','ycolor','w');
    end
    
    annotation('textbox',[0.02 0.43 0.1 0.1],'String',strrep(FourDataTypeStrs{cDataType},'_','\_'),...
        'FitBoxToText','on','Color','m');
    
    cFigSaveName = fullfile(cfigSaveFolder,sprintf('%s TypeInfo summary plots',...
        FourDataTypeStrs{cDataType}));
    
%     saveas(Baseh, cFigSaveName);
%     print(Baseh, cFigSaveName,'-dpng','-r350');
%     print(Baseh, cFigSaveName,'-dpdf','-bestfit');
%     close(Baseh);
end



%%
ax2 = subplot(122);
% AllnodeStr = unique(UsedPairStrs(:));
AllPair_MaxBTinfo_BTBVar_BWA2 = AllPair_MaxBTInfo_BK(:,2);
AFG1_sig2 = graph(UsedPairStrs(:,1),UsedPairStrs(:,2),AllPair_MaxBTinfo_BTBVar_BWA2);
IsNodeExists = ismember(AllnodeStr,table2cell(AFG1_sig2.Nodes));
AFG1_sig2 = addnode(AFG1_sig2,AllnodeStr(~IsNodeExists));
AFG1_sig2 = rmnode(AFG1_sig2,{'cc','aco'});
AFhg_sig2 = plot(AFG1_sig2,'layout','circle');
GraphWeights2 = AFG1_sig2.Edges.Weight; % this weights is not the same sequence as the raw input weights
AFhg_sig2.LineWidth = (GraphWeights2 - min(GraphWeights2))/2+0.4;
deg_ranks = centrality(AFG1_sig2,'degree','Importance',double(AFG1_sig2.Edges.Weight)); % pagerank,degree,eigenvector  {,'MaxIterations',1000}
rankRatio1 = 10/max(deg_ranks);
AFhg_sig2.MarkerSize = deg_ranks*rankRatio1+5;
title('BTinfo Area2');
% InfoWeightScale = 1.5;
highlight(AFhg_sig2,'Edges',find(GraphWeights2 > InfoWeightScale),'edgeColor','r');
highlight(AFhg_sig2,'Edges',find(GraphWeights2 <= InfoWeightScale),'linestyle','--');


%%
AllPairInfoDatapath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\AreaCrossCorrPlots\PairedAreaCorrPlots';
% AllPairInfoDatapath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\AreaCrossCorrPlots\PairedAreaCorrPlots';
AllPairInfoDatafile = fullfile(AllPairInfoDatapath,'ResidueCCAAndInfoSummaryDatas.mat');
PairInfoDataStrc = load(AllPairInfoDatafile,'PairAllInfos', 'PairAllRawDatas', ...
    'PairAreaStrs','IsPairWithExcludeArea','PairCorrDiffANDBTBVarInfo');
UsedPairInfos = PairInfoDataStrc.PairAllInfos(~PairInfoDataStrc.IsPairWithExcludeArea,[2,3,5,6]);
UsedPairBoundShifts = PairInfoDataStrc.PairAllInfos(~PairInfoDataStrc.IsPairWithExcludeArea,7);
% PairAllInfos(cPair, :) = {AllColorplotDatas,AllBaseInfo_avgData_basewin,AllBaseInfo_avgData_Afwin,...
%             AllColorplotDatas_Af,AllAfInfo_avgData_basewin,AllAfInfo_avgData_Afwin};
% DataDespStr = {'BTBVar A1','BTBVar A2','BTTrVar A1','BTTrVar A2',...
%             'ChBVar A1','ChBVar A2','ChTrVar A1','ChTrVar A2'};
UsedPairCorrs = PairInfoDataStrc.PairAllRawDatas(~PairInfoDataStrc.IsPairWithExcludeArea,:);
UsedPairStrs = PairInfoDataStrc.PairAreaStrs(~PairInfoDataStrc.IsPairWithExcludeArea,:);

NumUsedPairs = size(UsedPairInfos,1);
%
cfigSaveFolder = fullfile(AllPairInfoDatapath,'Info_Avgtrace_plots');
%% for PairInfoAboveThreshold plots
TypeDespStr = {'BiBw','BiAw','AiBw','AiAw'};
AvgPairCorrANDinfos = cat(2,PairCorrDiffANDBTBVarInfo{:,4});
AvgPairStrs = PairAreaStrs(~IsPairWithExcludeArea,:);
% baseinfo_basewin, baseinfo_Afwin
PairInfoAbove1Fracs = cellfun(@(x) mean(x(:,2) >= 1), AvgPairCorrANDinfos);
PairInfoAbove1InfoAvg = cellfun(@(x) mean(x(x(:,2) >= 1,2)), AvgPairCorrANDinfos,'un',0);
AllnodeStr = unique(AvgPairStrs(:));
BTFrach = figure('position',[100 100 800 640]);
AllGraphplotHandle = cell(4,1);
AllGraphs = cell(4,1);
for cA = 1 : 4
        ax1 = subplot(2,2,cA);
        cData_pairFracs = PairInfoAbove1Fracs(cA,:);
        UsedDataFracInds = cData_pairFracs > 0.2; %1e-6
        cUsedDataFracs = cData_pairFracs(UsedDataFracInds);
        cUsedDataPairStrs = AvgPairStrs(UsedDataFracInds,:);
        
        AllPair_MaxBTinfo_BTBVar_BWA1 = cUsedDataFracs;
        %     largeWeightsInds = AllPair_MaxBTinfo_BTBVar_BWA1>InfoWeightScale;
        largeWeightsInds = AllPair_MaxBTinfo_BTBVar_BWA1>0; % use all connections
        AFG1_sig = graph(cUsedDataPairStrs(largeWeightsInds,1),cUsedDataPairStrs(largeWeightsInds,2),...
        AllPair_MaxBTinfo_BTBVar_BWA1(largeWeightsInds));
        IsNodeExists = ismember(AllnodeStr,table2cell(AFG1_sig.Nodes));
        AFG1_sig = addnode(AFG1_sig,AllnodeStr(~IsNodeExists));
        AFG1_sig = rmnode(AFG1_sig,{'cc','aco'});
        graphNodeStrs = AFG1_sig.Edges.EndNodes;
        
        AFhg_sig = plot(AFG1_sig,'layout','circle');
        GraphWeights = double(AFG1_sig.Edges.Weight); % this weights is not the same sequence as the raw input weights
        AFhg_sig.LineWidth = (GraphWeights - min(GraphWeights))*5+0.4;

        deg_ranks = centrality(AFG1_sig,'degree','Importance',...
            GraphWeights); % pagerank,degree,eigenvector  {,'MaxIterations',1000}
        
        rankRatio1 = 10/max(deg_ranks);
        AFhg_sig.MarkerSize = deg_ranks*rankRatio1+5;
        title(TypeDespStr{cA});
        set(ax1,'box','off','xcolor','w','ycolor','w');
        AllGraphplotHandle{cA} = AFhg_sig;
        AllGraphs{cA} = AFG1_sig;
end
%%
AfNodeLabels = AllGraphplotHandle{1}.NodeLabel;
BaseNodeLabels = AllGraphplotHandle{2}.NodeLabel;

[~, Inds] = ismember(BaseNodeLabels, AfNodeLabels);

Af_xData = AllGraphplotHandle{1}.XData;
Af_yData = AllGraphplotHandle{1}.YData;

AllGraphplotHandle{2}.XData = Af_xData(Inds);
AllGraphplotHandle{2}.YData = Af_yData(Inds);

%%
AfNodeLabels = AllGraphplotHandle{3}.NodeLabel;
BaseNodeLabels = AllGraphplotHandle{4}.NodeLabel;

[~, Inds] = ismember(BaseNodeLabels, AfNodeLabels);

Af_xData = AllGraphplotHandle{3}.XData;
Af_yData = AllGraphplotHandle{3}.YData;

AllGraphplotHandle{4}.XData = Af_xData(Inds);
AllGraphplotHandle{4}.YData = Af_yData(Inds);



%%
cFigSaveName = fullfile(cfigSaveFolder,'SigBTInfo fraction graph plots');
    
saveas(BTFrach, cFigSaveName);
print(BTFrach, cFigSaveName,'-dpng','-r350');
print(BTFrach, cFigSaveName,'-dpdf','-bestfit');
close(BTFrach);




