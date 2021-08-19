classdef NPspikeDataMining
    properties (SetAccess = private)
        NumOfWaves = 2000;
        WaveWinSamples = [-30,51];
        SessTypeStrs = {'Task','Passive'};
    end
    
    properties (SetAccess = public)
        ksFolder = '';
        binfilePath = ''
        RawDataFilename = ''
        NumChn = 385; % the last channel index is the trigger channel recording
        Numsamp = [];
        Datatype = 'int16';
        mmf
        SpikeStrc = struct();
        
        SpikeClus
        SpikeTimeSample % spike time, in integer format, for indexing
        SpikeTimes % in seconds, float values
        chnMaps
        
        ClusterInfoAll
        UsedClus_IDs % used cluster index
        ChannelUseds_id % used channel index
        RawClusANDchan_ids_All = {[],[]};
        UsedClusinds % inds indicating which cluster is to be used
        UsedChnDepth
        ChannelAreaStrs = {}; % channel area strings
        
        SessBlockTypes = [];
        
        % for triggered PSTH
        UsedTrigOnTime = {[],[]}; % trigger onset time, in seconds format
        TrigData_Bin = {[],[]};
        CurrentSessInds = []
        BinCenters = {[],[]};
        TriggerStartBin = {[],[]};
        USedbin = [];
        TrigDataBin_FRSub = {[],[]};
        TrTrigSpikeTimes = {[],[]};
        psthTimeWin = {[],[]};
        TrigAlignType = {'',''}; % could either be "trigger" or "stim", which indicates the events used for binned data extraction
        StimAlignedTime = {[],[]};
        
        % waveform datas
        UnitWaves = {};
        UnitWaveFeatures = {};
        UnitWaveExcluInds = [];
        
    end
    
    
    methods
        function obj = NPspikeDataMining(FolderPath, SessTypeStr)
            % session str type must be task or passive, and must be given
            SessTypeInds = strcmpi(SessTypeStr,obj.SessTypeStrs);
            if ~sum(SessTypeInds)
                error('Unknowed trigger session type.');
            end
            obj.CurrentSessInds = SessTypeInds;
            % if add another session to same recording file's spike sorting
            % outputs
            if isempty(FolderPath)
                if isempty(obj.ksFolder)
                    error('The ksfolder path is not defined!');
                else
                    FolderPath = obj.ksFolder;
                end
            end
            
            if ~exist(fullfile(FolderPath,'*.ap.bin'),'file') && ~exist(fullfile(FolderPath,'..','*.ap.bin'),'file')
                warning('Unable to find target bin file.');
                obj.ksFolder = FolderPath;
                obj.binfilePath = [];
                obj.RawDataFilename = [];
                if ~exist(fullfile(FolderPath,'rezdata.mat'),'file')
                    error('Unable to locate *.bin file location or rez.mat file location, which is needed for further analysis.');
                else
                    fprintf('Load sample number from rez.mat file.\n');
                    RezStrc = load(fullfile(FolderPath,'rezdata.mat'));
                    obj.Numsamp = RezStrc.rez.ops.sampsToRead;
                    obj.mmf = [];
                end
            else
                if exist(fullfile(FolderPath,'*.ap.bin'),'file')
                    binfileInfo = dir(fullfile(FolderPath,'*.ap.bin'));
                    obj.binfilePath = FolderPath;
                else
                    binfileInfo = dir(fullfile(FolderPath,'..','*.ap.bin'));
                    obj.binfilePath = fullfile(FolderPath,'..');
                end
                obj.RawDataFilename = binfileInfo(1).name;
                obj.ksFolder = FolderPath;
                
                dataTypeNBytes = numel(typecast(cast(0, obj.Datatype), 'uint8')); % determine number of bytes per sample
                obj.Numsamp = binfileInfo(1).bytes/(dataTypeNBytes*obj.NumChn);
                fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
                obj.mmf = memmapfile(fullpaths, 'Format', {obj.Datatype, [obj.NumChn obj.Numsamp], 'x'});
                
            end
            
            
            % spike data info reading
            obj.SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
            
            % read npy files
            obj.SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
            obj.SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
            obj.SpikeTimes = double(obj.SpikeTimeSample)/obj.SpikeStrc.sample_rate;
            obj.chnMaps = readNPY(fullfile(FolderPath, 'channel_map.npy'));
            
            if ~exist(fullfile(FolderPath,'cluster_info.tsv'),'file')
                
                FolderPath = obj.ksFolder;
                binfilepath = obj.binfilePath;
                SR = obj.SpikeStrc.sample_rate;
                disp('Constructing cluster info files...\n');
                ks3_Result2Info_script;
                %                 warning('Unbale to locate phy processed file.');
                %                 return;
            end
            
            % sorted data have been processed by phy
            % cluster include criteria: good, not noise, fr >=1
            cgsFile = fullfile(FolderPath,'cluster_info.tsv');
            [obj.UsedClus_IDs,obj.ChannelUseds_id,obj.UsedClusinds,...
                obj.ClusterInfoAll] = ClusterGroups_Reads(cgsFile);
            
            ChannelDepth = cell2mat(obj.ClusterInfoAll(2:end,7));
            obj.UsedChnDepth = ChannelDepth(obj.UsedClusinds);
            NumGoodClus = length(obj.UsedClus_IDs);
            fprintf('Totally %d number of good units were find.\n',NumGoodClus);
            obj.RawClusANDchan_ids_All = {obj.UsedClus_IDs, obj.ChannelUseds_id};
            % load unit waveform data is saved file exists
            if ~exist(fullfile(FolderPath,'UnitwaveformDatas.mat'),'file')
                waveDatas = load(fullfile(FolderPath,'UnitwaveformDatas.mat'));
                obj.UnitWaves = waveDatas.UnitDatas;
                obj.UnitWaveFeatures = waveDatas.UnitFeatures;
                
                obj = obj.wavefeatureExclusion;
            end
            
        end
        
        function obj = wavefeatureExclusion(obj, varargin)
           %  further exclude some units according to unit spike waveform
           %  and other criterias
           if isempty(obj.UnitWaveFeatures) || isempty(obj.UnitWaves)
               warning('The unit waveform data does not exists, please check your class handle contains.');
               return;
           end
           if isempty(obj.RawClusANDchan_ids_All{1})
                obj.RawClusANDchan_ids_All = {obj.UsedClus_IDs, obj.ChannelUseds_id};
           end
           
           UnitWaveExclusionInds = cell2mat(obj.UnitWaveFeatures(:,2)); % Isoformed waves were excluded
           Unit_pre2post_peakRatio = cellfun(@(x) x.pre2post_peakratio,obj.UnitWaveFeatures(:,1));
           Unit_sp_duration = cellfun(@(x) x.tough2peakT,obj.UnitWaveFeatures(:,1));
           
           % lick artifact exclusion
           lickArtifactExclusion = Unit_sp_duration >= (1.5*1e-3*obj.SpikeStrc.sample_rate); % spike duratio longer than 1.5ms
           
           % axonal spike exclusion
           axonalspExclusion = abs(Unit_pre2post_peakRatio) > 1;
           
           % summarize all exclusion criterias
           UnitWaveExclusionInds(lickArtifactExclusion) = 1;
           UnitWaveExclusionInds(axonalspExclusion) = 1;
           
           obj.UnitWaveExcluInds = logical(UnitWaveExclusionInds);
           fprintf('Totally %d number of unit will be excluded because of the isoformed waveform.\n',sum(UnitWaveExclusionInds));
           
           % exclued waveform discarded units
           logiExcluInds = logical(UnitWaveExclusionInds);
           obj.UsedClus_IDs(logiExcluInds) = [];
           obj.ChannelUseds_id(logiExcluInds) = [];
           obj.UsedClusinds(logiExcluInds) = [];
           obj.UsedChnDepth(logiExcluInds) = [];
           
           if ~isempty(obj.TrigData_Bin{1})
               obj.TrigData_Bin{1}(logiExcluInds,:) = [];
               obj.TrTrigSpikeTimes{1}(logiExcluInds,:) = [];
               if ~isempty(obj.TrigDataBin_FRSub{1})
                    obj.TrigDataBin_FRSub{1}(logiExcluInds,:) = [];
               end
           end
           if ~isempty(obj.TrigData_Bin{2})
               obj.TrigData_Bin{2}(logiExcluInds,:) = [];
               obj.TrTrigSpikeTimes{2}(logiExcluInds,:) = [];
               if ~isempty(obj.TrigDataBin_FRSub{2})
                    obj.TrigDataBin_FRSub{2}(logiExcluInds,:) = [];
               end
           end
           
        end
        
        function obj = Sesssptime_check_exclusion(obj)
            % exclusion some units based on the response pattern of each
            % single unit within the recording session, the spikes should
            % be uniformly distributed throughout the session period but
            % not onlt happens at a narrowd time window, which usually is a
            % indication of channel drifting
            if isempty(obj.RawClusANDchan_ids_All{1})
                obj.RawClusANDchan_ids_All = {obj.UsedClus_IDs, obj.ChannelUseds_id};
            end
            
            RemainedInds = SessResp_binnedcheckFun(obj);
            ExcludeInds = true(numel(obj.UsedClus_IDs),1);
            ExcludeInds(RemainedInds) = false;
            
            fprintf('Totally %d number of unit will be excluded because of unevened spike times.\n',sum(ExcludeInds));
            
            obj.UsedClus_IDs = obj.UsedClus_IDs(RemainedInds);
            obj.ChannelUseds_id = obj.ChannelUseds_id(RemainedInds);
            obj.UsedClusinds = obj.UsedClusinds(RemainedInds);
            obj.UsedChnDepth = obj.UsedChnDepth(RemainedInds);
            
            if ~isempty(obj.TrigData_Bin{1})
                obj.TrigData_Bin{1}(ExcludeInds,:) = [];
                obj.TrTrigSpikeTimes{1}(ExcludeInds,:) = [];
                if ~isempty(obj.TrigDataBin_FRSub{1})
                     obj.TrigDataBin_FRSub{1}(ExcludeInds,:) = [];
                end
            end
            if ~isempty(obj.TrigData_Bin{2})
                obj.TrigData_Bin{2}(ExcludeInds,:) = [];
                obj.TrTrigSpikeTimes{2}(ExcludeInds,:) = [];
                if ~isempty(obj.TrigDataBin_FRSub{2})
                     obj.TrigDataBin_FRSub{2}(ExcludeInds,:) = [];
                end
            end
            
        end
        
        function ClusChnDatas = SpikeWaveFun(obj,varargin)
            if isempty(obj.mmf)
                error('The bin file location is undefined, unbale to extract spike waveform.');
            end
            SpecificClus = obj.UsedClus_IDs;
            if nargin > 1
                if ~isempty(varargin{1})
                    SpecificClus = varargin{1};
                end
            end
            NumExtractClus = length(SpecificClus);
            
            % extrac the channel waveform for each detected spikes
            %            obj.NumOfWaves
            %            obj.WaveWinSamples
            ClusChnDatas = cell(NumExtractClus,3);
            for PlotClu = 1 : NumExtractClus
                Clu_index = obj.UsedClus_IDs(PlotClu);
                Channel_index = obj.ChannelUseds_id(PlotClu);
                SpikeTime_Alls = obj.SpikeTimeSample(obj.SpikeClus == Clu_index);
                SpikeTime_shuf = Vshuffle(SpikeTime_Alls);
                NumofSpikes = length(SpikeTime_Alls);
                SpikeDataMtx = nan(obj.NumOfWaves,length(obj.chnMaps),diff(obj.WaveWinSamples));
                UsedSpikeTimes = sort(SpikeTime_shuf(1 : min(NumofSpikes,obj.NumOfWaves)));
                for csp = 1 : min(NumofSpikes,obj.NumOfWaves)
                    cst = UsedSpikeTimes(csp);
                    SpikeDataMtx(csp,:,:) = double(obj.mmf.Data.x((obj.chnMaps+1),...
                        (cst+obj.WaveWinSamples(1)):(cst+obj.WaveWinSamples(2)-1)));
                end
                ClusChnDatas{PlotClu,1} = Clu_index;
                ClusChnDatas{PlotClu,2} = Channel_index;
                ClusChnDatas{PlotClu,3} = SpikeDataMtx;
            end
        end
        
        
        function chnwaveplot(obj,cluschnDatas,plotCluInds)
            Usedchannel_range = [-6,6];
            Clu_Index = cluschnDatas{plotCluInds,1};
            Channel_index = cluschnDatas{plotCluInds,2};
            ChnDatas = cluschnDatas{plotCluInds,3};
            
            ChannelMap_Index = find(obj.chnMaps == Channel_index-1);
            Usedchn_realInds = [max(1,ChannelMap_Index+Usedchannel_range(1)),...
                min(obj.NumChn,ChannelMap_Index+Usedchannel_range(2))];
            MapChannels = channelMap(Usedchn_realInds(1):Usedchn_realInds(2));
            
            Clu_channle_data = ChnDatas(:,Usedchn_realInds(1):Usedchn_realInds(2),:);
            %             CenterChannelData = squeeze(ChnDatas(:,ChannelMap_Index,:));
            
            AvgSpikes = squeeze(mean(Clu_channle_data));
            % Avg_centerchannelwave = mean(CenterChannelData);
            
            ybase = 0;
            yBaseAlls = zeros(length(MapChannels),1);
            CenterChannel_tempinds = ChannelMap_Index - Usedchn_realInds(1) + 1;
            NumSamples = size(AvgSpikes,2);
            
            figure;
            hold on
            for chn = 1 : length(MapChannels)
                plot(1:NumSamples,ybase+AvgSpikes(chn,:),'Color',[.7 .7 .7],'linewidth',0.6);
                WaveHeight = max(AvgSpikes(chn,:))-min(AvgSpikes(chn,:));
                text(NumSamples+5,ybase+WaveHeight,num2str(MapChannels(chn),'chn=%d'),'Color','m','FontSize',8);
                yBaseAlls(chn) = ybase;
                ybase = ybase + WaveHeight + 30;
            end
            plot((1:NumSamples),yBaseAlls(CenterChannel_tempinds)+AvgSpikes(CenterChannel_tempinds,:),'Color','k','linewidth',1.2);
            line([1,spikeStruct.sample_rate*1e-3],[yBaseAlls(1)- 15,yBaseAlls(1)- 15],'Color','k','linewidth',1.5);
            text(NumSamples+5,yBaseAlls(CenterChannel_tempinds+1)-30,num2str(MapChannels(CenterChannel_tempinds),'chn=%d'),'Color','c','FontSize',8);
            text(1,yBaseAlls(1)-30,'1 ms','Color','k','FontSize',8);
            % axis off;
            title(sprintf('Clu = %d',Clu_Index));
            
        end
        
        function obj = triggerOnsetTime(obj,TrigwaveScales,trigTime_ms,TriggerType)
            % TriggerType should be a string variable indicates what the
            % trigger onset time is indicated, either task or passive
            % sessions
            if ~exist('TriggerType','Var') || isempty(TriggerType)
                SessTypeInds = obj.CurrentSessInds;
            else
                SessTypeInds = strcmpi(TriggerType,obj.SessTypeStrs);
                if ~sum(SessTypeInds)
                    error('Unknowed trigger session type.');
                end
                obj.CurrentSessInds = SessTypeInds;
            end
            % trigTimeLen should in ms form
            if isempty(trigTime_ms)
                trigTime_ms = 2; % default is 2ms
            end
            
            if isempty(TrigwaveScales)
                try
                    trigScaleStrc = load(fullfile(obj.ksFolder,'..','TriggerDatas.mat'),'TriggerEvents');
                catch
                    trigScaleStrc = load(fullfile(obj.ksFolder,'TriggerDatas.mat'),'TriggerEvents');
                end
                TrigwaveScales = trigScaleStrc.TriggerEvents;
            end
            
            trigLen = trigTime_ms/1000*obj.SpikeStrc.sample_rate;
            TrigWaveAll_lens = TrigwaveScales(:,2) - TrigwaveScales(:,1);
            TrigWaveAll_lens(TrigWaveAll_lens < 0.0005*obj.SpikeStrc.sample_rate) = []; % exclude some unknowed zeros trigger events
            
            if length(trigLen) > 1
                % for task condition, the first 10 trial will have different trigger durations
                Trig_InitSeg_durs = (abs(TrigWaveAll_lens - trigLen(1)) < 2);
                Trig_InitSeg_consec = consecTRUECount(Trig_InitSeg_durs);
                Trig_Init_TrialEnd = find(Trig_InitSeg_consec == 10,1,'first'); % used the first 10 tirals
                if isempty(Trig_Init_TrialEnd)
                    warning('Failed to find enough lengthed consecutive trials.\n Please check your trigger duration data or input value.\n')
                end
                SessionTrStartInds = find(abs(TrigWaveAll_lens((Trig_Init_TrialEnd(1)+1):end) - trigLen(2)) < 2)+Trig_Init_TrialEnd(1);
                TrigWaveAll_lensEquals = [((Trig_Init_TrialEnd-9):Trig_Init_TrialEnd)';SessionTrStartInds];
                
                obj.UsedTrigOnTime{SessTypeInds} = TrigwaveScales(TrigWaveAll_lensEquals,1)/obj.SpikeStrc.sample_rate; % in seconds
            else
                % for passive condition, unique trigger duration
                TrigWaveAll_lensEquals = abs(TrigWaveAll_lens - trigLen) < 2;
                obj.UsedTrigOnTime{SessTypeInds} = TrigwaveScales(TrigWaveAll_lensEquals,1)/obj.SpikeStrc.sample_rate; % in seconds
            end
            
            
            fprintf('Totally %d number of triggers were detected.\n',length(obj.UsedTrigOnTime{SessTypeInds}));
            
        end
        
        function obj = TrigPSTH(obj,timeWin,smoothbin,varargin)
            % smoothbin should be a [a,b] vector, a must be larger than b,
            % indicating the smoothed bin steps
            
            % timeWin was also a 1-by-2 vector, indicates the time window
            % that was used to calculate the PSTH
            if isempty(timeWin)
                timeWin = [-1, 5]; % in seconds
            end
            if timeWin(1) >=0
                warning('There should be baseline period before each trigger time.');
                return;
            end
            IsEventDataGiven = 0;
            if length(varargin) > 0
                if ~isempty(varargin{1})
                    StimEventTime = varargin{1}/1000; % convert into seconds
                    IsEventDataGiven = 1;
                end
            end
            obj.psthTimeWin{obj.CurrentSessInds} = timeWin;
            if isempty(smoothbin)
                if isempty(obj.USedbin)
                    smoothbin = [50,10]; % in miliseconds
                else
                    smoothbin = obj.USedbin * 1000;
                end
            end
            smoothbin = smoothbin / 1000;
            smoothbinfactor = smoothbin(1)/smoothbin(2);
            
            if isempty(obj.UsedTrigOnTime{obj.CurrentSessInds})
                % load trigger scale time file
                trigScaleStrc = load(fullfile(obj.ksFolder,'..','TriggerDatas.mat'),'TriggerEvents');
                obj = obj.triggerOnsetTime(trigScaleStrc.TriggerEvents,[],[]);
            end
            if IsEventDataGiven
                if  length(StimEventTime) ~= length(obj.UsedTrigOnTime{obj.CurrentSessInds})
                    error('The input event time length %d is different from trigger trial number %d.',...
                        length(StimEventTime),length(obj.UsedTrigOnTime{obj.CurrentSessInds}));
                end
                obj.StimAlignedTime{obj.CurrentSessInds} = StimEventTime;
            end
            %%
            
            histbin = [timeWin(1):smoothbin(2):0,smoothbin(2):smoothbin(2):timeWin(2)];
            obj.BinCenters = histbin(1:end-1)+smoothbin(2)/2;
            obj.TriggerStartBin{obj.CurrentSessInds} = find(obj.BinCenters > 0,1,'first');
            
            TrigNums = length(obj.UsedTrigOnTime{obj.CurrentSessInds});
            TrigBinDatas = cell(TrigNums,2);
            NumUsedClus = length(obj.UsedClus_IDs);
            cTrig_TrialSPtimes = cell(NumUsedClus,TrigNums);
            for ctrig = 1 : TrigNums
                if IsEventDataGiven
                    % Select data range according to the event time
                    cTrigTime = obj.UsedTrigOnTime{obj.CurrentSessInds}(ctrig)+StimEventTime(ctrig); % in seconds
                    obj.TrigAlignType{obj.CurrentSessInds} = 'stim'; % ZerosBin is stimulus
                    if ctrig == 1
                        fprintf('Spiketimes was aligned to stimulus onset times!\n');
                    end
                else
                    % Select data range according to the trigger time
                    cTrigTime = obj.UsedTrigOnTime{obj.CurrentSessInds}(ctrig); % in seconds
                    obj.TrigAlignType{obj.CurrentSessInds} = 'trigger'; % zeros Bin is trigger
                    if ctrig == 1
                        fprintf('Spiketimes was aligned to trigger times!\n');
                    end
                end
                %
                cTrigTimeWin = cTrigTime + timeWin;
                WithinTimewinInds = obj.SpikeTimes > cTrigTimeWin(1) & obj.SpikeTimes < cTrigTimeWin(2);
                cTrigWin_spTimes = obj.SpikeTimes(WithinTimewinInds);
                cTrigWin_spClus = obj.SpikeClus(WithinTimewinInds);
                
                cTrig_binClusCount = nan(NumUsedClus,length(obj.BinCenters));
                cTrig_binCountSM = nan(NumUsedClus,length(obj.BinCenters));
                %
                for cClus = 1 : NumUsedClus
                    cClusTime = cTrigWin_spTimes(cTrigWin_spClus == obj.UsedClus_IDs(cClus)) - cTrigTime;
                    cTrig_TrialSPtimes(cClus,ctrig) = {cClusTime};
                    [bincounts,~] = histcounts(cClusTime,histbin);
                    
                    cTrig_binClusCount(cClus,:) = bincounts;
                    % before trig sps
                    % Do not use segment smooth method, may cause artifact
                    % at trigger position
                    %                     Beforecounts = bincounts(obj.BinCenters < 0);
                    %                     cTrig_binCountSM(cClus,obj.BinCenters < 0) = smooth(Beforecounts,smoothbinfactor);
                    %
                    %                     Aftercounts = bincounts(obj.BinCenters >= 0);
                    %                     cTrig_binCountSM(cClus,obj.BinCenters >= 0) = smooth(Aftercounts,smoothbinfactor);
                    cTrig_binCountSM(cClus,:) = smooth(bincounts,smoothbinfactor);
                end
                TrigBinDatas(ctrig,:) = {cTrig_binClusCount/smoothbin(2), cTrig_binCountSM/smoothbin(2)}; % convert into Hz
            end
            %%
            obj.USedbin = smoothbin;
            TrigData_Bins = cell(NumUsedClus,2);
            obj.TrTrigSpikeTimes{obj.CurrentSessInds} = cTrig_TrialSPtimes;
            for cClus = 1 : NumUsedClus
                cClus_trigTimeC = cellfun(@(x) x(cClus,:),TrigBinDatas(:,1),'uniformOutput',false);
                cClus_trigTimeSMC = cellfun(@(x) x(cClus,:),TrigBinDatas(:,2),'uniformOutput',false);
                cClus_trigTime = cell2mat(cClus_trigTimeC);
                cClus_trigTimeSM = cell2mat(cClus_trigTimeSMC);
                TrigData_Bins(cClus,:) = {cClus_trigTime, cClus_trigTimeSM};
            end
            obj.TrigData_Bin{obj.CurrentSessInds} = TrigData_Bins;
        end
        
        function obj = BaselineSubFun(obj, RawDatas, StimOnsetTimes)
            % substract the baseline FR to create response change datas
            BinWidth = obj.USedbin(2);
            EventBinLength = ceil((StimOnsetTimes/1000)/BinWidth);
            
            BaseFRSubData = RawDatas;
            TrNums = length(StimOnsetTimes);
            UnitNum = size(BaseFRSubData,1);
            
            for cUnit = 1 : UnitNum
                cUnitData = BaseFRSubData{cUnit,1};
                cUnitDataSM = BaseFRSubData{cUnit,2};
                for cTr = 1 : TrNums
                    cTrOnsetBin = EventBinLength(cTr);
                    cUnitData(cTr,:) = cUnitData(cTr,:) - mean(cUnitData(cTr,5:cTrOnsetBin)); % not start from inds 1, to avoid trigger signal artifact
                    cUnitDataSM(cTr,:) = cUnitDataSM(cTr,:) - mean(cUnitDataSM(cTr,5:cTrOnsetBin));
                end
                
                BaseFRSubData{cUnit,1} = cUnitData;
                BaseFRSubData{cUnit,2} = cUnitDataSM;
            end
            obj.TrigDataBin_FRSub{obj.CurrentSessInds} = BaseFRSubData;
            
        end
        
        function RawRasterplot(obj,EventsDelay,EventStrs,EventColors,StimRepeats)
            % spike raster plot for spike times
            if isempty(obj.TrTrigSpikeTimes{obj.CurrentSessInds})
                obj = TrigPSTH(obj,[],[]);
            end
            if size(EventsDelay,1) == 1
                EventsDelay = EventsDelay';
            end
            if size(obj.TrTrigSpikeTimes{obj.CurrentSessInds},2) ~= size(EventsDelay,1)
                error('The input event size isn''t fit with trigger event numbers.');
            end
            UnitChannelID = obj.ChannelUseds_id;
            if isempty(StimRepeats)
                %                 fprintf('Raw trial response colorplot only');
                RawColorPlotOnly = 1;
            else
                % also plot the trial response according to given repeats
                RawColorPlotOnly = 0;
                
                UniqueTypes = unique(StimRepeats(:,1));
                PlotSortInds = cell(length(UniqueTypes),1);
                TypeStimNum = zeros(length(UniqueTypes),1);
                for cStims = 1 : length(UniqueTypes)
                    cStimInds = find(StimRepeats(:,1) == UniqueTypes(cStims));
                    if size(StimRepeats,2) > 1
                        SortTypes = StimRepeats(cStimInds,2);
                        [~,SortedInds] = sort(SortTypes);
                        PlotSortInds{cStims} = cStimInds(SortedInds);
                    else
                        PlotSortInds{cStims} = SortedInds;
                    end
                    TypeStimNum(cStims) = numel(cStimInds);
                end
                PlotSortVec = cell2mat(PlotSortInds);
            end
            
            % after trigget event time
            EventTAfTrig = (EventsDelay/1000);% real time but not in bin mode, trigger time is 0
            %             TriggerTime = (obj.TriggerStartBin-1)*obj.USedbin(2);
            
            [unitNum, TrNum] = size(obj.TrTrigSpikeTimes{obj.CurrentSessInds});
            
            % processing event lines
            NumOfEvents = length(EventStrs);
            EventPlotBins = cell(NumOfEvents,2);
            for cEvent = 1 : NumOfEvents
                cEventBin =  EventTAfTrig(:,cEvent);
                cEventBin(cEventBin < 1e-8) = NaN;
                xEventBinMtx = [cEventBin';cEventBin';nan(1,TrNum)];
                EventPlotBins{cEvent,1} = xEventBinMtx(:);
                
                if ~RawColorPlotOnly
                    xSortEventBinMtx = [cEventBin(PlotSortVec)';cEventBin(PlotSortVec)';nan(1,TrNum)];
                    EventPlotBins{cEvent,2} = xSortEventBinMtx(:);
                end
            end
            yPlotMtx = [(1:TrNum)-0.5;(1:TrNum)+0.5;nan(1,TrNum)];
            yPlotBinInds = yPlotMtx(:);
            if ~isdir(fullfile(obj.ksFolder,'RawRasterPlot'))
                mkdir(fullfile(obj.ksFolder,'RawRasterPlot'));
            end
            %             cd(fullfile(obj.ksFolder,'RawRasterPlot'));
            
            for cUnit = 1 : unitNum
                %%
                cUnitData = obj.TrTrigSpikeTimes{obj.CurrentSessInds}(cUnit,:);
                cUnitChnID = UnitChannelID(cUnit);
                
                if RawColorPlotOnly
                    hcf = figure('position',[50 150 600 750],'visible','off'); %
                else
                    hcf = figure('position',[50 150 1250 750],'visible','off'); %
                    ax1 = subplot(121);
                end
                set(hcf,'paperpositionmode','manual');
                hold on
                currentPos = get(gca,'position');
                for cTrig = 1 : TrNum
                    cTrigSPtimes = cUnitData{cTrig};
                    if ~isempty(cTrigSPtimes)
                        TrNumSpikes = numel(cTrigSPtimes);
                        xtimes = ([cTrigSPtimes(:) cTrigSPtimes(:) nan(TrNumSpikes,1)])';
                        yticks = ([zeros(TrNumSpikes,1)+cTrig-0.3,zeros(TrNumSpikes,1)+cTrig+0.3,nan(TrNumSpikes,1)])';
                        plot(xtimes(:),yticks(:),'k','linewidth',1.2);
                    end
                end
                %                 set(hcf,'visible','on')
                line([0 0],[0.5 TrNum+0.5],'Color','g','linewidth',1);
                hhl = [];
                for cEvent = 1 :NumOfEvents
                    hl = plot(EventPlotBins{cEvent,1},yPlotBinInds,'Color',EventColors{cEvent},'linewidth',1.4);
                    hhl = [hhl,hl];
                end
                
                set(gca,'xlim',obj.psthTimeWin{obj.CurrentSessInds},'ylim',[0.5 TrNum+0.5]);
                xlabel('Time (s)');
                ylabel('# Trials');
                title(sprintf('Unit %d, chn %d',cUnit,cUnitChnID));
                if RawColorPlotOnly
                    legend(hhl,EventStrs(:),'Box','Off','location','NortheastOutside');
                    set(gca,'position',currentPos)
                end
                
                % ############################# sortted plot if given
                if ~RawColorPlotOnly
                    ax2 = subplot(122);
                    hold on
                    SortUnitSPtimes = obj.TrTrigSpikeTimes{obj.CurrentSessInds}(cUnit,PlotSortVec);
                    for cTrig = 1 : TrNum
                        cTrigSPtimes = SortUnitSPtimes{cTrig};
                        if ~isempty(cTrigSPtimes)
                            TrNumSpikes = numel(cTrigSPtimes);
                            xtimes = ([cTrigSPtimes(:) cTrigSPtimes(:) nan(TrNumSpikes,1)])';
                            yticks = ([zeros(TrNumSpikes,1)+cTrig-0.3,zeros(TrNumSpikes,1)+cTrig+0.3,nan(TrNumSpikes,1)])';
                            plot(xtimes(:),yticks(:),'k','linewidth',1.2);
                        end
                    end
                    
                    line([0,0],[0.5 TrNum+0.5],'Color','g','linewidth',1);
                    RawImPos = get(ax2,'position');
                    hl2 = [];
                    for cEvent = 1 :NumOfEvents
                        hl = plot(EventPlotBins{cEvent,2},yPlotBinInds,'Color',EventColors{cEvent},'linewidth',1.4);
                        hl2 = [hl2,hl];
                    end
                    % add segration lines
                    SegLinePos = cumsum(TypeStimNum);
                    for cType = 1 : length(TypeStimNum)
                        line(obj.psthTimeWin{obj.CurrentSessInds},[SegLinePos(cType) SegLinePos(cType)],...
                            'Color','c','linewidth',1.2);
                    end
                    
                    %                     legend(hhl,EventStrs(:),'Box','Off','location','NortheastOutside');
                    set(gca,'xlim',obj.psthTimeWin{obj.CurrentSessInds},'ylim',[0.5 TrNum+0.5]);
                    set(gca,'YDir','reverse')
                    xlabel('Time (s)');
                    ylabel('# Sort Trials');
                    title(sprintf('Unit %d, chn %d',cUnit,cUnitChnID));
                    
                    lax = legend(hl2,EventStrs(:),'Box','Off','location','SouthOutside','FontSize',8);
                    set(lax,'position',get(lax,'position')+[-0.2 -0.07 0 0]);
                    
                    set(ax2,'position',RawImPos);
                end
                %%
                savefileName = fullfile(obj.ksFolder,'RawRasterPlot',sprintf('Unit%03d raw spike raster color plot',obj.UsedClus_IDs(cUnit)));
                saveas(hcf,savefileName);
                saveas(hcf,savefileName,'png');
                close(hcf);
                %                 saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit));
            end
            
        end
        function RawRespPreview(obj,EventsDelay,EventStrs,EventColors,StimRepeats)
            % this function is used to plot the raw response color plot
            % according to the real trial sequency, for a preview to see
            % whether the unit activity is persistant or whether there are
            % unexpected response level change as the trial increases
            if isempty(obj.TrigData_Bin{obj.CurrentSessInds}) || isempty(obj.UsedTrigOnTime{obj.CurrentSessInds})
                obj = TrigPSTH(obj,[],[]);
            end
            if size(EventsDelay) == 1
                EventsDelay = EventsDelay';
            end
            if length(obj.UsedTrigOnTime) ~= size(EventsDelay,1)
                error('The input event size isn''t fit with trigger event numbers.');
            end
            UnitChannelID = obj.ChannelUseds_id;
            if isempty(StimRepeats)
                %                 fprintf('Raw trial response colorplot only');
                RawColorPlotOnly = 1;
            else
                % also plot the trial response according to given repeats
                RawColorPlotOnly = 0;
                
                UniqueTypes = unique(StimRepeats(:,1));
                PlotSortInds = cell(length(UniqueTypes),1);
                TypeStimNum = zeros(length(UniqueTypes),1);
                for cStims = 1 : length(UniqueTypes)
                    cStimInds = find(StimRepeats(:,1) == UniqueTypes(cStims));
                    if size(StimRepeats,2) > 1
                        SortTypes = StimRepeats(cStimInds,2);
                        [~,SortedInds] = sort(SortTypes);
                        PlotSortInds{cStims} = cStimInds(SortedInds);
                    else
                        PlotSortInds{cStims} = SortedInds;
                    end
                    TypeStimNum(cStims) = numel(cStimInds);
                end
                PlotSortVec = cell2mat(PlotSortInds);
            end
            
            % after trigget event bin
            BinWidth = obj.USedbin(2);
            EventBinLength = ((EventsDelay/1000))+(obj.TriggerStartBin{obj.CurrentSessInds}-1)*obj.USedbin(2);% real time but not in bin mode
            TriggerTime = (obj.TriggerStartBin{obj.CurrentSessInds}-1)*obj.USedbin(2);
            if isempty(obj.TrigDataBin_FRSub{obj.CurrentSessInds})
                obj = obj.BaselineSubFun(obj.TrigData_Bin{obj.CurrentSessInds}, EventsDelay(:,1)+...
                    obj.TriggerStartBin{obj.CurrentSessInds}-1);
            end
            PlotDataType = 1; % 1 indicates unsmoothed raw plot, 2 indicates smoothed plot
            SMBinDataMtx = permute(cat(3,obj.TrigDataBin_FRSub{obj.CurrentSessInds}{:,PlotDataType}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
            [TrNum, unitNum, BinNum] = size(SMBinDataMtx);
            
            % processing event lines
            NumOfEvents = length(EventStrs);
            EventPlotBins = cell(NumOfEvents,2);
            for cEvent = 1 : NumOfEvents
                cEventBin =  EventBinLength(:,cEvent);
                cEventBin(cEventBin < 1e-8) = NaN;
                xEventBinMtx = [cEventBin';cEventBin';nan(1,TrNum)];
                EventPlotBins{cEvent,1} = xEventBinMtx(:);
                
                if ~RawColorPlotOnly
                    xSortEventBinMtx = [cEventBin(PlotSortVec)';cEventBin(PlotSortVec)';nan(1,TrNum)];
                    EventPlotBins{cEvent,2} = xSortEventBinMtx(:);
                end
            end
            yPlotMtx = [(1:TrNum)-0.5;(1:TrNum)+0.5;nan(1,TrNum)];
            yPlotBinInds = yPlotMtx(:);
            if PlotDataType == 1
                if ~isdir(fullfile(obj.ksFolder,'RawRespPlots_unSM'))
                    mkdir(fullfile(obj.ksFolder,'RawRespPlots_unSM'));
                end
                savefolder = (fullfile(obj.ksFolder,'RawRespPlots_unSM'));
            elseif PlotDataType == 2
                if ~isdir(fullfile(obj.ksFolder,'RawRespPlots'))
                    mkdir(fullfile(obj.ksFolder,'RawRespPlots'));
                end
                savefolder = (fullfile(obj.ksFolder,'RawRespPlots'));
            end
            
            %             EventColors = blue2red_2(NumOfEvents*2, 0.7);
            %             UsedEventColors = EventColors((NumOfEvents+1):end,:);
            for cUnit = 1 : unitNum
                %%
                cUnitData = squeeze(SMBinDataMtx(:,cUnit,:));
                cUnitChnID = UnitChannelID(cUnit);
                xTimes = (1:BinNum)*BinWidth;
                ytickss = 1:TrNum;
                if RawColorPlotOnly
                    hcf = figure('position',[50 150 450 750],'visible','off');
                else
                    hcf = figure('position',[50 150 900 750],'visible','off');
                    ax1 = subplot(121);
                end
                set(hcf,'paperpositionmode','manual');
                hold on
                currentPos = get(gca,'position');
                imagesc(xTimes,ytickss,cUnitData,[0 max(0.1,prctile(cUnitData(:),98))]);
                line([TriggerTime TriggerTime],[0.5 TrNum+0.5],'Color','g','linewidth',1);
                hhl = [];
                for cEvent = 1 :NumOfEvents
                    hl = plot(EventPlotBins{cEvent,1},yPlotBinInds,'Color',EventColors{cEvent},'linewidth',1.4);
                    hhl = [hhl,hl];
                end
                
                set(gca,'xlim',[xTimes(1) xTimes(end)],'ylim',[0.5 TrNum+0.5]);
                set(gca,'YDir','reverse')
                xlabel('Time (s)');
                ylabel('# Trials');
                title(sprintf('Unit %d, chn %d',cUnit,cUnitChnID));
                if RawColorPlotOnly
                    legend(hhl,EventStrs(:),'Box','Off','location','NortheastOutside');
                    hBar = colorbar;
                    oldPos = get(hBar,'position');
                    set(hBar,'position',[oldPos(1)+0.1 oldPos(2) oldPos(3)*0.8 oldPos(4)*0.4]);
                    set(gca,'position',currentPos)
                end
                
                % ############################# sortted plot if given
                if ~RawColorPlotOnly
                    ax2 = subplot(122);
                    hold on
                    imagesc(xTimes,ytickss,cUnitData(PlotSortVec,:),[0 max(0.1,prctile(cUnitData(:),98))]);
                    line([TriggerTime TriggerTime],[0.5 TrNum+0.5],'Color','g','linewidth',1);
                    RawImPos = get(ax2,'position');
                    hl2 = [];
                    for cEvent = 1 :NumOfEvents
                        hl = plot(EventPlotBins{cEvent,2},yPlotBinInds,'Color',EventColors{cEvent},'linewidth',1.8);
                        hl2 = [hl2,hl];
                    end
                    % add segration lines
                    SegLinePos = cumsum(TypeStimNum);
                    for cType = 1 : length(TypeStimNum)
                        line([xTimes(1) xTimes(end)],[SegLinePos(cType) SegLinePos(cType)],...
                            'Color','c','linewidth',1.4);
                    end
                    
                    %                     legend(hhl,EventStrs(:),'Box','Off','location','NortheastOutside');
                    set(gca,'xlim',[xTimes(1) xTimes(end)],'ylim',[0.5 TrNum+0.5]);
                    set(gca,'YDir','reverse')
                    xlabel('Time (s)');
                    ylabel('# Sort Trials');
                    title(sprintf('Unit %d, chn %d',cUnit,cUnitChnID));
                    
                    lax = legend(hl2,EventStrs(:),'Box','Off','location','SouthOutside','FontSize',8);
                    set(lax,'position',get(lax,'position')+[-0.2 -0.07 0 0]);
                    hBar = colorbar;
                    oldPos = get(hBar,'position');
                    set(hBar,'position',[oldPos(1)+0.08 oldPos(2)+0.05 oldPos(3)*0.8 oldPos(4)*0.3]);
                    set(ax2,'position',RawImPos);
                end
                %%
                saveName = fullfile(savefolder,sprintf('ROI%03d raw spike change color plot',obj.UsedClus_IDs(cUnit)));
                saveas(hcf,saveName);
                saveas(hcf,saveName,'png');
                close(hcf);
                %                 saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit));
            end
            
        end
        
        
        function [obj, varargout] = EventsPSTHplot(obj,EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,varargin)
            % EventsDelay should be a n-by-p matrix, in milisecond format. n is the number of
            % trials, which should be the same as trigger number; p is the
            % number of events types. for example, the passive listening
            % session usually have p=2, which is the sound onset and offset
            % time; the task session should have p >=2,
            % which includes events like stim, choice, reward and so on
            
            % DUE TO THE BINNED DATA CREATION METHOD, THE FIRST COLUMN MUST
            % BE STIMULUS ONSET TIME.
            
            % AlignEvent indicate which of the event(s) will be used for
            % alignment, the default value is 1, which usually is the stim
            % event
            
            % RepeatTypes is the repeat values for different trials, which
            % should includes stimulus or stimulus and choices.
            
            % EventColors indicates the plot color for each events
            
            % if varargin isn't empty, some extra input can be given for
            % tiral specific plots, the second input can be the foldername str that the user wants to use
            
            
            if isempty(obj.TrigData_Bin{obj.CurrentSessInds}) || isempty(obj.UsedTrigOnTime{obj.CurrentSessInds})
                obj = TrigPSTH(obj,[],[]);
                obj.TrigAlignType{obj.CurrentSessInds} = 'trigger';
            end
            if size(EventsDelay,1) < size(EventsDelay,2)
                EventsDelay = EventsDelay';
            end
            
            PlotTrInds = true(size(EventsDelay,1),1);
            if ~isempty(varargin)
                if ~isempty(varargin{1})
                    PlotTrInds = varargin{1};
                end
            end
            EventsDelay = EventsDelay(PlotTrInds,:);
            RepeatTypes = RepeatTypes(PlotTrInds,:);
            
            SaveFolderNames = 'EventAlignPlot';
            if length(varargin) > 1
                if ~isempty(varargin{2})
                    SaveFolderNames = varargin{2};
                end
            end
            
            IsLickPlot = 0;
            if length(varargin) > 2
                if ~isempty(varargin{3})
                    IsLickPlot = 1;
                    LickTimeStrc = varargin{3};
                end
            end
            IsChnAreaGiven = 0;
            if length(varargin) > 3
                if ~isempty(varargin{4})
                    IsChnAreaGiven = 1;
                    ChnAreaStrs = varargin{4};
                    obj.ChannelAreaStrs = ChnAreaStrs;
                end
            end
            if ~IsChnAreaGiven && ~isempty(obj.ChannelAreaStrs)
                IsChnAreaGiven = 1;
                ChnAreaStrs = obj.ChannelAreaStrs;
            end
            if IsLickPlot
                UsedLickStrc = LickTimeStrc(PlotTrInds);
            end
            
            if length(obj.UsedTrigOnTime{obj.CurrentSessInds}(PlotTrInds)) ~= size(EventsDelay,1)
                error('The input event size isn''t fit with trigger event numbers.');
            end
            if size(EventsDelay,2) ~= size(EventColors,2)
                error('Event column number is different from dscription color str numbers.');
            end
            if isempty(AlignEvent)
                AlignEvent = 1;
            end
            if AlignEvent > size(EventsDelay,2)
                error('The aligned event index (%d) should less than total events types (%d).',AlignEvent,size(EventsDelay,2));
            end
            RepeatDespStr = RepeatStr;
            EventDespStrs = EventColors(1,:);
            EventPlotColors = EventColors(2,:);
            % after trigget event bin
            BinWidth = obj.USedbin(2);
            
            % sort and align the binned data according to the event times
            % only input trials will be plotted
            SMBinDataMtx = permute(cat(3,obj.TrigData_Bin{obj.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
            SMBinDataMtx = SMBinDataMtx(PlotTrInds,:,:);
            [TrNum, unitNum, BinNum] = size(SMBinDataMtx);
            
            % firstly excluded zeros time events
            ExcludeInds = sum(EventsDelay < 1e-4, 2);
            if sum(ExcludeInds)
                EventsDelay(ExcludeInds,:) = [];
                TrNum = TrNum - sum(ExcludeInds);
                SMBinDataMtx(ExcludeInds,:,:) = [];
                RepeatTypes(ExcludeInds,:) = [];
                UsedLickStrc(ExcludeInds) = [];
            end
            
            if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                % exclude some long-delayed onset bins
                ZeroPointBin = obj.TriggerStartBin{obj.CurrentSessInds};
                EventBinLength = ceil((EventsDelay/1000)/BinWidth)+ZeroPointBin; % aligned to trigger onset time, plus trigger onset time bin
                OutlierEventBins = sum(EventBinLength > (BinNum - 1),2);
                if sum(OutlierEventBins)
                    ExcludeInds = OutlierEventBins > 0;
                    EventBinLength(ExcludeInds,:) = [];
                    TrNum = TrNum - sum(ExcludeInds);
                    SMBinDataMtx(ExcludeInds,:,:) = [];
                    RepeatTypes(ExcludeInds,:) = [];
                    UsedLickStrc(ExcludeInds) = [];
                end
                AlignedEvents = EventBinLength(:,AlignEvent);
                TrShifts = AlignedEvents - min(AlignedEvents); % bin number to be shifted for each trial
                AllEvent_shifts = max(1,bsxfun(@minus,EventBinLength,TrShifts)); % memory friendly way
                %             AllEvent_shifts = EventBinLength - repmat(TrShifts,1,size(EventBinLength,2)); % All event shifts according to aligned event
                NumPlotEvents = size(AllEvent_shifts,2);
                
            elseif strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'stim')
                % align all events to stim events at first, as the data was
                % extracted based on stimulus onset time
                EventBinLength = ceil((EventsDelay/1000)/BinWidth);
                ComUsedEventBin = min(EventBinLength(:,1));
                TrEventAligned = bsxfun(@minus,EventBinLength, EventBinLength(:,1)-ComUsedEventBin) - ComUsedEventBin; % zero time to aligned to stimOnset time
                ZeroPointBin = obj.TriggerStartBin{obj.CurrentSessInds};
                EventBinLengthBack = EventBinLength; % for debug, not used
                EventBinLength = TrEventAligned + obj.TriggerStartBin{obj.CurrentSessInds}; % Event time bin relative to matrix start inds
                %%
                OutlierEventBins = sum(EventBinLength > (BinNum - 1),2);
                if sum(OutlierEventBins)
                    ExcludeInds = OutlierEventBins > 0;
                    EventBinLength(ExcludeInds,:) = [];
                    TrNum = TrNum - sum(ExcludeInds);
                    SMBinDataMtx(ExcludeInds,:,:) = [];
                    RepeatTypes(ExcludeInds,:) = [];
                    UsedLickStrc(ExcludeInds) = [];
                end
                AlignedEvents = EventBinLength(:,AlignEvent);
                TrShifts = AlignedEvents - min(AlignedEvents); % bin number to be shifted for each trial
                AllEvent_shifts = max(1,bsxfun(@minus,EventBinLength,TrShifts)); % memory friendly way, reset to 1if there are negtive values
                %             AllEvent_shifts = EventBinLength - repmat(TrShifts,1,size(EventBinLength,2)); % All event shifts according to aligned event
                NumPlotEvents = size(AllEvent_shifts,2);
                
            end
            %%
            if IsLickPlot
                LRLick_alignBins = cell(TrNum,2);
                % align lick times
                for cTr = 1 : TrNum
                    cTrLeftLick = UsedLickStrc(cTr).LickTimeLeft;
                    if ~isempty(cTrLeftLick)
                        LeftTimeBin = ceil((cTrLeftLick/1000)/BinWidth);
                        if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                            LRLick_alignBins{cTr,1} = LeftTimeBin(:) - TrShifts(cTr) - 1 + obj.TriggerStartBin{obj.CurrentSessInds}; % correct to matrix start
                        else
                            LRLick_alignBins{cTr,1} = LeftTimeBin(:) - EventBinLengthBack(cTr,1) - TrShifts(cTr) - 1 ...
                                 + obj.TriggerStartBin{obj.CurrentSessInds};
                        end
                    end
                    
                    cTrRightLick = UsedLickStrc(cTr).LickTimeRight;
                    if ~isempty(cTrRightLick)
                        RightTimeBin = ceil((cTrRightLick/1000)/BinWidth);
                        if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                            LRLick_alignBins{cTr,2} = RightTimeBin(:) - TrShifts(cTr) - 1 + obj.TriggerStartBin{obj.CurrentSessInds};
                        else
                            LRLick_alignBins{cTr,2} = RightTimeBin(:) - TrShifts(cTr) - 1 - ...
                                EventBinLengthBack(cTr,1) + obj.TriggerStartBin{obj.CurrentSessInds};
                        end
                    end
                    
                end
            end
            %%
            if BinNum < max(AlignedEvents)
                error('The maximum event time length is longer than binned data length.');
            end
            
            [SortEventInds,AlignedSortDatas,AlignedEventOnBin,AlignSortEventsBin,UsedBinLength] = obj.AlignANDsortInds(SMBinDataMtx,...
                AlignedEvents,EventBinLength,AlignEvent,AllEvent_shifts,TrShifts);
            
            SortRepeats = RepeatTypes(SortEventInds,:);
            if IsLickPlot
                LRLick_alignBinsSort = LRLick_alignBins(SortEventInds,:);
            end
            %%
            if size(RepeatTypes,2) == 2
                SegNums = 2;
                Seg1_types = unique(SortRepeats(:,1));
                Seg2_types = unique(SortRepeats(:,2));
                Seg2TypeNum = length(Seg2_types);
                if Seg2TypeNum > 3
                    warning('Two much segments for the second repeat type, the figure will be too large to be displayed.\n');
                    return;
                end
                % calculate the segments inds
                SegTypeInds = cell(numel(Seg1_types),numel(Seg2_types));
                for cSeg1 = 1 : numel(Seg1_types)
                    for cSeg2 = 1:numel(Seg2_types)
                        SegTypeInds{cSeg1,cSeg2} = find(SortRepeats(:,1) == Seg1_types(cSeg1) & ...
                            SortRepeats(:,2) == Seg2_types(cSeg2));
                    end
                end
                
            elseif size(SortRepeats,2) == 1
                SegNums = 1;
                Seg1_types = unique(SortRepeats(:,1));
                Seg2TypeNum = 1;
                Seg2_types = unique(SortRepeats(:,2));
                
                SegTypeInds = cell(numel(Seg1_types),1);
                for cSeg1 = 1 : numel(Seg1_types)
                    SegTypeInds{cSeg1,1} = find(SortRepeats(:,1) == Seg1_types(Seg1_types(cSeg1)));
                end
                
            else
                error('Unsupported segments numbers, please check your inputs.');
            end
            %%
            NumSingleUnits = size(obj.TrigData_Bin{obj.CurrentSessInds},1);
            %             xTs = obj.psthTimeWin(1):obj.USedbin(2):(obj.psthTimeWin(2)-obj.USedbin(2));
            
            xTs = ((1:UsedBinLength) - AlignedEventOnBin)*obj.USedbin(2);
            xTs = xTs + obj.USedbin(2)/2; % convert to bin center
            ChoiceStrs = {'LeftC','RightC'};
            BloundaryBlockStrs = {'LowBound','HighBound'};
            if isempty(obj.SessBlockTypes)
                cBlockTypeStrs = '';
            else
                cBlockTypeStrs = BloundaryBlockStrs{obj.SessBlockTypes+1};
            end
            Seg1TypeNum = length(Seg1_types);
            SegMeanTraces = cell(NumSingleUnits,Seg1TypeNum,Seg2TypeNum,3);
            for cUnit = 1 : NumSingleUnits
                cUnitData = squeeze(AlignedSortDatas(:,cUnit,:)); % sorted by events time
                UnitPlotScale = [0 max(prctile(cUnitData(:),99),1)];
                
                hcf = figure('position',[100 100 1450 300],'visible','off'); %,'visible','off'
                IstitleAdded = 0;
                for c1Seg = 1 :Seg1TypeNum  % normally stimulus segments
                    %                     c1SegInds = SortRepeats(:,1) == Seg1_types(c1Seg);
                    if Seg2TypeNum > 1
                        set(hcf,'position',[100 100 1450 300*Seg2TypeNum]);
                    end
                    for c2Seg = 1 : Seg2TypeNum % normally choice segments
                        %                         c2Seg_Inds = SortRepeats(:,2) == Seg2_types(c2Seg);
                        cComSeg_datas = cUnitData(SegTypeInds{c1Seg,c2Seg},:);
                        if isempty(cComSeg_datas)
                            if c1Seg == 1
                                ax = subplot(Seg2TypeNum,Seg1TypeNum,(c2Seg-1)*Seg1TypeNum+c1Seg);
                                if max(Seg2_types) > 2
                                    ylabel(ax,sprintf('%d\n # Trials',Seg2_types(c2Seg)));
                                else
                                    ylabel(ax,sprintf('%s\n # Trials',ChoiceStrs{Seg2_types(c2Seg)+1}));
                                end
                            end
                            continue;
                        end
                        cComSeg_Events = AlignSortEventsBin(SegTypeInds{c1Seg,c2Seg},:);
                        cComSeg_TrNums = size(cComSeg_Events,1);
                        if IsLickPlot
                            cSegLicks_L =  LRLick_alignBinsSort(SegTypeInds{c1Seg,c2Seg},1);
                            LIndexedPlotVec = obj.Cell2indexPlots(cSegLicks_L);
                            cSegLicks_R =  LRLick_alignBinsSort(SegTypeInds{c1Seg,c2Seg},2);
                            RIndexedPlotVec = obj.Cell2indexPlots(cSegLicks_R);
                        end
                        
                        %                         c2SegTypeStr = RepeatDespStr{2};
                        %                         c2SegPlotColor = EventPlotColors{2};
                        %
                        ax = subplot(Seg2TypeNum,Seg1TypeNum,(c2Seg-1)*Seg1TypeNum+c1Seg);
                        hold on
                        imagesc(ax,xTs,1:cComSeg_TrNums,cComSeg_datas,UnitPlotScale);
                        if c1Seg == 1 && c2Seg == 1
                            hlAll = [];
                        end
                        for cEvent = 1 : NumPlotEvents
                            % plot all events
                            cEventBins = (cComSeg_Events(:,cEvent)-AlignedEventOnBin)'* BinWidth;
                            PlotMtx_x = [cEventBins;cEventBins;nan(1,cComSeg_TrNums)];
                            Plot_x = PlotMtx_x(:);
                            PlotMtx_y = [(1:cComSeg_TrNums)-0.5;(1:cComSeg_TrNums)+0.5;nan(1,cComSeg_TrNums)];
                            Plot_y = PlotMtx_y(:);
                            hl = plot(ax,Plot_x,Plot_y,'Color',EventPlotColors{cEvent},'linewidth',1.2);
                            if c1Seg == 1 && c2Seg == 1
                                hlAll = [hlAll,hl];
                            end
                        end
                        if IsLickPlot
                            if ~isempty(LIndexedPlotVec)
                                %                                 LeftLickInds_x = ([LIndexedPlotVec(:,1),LIndexedPlotVec(:,1),nan(numel(LIndexedPlotVec),1)])';
                                %                                 LeftLickInds_y = ([LIndexedPlotVec(:,2)-0.5,LIndexedPlotVec(:,2)+0.5,nan(numel(LIndexedPlotVec),1)])';
                                %                                 LeftLick_x = LeftLickInds_x(:);
                                %                                 LeftLick_y = LeftLickInds_y(:);
                                plot((LIndexedPlotVec(:,1) - AlignedEventOnBin)*BinWidth,LIndexedPlotVec(:,2),'c.','MarkerSize',4);
                            end
                            
                            if ~isempty(RIndexedPlotVec)
                                plot((RIndexedPlotVec(:,1) - AlignedEventOnBin)*BinWidth,RIndexedPlotVec(:,2),'.','color',[1,.7,.2],'MarkerSize',4);
                            end
                            
                        end
                        
                        set(ax,'xlim',[xTs(1) xTs(end)],'ylim',[0.5 cComSeg_TrNums+0.5],'xtick',0:floor(xTs(end)));
                        set(ax,'YDir','reverse');
                        %
                        if c1Seg == 1
                            if max(Seg2_types) > 2
                                ylabel(ax,sprintf('%d\n # Trials',Seg2_types(c2Seg)));
                            else
                                ylabel(ax,sprintf('%s\n # Trials',ChoiceStrs{Seg2_types(c2Seg)+1}));
                            end
                        end
                        if c2Seg == Seg2TypeNum
                            xlabel(ax,'Times(s)');
                        end
                        if c2Seg == 1
                            title(sprintf('%d',Seg1_types(c1Seg)));
                            IstitleAdded = 1;
                        end
                        if ~IstitleAdded && c2Seg > 1
                            title(sprintf('%d',Seg1_types(c1Seg)));
                            IstitleAdded = 1;
                        end
                        
                        if c1Seg == Seg1TypeNum && c2Seg == Seg2TypeNum
                            haxisPos = get(ax,'position');
                            hbar = colorbar;
                            cBarPos = get(hbar,'position');
                            if Seg2TypeNum == 1
                                set(hbar,'position',cBarPos+[0.05 0 cBarPos(3) -0.5*cBarPos(4)]);
                            else
                                set(hbar,'position',cBarPos+[0.05 0 cBarPos(3)*2 0.1*cBarPos(4)]);
                            end
                            set(get(hbar,'Title'),'String','Frate');
                            set(ax,'position',haxisPos);
                            
                            leg = legend(hlAll,EventDespStrs,'location','Southwest','box','off');
                            oldLegPos = get(leg,'position');
                            set(leg,'position',[0.02 0.05 oldLegPos(3) oldLegPos(4)]);
                        end
                        
                    end
                    IstitleAdded = 0;
                end
                if ~IsChnAreaGiven
                    annotation(hcf,'textbox',[0.475,0.68,0.3,0.3],'String',sprintf('Unit %d, Chn %d, (%s)',...
                        obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)),cBlockTypeStrs,'FitBoxToText','on','EdgeColor',...
                        'none','FontSize',12);
                else
                    cChnAreaIndex = ChnAreaStrs{obj.ChannelUseds_id(cUnit),1};
                    if cChnAreaIndex < 0
                        ChnAreaStr = ['(',ChnAreaStrs{obj.ChannelUseds_id(cUnit),3},')'];
                    else
                        ChnAreaStr = ChnAreaStrs{obj.ChannelUseds_id(cUnit),3};
                    end
                    annotation(hcf,'textbox',[0.01,0.32,0.05,0.3],'String',sprintf('(%s), \nUnit %d, \nChn %d \nArea :\n%s',...
                        cBlockTypeStrs,obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit),ChnAreaStr),'FitBoxToText','on','EdgeColor',...
                        'none','FontSize',10,'Color',[0.8 0.5 0.2],'FitBoxToText','on');
                    
                end
                
                %%
                % add a mean trace plot for current unit, aligned to
                % aligned event time
                hMeanf = figure('position',[100 100 1450 300],'visible','off'); %,'visible','off'
                yaxisScales = zeros(Seg1TypeNum,2);
                IsLegendExist = 0;
                TraceAxess = [];
                for cSeg1Inds = 1 :Seg1TypeNum  % normally stimulus segments
                    ax = subplot(1,Seg1TypeNum,cSeg1Inds);
                    hold on;
                    TraceColors = jet(Seg2TypeNum);
                    
                    hlAlls = [];
                    
                    for cSeg2Inds = 1 : Seg2TypeNum
                        cComSeg_datas = cUnitData(SegTypeInds{cSeg1Inds,cSeg2Inds},:);
                        if isempty(cComSeg_datas)
                            continue;
                        end
                        
                        cComNums = size(cComSeg_datas,1);
                        if cComNums > 2
                            %                             SegTraceMean = (mean(cComSeg_datas));
                            SegTraceMean = (smooth(mean(cComSeg_datas),5))';
                            SegTraceSem = (std(cComSeg_datas)/sqrt(cComNums));
                            
                            patch_x = [xTs,fliplr(xTs)];
                            patch_y = [SegTraceMean-SegTraceSem,fliplr(SegTraceMean+SegTraceSem)];
                            patch(ax,patch_x,patch_y,1,'FaceColor',[.8 .8 .8],'EdgeColor','none');
                            
                            hl = plot(ax,xTs,SegTraceMean,'Color',TraceColors(cSeg2Inds,:),'linewidth',1);
                            if ~IsLegendExist
                                hlAlls = [hlAlls,hl];
                            end
                            set(ax,'xlim',[xTs(1) xTs(end)],'xtick',0:floor(xTs(end)));
                        else
                            SegTraceMean = NaN;
                            SegTraceSem = NaN;
                        end
                        SegMeanTraces{cUnit,cSeg1Inds,cSeg2Inds,1} = SegTraceMean;
                        SegMeanTraces{cUnit,cSeg1Inds,cSeg2Inds,2} = SegTraceSem;
                        SegMeanTraces{cUnit,cSeg1Inds,cSeg2Inds,3} = cComNums;
                    end
                    yaxisScales(cSeg1Inds,:) = get(ax,'ylim');
                    TraceAxess = [TraceAxess,ax];
                    if cSeg1Inds == 1
                        ylabel(sprintf('Unit %d, Chn %d',obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)));
                    else
                        set(ax,'yticklabel',{});
                    end
                    if length(hlAlls) == Seg2TypeNum
                        LegStrs = num2str(Seg2_types(:),[RepeatStr{2},'=%d']);
                        legend(ax,hlAlls,LegStrs,'location','northeast','box','off','autoupdate','off');
                        IsLegendExist = 1;
                        hlAlls = [];
                    end
                end
                
                CommonYScales = [max(min(yaxisScales(:,1)),0),max(yaxisScales(:,2))];
                for cSeg1Inds = 1 :Seg1TypeNum
                    set(TraceAxess(cSeg1Inds),'ylim',CommonYScales);
                    line(TraceAxess(cSeg1Inds),[0 0],...
                        CommonYScales,'Color','k','linewidth',0.8,'linestyle','--');
                end
                
                annotation(hMeanf,'textbox',[0.50,0.71,0.3,0.3],'String',sprintf('Unit %d, Chn %d, (%s)',...
                    obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit),cBlockTypeStrs),'FitBoxToText','on','EdgeColor',...
                    'none','FontSize',12);
                
                %%
                if ~isdir(fullfile(obj.ksFolder,SaveFolderNames))
                    mkdir(fullfile(obj.ksFolder,SaveFolderNames));
                end
                %                  cd(fullfile(obj.ksFolder,SaveFolderNames));
                ColorSaveName = sprintf('Unit%3d Eventaligned color plots',obj.UsedClus_IDs(cUnit));
                ColorSaveName = fullfile(obj.ksFolder,SaveFolderNames,ColorSaveName);
                saveas(hcf,ColorSaveName);
                saveas(hcf,ColorSaveName,'png');
                set(hcf,'paperpositionmode','manual');
                print(hcf,'-dpdf',ColorSaveName,'-painters');
                
                AvgSaveName = sprintf('Unit%3d Eventaligned meantrace plots',obj.UsedClus_IDs(cUnit));
                AvgSaveName = fullfile(obj.ksFolder,SaveFolderNames,AvgSaveName);
                saveas(hMeanf,AvgSaveName);
                saveas(hMeanf,AvgSaveName,'png');
                set(hMeanf,'paperpositionmode','manual');
                print(hMeanf,'-dpdf',AvgSaveName,'-painters');
                
                close(hcf);
                close(hMeanf);
            end
            if nargout > 1
                varargout{1} = {SegMeanTraces,xTs};
                varargout{2} = {Seg1_types, Seg2_types};
            end
            
        end
        
        function EventRasterplot(obj,EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,varargin)
            % same function as obj.EventsPSTHplot, instead of plot the binned spike
            % data, plot the raw raster plots
            
            % if the length of the AlignEvent is one, then only the alignment event
            % column is given, we then will use default event column for sorting; if
            % the AlignEvent is a 2-element vector, we will use the first one as
            % alignment and the second one as sorting column
            
            
            if isempty(obj.TrigData_Bin{obj.CurrentSessInds}) || isempty(obj.UsedTrigOnTime{obj.CurrentSessInds})
                obj = TrigPSTH(obj,[],[]);
                obj.TrigAlignType{obj.CurrentSessInds} = 'trigger';
            end
            if size(EventsDelay,1) < size(EventsDelay,2)
                EventsDelay = EventsDelay';
            end
            
            PlotTrInds = true(size(EventsDelay,1),1);
            if ~isempty(varargin)
                if ~isempty(varargin{1})
                    PlotTrInds = varargin{1};
                end
            end
            EventsDelay = EventsDelay(PlotTrInds,:);
            RepeatTypes = RepeatTypes(PlotTrInds,:);
            
            SaveFolderNames = 'EventAlignPlot';
            if length(varargin) > 1
                if ~isempty(varargin{2})
                    SaveFolderNames = varargin{2};
                end
            end
            
            IsLickPlot = 0;
            if length(varargin) > 2
                if ~isempty(varargin{3})
                    IsLickPlot = 1;
                    LickTimeStrc = varargin{3};
                end
            end
            IsChnAreaGiven = 0;
            if length(varargin) > 3
                if ~isempty(varargin{4})
                    IsChnAreaGiven = 1;
                    ChnAreaStrs = varargin{4};
                    obj.ChannelAreaStrs = ChnAreaStrs;
                end
            end
            if ~IsChnAreaGiven && ~isempty(obj.ChannelAreaStrs)
                IsChnAreaGiven = 1;
                ChnAreaStrs = obj.ChannelAreaStrs;
            end
            if IsLickPlot
                UsedLickStrc = LickTimeStrc(PlotTrInds);
            end
            
            if length(obj.UsedTrigOnTime{obj.CurrentSessInds}(PlotTrInds)) ~= size(EventsDelay,1)
                error('The input event size isn''t fit with trigger event numbers.');
            end
            if size(EventsDelay,2) ~= size(EventColors,2)
                error('Event column number is different from dscription color str numbers.');
            end
            InputVec = AlignEvent; % backup variable, for debug use
            if isempty(AlignEvent)
                AlignEvent = 1;
                SortEvents = 2;
            else
                if length(AlignEvent) == 1
                    if AlignEvent == 1
                        SortEvents = 2;
                    else
                        SortEvents = 1;
                    end
                elseif length(AlignEvent) == 2
                    AlignEvent = InputVec(1);
                    SortEvents = InputVec(2);
                else
                    error('The input Event alignment vector must be a single or two-valued vector.');
                end
            end
            if AlignEvent > size(EventsDelay,2)
                error('The aligned event index (%d) should less than total events types (%d).',AlignEvent,size(EventsDelay,2));
            end
            
            if SortEvents > size(EventsDelay,2)
                warning('The column index used for sorting is larger than total column number, use alignemnt column for sorting.');
                SortEvents = AlignEvent;
            end
            
            RepeatDespStr = RepeatStr; % description of the repeated events info
            EventDespStrs = EventColors(1,:);
            EventPlotColors = EventColors(2,:);
            
            RawSptimeData = obj.TrTrigSpikeTimes{obj.CurrentSessInds}(:,PlotTrInds); % should be a numUnit-by-numTrigtrial cell matrix
            [unitNum, TrNum] = size(RawSptimeData);
            
            if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                OnsetTimes = obj.TriggerStartBin{obj.CurrentSessInds}*obj.USedbin(2); % trigger onset time, in seconds
                EventTimes = EventsDelay/1000 + OnsetTimes; % in seconds
                zerospointtime = OnsetTimes;
                % in case some of the trials have very long presound delay caused by
                % presound no-lick punishment
                LatterOnsettimeTrs = sum(EventTimes > (obj.psthTimeWin{obj.CurrentSessInds}(2) - 1),2);
                if sum(LatterOnsettimeTrs)
                    ExcludeInds = LatterOnsettimeTrs > 0;
                    EventTimes(ExcludeInds,:) = [];
                    TrNum = TrNum - sum(ExcludeInds);
                    RawSptimeData(:,ExcludeInds) = [];
                    RepeatTypes(ExcludeInds,:) = [];
                    UsedLickStrc(ExcludeInds) = [];
                end
            elseif strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'stim')
                EventTimes = EventsDelay/1000; % in seconds
                MinimunEventOnTime = min(EventTimes(:,1));
                % set time zeros to event1 (stim) onset times
                % correct event times to aligned to stim onset time, which is the first column
                TrEventTimeAligned = bsxfun(@minus,EventTimes, EventTimes(:,1)-MinimunEventOnTime) - MinimunEventOnTime;
                EventTimesBK = EventTimes; % backup for EventTimes, for debug
                EventTimes = TrEventTimeAligned;
                %     AlignedEvents = EventTimes(:,AlignEvent);
                %     TrShifts = AlignedEvents - min(AlignedEvents);
                %     AllEvent_shifts = max(0,bsxfun(@minus,EventTimes,TrShifts));
                %     NumPlotEvents = size(AllEvent_shifts,2);
            end
            AlignedEvents = EventTimes(:,AlignEvent);
            TrShifts = AlignedEvents - min(AlignedEvents); % times to be shifted for each trial
            AllEvent_shifts = max(0,bsxfun(@minus,EventTimes,TrShifts)); % memory friendly way
            NumPlotEvents = size(AllEvent_shifts,2);
            
            SortEventTimes = AllEvent_shifts(:,SortEvents);
            [~,SortInds]  = sort(SortEventTimes);
            
            ShiftedSptimes = cell(unitNum, TrNum);
            % [unitNum, TrNum] = size(RawSptimeData);
            for cTr = 1 : TrNum
                % correct the spiketimes for each shifted trial
                %     shifttimes = sptimes_shiftfun(sptimes, shifts, bounds)
                cTr_unitsptimes = RawSptimeData(:,cTr);
                cTr_shiftTimes = cellfun(@(x) obj.sptimes_shiftfun(x,TrShifts(cTr),obj.psthTimeWin{obj.CurrentSessInds}),...
                    cTr_unitsptimes,'Uniformoutput',false);
                ShiftedSptimes(:,cTr) = cTr_shiftTimes;
            end
            
            %% align lick time data
            if IsLickPlot
                LRLick_alignTimes = cell(TrNum,2);
                % align lick times
                for cTr = 1 : TrNum
                    cTrLeftLick = UsedLickStrc(cTr).LickTimeLeft;
                    if ~isempty(cTrLeftLick)
                        LeftlickTime = (cTrLeftLick/1000);
                        if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                            LRLick_alignTimes{cTr,1} = LeftlickTime(:) - TrShifts(cTr) + zerospointtime; % correct to matrix start
                        else
                            LRLick_alignTimes{cTr,1} = LeftlickTime(:) - TrShifts(cTr) - EventsDelay(cTr,1)/1000;
                        end
                    end
                    
                    cTrRightLick = UsedLickStrc(cTr).LickTimeRight;
                    if ~isempty(cTrRightLick)
                        RightLickTime = (cTrRightLick/1000);
                        if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                            LRLick_alignTimes{cTr,2} = RightLickTime(:) - TrShifts(cTr) + zerospointtime;
                        else
                            LRLick_alignTimes{cTr,2} = RightLickTime(:) - TrShifts(cTr) ...
                                - EventsDelay(cTr,1)/1000;
                        end
                    end
                    
                end
            end
            %%
            % sort all shifted events and lick times usng sortinds
            ShiftedSptimes_sort = ShiftedSptimes(:,SortInds);
            SortRepeats = RepeatTypes(SortInds,:);
            SortedEvents = AllEvent_shifts(SortInds,:);
            if IsLickPlot
                LRLick_alignTimesSort = LRLick_alignTimes(SortInds,:);
            end
            %%
            if size(RepeatTypes,2) == 2
                SegNums = 2;
                Seg1_types = unique(SortRepeats(:,1));
                Seg2_types = unique(SortRepeats(:,2));
                Seg2TypeNum = length(Seg2_types);
                if Seg2TypeNum > 3
                    warning('Two much segments for the second repeat type, the figure will be too large to be displayed.\n');
                    return;
                end
                % calculate the segments inds
                SegTypeInds = cell(numel(Seg1_types),numel(Seg2_types));
                for cSeg1 = 1 : numel(Seg1_types)
                    for cSeg2 = 1:numel(Seg2_types)
                        SegTypeInds{cSeg1,cSeg2} = find(SortRepeats(:,1) == Seg1_types(cSeg1) & ...
                            SortRepeats(:,2) == Seg2_types(cSeg2));
                    end
                end
                
            elseif size(SortRepeats,2) == 1
                SegNums = 1;
                Seg1_types = unique(SortRepeats(:,1));
                Seg2TypeNum = 1;
                Seg2_types = unique(SortRepeats(:,2));
                
                SegTypeInds = cell(numel(Seg1_types),1);
                for cSeg1 = 1 : numel(Seg1_types)
                    SegTypeInds{cSeg1,1} = find(SortRepeats(:,1) == Seg1_types(Seg1_types(cSeg1)));
                end
                
            else
                error('Unsupported segments numbers, please check your inputs.');
            end
            %%
            ChoiceStrs = {'LeftC','RightC'};
            BloundaryBlockStrs = {'LowBound','HighBound'};
            if isempty(obj.SessBlockTypes)
                cBlockTypeStrs = '';
            else
                cBlockTypeStrs = BloundaryBlockStrs{obj.SessBlockTypes+1};
            end
            for cUnit = 1 : unitNum
                %%
                cU_trsptimes = ShiftedSptimes_sort(cUnit,:);
                hcf = figure('position',[100 100 1450 300],'visible','off'); %,'visible','off'
                Seg1TypeNum = length(Seg1_types);
                IstitleAdded = 0;
                for c1Seg = 1 :Seg1TypeNum  % normally stimulus segments
                    %                     c1SegInds = SortRepeats(:,1) == Seg1_types(c1Seg);
                    if Seg2TypeNum > 1
                        set(hcf,'position',[100 100 1450 300*Seg2TypeNum]);
                    end
                    for c2Seg = 1 : Seg2TypeNum % normally choice segments
                        %                         c2Seg_Inds = SortRepeats(:,2) == Seg2_types(c2Seg);
                        cComSeg_datas = cU_trsptimes(SegTypeInds{c1Seg,c2Seg});
                        if isempty(cComSeg_datas)
                           continue; 
                        end
                        spTime_indexedVec = obj.Cell2indexPlots(cComSeg_datas); % the first column is real time, the second is indexed values
                        
                        ax = subplot(Seg2TypeNum,Seg1TypeNum,(c2Seg-1)*Seg1TypeNum+c1Seg);
                        hold on
                        if ~isempty(spTime_indexedVec)
                            Plotmtx_x = ([spTime_indexedVec(:,1),spTime_indexedVec(:,1),nan(size(spTime_indexedVec,1),1)])';
                            Plotmtx_y = ([spTime_indexedVec(:,2)-0.4,spTime_indexedVec(:,2)+0.4,nan(size(spTime_indexedVec,1),1)])';
                            plot(ax,Plotmtx_x(:),Plotmtx_y(:),'Color','k','linewidth',1);
                        end
                        %
                        if c1Seg == 1 && c2Seg == 1
                           hlAll = []; 
                        end
                        for cEvent = 1 : NumPlotEvents
                            cEventTimes = (SortedEvents(SegTypeInds{c1Seg,c2Seg},cEvent))';
                            SegEventNum = numel(cEventTimes);
                            Eventplot_x = [cEventTimes;cEventTimes;nan(1,SegEventNum)];
                            plot_x = Eventplot_x(:);
                            Eventplot_y = [(1:SegEventNum)-0.5;(1:SegEventNum)+0.5;nan(1,SegEventNum)];
                            plot_y = Eventplot_y(:);
                            
                            hl = plot(ax,plot_x,plot_y,'Color',EventPlotColors{cEvent},'linewidth',1.2);
                            if c1Seg == 1 && c2Seg == 1
                               hlAll = [hlAll,hl]; 
                            end
                        end
                        %
                        if IsLickPlot
                            cSegLicks_L =  LRLick_alignTimesSort(SegTypeInds{c1Seg,c2Seg},1);
                            LIndexedPlotVec = obj.Cell2indexPlots(cSegLicks_L);
                            cSegLicks_R =  LRLick_alignTimesSort(SegTypeInds{c1Seg,c2Seg},2);
                            RIndexedPlotVec = obj.Cell2indexPlots(cSegLicks_R);
                            
                            if ~isempty(LIndexedPlotVec)
                                plot(LIndexedPlotVec(:,1),LIndexedPlotVec(:,2),'o','MarkerSize',2,'MarkerEdgeColor','c',...
                                    'MarkerFaceColor','none');
                            end
                            if ~isempty(RIndexedPlotVec)
                                plot(RIndexedPlotVec(:,1),RIndexedPlotVec(:,2),'o','MarkerEdgeColor',[1,.7,.2],...
                                    'MarkerFaceColor','none','MarkerSize',2);
                            end
                            
                        end
                        %
                        set(ax,'ylim',[0.5,SegEventNum+0.5],'xlim',obj.psthTimeWin{obj.CurrentSessInds});
                        set(ax,'YDir','reverse');
                        
                        if c1Seg == 1
                            if max(Seg2_types) > 2
                                ylabel(ax,sprintf('%d\n # Trials',Seg2_types(c2Seg)));
                            else
                                ylabel(ax,sprintf('%s\n # Trials',ChoiceStrs{Seg2_types(c2Seg)+1}));
                            end
                        end
                        if c2Seg == Seg2TypeNum
                            xlabel(ax,'Times(s)');
                        end
                        if c2Seg == 1
                            title(sprintf('%d',Seg1_types(c1Seg)));
                            IstitleAdded = 1;
                        end
                        if ~IstitleAdded && c2Seg > 1
                            title(sprintf('%d',Seg1_types(c1Seg)));
                            IstitleAdded = 1;
                        end
                            
                        if c1Seg == Seg1TypeNum && c2Seg == Seg2TypeNum
                            leg = legend(hlAll,EventDespStrs,'location','Southwest','box','off');
                            oldLegPos = get(leg,'position');
                            set(leg,'position',[0.02 0.05 oldLegPos(3) oldLegPos(4)]);
                        end
                    end
                    IstitleAdded = 0;
                end
                %%
                if ~IsChnAreaGiven
                    annotation(hcf,'textbox',[0.475,0.68,0.3,0.3],'String',sprintf('Unit %d, Chn %d, (%s)',...
                        obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)),cBlockTypeStrs,'FitBoxToText','on','EdgeColor',...
                        'none','FontSize',12);
                else
                    cChnAreaIndex = ChnAreaStrs{obj.ChannelUseds_id(cUnit),1};
                    if cChnAreaIndex < 0
                        ChnAreaStr = ['(',ChnAreaStrs{obj.ChannelUseds_id(cUnit),3},')'];
                    else
                        ChnAreaStr = ChnAreaStrs{obj.ChannelUseds_id(cUnit),3};
                    end
                    annotation(hcf,'textbox',[0.01,0.32,0.05,0.3],'String',sprintf('(%s), \nUnit %d, \nChn %d \nArea :\n%s',...
                        cBlockTypeStrs,obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit),ChnAreaStr),'FitBoxToText','on','EdgeColor',...
                        'none','FontSize',10,'Color',[0.8 0.5 0.2],'FitBoxToText','on');
                end
                %%
                if ~isdir(fullfile(obj.ksFolder,SaveFolderNames))
                    mkdir(fullfile(obj.ksFolder,SaveFolderNames));
                end
                %                  cd(fullfile(obj.ksFolder,SaveFolderNames));
                ColorSaveName = sprintf('Unit%3d Eventaligned spike raster plots',obj.UsedClus_IDs(cUnit));
                ColorSaveName = fullfile(obj.ksFolder,SaveFolderNames,ColorSaveName);
                saveas(hcf,ColorSaveName);
                saveas(hcf,ColorSaveName,'png');
                %      set(hcf,'paperpositionmode','manual');
                %      print(hcf,'-dpdf',ColorSaveName,'-painters');
                close(hcf);
                
            end
            
        end
        % function used to calculate the averaged respose FR within target
        % time window
        function [binwinDatas,obj] = EventRespFR(obj,EventTimes,Timewin,usedTrialInds,StimOnTime)
            % this function is used to extract event triggered response within given
            % 'Timewin', than return the event evoked response values that have the same
            % size as 'EventTimes'

            if isempty(obj.TrigData_Bin{obj.CurrentSessInds}) || isempty(obj.UsedTrigOnTime{obj.CurrentSessInds})
                error('Please run the spine data psth code before using current function.');
            end
            if length(Timewin) ~= 1
               error('Only a single valued timewin value was supportted currently, but current length is %d.',length(Timewin)); 
            end
            
            if ~isprop(obj,'StimAlignedTime') || isempty(obj.StimAlignedTime{obj.CurrentSessInds})
                obj.StimAlignedTime{obj.CurrentSessInds} = StimOnTime/1000;
            end
            
            if ~exist('usedTrialInds','var') || isempty(usedTrialInds)
                TrUsedInds = true(size(obj.StimAlignedTime{obj.CurrentSessInds},1),1);
            else
                TrUsedInds = usedTrialInds;
            end
            
            % sort and align the binned data according to the event times
            % only input trials will be used
            SMBinDataMtx = permute(cat(3,obj.TrigData_Bin{obj.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
            SMBinDataMtx = SMBinDataMtx(TrUsedInds,:,:);
            [TrNum, unitNum, BinNum] = size(SMBinDataMtx);

            BinWidth = obj.USedbin(2);
            StimOnsetTime = obj.StimAlignedTime{obj.CurrentSessInds}(TrUsedInds); % only used trials were included
            if Timewin > 0
                % calculate response after certain event
                TrEventTime = EventTimes(TrUsedInds,:);
                
                % determine the propossed event bin according to the psth alignment methods
                if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                    EventOnBins = ceil((TrEventTime/1000)/BinWidth)+obj.TriggerStartBin{obj.CurrentSessInds};
                elseif strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'stim')
                    EventOnBins = ceil(((TrEventTime/1000-StimOnsetTime))/BinWidth) + ...
                        obj.TriggerStartBin{obj.CurrentSessInds};
                end
                                
                winbin = ceil(Timewin/BinWidth);
                if (max(EventOnBins)+winbin) > BinNum
                    error('The maximum bin index is out-of-range.');
                end
                TrTargetBinAlls = EventOnBins+[1,winbin];
                
            elseif Timewin == 0
               % calculate baseline response FR
               % if Timewin == 0, indicates using all baseline times for
               % calculation, if Timewin < 0, using given time length for
               % calculation
               if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                    MaxBasebin = ceil((StimOnsetTime)/BinWidth)+obj.TriggerStartBin{obj.CurrentSessInds}-1;
                elseif strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'stim')
                    MaxBasebin = (obj.TriggerStartBin{obj.CurrentSessInds}-1)*ones(TrNum,1);
                end
               TrTargetBinAlls = [ones(TrNum,1),MaxBasebin];
               
            else % Timewin < 0
               winbin = ceil(Timewin/BinWidth);
               if abs(winbin) > obj.TriggerStartBin{obj.CurrentSessInds}
                   winbin = -1*obj.TriggerStartBin{obj.CurrentSessInds};
               end
               StartBinInds = obj.TriggerStartBin{obj.CurrentSessInds}+winbin;
               
               if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                    MaxBasebin = ceil((StimOnsetTime)/BinWidth)+obj.TriggerStartBin{obj.CurrentSessInds}-1;
                elseif strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'stim')
                    MaxBasebin = (obj.TriggerStartBin{obj.CurrentSessInds}-1)*ones(TrNum,1);
               end
                TrTargetBinAlls = [ones(TrNum,1)*StartBinInds,MaxBasebin];
                
            end
            % extract data from target time bin in a trial-by-trial manner
            binwinDatas = zeros(TrNum, unitNum);
            for cTr = 1 : TrNum
                cTr_winbin_range = TrTargetBinAlls(cTr,:);
                binwinDatas(cTr,:) = mean(SMBinDataMtx(cTr,:,cTr_winbin_range(1):cTr_winbin_range(2)),3);
            end
        end

        
        function obj = SpikeWaveFeature(obj,varargin)
            % function used to analysis single unit waveform features
            % the wave form features may includes firerate, peak-to-trough
            % width, refraction peak and so on
            
            % from "Nuo Li et al, 2016", trough-to-peak interval  less than
            % 0.35ms were defined as fast-spiking neuron and spike width
            % larger than 0.45ms as putative pyramidal neurons
            
            
            if isempty(obj.binfilePath) || isempty(obj.RawDataFilename)
                if ~isempty(varargin) && ~isempty(varargin{1})
                    obj.binfilePath = varargin{1};
                    possbinfilestrc = dir(fullfile(obj.binfilePath,'*.ap.bin'));
                    if isempty(possbinfilestrc)
                        error('target bin file doesnt exists.');
                    end
                    obj.RawDataFilename = possbinfilestrc(1).name;
                else
                    error('Bin file location is needed for spikewave extraction.');
                end
            end
            %             if isempty(obj.mmf) && eixst(fullfile(obj.binfilePath,obj.RawDataFilename))
            %                 fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
            % %                 dataNBytes = get_file_size(fullpaths); % determine number of bytes per sample
            % %                 obj.Numsamp = dataNBytes/(2*obj.NumChn);
            % %                 obj.mmf = memmapfile(fullpaths, 'Format', {obj.Datatype, [obj.NumChn obj.Numsamp], 'x'});
            % %
            %             end
            fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
            ftempid = fopen(fullpaths);
            
            if ~isfolder(fullfile(obj.ksFolder,'UnitWaveforms'))
                mkdir(fullfile(obj.ksFolder,'UnitWaveforms'));
            end
            % startTime = 15000;
            % offsets = 385*startTime*2;
            % status = fseek(ftempid,offsets,bof);
            % AsNew= fread(ftempid,[385 15000],'int16');
            NumofUnit = length(obj.UsedClus_IDs);
            UnitDatas = cell(NumofUnit,1);
            UnitFeatures = cell(NumofUnit,3);
            for cUnit = 1 : NumofUnit
                % cUnit = 137;
                %% close;
                cClusInds = obj.UsedClus_IDs(cUnit);
                cClusChannel = obj.ChannelUseds_id(cUnit);
                cClus_Sptimes = obj.SpikeTimeSample(obj.SpikeClus == cClusInds);
                if numel(cClus_Sptimes) < 2000
                    UsedSptimes = cClus_Sptimes;
                    SPNums = length(UsedSptimes);
                else
                    UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
                    SPNums = 2000;
                end
                cspWaveform = nan(SPNums,diff(obj.WaveWinSamples));
                for csp = 1 : SPNums
                    cspTime = UsedSptimes(csp);
                    cspStartInds = cspTime+obj.WaveWinSamples(1);
                    cspEndInds = cspTime+obj.WaveWinSamples(2);
                    offsetTimeSample = cspStartInds - 1;
                    if offsetTimeSample < 0 || cspEndInds > obj.Numsamp
                        continue;
                    end
                    offsets = 385*(cspStartInds-1)*2;
                    status = fseek(ftempid,offsets,'bof');
                    if ~status
                        % correct offset value is set
                        AllChnDatas = fread(ftempid,[385 diff(obj.WaveWinSamples)],'int16');
                        cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
                        %        cspWaveform(csp,:) = mean(AllChnDatas);
                    end
                end
                
                huf = figure('visible','off');
                AvgWaves = mean(cspWaveform,'omitnan');
                UnitDatas{cUnit} = cspWaveform;
                %%
                plot(AvgWaves);
                try
                    [isabnorm,isUsedVec] = iswaveformatypical(AvgWaves,obj.WaveWinSamples,false);
                catch ME
                    fprintf('Errors');
                end
                title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
                wavefeature = SPwavefeature(AvgWaves,obj.WaveWinSamples);
                text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
                    sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);
                
                if wavefeature.IsPrePosPeak
                    text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
                end
                UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec};
                %
                
                saveName = fullfile(obj.ksFolder,'UnitWaveforms',sprintf('Unit%d waveform plot save',cUnit));
                saveas(huf,saveName);
                saveas(huf,saveName,'png');
                
                close(huf);
                
            end
            obj.UnitWaves = UnitDatas;
            obj.UnitWaveFeatures = UnitFeatures;
            save(fullfile(obj.ksFolder,'UnitwaveformDatas.mat'), 'UnitDatas', 'UnitFeatures', '-v7.3');
            
            %             % ways to calculate the refractory period using output datas
            %             default_binsize = 1e-3;
            %             if ~exist('binsize_time','var')
            %                 binsize_time = default_binsize;
            %             end
            %             baselinefr_timebin = [600, 900]; % ms
            %             baselinefr_bin = round(baselinefr_timebin/1000/default_binsize);
            %
            %             % ccgData = ClusSelfccg{1};
            %             RefracBinNum = cellfun(@(x) refractoryperiodFun(x,baselinefr_bin),ClusSelfccg);
            %             RefracBinTime = RefracBinNum*binsize_time;
            
        end
        
        function ClusSelfccg = refractoryPeriodCal(obj,spclus,winsize,binsize)
            % function to calculate the refractory period for given cluster
            % inds, if empty cluster inds is given, try to calculate the
            % ccg values for all valid clusters
            if isempty(spclus)
                PlotclusInds = obj.UsedClus_IDs;
                AllClusCal = 1;
            else
                PlotclusInds = sort(spclus); %
                AllClusCal = 0;
            end
            if binsize < 1 % in case of input as real time in seconds
                winsize = round(winsize * obj.SpikeStrc.sample_rate);
                binsize = round(binsize * obj.SpikeStrc.sample_rate);
            end
            
            MaxclusbatchSize = 5;
            if length(PlotclusInds) > MaxclusbatchSize
                BatchNums = ceil(length(PlotclusInds) / MaxclusbatchSize);
                ClusSelfccg = cell(length(PlotclusInds),1);
                %%
                for cBatch = 1 : BatchNums
                    cBatchedScale = [(cBatch-1)*MaxclusbatchSize+1,min(cBatch*MaxclusbatchSize,length(PlotclusInds))];
                    cBatchedInds = cBatchedScale(1):cBatchedScale(2);
                    cBatch_clus_inds = PlotclusInds(cBatchedInds);
                    BatchClus2fullInds = ismember(obj.SpikeClus,cBatch_clus_inds);
                    Batch_sptimesAll = obj.SpikeTimeSample(BatchClus2fullInds); % using sample value to increase the bin accuracy
                    Batch_spclusAll = obj.SpikeClus(BatchClus2fullInds);
                    Batchccg = Spikeccgfun(Batch_sptimesAll,Batch_spclusAll,winsize,binsize,false);
                    for cb = 1 : length(cBatch_clus_inds)
                        ClusSelfccg(cBatchedInds(cb)) = {squeeze(Batchccg(cb,cb,:))};
                    end
                end
                %%
            else
                ClusSelfccg = cell(length(PlotclusInds),1);
                clus2fullInds = ismember(obj.SpikeClus,PlotclusInds);
                sptimeAlls = obj.SpikeTimeSample(clus2fullInds);
                spclusAlls = obj.SpikeClus(clus2fullInds);
                ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
                for cb = 1 : length(PlotclusInds)
                    ClusSelfccg(cb) = {squeeze(ccgs(cb,cb,:))};
                end
            end
            if AllClusCal
                save(fullfile(obj.ksFolder,'AllClusccgData.mat'),'ClusSelfccg','PlotclusInds','-v7.3');
            end
            
        end
        
        function shifttimes = sptimes_shiftfun(obj,sptimes, shifts, bounds)
            % this function is used to calculate the shifted spike times, and excluded
            % those out-of-bound times after alignment
            if isempty(sptimes)
                shifttimes = [];
                return;
            end
            shifttimes = sptimes - shifts;
            shifttimes(shifttimes < bounds(1) | shifttimes > bounds(2)) = [];
            
        end
        
        function UnitAmps = unitspTemplateCheck(obj)
            % function used to extract unit spike amplitude and check
            % whether the unit position is shiftted during recording
            sp_template_fold = fullfile(obj.ksFolder,'amplitudes.npy');
            sp_templates = readNPY(sp_template_fold);
            NumUsedClus = length(obj.UsedClus_IDs);
            UnitAmps = cell(NumUsedClus,1);
            for cUnit = 1 : NumUsedClus
                cUnit_inds = obj.SpikeClus == obj.UsedClus_IDs(cUnit);
                cUnit_template = sp_templates(cUnit_inds);
                UnitAmps{cUnit} = cUnit_template;
            end
            
        end
        
    end
    
    methods(Access = private)
        function [SortEventInds,AlignedSortDatas,AlignedEventOnBin,AlignSortEventsBin,UsedBinLength] = ...
                AlignANDsortInds(obj,SMBinDataMtx,AlignedEvents,EventBinLength,AlignEvent,AllEvent_shifts,TrShifts)
            
            [TrNum, unitNum, BinNum] = size(SMBinDataMtx);
            if strcmpi(obj.TrigAlignType{obj.CurrentSessInds},'trigger')
                
                UsedBinLength = min(AlignedEvents) + BinNum - max(AlignedEvents);
                if size(EventBinLength,2) == 1
                    % no need to sort the original trial sequence
                    AlignedSortDatas = zeros(TrNum, unitNum, UsedBinLength);
                    for cTr = 1 : TrNum %AllEvent_shifts(:,1)
                        AlignedSortDatas(cTr,:,:) =  SMBinDataMtx(cTr,:,TrShifts(cTr)+(1:UsedBinLength));
                    end
                    AlignedEventOnBin = min(AlignedEvents);
                    AlignSortEventsBin = [];
                    SortEventInds = 1:TrNum;
                elseif size(EventBinLength,2) > 1
                    if AlignEvent == 1 % sorted with the second events, which is usually choice event
                        SortEvents = max(AllEvent_shifts(:,2) - AllEvent_shifts(:,AlignEvent),0); % in case of no choice time events
                        AlignedData = zeros(TrNum, unitNum, UsedBinLength);
                        for cTr = 1 : TrNum
                            AlignedData(cTr,:,:) =  SMBinDataMtx(cTr,:,TrShifts(cTr)+(1:UsedBinLength));
                        end
                        [~,SortEventInds] = sort(SortEvents);
                        AlignedSortDatas = AlignedData(SortEventInds,:,:);
                        AlignedEventOnBin = min(AlignedEvents);
                        AlignSortEventsBin = AllEvent_shifts(SortEventInds,:);
                    elseif AlignEvent == 2 % choice align or sound offset align, sorted by the first events
                        SortEvents = max(0,AllEvent_shifts(:,2) - AllEvent_shifts(:,1));
                        AlignedData = zeros(TrNum, unitNum, UsedBinLength);
                        for cTr = 1 : TrNum
                            AlignedData(cTr,:,:) =  SMBinDataMtx(cTr,:,TrShifts(cTr)+(1:UsedBinLength));
                        end
                        [~,SortEventInds] = sort(SortEvents);
                        AlignedSortDatas = AlignedData(SortEventInds,:,:);
                        AlignedEventOnBin = min(AlignedEvents);
                        AlignSortEventsBin = AllEvent_shifts(SortEventInds,:);
                    else
                        SortEvents = max(0,AllEvent_shifts(:,AlignEvent) - AllEvent_shifts(:,1));
                        AlignedData = zeros(TrNum, unitNum, UsedBinLength);
                        for cTr = 1 : TrNum
                            AlignedData(cTr,:,:) =  SMBinDataMtx(cTr,:,TrShifts(cTr)+(1:UsedBinLength));
                        end
                        [~,SortEventInds] = sort(SortEvents);
                        AlignedSortDatas = AlignedData(SortEventInds,:,:);
                        AlignedEventOnBin = min(AlignedEvents);
                        AlignSortEventsBin = AllEvent_shifts(SortEventInds,:);
                    end
                    
                end
            else
                % if binned data is use stimonset as zeros time point
                if size(EventBinLength,2) == 1 % only the stim onset event is given
                    % no need to sort the original trial sequence
                    %         AlignedSortDatas = zeros(TrNum, unitNum, UsedBinLength);
                    %         for cTr = 1 : TrNum %AllEvent_shifts(:,1)
                    %             AlignedSortDatas(cTr,:,:) =  SMBinDataMtx(cTr,:,TrShifts(cTr)+(1:UsedBinLength));
                    %         end
                    AlignedSortDatas = SMBinDataMtx;
                    AlignedEventOnBin = obj.TriggerStartBin{obj.CurrentSessInds};
                    AlignSortEventsBin = [];
                    SortEventInds = 1:TrNum;
                    UsedBinLength = size(AlignedSortDatas,3);
                else
                    if AlignEvent == 1 % already aligned to stim event, sorted with choice (2nd events)
                        SortEvents = max(AllEvent_shifts(:,2) - AllEvent_shifts(:,1),0);
                        [~,SortEventInds] = sort(SortEvents);
                        AlignedSortDatas = SMBinDataMtx(SortEventInds,:,:);
                        AlignedEventOnBin = obj.TriggerStartBin{obj.CurrentSessInds};
                        AlignSortEventsBin = AllEvent_shifts(SortEventInds,:);
                        UsedBinLength = size(AlignedSortDatas,3);
                    else % need aligned to other events
                        BinNum = size(SMBinDataMtx,3);
                        UsedBinLength = min(AlignedEvents) + BinNum - max(AlignedEvents);
                        AlignedData = zeros(TrNum, unitNum, UsedBinLength);
                        for cTr = 1 : TrNum
                            AlignedData(cTr,:,:) =  SMBinDataMtx(cTr,:,...
                                (TrShifts(cTr) + 1):(TrShifts(cTr) + UsedBinLength));
                        end
                        SortEvents = AllEvent_shifts(:,1);
                        [~,SortEventInds] = sort(SortEvents);
                        AlignedSortDatas = AlignedData(SortEventInds,:,:);
                        AlignedEventOnBin = min(AlignedEvents);
                        AlignSortEventsBin = AllEvent_shifts(SortEventInds,:);
                        
                        
                    end
                    
                end
            end
            
        end
        
        function IndexedPlotVec = Cell2indexPlots(obj,CellData)
            % convert cell data into index data for quick plot
            NumofRows = length(CellData);
            IndexedPlotCell = cell(NumofRows,2);
            for cRow = 1 : NumofRows
                cRData = CellData{cRow};
                if ~isempty(cRData)
                    IndexedPlotCell{cRow,1} = cRData(:);
                    IndexedPlotCell{cRow,2} = cRow*ones(numel(cRData),1);
                end
            end
            
            IndexedPlotVec = cell2mat(IndexedPlotCell);
            
        end
        
    end
    
end
