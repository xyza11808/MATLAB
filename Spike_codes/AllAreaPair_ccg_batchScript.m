cclr
%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
    'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);

%%

for cSess = 5 : NumUsedSess
    
    clearvars AllPairCCG ExistField_ClusIDs spdata
    fprintf('Processing session %d...\n',cSess);
%     ksfolder = fullfile(SessionFolders{cSess},'ks2_5');
    ksfolder = strrep(fullfile(SessionFolders{cSess},'ks2_5'),'F:\','E:\NPCCGs\');
    % read raw spike time data
    spdata = struct();
    AllSPClus = readNPY(fullfile(ksfolder,'spike_clusters.npy'));
    AllSPsampleTimes = readNPY(fullfile(ksfolder,'spike_times.npy'));
    
    spdata.sample_rate = 30000;
    
    % only spikes within task session period was used for calculation
    TrigFilePath = fullfile(ksfolder,'..','TriggerDatas.mat');
    TrigEventsTime = load(TrigFilePath,'TriggerEvents');
    TaskSessStartTime = TrigEventsTime.TriggerEvents(1,1) - 5*spdata.sample_rate;
    TaskSessEndTime = TrigEventsTime.TriggerEvents(end,2) + 5*spdata.sample_rate;
    UsedSptimeInds = AllSPsampleTimes > TaskSessStartTime & AllSPsampleTimes < TaskSessEndTime;
    spdata.SpikeClus = AllSPClus(UsedSptimeInds);
    spdata.SpikeTimeSample = AllSPsampleTimes(UsedSptimeInds);
    %
    AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
    AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
    UsedNames = AllFieldNames(1:end-1);
    ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);
    
    if strcmpi(ExistAreaNames(end),'Others')
        ExistAreaNames(end) = [];
    end
    
    Numfieldnames = length(ExistAreaNames);
    ExistField_ClusIDs = [];
    for cA = 1 : Numfieldnames
        cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
        cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
        ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    end
    
    CCGDataSavePath = fullfile(ksfolder,'CCGDataSaves');
    if ~isfolder(CCGDataSavePath)
        mkdir(CCGDataSavePath);
    end
    
    if ~isempty(ExistField_ClusIDs)
        spdata.UsedClus_IDs = ExistField_ClusIDs(:,1);
        %
%         [AllPairCCG, CCGSPtimes, JitCCGs] = ...
        refractoryPeriodCal_Allpair_fast(spdata,[],2,1e-3,ksfolder); % [] indicates all clustes
        
        %
        saveName = fullfile(CCGDataSavePath,'CCGused_ClusInds.mat');
        save(saveName,'ExistField_ClusIDs','spdata','-v7.3');
    end
    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% task period spike time analysis of co-exists spikes

cclr
%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
    'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);

%%

for cSess = 5 : NumUsedSess
    
    clearvars ProbNPSess PairedDatas
    fprintf('Processing session %d...\n',cSess);
    ksfolder = fullfile(SessionFolders{cSess},'ks2_5');
    % read raw spike time data
    Sessdatafiles = fullfile(ksfolder,'NPClassHandleSaved.mat');
    load(Sessdatafiles,'ProbNPSess');
    %
    TaskSessTriTimesAll = ProbNPSess.UsedTrigOnTime{1}; % task trigger times
    TaskOnAndOffTimes = [TaskSessTriTimesAll(1)-30, TaskSessTriTimesAll(end)+60];
    
    UsedSPtimeInds = ProbNPSess.SpikeTimes > TaskOnAndOffTimes(1) & ...
        ProbNPSess.SpikeTimes < TaskOnAndOffTimes(2);
    UsedSPTimesAll = ProbNPSess.SpikeTimes(UsedSPtimeInds);
    UsedSPClusAll = ProbNPSess.SpikeClus(UsedSPtimeInds);
    % find valid clusters within target areas
    AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
    AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
    UsedNames = AllFieldNames(1:end-1);
    ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);
    
    if strcmpi(ExistAreaNames(end),'Others')
        ExistAreaNames(end) = [];
    end
    
    Numfieldnames = length(ExistAreaNames);
    ExistField_ClusIDs = [];
    for cA = 1 : Numfieldnames
        cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
        cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
        ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    end
    UsedClus_IDs = ExistField_ClusIDs(:,1);
    
    NumUsedClus = numel(UsedClus_IDs);
    NumClusSptimesAll = cell(NumUsedClus,1);
    for clusIndex = 1 : NumUsedClus
        NumClusSptimesAll{clusIndex} = UsedSPTimesAll(UsedSPClusAll == UsedClus_IDs(clusIndex));
    end
    
%     MaxTimewinLen = diff(TaskOnAndOffTimes);
%     NumShufRepeats = 500;
%     NerSPWin = 0.003:0.001:0.01; % the two spikes within few milliseconds
    
%
    PairNums = NumUsedClus*(NumUsedClus-1)/2;
    ClusDataInds = zeros(PairNums,2);
    PairedDatas = cell(PairNums,2);
    % calculate the spike times
    k = 1;
    %%
    for cClus1 = 2 : NumUsedClus
        %
        for cClus2 = cClus1+1 : NumUsedClus %cClus1+1
            cClus1_SPtimes = NumClusSptimesAll{cClus1};
            cClus2_SPtimes = NumClusSptimesAll{cClus2};
            
%             [ClusWithinWinCount,CLusWithWinSPtime] = ClusSPtimeCVFun(cClus1_SPtimes, cClus2_SPtimes, NerSPWin);
%             
%             
%             SPTimeShiftsNum = 2*(rand(NumShufRepeats,1)-0.5) * MaxTimewinLen/3;
%             SPshufClusWithinCount = cell(NumShufRepeats,1);
%             parfor cShufRe = 1 : NumShufRepeats
%                 cClus2_SPtimes_shuf = SPTimeShiftsNum(cShufRe) + cClus2_SPtimes;
%                 cClus2_SPtimes_shuf(cClus2_SPtimes_shuf > TaskOnAndOffTimes(2)) = ...
%                     cClus2_SPtimes_shuf(cClus2_SPtimes_shuf > TaskOnAndOffTimes(2)) - TaskOnAndOffTimes(2);
%                 [ShufCounts,~] = ClusSPtimeCVFun(cClus1_SPtimes,cClus2_SPtimes_shuf,NerSPWin);
%                 SPshufClusWithinCount(cShufRe) = {ShufCounts};
%             end
%             ClusDataInds(k,:) = [cClus1,cClus2];
%             ShufSP_countThres = cellfun(@(x) prctile(cat(3,x{:}),99,3),SPshufClusWithinCount,'UniformOutput',false);
%             
%             PairedDatas(k,:) = {ClusWithinWinCount,CLusWithWinSPtime,ShufSP_countThres};
%             k = k + 1;
%             clearvars SPshufClusWithinCount
            correlograms = twoClusCCGCalFun(cClus1_SPtimes, cClus2_SPtimes);
            PairedDatas(k,:) = {squeeze(correlograms(1,2,:)),squeeze(correlograms(2,1,:))};
            k = k + 1;
            
        end
        
    end
    %
    saveName = fullfile(ksfolder,'SPtime_coexist_count.mat');
    save(saveName,'PairedDatas','-v7.3');
    
    
end






