classdef NPspikeDataMining
    properties (SetAccess = private)
        NumOfWaves = 2000;
        WaveWinSamples = [-30,51];
        
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
        UsedClusinds % inds indicating which cluster is to be used
        UsedChnDepth
        
        % for triggered PSTH 
        UsedTrigOnTime = []; % trigger onset time, in seconds format
        TrigData_Bin = {};
        BinCenters = [];
        TriggerStartBin = [];
        USedbin
        TrigDataBin_FRSub = {};
        TrTrigSpikeTimes = {};
        psthTimeWin = [];
        
    end
    
    
    methods
        function obj = NPspikeDataMining(FolderPath)
            binfileInfo = dir(fullfile(FolderPath,'*.ap.bin'));
            if isempty(binfileInfo)
                % looking in parent folders, in case of ks3 outputs
                binfileInfo = dir(fullfile(FolderPath,'..','*.ap.bin'));
                if isempty(binfileInfo)
                    warning('Unable to find target bin file.');
                    return;
                else
                    obj.binfilePath = fullfile(FolderPath,'..');
                end
            else
                obj.binfilePath = FolderPath;
            end
            
            obj.RawDataFilename = binfileInfo(1).name;
            obj.ksFolder = FolderPath;
            
            dataTypeNBytes = numel(typecast(cast(0, obj.Datatype), 'uint8')); % determine number of bytes per sample
            obj.Numsamp = binfileInfo(1).bytes/(dataTypeNBytes*obj.NumChn);
            fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
            obj.mmf = memmapfile(fullpaths, 'Format', {obj.Datatype, [obj.NumChn obj.Numsamp], 'x'});
            
            % spike data info reading
            obj.SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
            
            % read npy files
            obj.SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
            obj.SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
            obj.SpikeTimes = double(obj.SpikeTimeSample)/obj.SpikeStrc.sample_rate;
            obj.chnMaps = readNPY(fullfile(FolderPath, 'channel_map.npy'));
            
            if ~exist(fullfile(FolderPath,'cluster_info.tsv'),'file')

                FolderPath = obj.ksFolder;
                binfilepath = fullpaths;
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
            
        end
        
        
        function ClusChnDatas = SpikeWaveFun(obj,varargin)
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
        
        function obj = triggerOnsetTime(obj,TrigwaveScales,trigTime_ms)
            % trigTimeLen should in ms form
            if isempty(trigTime_ms)
                trigTime_ms = 2; % default is 2ms
            end
            
            if isempty(TrigwaveScales)
                trigScaleStrc = load(fullfile(obj.ksFolder,'TriggerDatas.mat'),'TriggerEvents');
                TrigwaveScales = trigScaleStrc.TriggerEvents;
            end
            
            trigLen = trigTime_ms/1000*obj.SpikeStrc.sample_rate;
            TrigWaveAll_lens = TrigwaveScales(:,2) - TrigwaveScales(:,1);
            TrigWaveAll_lens(TrigWaveAll_lens < 0.0005) = []; % exclude some unknowed zeros trigger events
            TrigWaveAll_lensEquals = abs(TrigWaveAll_lens - trigLen) < trigTime_ms;
            
            obj.UsedTrigOnTime = TrigwaveScales(TrigWaveAll_lensEquals,1)/obj.SpikeStrc.sample_rate+trigTime_ms/1000; % in seconds
            fprintf('Totally %d number of triggers were detected.\n',length(obj.UsedTrigOnTime));
            
        end
        
        function obj = TrigPSTH(obj,timeWin,smoothbin)
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
            obj.psthTimeWin = timeWin;
            if isempty(smoothbin)
                smoothbin = [50,10]; % in miliseconds
            end
            smoothbin = smoothbin / 1000;
            smoothbinfactor = smoothbin(1)/smoothbin(2);
            
            if isempty(obj.UsedTrigOnTime)
                % load trigger scale time file
                trigScaleStrc = load(fullfile(obj.ksFolder,'TriggerDatas.mat'),'TriggerEvents');
                obj = obj.triggerOnsetTime(trigScaleStrc.TriggerEvents,[]);
            end
            
            
            TrigNums = length(obj.UsedTrigOnTime);
            TrigBinDatas = cell(TrigNums,2);
            NumUsedClus = length(obj.UsedClus_IDs);
            cTrig_TrialSPtimes = cell(NumUsedClus,TrigNums);
            for ctrig = 1 : TrigNums
                cTrigTime = obj.UsedTrigOnTime(ctrig); % in seconds
                cTrigTimeWin = cTrigTime + timeWin;
                WithinTimewinInds = obj.SpikeTimes > cTrigTimeWin(1) & obj.SpikeTimes < cTrigTimeWin(2);
                cTrigWin_spTimes = obj.SpikeTimes(WithinTimewinInds);
                cTrigWin_spClus = obj.SpikeClus(WithinTimewinInds);
                histbin = [timeWin(1):smoothbin(2):0,smoothbin(2):smoothbin(2):timeWin(2)];
                obj.BinCenters = histbin(1:end-1)+smoothbin(2)/2;
                obj.TriggerStartBin = find(obj.BinCenters > 0,1,'first');
                
                cTrig_binClusCount = nan(NumUsedClus,length(obj.BinCenters));
                cTrig_binCountSM = nan(NumUsedClus,length(obj.BinCenters));
                
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
            obj.USedbin = smoothbin;
            obj.TrigData_Bin = cell(NumUsedClus,2);
            obj.TrTrigSpikeTimes = cTrig_TrialSPtimes;
            for cClus = 1 : NumUsedClus
                cClus_trigTimeC = cellfun(@(x) x(cClus,:),TrigBinDatas(:,1),'uniformOutput',false);
                cClus_trigTimeSMC = cellfun(@(x) x(cClus,:),TrigBinDatas(:,2),'uniformOutput',false);
                cClus_trigTime = cell2mat(cClus_trigTimeC);
                cClus_trigTimeSM = cell2mat(cClus_trigTimeSMC);
                obj.TrigData_Bin(cClus,:) = {cClus_trigTime, cClus_trigTimeSM};
            end
            
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
            obj.TrigDataBin_FRSub = BaseFRSubData;
            
        end
        
        function RawRasterplot(obj,EventsDelay,EventStrs,EventColors,StimRepeats)
            % spike raster plot for spike times
            if isempty(obj.TrTrigSpikeTimes)
                obj = TrigPSTH(obj,[],[]);
            end
            if size(EventsDelay,1) == 1
                EventsDelay = EventsDelay';
            end
            if size(obj.TrTrigSpikeTimes,2) ~= size(EventsDelay,1)
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
            
            [unitNum, TrNum] = size(obj.TrTrigSpikeTimes);
            
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
            cd(fullfile(obj.ksFolder,'RawRasterPlot'));
            
            for cUnit = 1 : unitNum
                %%
                cUnitData = obj.TrTrigSpikeTimes(cUnit,:);
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
                
                line([0 0],[0.5 TrNum+0.5],'Color','g','linewidth',1);
                hhl = [];
                for cEvent = 1 :NumOfEvents
                    hl = plot(EventPlotBins{cEvent,1},yPlotBinInds,'Color',EventColors{cEvent},'linewidth',1.4);
                    hhl = [hhl,hl];
                end
                
                set(gca,'xlim',obj.psthTimeWin,'ylim',[0.5 TrNum+0.5]);
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
                    SortUnitSPtimes = obj.TrTrigSpikeTimes(cUnit,PlotSortVec);
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
                        line(obj.psthTimeWin,[SegLinePos(cType) SegLinePos(cType)],...
                            'Color','c','linewidth',1.2);
                    end
                    
