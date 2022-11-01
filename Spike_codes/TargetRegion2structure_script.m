
% TargetRegionFile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\TargetbrainRegions.xlsx';
TargetRegionFile = 'K:\Documents\me\projects\NP_reversaltask\TargetbrainRegions.xlsx';

ChnposIndex = readcell(TargetRegionFile,'Range','A:A',...
        'Sheet',1);
BrainArea_shortsCell = readcell(TargetRegionFile,'Range','E:E',...
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
% saveNames = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
saveNames = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

save(saveNames,'BrainRegions','-v7.3');

%% ########################################################################################
% loop through all ks sessions to extract chn area info
cclr
AnmSess_sourcepath = 'F:\b106a07_ksoutputs';
% AnmSess_sourcepath = 'I:\ksOutput_backup';

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
SessionFolders = nameSplit((ProcessedFoldInds>0));
NumprocessedNPSess = length(SessionFolders);
if NumprocessedNPSess < 1
    warning('No valid NP session was found in current path.');
end

%%
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);


%%
TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
sortingcode_string = 'ks2_5';
NumofTargetAreas = length(TargetRegionNamesAll);
%%
UnitNumsAll = zeros(NumprocessedNPSess,1);
for cP = 1 : NumprocessedNPSess
     fprintf('Processing session %d...\n',cP);
%     cPath = SessionFolders{cP};
%     cPath = fullfile(strrep(SessionFolders{cP},'F:\','E:\NPCCGs\'),sortingcode_string);
    cPath = fullfile(strrep(SessionFolders{cP},'F:','I:\ksOutput_backup'),sortingcode_string); %
%%     cPath = fullfile(strrep(SessionFolders{cP},'F:','P:'));
    try
        load(fullfile(cPath,'NPClassHandleSaved.mat'));
    catch
       warning('NPClassHandle file is missing in session %s',cPath);
    end
%%     ProbNPSess = Newclasshandle;
%     if isempty(ProbNPSess.ChannelAreaStrs)
     try
        load(fullfile(cPath,'Chnlocation.mat'),'AlignedAreaStrings');
     catch
%          load(fullfile(cPath,sortingcode_string,'Chnlocation.mat'),'ChnArea_Strings');
         warning('Session %s may need electrophysiology alignment before further analysis.',cPath);
%          continue;
     end
%      ProbNPSess.ChannelAreaStrs = ChnArea_Strings(2:end,:);
     ProbNPSess.ChannelAreaStrs = AlignedAreaStrings;
%     end
    %
    UnitMaxampChnInds = ProbNPSess.ChannelUseds_id; % already had +1 for matlab indexing
%     UnitNumsAll(cP) = length(UnitMaxampChnInds);
    
%     UnitChnAreasAll = ProbNPSess.ChannelAreaStrs(UnitMaxampChnInds,:);
%     UnitChnAreaIndexAll = cell2mat(UnitChnAreasAll(:,2));
    UnitChnAreaIndexAll = ProbNPSess.ChannelAreaStrs{1}(UnitMaxampChnInds);
    
    totalUnitNum = length(UnitMaxampChnInds);
    SessAreaIndexStrc = struct();
    IsUnitAreTarget = false(totalUnitNum, 1);  
    IstargetfieldExist = false(NumofTargetAreas+1,1);
    for cNameNum = 1 : NumofTargetAreas
        [Lia, Lib] = ismember(UnitChnAreaIndexAll,BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}));
        if sum(Lia)
            SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct('MatchedInds',BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}),...
                'MatchedUnitInds',find(Lia),'MatchUnitRealIndex',ProbNPSess.UsedClus_IDs(Lia),'MatchUnitRealChn',...
                UnitMaxampChnInds(Lia),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(Lia)));
            IstargetfieldExist(cNameNum) = true;
            IsUnitAreTarget(Lia)=true;
        else
            SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct();
        end
    end
    
    OtherRegionsUnit = ~IsUnitAreTarget;
    if sum(OtherRegionsUnit)
        SessAreaIndexStrc.Others = struct('MatchedInds',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)),...
            'MatchedUnitInds',find(~IsUnitAreTarget),'MatchUnitRealIndex',ProbNPSess.UsedClus_IDs(~IsUnitAreTarget),...
            'MatchUnitRealChn',UnitMaxampChnInds(~IsUnitAreTarget),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)));
        IstargetfieldExist(end) = true;
    end
    SessAreaIndexStrc.UsedAbbreviations = IstargetfieldExist;
    SessAreaIndex_saveName = fullfile(cPath,'SessAreaIndexDataNewAlign.mat');
    save(SessAreaIndex_saveName,'SessAreaIndexStrc','-v7.3');
    %
end




