cclr

% AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
% RegionScoresCell = readcell(AllenHScoreFullPath,'Range','F:F',...
%     'Sheet','hierarchy_all_regions');
IsCellMissing = cellfun(@(x) any(ismissing(x)),RegionScoresCell);
RegionScoresCell(IsCellMissing) = {NaN};
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

NanInds = isnan(RegionScoresUsed);
if any(NanInds)
    RegionScoresUsed(NanInds) = [];
    AllenRegionStrsModi(NanInds) = [];
end
% %%
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% % AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% 
% BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
%         'Sheet',1);
% BrainAreasStrCC = BrainAreasStrC(2:end);
% % BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
% BrainAreasStr = BrainAreasStrCC(~EmptyInds);
% 
% NumBrainAreas = length(BrainAreasStr);


%%
% SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary2\RegAreawiseFrac_noExStim.mat';
SelectiveAreaDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary2\RegAreawiseFrac_noExStim.mat';
AreaSelectFracStrc = load(SelectiveAreaDatafile,'AllAreaFracs','NEBrainStrs');

%%
NumBrainAreas = length(AreaSelectFracStrc.NEBrainStrs);
SelfBrainInds2Allen = nan(NumBrainAreas,3);

for cA = 1 : NumBrainAreas
    cA_brain_str = AreaSelectFracStrc.NEBrainStrs{cA};
    TF = matches(AllenRegionStrsModi,cA_brain_str,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        SelfBrainInds2Allen(cA,:) = [cA, AllenRegionInds, RegionScoresUsed(AllenRegionInds)];
    end
end

%%
ExistAreaInds = ~isnan(SelfBrainInds2Allen(:,1));
ExistAreaAllenScore = SelfBrainInds2Allen(ExistAreaInds,3);
ExistAreaFracsAll = AreaSelectFracStrc.AllAreaFracs(ExistAreaInds,:);

% hf = figure('position',[100 100 500 680]);
% hold on
% sc1 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,1),'ro','linewidth',1.2);
% sc2 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,2),'co','linewidth',1.2);
% sc3 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,3),'bo','linewidth',1.2);
% yscales = get(gca,'ylim');
% line([0 0],yscales,'Color','k','linestyle','--','linewidth',1.2);
% xlabel('Allen Score');
% ylabel('Selective ROI fraction');
% legend([sc1,sc2,sc3],{'Blocktype','Stim','Choice'},'location','northeastoutside','box','off');


TypeStrs = {'Blocktype','Stim','Choice'};
TypeColors = {'r','c','b'};
CorrStrs = {'','',''};
AHS_score_scale = [0 0];
h1f = figure('position',[100 100 500 680]);
hold on
for cType = 1 : 3
    
%     errorbar(cType_validData(:,3),cType_validData(:,4),cType_validData(:,5)*0.2,'o',...
%         'Color',TypeColors{cType},'linewidth',1.5);
    plot(ExistAreaAllenScore,ExistAreaFracsAll(:,cType),'o','Color',TypeColors{cType},...
        'linewidth',1.5);
    AHS_score_scale(1) = min(AHS_score_scale(1),min(ExistAreaAllenScore));
    AHS_score_scale(2) = max(AHS_score_scale(2),max(ExistAreaAllenScore));
    
    [r,p] = corr(ExistAreaAllenScore,ExistAreaFracsAll(:,cType));
    RStrs = sprintf('%s: R = %.3f, p = %.3f',TypeStrs{cType},r,p);
    CorrStrs{cType} = RStrs;
end
yscales = get(gca,'ylim');
line([0 0],yscales,'Color','k','linestyle','--','linewidth',1.2);
set(gca,'xlim',AHS_score_scale+[-0.1 0.1],'ylim',yscales+[-0.005 0]);
xlabel('Allen Hierarchy Score');
ylabel('Selective ROI fraction');
lg = legend({'Blocktype','Stim','Choice'},'location','northeastoutside','box','on');
lgPos = get(lg,'position');
set(lg,'position',lgPos + [0.05 0.04 0 0]);

annotation('textbox',[0.15 0.55 0.1 0.4],'String',CorrStrs(:),'FitBoxToText','on','Color','k')

