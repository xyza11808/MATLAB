
AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
% AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

%%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = BrainAreasStrCC(~EmptyInds);

NumBrainAreas = length(BrainAreasStr);


%%
SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\RegAreawiseFrac.mat';
AreaSelectFracStrc = load(SelectiveAreaDatafile,'AllAreaFracs','NEBrainStrs');






