
% TargetRegionFile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\TargetbrainRegions.xlsx';
TargetRegionFile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\TargetbrainRegions.xlsx';

ChnposIndex = readcell(TargetRegionFile,'Range','A:A',...
        'Sheet',1);
BrainArea_shortsCell = readcell(TargetRegionFile,'Range','D:D',...
        'Sheet',1);
%%
Valid_cell_inds = cellfun(@(x) all(ismissing(x)),ChnposIndex(2:end));
Content_rowInds = find(~Valid_cell_inds);

Content_indexRangeStr = ChnposIndex(Content_rowInds+1);

Content_indexRangeVec = cellfun(@(x) str2indsVecFun(x),Content_indexRangeStr,'UniformOutput',false);

NumTargetAreas = length(Content_indexRangeVec);
BrainArea4shorts = BrainArea_shortsCell(Content_rowInds+1);
BrainRegions = struct();
for cArea = 1 : NumTargetAreas
    BrainRegions.(BrainArea4shorts{cArea}) = Content_indexRangeVec{cArea};
end

%%
saveNames = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

save(saveNames,'BrainRegions','-v7.3');

%% ########################################################################################
% loop through all ks sessions to extract chn area info
cclr
% AnmSess_sourcepath = 'F:\b103a04_ksoutput';
AnmSess_sourcepath = 'I:\ksOutput_backup';

xpath = genpath(AnmSess_sourcepath);
nameSplit = (strsplit(xpath,';'))';

if isempty(nameSplit{end})
    nameSplit(end) = [];
end
% DirLength = length(nameSplit);
% PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
% PossDataPath = nameSplit(PossibleInds);
sortingcode_string = 'ks2_5';
% Find processed folders 
ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,sortingcode_string,'NPClassHandleSaved.mat'),'file') && ...
   exist(fullfile(x,sortingcode_string,'Chnlocation.mat'),'file') ,nameSplit);
NPsessionfolders = nameSplit((ProcessedFoldInds>0));
NumprocessedNPSess = length(NPsessionfolders);
if NumprocessedNPSess < 1
    warning('No valid NP session was found in current path.');
end

%%
cclr

AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumprocessedNPSess = length(SessionFolders);


%%
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
TargetBrainArea_file = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
NumofTargetAreas = length(TargetRegionNamesAll);
for cP = 1 : NumprocessedNPSess
    %
%     cPath = NPsessionfolders{cP};
    cPath = fullfile(strrep(SessionFolders{cP}(2:end-1),'F:','I:\ksOutput_backup'));
    load(fullfile(cPath,sortingcode_string,'NPClassHandleSaved.mat'));
    
    if isempty(ProbNPSess.ChannelAreaStrs)
        load(fullfile(cPath,sortingcode_string,'Chnlocation.mat'));
        ProbNPSess.ChannelAreaStrs = ChnArea_Strings(2:end,:);
    end
    %
    UnitMaxampChnInds = ProbNPSess.ChannelUseds_id; % already had +1 for matlab indexing
    UnitChnAreasAll = ProbNPSess.ChannelAreaStrs(UnitMaxampChnInds,:);
    UnitChnAreaIndexAll = cell2mat(UnitChnAreasAll(:,2));
    SessAreaIndexStrc = struct();
    IstargetfieldExist = false(NumofTargetAreas,1);
    for cNameNum = 1 : NumofTargetAreas
        [Lia, Lib] = ismember(UnitChnAreaIndexAll,BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}));
        if sum(Lia)
            SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct('MatchedInds',BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}),...
                'MatchedUnitInds',find(Lia),'MatchUnitRealIndex',ProbNPSess.UsedClus_IDs(Lia),'MatchUnitRealChn',...
                UnitMaxampChnInds(Lia),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(Lia)));
            IstargetfieldExist(cNameNum) = true;
        else
            SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct();
            
        end
    end
    SessAreaIndexStrc.UsedAbbreviations = IstargetfieldExist;
    
    
    SessAreaIndex_saveName = fullfile(cPath,sortingcode_string,'SessAreaIndexData.mat');
    save(SessAreaIndex_saveName,'SessAreaIndexStrc','-v7.3');
    clearvars ProbNPSess
    %
end