%%
plotfigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\AHSScoreCorrplot\CC_TC_CT';
% plotfigSavePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\AHSScoreCorrplot\CC_TC_CT';

if ~isfolder(plotfigSavePath)
    mkdir(plotfigSavePath);
end

savename1 = fullfile(plotfigSavePath,'AHSScore with sigFraction plot');
saveas(h1f,savename1);
print(h1f,savename1,'-dpng','-r400');
print(h1f,savename1,'-dpdf','-bestfit');

%% ##############################################################################################
%%
SelectiveAreaDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary2\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
% SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary2\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
AreaSelectEVStrc = load(SelectiveAreaDatafile,'AreaSigUnit_TypeRespEV','BrainAreasStr','Area_RespMtxAll');

%% Selective unit explained variance plot

NumAllBrainAreas = length(AreaSelectEVStrc.BrainAreasStr);
SelfBrainInds2Allen2 = nan(NumAllBrainAreas,5,3); % for the third dimension, each is BT, Stim, Choice
AreaAllUnitEVs = cell(NumAllBrainAreas,3,2);
for cCol = 1 : 3
    for cA = 1 : NumAllBrainAreas
        if length(AreaSelectEVStrc.AreaSigUnit_TypeRespEV{cA,cCol}) >= 1 && (AreaSelectEVStrc.Area_RespMtxAll{cA,3}) >= 3 ...
            && size(AreaSelectEVStrc.Area_RespMtxAll{cA,1},1) >= 10
            cA_brain_str = AreaSelectEVStrc.BrainAreasStr{cA};
            TF = matches(AllenRegionStrsModi,cA_brain_str,'IgnoreCase',true);
            if any(TF)
                AllenRegionInds = find(TF);
                if length(AllenRegionInds) > 1
                    fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
                    continue;
                end
                cTypeEVar = AreaSelectEVStrc.AreaSigUnit_TypeRespEV{cA,cCol};
                AreaAllUnitEVs(cA,cCol,:) = {cTypeEVar,RegionScoresUsed(AllenRegionInds)*ones(numel(cTypeEVar),1)};
                if length(cTypeEVar) < 3
                    SelfBrainInds2Allen2(cA,:,cCol) = [cA, AllenRegionInds, ...
                        RegionScoresUsed(AllenRegionInds),mean(cTypeEVar),0];
                else
                    SelfBrainInds2Allen2(cA,:,cCol) = [cA, AllenRegionInds, ...
                        RegionScoresUsed(AllenRegionInds),mean(cTypeEVar),std(cTypeEVar)/sqrt(numel(cTypeEVar))];
                end
            end
        end
    end
end
%% line plot for coarse classification comparison
TypeStrs = {'Blocktype','Stim','Choice'};
TypeScorewiseDataCell = cell(3,2);
TypeScorewiseData = zeros(3,4,2);
pStrings = cell(3,1);
for cType = 1 : 3
    cTypeDatas = SelfBrainInds2Allen2(:,:,cType);
    ValidAreaInds = ~isnan(cTypeDatas(:,1));
    cType_validData = cTypeDatas(ValidAreaInds,:);
    cT_AllUnitEVs = squeeze(AreaAllUnitEVs(ValidAreaInds,cType,:));
    
%     cT_AllEVs_Values = cat(1,cT_AllUnitEVs{:,1});
%     cT_AllEVs_Scores = cat(1,cT_AllUnitEVs{:,2});
    cT_AllEVs_Values = cellfun(@mean,cT_AllUnitEVs(:,1));
    cT_AllEVs_Scores = cellfun(@mean,cT_AllUnitEVs(:,2));
    
    LowScoreInds = cT_AllEVs_Scores < 0.2;
    LowData = cT_AllEVs_Values(LowScoreInds);
    HighData = cT_AllEVs_Values(~LowScoreInds);
    TypeScorewiseDataCell(cType,:) = {LowData,HighData};
    [~,p] = ttest2(LowData,HighData);
    
    TypeScorewiseData(cType,:,1) = [mean(LowData),std(LowData)/sqrt(numel(LowData)),numel(LowData),p];
    TypeScorewiseData(cType,:,2) = [mean(HighData),std(HighData)/sqrt(numel(HighData)),numel(HighData),p];
    if p > 0.05
        pStrings{cType} = num2str(p,'p = %.2f');
    elseif p > 0.01
        pStrings{cType} = '*';
    elseif p > 0.001
        pStrings{cType} = '**';
    else
        pStrings{cType} = '***';
    end
