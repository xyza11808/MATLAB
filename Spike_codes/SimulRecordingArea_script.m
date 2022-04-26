% % % ###############################################################################################

cclr

% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
    'Sheet',1);
SessionFolderStr = SessionFoldersC(2:end);

SessionRecordIndexC = readcell(AllSessFolderPathfile,'Range','D:D',...
    'Sheet',1);
SessionRecordingIndex = cell2mat(SessionRecordIndexC(2:end));
NumUsedSess = length(SessionRecordingIndex);


%%

RecordingIndexTypes = unique(SessionRecordingIndex);
NumRecordIndex = length(RecordingIndexTypes);

RecordIndexAreas = cell(NumRecordIndex,5);
RecordDate_SessANDAreas = cell(NumRecordIndex,1);
for cRcIndex = 1:NumRecordIndex
    cRIndex_Inds = find(SessionRecordingIndex == RecordingIndexTypes(cRcIndex));
    Num_SimSess = numel(cRIndex_Inds);
    if Num_SimSess > 1 % simultaneously recorded probes exists
        SessPathANDAreas = cell(Num_SimSess,2);
        for cSess = 1 : Num_SimSess
            %            cSess_folder = SessionFolderStr{cRIndex_Inds(cSess)};
            %            cSess_Area_file = fullfile(cSess_folder,'ks2_5','SessAreaIndexData.mat');
            cSess_folder = strrep(fullfile(SessionFolderStr{cRIndex_Inds(cSess)},'ks2_5'),'F:\','E:\NPCCGs\');
            cSess_Area_file = fullfile(cSess_folder,'SessAreaIndexData.mat');
            
            cSess_area_strc = load(cSess_Area_file);
            cSess_areaIndex_strc = cSess_area_strc.SessAreaIndexStrc;
            cSess_fieldnames = fieldnames(cSess_areaIndex_strc);
            cSess_fieldname_Used = cSess_fieldnames(1:end-1);
            cSess_Exists_areaInds = cSess_areaIndex_strc.UsedAbbreviations;
            cSess_fieldname_exists = cSess_fieldname_Used(cSess_Exists_areaInds);
            SessPathANDAreas(cSess,:) = {cSess_folder,cSess_fieldname_exists};
        end
        
        RecordDate_SessANDAreas(cRcIndex) = {SessPathANDAreas};
    end
    
end


%% summary figure plots saved position
sumfigsavefolder = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\SameDateRecordProbes';
% sumfigsavefolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\SameDateRecordProbes';
if ~isfolder(sumfigsavefolder)
    mkdir(sumfigsavefolder);
end

%%
dataSaveName = fullfile(sumfigsavefolder,'RecordDateAreas.mat');
save(dataSaveName,'RecordDate_SessANDAreas','-v7.3');

%% designed target areas which were recorded simultaneously
summarySavefolder = 'E:\NPCCGs\SimRecordingSess';

NumRecordIndex = length(RecordDate_SessANDAreas);
for cRecorIndex = 1 : NumRecordIndex
    cSessStrs = RecordDate_SessANDAreas{cRecorIndex};
    SimuRecordingSessNum = size(SessPathANDAreas,1);
    if SimuRecordingSessNum > 1
        ccRecordPath = fullfile(summarySavefolder,sprintf('SimSession_%d',cRecorIndex));
        if ~isfolder(ccRecordPath)
            mkdir(ccRecordPath);
        end
        
        SessionSPDataANDClusInds = cell(SimuRecordingSessNum,3);
        ClusBase = 1;
        for cSameSess = 1 : SimuRecordingSessNum
            cSessfolder = cSessStrs{cSameSess,1};
            ksfolder = strrep(fullfile(SessionFolders{cSess},'ks2_5'),...
                'F:\','E:\NPCCGs\');
            
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
            SSpikeClus = AllSPClus(UsedSptimeInds);
            SSpikeTimeSample = AllSPsampleTimes(UsedSptimeInds);
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
            AllClus_realIndex = ExistField_ClusIDs(:,1);
            [TargetClusInds,~] = ismember(SSpikeClus,AllClus_realIndex);
            
            % only used clusters were included
            spdata.SpikeClus = SSpikeClus(TargetClusInds);
            [~,~,spdata.SpikeClusRank] = unique(spdata.SpikeClus);
            spdata.SpikeTimeSample = SSpikeTimeSample(TargetClusInds);
            spdata.SpikeClusRank = spdata.SpikeClusRank + ClusBase;
            
            [~,UsedRealClusInds] = sort(ExistField_ClusIDs(:,1));
            ExistField_ClusIDs_sort = ExistField_ClusIDs(UsedRealClusInds,:);
            
            NumUsedClusters = numel(UsedRealClusInds);
            AllSortIndsMtx = [(1:NumUsedClusters)'+ClusBase,...
                ExistField_ClusIDs_sort,cSameSess*ones(NumUsedClusters,1)];
            
            SessionSPDataANDClusInds(cSameSess,:) = {spdata, AllSortIndsMtx,NumUsedClusters};
            ClusBase = ClusBase + NumUsedClusters;
        end
        
        AllSessSPtimes_cell = (cellfun(@(x) x.SpikeTimeSample,SessionSPDataANDClusInds(:,1),...
            'uniformoutput',false))';
        AllSessClusInds_cell = (cellfun(@(x) x.SpikeClusRank,SessionSPDataANDClusInds(:,1),...
            'uniformoutput',false))';
        AllSessClusRank2Inds = cat(1,SessionSPDataANDClusInds{:,2});
        SessClusNums = cat(1,SessionSPDataANDClusInds{:,3});
        
        AllSessSPtimesVec = cat(2, AllSessSPtimes_cell{:});
        AllSessClusIndsVec = cat(2, AllSessClusInds_cell{:});
        
        [SortedAllSessSPtimes,SPTimeSortedInds] = sort(AllSessSPtimesVec);
        SortedAllSessClusInds = AllSessClusIndsVec(SPTimeSortedInds);
        
        SampleRate = 30000;
        binLen = 1e-3; %seconds
        WindowLength = 0.5; %seconds
        WinSize = round(WindowLength*SampleRate);
        BinSize = round(binLen*SampleRate);
        
        [ccgs, ConnectionWinSPTs] = Spikeccgfun_withSPtimes(sptimeAllUsed,spclusAllUsed,winsize,binsize,false);
        TempDataSavePath = fullfile(ccRecordPath,'CCGdata_SPtimes.mat');
        save(TempDataSavePath,'ccgs', 'ConnectionWinSPTs','SessionSPDataANDClusInds','-v7.3');

        clearvars ccgs ConnectionWinSPTs
        JitterScale = (5/1000) * SampleRate; % jitter within [-5 5]ms window
        JitterRepeatTimes = 1000;
        SPTrainLen = numel(sptimeAllUsed);
        JitWinSize = round(0.05 * SampleRate);
        JitterRepeatCCGs = cell(JitterRepeatTimes,1);
        for cJ = 1 : JitterRepeatTimes
            SPtimeJitterNum = (rand(SPTrainLen,1)-0.5)*2*JitterScale;
            JitterSPtrain = uint64(double(sptimeAllUsed) + SPtimeJitterNum);
            [JitterSPResort, SortInds] = sort(JitterSPtrain);
            JitterSortCLusInds = spclusAllUsed(SortInds);
            Jitccgs = Spikeccgfun(JitterSPResort,JitterSortCLusInds,JitWinSize,binsize,false);
            JitterRepeatCCGs{cJ} = Jitccgs;
        end
        
        JitDataSizes = size(JitterRepeatCCGs{1});
        JitCCGSummary = zeros(JitDataSizes(1),JitDataSizes(2),4,JitDataSizes(3));
        for cRow = 1 : JitDataSizes(1)
            for cCol = 1 : JitDataSizes(2)
                cJitData = cellfun(@(x) (squeeze(x(cRow,cCol,:)))',JitterRepeatCCGs,'UniformOutput',false);
                cAllJitData = cat(1,cJitData{:});
                cJitCI = prctile(cAllJitData,[1 99]);
                cJitAvg = mean(cAllJitData);
                cJitSD = std(cAllJitData);
                JitCCGSummary(cRow,cCol,:,:) = [cJitAvg;cJitSD;cJitCI];
            end
        end

        toc;
        
        TempDataSavePath2 = fullfile(ccRecordPath,'JitterCCGdata.mat');
        save(TempDataSavePath2,'JitterRepeatCCGs', 'JitCCGSummary','-v7.3');

    end
end
            
            
            
