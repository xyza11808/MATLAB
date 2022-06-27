
cclr

AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);

%% in case needs to change unit inclusion criteria
Errors = zeros(NumUsedSess,1);
for cSess = 1 : NumUsedSess
    clearvars ProbNPSess PassSoundDatas behavResults
    try
    %     cSessFolder = fullfile(SessionFolders{cSess}(2:end-1),'ks2_5');
        ProbespikeFolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'));
        
            load(fullfile(ProbespikeFolder,'ks2_5','NPClassHandleSaved.mat'));

            ProbNPSess = ProbNPSess.ClusScreeningFun; % change the inclusion criteria if needed

            saveName = fullfile(ProbespikeFolder,'ks2_5','NPClassHandleSaved.mat');
            save(saveName,'ProbNPSess','PassSoundDatas','behavResults','-v7.3');
    catch ME
        Errors(cSess) = 1;
    end
end



%% unit response colorplot replots
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);

%%
Errors = zeros(NumUsedSess,1);
for cSess = 1 : NumUsedSess
    clearvars ProbNPSess PassSoundDatas behavResults
    try
    %     cSessFolder = fullfile(SessionFolders{cSess}(2:end-1),'ks2_5');
        ProbespikeFolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'));
        
        % check whether the polts have been updated
        TaskDataSavePath = fullfile(ProbespikeFolder,'TaskSessData.mat');
        fileinfo = dir(TaskDataSavePath);
        fileDate = datevec(fileinfo.date);
        if fileDate(2) == 2 && fileDate(3) >= 9
            fprintf('Already processed session %d...\n', cSess);
            continue;
        end
        fprintf('Processing session %d...\n', cSess);
        load(fullfile(ProbespikeFolder,'ks2_5','NPClassHandleSaved.mat'));
        
%         if isprop(ProbNPSess,'UnitInclusionCriteria')
%             fprintf('Already processed session %d...\n', cSess);
%             continue;
%         end
        NPSession_directANA_4batch;

        saveName = fullfile(ProbespikeFolder,'ks2_5','NPClassHandleSaved.mat');
        save(saveName,'ProbNPSess','PassSoundDatas','behavResults','-v7.3');
    catch ME
        Errors(cSess) = 1;
    end
        
end

%% update sesseion area index file

cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumprocessedNPSess = length(SessionFolders);


%%
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

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


%% used unit response amplitue analysis
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumUsedSess = length(SessionFolders);
%%

for cSess = 1 : NumUsedSess
    clearvars ProbNPSess UnitSPAmps UnitLlmfits ClusInds SPTimes Amps
    
%     cSessFolder = fullfile(strrep(SessionFolders{cSess},'F:','E:\NPCCGs'),'ks2_5');
    cSessFolder = fullfile(strrep(SessionFolders{cSess},'F:','I:\ksOutput_backup'),'ks2_5');
%     if exist(fullfile(cSessFolder,'UnitspikeAmpSave.mat'),'file')
%         continue;
%     end
    fprintf('Processing Session %d...\n', cSess);
    %%
    Amps = readNPY(fullfile(cSessFolder,'amplitudes.npy'));
    ClusInds = readNPY(fullfile(cSessFolder,'spike_clusters.npy'));
    SPTimes = readNPY(fullfile(cSessFolder,'spike_times.npy'));
    load(fullfile(cSessFolder,'NPClassHandleSaved.mat'));
    
    %
    UsedUnitIDs = ProbNPSess.FRIncludeClus;
    NumUnitIDs = length(UsedUnitIDs);

    UnitSPAmps = cell(NumUnitIDs,2);
    UnitLlmfits = cell(NumUnitIDs,2);
    for cUnit = 1 : NumUnitIDs
        cUnit_ID = UsedUnitIDs(cUnit);
        cUnit_ID_Inds = ClusInds == cUnit_ID;
        cUnit_ID_sptimes = double(SPTimes(cUnit_ID_Inds))/30000;
        cUnit_ID_spAmps = Amps(cUnit_ID_Inds);
        UnitSPAmps(cUnit,:) = {cUnit_ID_sptimes, cUnit_ID_spAmps};

        tb1 = fitlm(UnitSPAmps{cUnit,1},UnitSPAmps{cUnit,2});
        UnitLlmfits(cUnit,:) = {tb1.Coefficients, tb1.Rsquared};
        
    end

    saveName = fullfile(cSessFolder,'UnitspikeAmpSave.mat');
    save(saveName,'UnitSPAmps','UnitLlmfits','-v7.3');
    %%
end


