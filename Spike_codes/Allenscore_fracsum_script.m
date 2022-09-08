
AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
% AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

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
SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\RegAreawiseFrac.mat';
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

hf = figure('position',[100 100 500 680]);
hold on
sc1 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,1),'ro','linewidth',1.2);
sc2 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,2),'co','linewidth',1.2);
sc3 = plot(ExistAreaAllenScore,ExistAreaFracsAll(:,3),'bo','linewidth',1.2);
xlabel('Allen Score');
ylabel('Selective ROI fraction');
legend([sc1,sc2,sc3],{'BT','Stim','Choice'},'location','northeastoutside','box','off');



