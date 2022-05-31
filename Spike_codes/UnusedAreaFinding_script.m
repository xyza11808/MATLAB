cclr

% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumprocessedNPSess = length(SessionFolders);


%%
% TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% 
% BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
% TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
% %
% NumofTargetAreas = length(TargetRegionNamesAll);

% SessAreaIndexes = cell(NumprocessedNPSess,1);
for cP = 62 : NumprocessedNPSess
    %
%     cPath = SessionFolders{cP};
    cPath = strrep(SessionFolders{cP},'F:\','E:\NPCCGs\');
%     cPath = fullfile(strrep(SessionFolders{cP},'F:','I:\ksOutput_backup'));
    load(fullfile(cPath,sortingcode_string,'NPClassHandleSaved.mat'));
    
    if isempty(ProbNPSess.ChannelAreaStrs)
        load(fullfile(cPath,sortingcode_string,'Chnlocation.mat'));
        ProbNPSess.ChannelAreaStrs = ChnArea_Strings(2:end,:);
    end
    %
    UnitMaxampChnInds = ProbNPSess.ChannelUseds_id; % already had +1 for matlab indexing
    UnitChnAreasAll = ProbNPSess.ChannelAreaStrs(UnitMaxampChnInds,:);
    UnitChnAreaIndexAll = cell2mat(UnitChnAreasAll(:,2));
    totalUnitNum = length(UnitMaxampChnInds);
    
    SessAreaIndexes{cP} = UnitChnAreasAll;
    
end