end

SortedTypeScorewiseData = TypeScorewiseData([2,3,1],:,:);
SortedTypeStr = TypeStrs([2,3,1]);
LowHSData = SortedTypeScorewiseData(:,:,1);
HighHSData = SortedTypeScorewiseData(:,:,2);

h5f = figure('position',[100 100 280 180]);
hold on
hl1 = errorbar(1:3, LowHSData(:,1),LowHSData(:,2),'-o','linewidth',0.75,'color',[0 0.8 0.8]);
hl2 = errorbar(1:3, HighHSData(:,1),HighHSData(:,2),'-o','linewidth',0.75,'color',[0.8 0 0.8]);
text(1:3,max([sum(LowHSData(:,1:2),2),sum(HighHSData(:,1:2),2)],[],2)+0.005,pStrings([2,3,1]),'FontSize',10);

[~, pHigh] = ttest2(TypeScorewiseDataCell{1,2},TypeScorewiseDataCell{2,2});
[~, pLow] = ttest2(TypeScorewiseDataCell{1,1},TypeScorewiseDataCell{2,1});
text(1.2,0.04,{sprintf('LowStimANDBT = %.3e',pLow);sprintf('HighStimANDBT = %.3e',pHigh)},'FontSize',8);

set(gca,'xlim',[0.5 3.5],'xtick',1:3,'xticklabel',SortedTypeStr(:),'ylim',[0.02 0.12],'FontSize',10);
ylabel('Explained variance');
legend([hl1,hl2],{'Low Score','High Score'},'location','northwest','box','off','autoupdate','off');
%%
% plotfigSavePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\AHSScoreCorrplot';
plotfigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\AHSScoreCorrplot';
savename2 = fullfile(plotfigSavePath,'AHSScore class EVs Areawise');
saveas(h5f,savename2);
print(h5f,savename2,'-dpng','-r300');
print(h5f,savename2,'-dpdf','-bestfit');

%% performing plots

TypeStrs = {'Blocktype','Stim','Choice'};
TypeColors = {'r','c','b'};
CorrStrs = {'','',''};
AHS_score_scale = [0 0];
h2f = figure('position',[100 100 500 680]);
hold on
for cType = 1 : 3
    cTypeDatas = SelfBrainInds2Allen2(:,:,cType);
    ValidAreaInds = ~isnan(cTypeDatas(:,1));
    cType_validData = cTypeDatas(ValidAreaInds,:);
    
    errorbar(cType_validData(:,3),cType_validData(:,4),cType_validData(:,5)*0.2,'o',...
        'Color',TypeColors{cType},'linewidth',1.5);
%     plot(cType_validData(:,3),cType_validData(:,4),'o','Color',TypeColors{cType},...
%         'linewidth',1.5);
    AHS_score_scale(1) = min(AHS_score_scale(1),min(cType_validData(:,3)));
    AHS_score_scale(2) = max(AHS_score_scale(2),max(cType_validData(:,3)));
    
    [r,p] = corr(cType_validData(:,3),cType_validData(:,4));
    RStrs = sprintf('%s: R = %.3f, p = %.3f',TypeStrs{cType},r,p);
    CorrStrs{cType} = RStrs;
end
yscales = get(gca,'ylim');
line([0 0],yscales,'Color','k','linestyle','--','linewidth',1.2);
set(gca,'xlim',AHS_score_scale+[-0.1 0.1]);
xlabel('Allen Hierarchy Score');
ylabel('Selective Field Explained Variance');
lg = legend({'Blocktype','Stim','Choice'},'location','northeastoutside','box','on');
lgPos = get(lg,'position');
set(lg,'position',lgPos + [0.05 0.04 0 0]);

annotation('textbox',[0.15 0.55 0.1 0.4],'String',CorrStrs(:),'FitBoxToText','on','Color','k')

