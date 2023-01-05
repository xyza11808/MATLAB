

% batched through all used sessions
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',2); % load DJ's animal data
% SessionFolders = SessionFoldersC(2:end);
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
ErrosSess = zeros(NumprocessedNPSess,1);
% ProcessSess = [36,37,38,56,57];
for cfff = 1 : NumprocessedNPSess
% for cff = 1 : length(ProcessSess)
    
%     cfff = ProcessSess(cff);
    ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','K:\NPdatas\DJData'),sortingcode_string);
%     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','I:\ksOutput_backup'),sortingcode_string);
%     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','P:'),sortingcode_string);
    cSessFolder = ksfolder;
    fprintf('Processing session %d...\n', cfff);
    clearvars -except SessionFolders sortingcode_string cfff NumprocessedNPSess ErrosSess cSessFolder ksfolder ...
        NumofTargetAreas TargetRegionNamesAll BrainRegionStrc

    try
        run('E:\MatCode\MATLAB\Spike_codes\lyh_code\BS_RL_script.m');
%         NPhandleData = load(fullfile(ksfolder,'probeNPSess.mat'));
%         NewNPClusHandle = NPhandleData.probeNPSess;
%         load(fullfile(ksfolder,'BehavData.mat'),'behavResults');
%         save(fullfile(ksfolder,'NewClassHandle2.mat'),'NewNPClusHandle','behavResults','-v7.3');
%         %
%         try
%             load(fullfile(ksfolder,'Chnlocation.mat'),'AlignedAreaStrings');
%          catch
%     %          load(fullfile(cPath,sortingcode_string,'Chnlocation.mat'),'ChnArea_Strings');
%              warning('Session %s may need electrophysiology alignment before further analysis.',ksfolder);
%     %          continue;
%          end
%     %      ProbNPSess.ChannelAreaStrs = ChnArea_Strings(2:end,:);
%          NewNPClusHandle.ChannelAreaStrs = AlignedAreaStrings;
%     %     end
%         %
%         UnitMaxampChnInds = NewNPClusHandle.ChannelUseds_id; % already had +1 for matlab indexing
%     %     UnitNumsAll(cP) = length(UnitMaxampChnInds);
% 
%     %     UnitChnAreasAll = ProbNPSess.ChannelAreaStrs(UnitMaxampChnInds,:);
%     %     UnitChnAreaIndexAll = cell2mat(UnitChnAreasAll(:,2));
%         UnitChnAreaIndexAll = NewNPClusHandle.ChannelAreaStrs{1}(UnitMaxampChnInds);
% 
%         totalUnitNum = length(UnitMaxampChnInds);
%         SessAreaIndexStrc = struct();
%         IsUnitAreTarget = false(totalUnitNum, 1);  
%         IstargetfieldExist = false(NumofTargetAreas+1,1);
%         for cNameNum = 1 : NumofTargetAreas
%             [Lia, Lib] = ismember(UnitChnAreaIndexAll,BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}));
%             if sum(Lia)
%                 SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct('MatchedInds',BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}),...
%                     'MatchedUnitInds',find(Lia),'MatchUnitRealIndex',NewNPClusHandle.UsedClus_IDs(Lia),'MatchUnitRealChn',...
%                     UnitMaxampChnInds(Lia),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(Lia)));
%                 IstargetfieldExist(cNameNum) = true;
%                 IsUnitAreTarget(Lia)=true;
%             else
%                 SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct();
%             end
%         end

%         OtherRegionsUnit = ~IsUnitAreTarget;
%         if sum(OtherRegionsUnit)
%             SessAreaIndexStrc.Others = struct('MatchedInds',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)),...
%                 'MatchedUnitInds',find(~IsUnitAreTarget),'MatchUnitRealIndex',NewNPClusHandle.UsedClus_IDs(~IsUnitAreTarget),...
%                 'MatchUnitRealChn',UnitMaxampChnInds(~IsUnitAreTarget),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)));
%             IstargetfieldExist(end) = true;
%         end
%         SessAreaIndexStrc.UsedAbbreviations = IstargetfieldExist;
%         SessAreaIndex_saveName = fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat');
%         save(SessAreaIndex_saveName,'SessAreaIndexStrc','-v7.3');
        
    catch ME
        fprintf('Errors for session %d.\n',cfff);
        ErrosSess(cfff) = 1;
        disp(ME.message);
        
    end
end
if sum(ErrosSess)
    fprintf('\n############# some session has error #################\n');
end