%                     legend(hhl,EventStrs(:),'Box','Off','location','NortheastOutside');
                    set(gca,'xlim',obj.psthTimeWin,'ylim',[0.5 TrNum+0.5]);
                    set(gca,'YDir','reverse')
                    xlabel('Time (s)');
                    ylabel('# Sort Trials');
                    title(sprintf('Unit %d, chn %d',cUnit,cUnitChnID));
                    
                    lax = legend(hl2,EventStrs(:),'Box','Off','location','SouthOutside','FontSize',8);
                    set(lax,'position',get(lax,'position')+[-0.2 -0.07 0 0]);
                    
                    set(ax2,'position',RawImPos);
                end 
                %%
                saveas(hcf,sprintf('Unit%03d raw spike raster color plot',cUnit));
                saveas(hcf,sprintf('Unit%03d raw spike raster color plot',cUnit),'png');
                close(hcf);
%                 saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit));
            end
            
        end
        function RawRespPreview(obj,EventsDelay,EventStrs,EventColors,StimRepeats)
            % this function is used to plot the raw response color plot
            % according to the real trial sequency, for a preview to see
            % whether the unit activity is persistant or whether there are
            % unexpected response level change as the trial increases
            if isempty(obj.TrigData_Bin) || isempty(obj.UsedTrigOnTime) 
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
            EventBinLength = ((EventsDelay/1000))+(obj.TriggerStartBin-1)*obj.USedbin(2);% real time but not in bin mode
            TriggerTime = (obj.TriggerStartBin-1)*obj.USedbin(2);
            if isempty(obj.TrigDataBin_FRSub)
                obj = obj.BaselineSubFun(obj.TrigData_Bin, EventsDelay(:,1)+obj.TriggerStartBin-1);
            end
            PlotDataType = 1; % 1 indicates unsmoothed raw plot, 2 indicates smoothed plot
            SMBinDataMtx = permute(cat(3,obj.TrigDataBin_FRSub{:,PlotDataType}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
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
                cd(fullfile(obj.ksFolder,'RawRespPlots_unSM'));
            elseif PlotDataType == 2
                if ~isdir(fullfile(obj.ksFolder,'RawRespPlots'))
                    mkdir(fullfile(obj.ksFolder,'RawRespPlots'));
                end
                cd(fullfile(obj.ksFolder,'RawRespPlots'));
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
                saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit));
                saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit),'png');
                close(hcf);