%%
savename2 = fullfile(plotfigSavePath,'AHSScore with SigfieldEV plot');
saveas(h2f,savename2);
print(h2f,savename2,'-dpng','-r400');
print(h2f,savename2,'-dpdf','-bestfit');

%% ##############################################################################################
%% All unit averaged explained variance plot 

SelectiveAreaDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
% SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
AreaSelectEVStrc2 = load(SelectiveAreaDatafile,'Area_RespMtxAll','BrainAreasStr');

%% Selective unit explained variance plot

NumAllBrainAreas = length(AreaSelectEVStrc2.BrainAreasStr);
SelfBrainInds2Allen3 = nan(NumAllBrainAreas,5,3); % for the third dimension, each is BT, Stim, Choice
for cCol = 1 : 3
    for cA = 1 : NumAllBrainAreas
        if size(AreaSelectEVStrc2.Area_RespMtxAll{cA,2},1) >= 1 && (AreaSelectEVStrc2.Area_RespMtxAll{cA,3}) >= 3 ...
            && size(AreaSelectEVStrc.Area_RespMtxAll{cA,1},1) >= 10
            cA_brain_str = AreaSelectEVStrc2.BrainAreasStr{cA};
            TF = matches(AllenRegionStrsModi,cA_brain_str,'IgnoreCase',true);
            if any(TF)
                AllenRegionInds = find(TF);
                if length(AllenRegionInds) > 1
                    fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
                    continue;
                end
                cTypeEVar = AreaSelectEVStrc2.Area_RespMtxAll{cA,2};
                for cType = 1 : 3
                    cTypeAllEVData = cTypeEVar(:,cType); 
                    SelfBrainInds2Allen3(cA,:,cType) = [cA, AllenRegionInds, ...
                        RegionScoresUsed(AllenRegionInds),mean(cTypeAllEVData),std(cTypeAllEVData)/sqrt(numel(cTypeAllEVData))];
                end
            end
        end
    end
end

%% performing plots

TypeStrs = {'Blocktype','Stim','Choice'};
TypeColors = {'r','c','b'};
CorrStrs = {'','',''};
AHS_score_scale = [0 0];
h3f = figure('position',[100 100 500 680]);
hold on
for cType = 1 : 3
    cTypeDatas = SelfBrainInds2Allen3(:,:,cType);
    ValidAreaInds = ~isnan(cTypeDatas(:,1));
    cType_validData = cTypeDatas(ValidAreaInds,:);
    
    errorbar(cType_validData(:,3),cType_validData(:,4),cType_validData(:,5)*0.2,'o',...
        'Color',TypeColors{cType},'linewidth',1.5);
%     plot(cType_validData(:,3),cType_validData(:,4),'o','Color',TypeColors{cType},...
%         'linewidth',1.5);
    AHS_score_scale(1) = min(AHS_score_scale(1),min(cType_validData(:,3)));
    AHS_score_scale(2) = max(AHS_score_scale(2),max(cType_validData(:,3)));
    
    [r,p] = corr(cType_validData(:,3),cType_validData(:,4));
    RStrs = sprintf('%s: R = %.3f, p = %.3f',TypeStrs{cType},r,p);
    CorrStrs{cType} = RStrs;
end
yscales = get(gca,'ylim');
line([0 0],yscales,'Color','k','linestyle','--','linewidth',1.2);
set(gca,'xlim',AHS_score_scale+[-0.1 0.1]);
xlabel('Allen Hierarchy Score');
ylabel('Selective Unit Explained Variance');
lg = legend({'Blocktype','Stim','Choice'},'location','northeastoutside','box','on');
lgPos = get(lg,'position');
set(lg,'position',lgPos + [0.05 0.04 0 0]);

annotation('textbox',[0.15 0.55 0.1 0.4],'String',CorrStrs(:),'FitBoxToText','on','Color','k')

%%
savename3 = fullfile(plotfigSavePath,'AHSScore with sigUnit AllEVfieldAvg plot');
saveas(h3f,savename3);
print(h3f,savename3,'-dpng','-r400');
print(h3f,savename3,'-dpdf','-bestfit');