%                 saveas(hcf,sprintf('ROI%03d raw spike change color plot',cUnit));
            end
            
        end
        
        
        function EventsPSTHplot(obj,EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,varargin)
            % EventsDelay should be a n-by-p matrix, in milisecond format. n is the number of
            % trials, which should be the same as trigger number; p is the
            % number of events types. for example, the passive listening
            % session should have p=1; the task session should have p >
            % 2,which includes events like stim, choice, reward and so on
            
            % AlignEvent indicate which of the event(s) will be used for
            % alignment, the default value is 1, which usually is the stim
            % event
            
            % RepeatTypes is the repeat values for different trials, which
            % should includes stimulus or stimulus and choices.
            
            % EventColors indicates the plot color for each events
            
            % if varargin isn't empty, some extra input can be given for
            % specific plots 
            
            
            if isempty(obj.TrigData_Bin) || isempty(obj.UsedTrigOnTime) 
                obj = TrigPSTH(obj,[],[]);
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
            
            if length(obj.UsedTrigOnTime) ~= size(EventsDelay,1)
                error('The input event size isn''t fit with trigger event numbers.');
            end
            if size(EventsDelay,2) ~= length(EventColors)
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
            EventBinLength = ceil((EventsDelay/1000)/BinWidth);
            
            % sort and align the binned data according to the event times
            % only input trials will be plotted
            SMBinDataMtx = permute(cat(3,obj.TrigData_Bin{PlotTrInds,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
            
            [TrNum, unitNum, BinNum] = size(SMBinDataMtx);
            AlignedEvents = EventBinLength(:,AlignEvent);
            TrShifts = AlignedEvents - min(AlignedEvents); % bin number to be shifted for each trial
            AllEvent_shifts = EventBinLength - repmat(TrShifts,1,size(EventBinLength,2)); % All event shifts according to aligned event
            NumPlotEvents = size(AllEvent_shifts,2);
            %%
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
            SortRepeats = RepeatTypes(SortEventInds,:);
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
            NumSingleUnits = size(obj.TrigData_Bin,1);
            xTs = obj.psthTimeWin(1):obj.USedbin(2):(obj.psthTimeWin(2)-obj.USedbin(2));
            xTs = xTs + obj.USedbin(2)/2; % convert to bin center
            for cUnit = 18 : NumSingleUnits
                cUnitData = squeeze(AlignedSortDatas(:,cUnit,:)); % sorted by events time
                UnitPlotScale = [0 prctile(cUnitData(:),99)];
                
                hcf = figure('position',[100 100 1450 300]); %,'visible','off'
                Seg1TypeNum = length(Seg1_types);
                for c1Seg = 1 :Seg1TypeNum  % normally stimulus segments
%                     c1SegInds = SortRepeats(:,1) == Seg1_types(c1Seg);
                    if Seg2TypeNum > 1
                        set(hcf,'position',[100 100 1450 300*Seg2TypeNum]);
                    end
                    for c2Seg = 1 : Seg2TypeNum % normally choice segments
%                         c2Seg_Inds = SortRepeats(:,2) == Seg2_types(c2Seg);
                        cComSeg_datas = cUnitData(SegTypeInds{c1Seg,c2Seg},:);
                        cComSeg_Events = AlignSortEventsBin(SegTypeInds{c1Seg,c2Seg},:);
                        cComSeg_TrNums = size(cComSeg_Events,1);
                        
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
                           cEventBins = (cComSeg_Events(:,cEvent))'* BinWidth;
                           PlotMtx_x = [cEventBins;cEventBins;nan(1,cComSeg_TrNums)];
                           Plot_x = PlotMtx_x(:);
                           PlotMtx_y = [(1:cComSeg_TrNums)-0.5;(1:cComSeg_TrNums)+0.5;nan(1,cComSeg_TrNums)];
                           Plot_y = PlotMtx_y(:);
                           hl = plot(ax,Plot_x,Plot_y,'Color',EventPlotColors{cEvent},'linewidth',1.2);
                           if c1Seg == 1 && c2Seg == 1
                               hlAll = [hlAll,hl]; 
                            end
                        end
                        set(ax,'xlim',obj.psthTimeWin,'ylim',[0.5 cComSeg_TrNums+0.5]);
                        set(ax,'YDir','reverse');
                        %
                        if c1Seg == 1
                           ylabel(ax,sprintf('%d\n # Trials',Seg2_types(c2Seg))); 
                        end
                        if c2Seg == Seg2TypeNum
                            xlabel(ax,'Times(s)');
                        end
                        if c2Seg == 1
                           title(sprintf('%d',Seg1_types(c1Seg))); 
                        end
                        if c1Seg == Seg1TypeNum && c2Seg == Seg2TypeNum
                           haxisPos = get(ax,'position');
                           hbar = colorbar;
                           cBarPos = get(hbar,'position');
                           set(hbar,'position',cBarPos+[0.05 0 cBarPos(3)*2 0.1*cBarPos(4)]);
                           set(ax,'position',haxisPos);
                           
                           leg = legend(hlAll,EventDespStrs,'location','Southwest','box','off');
                           oldLegPos = get(leg,'position');
                           set(leg,'position',[0.02 0.05 oldLegPos(3) oldLegPos(4)]);
                        end
                        
                    end
                    
                end
                annotation(hcf,'textbox',[0.475,0.68,0.3,0.3],'String',sprintf('Unit %d, Chn %d',...
                    obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)),'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',12);
              %%
                % add a mean trace plot for current unit, aligned to
                % aligned event time
                hMeanf = figure('position',[100 100 1450 300],'visible','off'); %,'visible','off'
                yaxisScales = zeros(Seg1TypeNum,2);
                hlAlls = [];
                TraceAxess = [];
                for cSeg1Inds = 1 :Seg1TypeNum  % normally stimulus segments
                    ax = subplot(1,Seg1TypeNum,cSeg1Inds);
                    hold on;
                    TraceColors = jet(Seg2TypeNum);
                    SegMeanTraces = cell(Seg1TypeNum,Seg2TypeNum,2);
                    for cSeg2Inds = 1 : Seg2TypeNum
                        cComSeg_datas = cUnitData(SegTypeInds{cSeg1Inds,cSeg2Inds},:);
                        cComNums = size(cComSeg_datas,1);
                        if cComNums > 2
                            SegTraceMean = (mean(cComSeg_datas));
                            SegTraceSem = (std(cComSeg_datas)/sqrt(cComNums));
                            
                            patch_x = [xTs,fliplr(xTs)];
                            patch_y = [SegTraceMean-SegTraceSem,fliplr(SegTraceMean+SegTraceSem)];
                            patch(ax,patch_x,patch_y,1,'FaceColor',[.8 .8 .8],'EdgeColor','none');
                            
                            hl = plot(ax,xTs,SegTraceMean,'Color',TraceColors(cSeg2Inds,:),'linewidth',1);
                            if cSeg1Inds == 1
                                hlAlls = [hlAlls,hl];
                            end
                            
                        else
                            SegTraceMean = NaN;
                            SegTraceSem = NaN;
                        end
                        SegMeanTraces{cSeg1Inds,cSeg2Inds,1} = SegTraceMean;
                        SegMeanTraces{cSeg1Inds,cSeg2Inds,2} = SegTraceSem;
                        
                    end
                    yaxisScales(cSeg1Inds,:) = get(ax,'ylim');
                    TraceAxess = [TraceAxess,ax];
                    if cSeg1Inds == 1
                        ylabel(sprintf('Unit %d, Chn %d',obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)));
                    else
                       set(ax,'yticklabel',{}); 
                    end
                    if cSeg1Inds == Seg1TypeNum
                        legend(ax,hlAlls,EventDespStrs,'location','northeast','box','off','autoupdate','off');
                    end
                end
                
                CommonYScales = [max(min(yaxisScales(:,1)),0),max(yaxisScales(:,2))];
                for cSeg1Inds = 1 :Seg1TypeNum
                   
                   set(TraceAxess(cSeg1Inds),'ylim',CommonYScales); 
                   line(TraceAxess(cSeg1Inds),[AlignedEventOnBin,AlignedEventOnBin]*BinWidth,...
                       CommonYScales,'Color','k','linewidth',0.8,'linestyle','--'); 
                end
                annotation(hMeanf,'textbox',[0.50,0.71,0.3,0.3],'String',sprintf('Unit %d, Chn %d',...
                    obj.UsedClus_IDs(cUnit),obj.ChannelUseds_id(cUnit)),'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',12);
                
            %
                 if ~isdir(fullfile(obj.ksFolder,'EventAlignPlot'))
                     mkdir(fullfile(obj.ksFolder,'EventAlignPlot'));
                 end
                 cd(fullfile(obj.ksFolder,'EventAlignPlot'));
                 ColorSaveName = sprintf('Unit%3d Eventaligned color plots',obj.UsedClus_IDs(cUnit));
                 saveas(hcf,ColorSaveName);
                 saveas(hcf,ColorSaveName,'png');
                 set(hcf,'paperpositionmode','manual');
                 print(hcf,'-dpdf',ColorSaveName,'-painters');

                 AvgSaveName = sprintf('Unit%3d Eventaligned meantrace plots',obj.UsedClus_IDs(cUnit));
                 saveas(hMeanf,AvgSaveName);
                 saveas(hMeanf,AvgSaveName,'png');
                 set(hMeanf,'paperpositionmode','manual');
                 print(hMeanf,'-dpdf',AvgSaveName,'-painters');

                 close(hcf);
                 close(hMeanf);
            end
            
            
        end
        
        function obj = SpikeWaveFeature(obj,varargins)
            % function used to analysis single unit waveform features
            % the wave form features may includes firerate, peak-to-trough
            % width, refraction peak and so on
            
            
            
        end
        
        
    end
    
end
