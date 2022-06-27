cclr;

%
ProbespikeFolder='I:\ksOutput_backup\b107a03_ksoutput\A2021230_b107a03_NPSess04_g0_cat\catgt_A2021230_b107a03_NPSess04_g0\Cat_A2021230_b107a03_NPSess04_g0_imec0';

%
% start a new NP data analysis session
ProbNPSess = NPspikeDataMining(fullfile(ProbespikeFolder,'ks2_5'),'Task');

ProbNPSess = ProbNPSess.triggerOnsetTime([],[6,2],[]);
% ProbNPSess = ProbNPSess.triggerOnsetTime([],[2,6],[]);
% load behavior datas

load('I:\ksOutput_backup\b107a03_ksoutput\A2021230_b107a03_NPSess04_g0_cat\catgt_A2021230_b107a03_NPSess04_g0\A2021230_b107a03_NPSess04_2afc.mat');
%
BlockSectionInfo = Bev2blockinfoFun(behavResults);
if isempty(BlockSectionInfo)
    return;
end

TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrTimeAnswer = double(behavResults.Time_answer(:));
TrTimeReward = double(behavResults.Time_reward(:));
TrManWaters = double(behavResults.ManWater_choice(:));
%
ExcludeFirstNumofInds = 0;
% if using stim aligned PSTH data
% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-1.5,4]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
    ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);
end
%% the unit exclusion needs spike time data, moved after the unit spike data
% construction
if isempty(ProbNPSess.SurviveInds)
    ProbNPSess = ProbNPSess.ClusScreeningFun;
else
    IsRescreening = questdlg('Survival inds already exists, do you want to rescreen the units?','rescreening check',...
        'Yes','No','Cancel','Yes');
    switch IsRescreening
        case 'Yes'
            ProbNPSess = ProbNPSess.ClusScreeningFun;
        case 'No'
            % do nothing
        case 'Cancel'
            % do nothing
    end
end


[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,TimeWin(2));

IsBoundshiftSess = 0;
SessFreqTypes = BlockSectionInfo.BlockFreqTypes;
if length(SessFreqTypes) > 3
    IsBoundshiftSess = 1;
end
SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
NumFreqs = length(SessFreqTypes);
BlockStartNotUsedTrs = 0; % number of trals not used after block switch
%
if ~exist('ProbeChn_regionCells','var')
    ProbeChn_regionCells = [];
end

if IsBoundshiftSess
    %    hf = figure('position',[100 100 400 300]);
    %    hold on
    NumBlocks = length(BlockSectionInfo.BlockTypes);
    
    BlockNMRealTrInds = cell(NumBlocks,1);
    BlockpsthAvgTrace = cell(NumBlocks,2);
    BlockAlignedEventTypes = cell(NumBlocks,2);
    
    EventsDelay = [TrStimOnsets,TrTimeAnswer];
    %
    for cB = 1 : NumBlocks
        cBScales = [max(BlockSectionInfo.BlockTrScales(cB,1),ExcludeFirstNumofInds),...
            BlockSectionInfo.BlockTrScales(cB,2)];
        cBScales = cBScales+[BlockStartNotUsedTrs,0];
        
        UsedTrRealInds = (cBScales(1):cBScales(2))';
        %        cBTrFreqs = TrFreqUseds(UsedTrRealInds);
        cBTrChoices = TrActionChoice(UsedTrRealInds);
        %        cBTrPerfs = TrTypes(UsedTrRealInds) == cBTrChoices;
        %        cBStimOnsets = TrStimOnsets(UsedTrRealInds);
        %        cBAnswer = TrTimeAnswer(UsedTrRealInds);
        
        cBNMInds = cBTrChoices~= 2;
        cBNMRealTrInds = UsedTrRealInds(cBNMInds);
        BlockNMRealTrInds{cB} = cBNMRealTrInds(:);
        %        cBTrFreqsNM = cBTrFreqs(cBNMInds);
        %        cBTrChoiceNM = cBTrChoices(cBNMInds);
        %        cBTrPerfsNM = cBTrPerfs(cBNMInds);
        AlignEvent = 1;
        if AlignEvent == 1
            if strcmpi(ProbNPSess.TrigAlignType,'trigger')
                BlockNameStr = sprintf('Block%d_plot_trigBin',cB);
                BlockNameStr2 = sprintf('Block%d_spRaster_trigBin',cB);
            else
                BlockNameStr = sprintf('Block%d_plot_stimBin',cB);
                BlockNameStr2 = sprintf('Block%d_spRaster_stimBin',cB);
            end
            RasterAlign = [1,2];
        elseif AlignEvent == 2
            if strcmpi(ProbNPSess.TrigAlignType,'trigger')
                BlockNameStr = sprintf('Block%d_plot_trigBin_AnsAlign',cB);
                BlockNameStr2 = sprintf('Block%d_spRaster_trig_AnsAlign',cB);
            else
                BlockNameStr = sprintf('Block%d_plot_stimBin_AnsAlign',cB);
                BlockNameStr2 = sprintf('Block%d_spRaster_stim_AnsAlign',cB);
            end
            RasterAlign = [2,1];
        end
        
        RepeatTypes = [TrFreqUseds,TrActionChoice];
        RepeatStr = {'Sounds','Choice'};
        EventColors = {'SOnset','AnswerT';'r','m'};
        
        ProbNPSess.SessBlockTypes = BlockSectionInfo.BlockTypes(cB);
        %
        
        if cB == 1 % save channel area infomation in the class handle
            %
            [ProbNPSess,StimAvgTrace,StimTypes] = ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
                cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
            %
        else
            [~,StimAvgTrace, StimTypes]= ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
                cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
        end
        ProbNPSess.SessBlockTypes = [];
        BlockpsthAvgTrace(cB,:) = StimAvgTrace;
        BlockAlignedEventTypes(cB,:) = StimTypes;
        
        % plot the stim aligned spike raster plot
        if strcmpi(ProbNPSess.TrigAlignType,'trigger')
            BlockNameStr2 = sprintf('Block%d_spRaster_trigBin',cB);
        else
            BlockNameStr2 = sprintf('Block%d_spRaster_stimBin',cB);
        end
        %
        ProbNPSess.EventRasterplot(EventsDelay,[1,2],RepeatTypes,RepeatStr,EventColors,...
            cBNMRealTrInds,BlockNameStr2,lick_time_struct,ProbeChn_regionCells);
        
    end
    
end

% save task data within current sessions
if AlignEvent == 1
    TaskDataSavePath = fullfile(ProbespikeFolder,'TaskSessData.mat'); 
else
    TaskDataSavePath = fullfile(ProbespikeFolder,'TaskSessData_AnsAlign.mat');
end

save(TaskDataSavePath,'BlockSectionInfo','behavResults','BlockNMRealTrInds',...
    'BlockpsthAvgTrace','BlockAlignedEventTypes','-v7.3');

% %%
% SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{1}{:,1}),[1,3,2]);
% [TotalTrNum,UnitNum,BinNumbers] = size(SMBinDataMtx);
% 
% % % zscore before average calculation
% % zsDatas = zeros(TotalTrNum,UnitNum,BinNumbers);
% % for cunit = 1 : UnitNum
% %     cUnitData = SMBinDataMtx(:,cunit,:);
% %     unitMean = mean(cUnitData(:));
% %     unitstd = std(cUnitData(:))+1e-6;
% %     zsDatas(:,cunit,:) = (cUnitData-unitMean)/unitstd;
% % end
% binTimeStep = ProbNPSess.USedbin(2); % in seconds
% % NumBlocks = length(BlockNMRealTrInds);
% % cBlockAvg_datas = cell(NumBlocks,2); % data and sorting inds
% % for cB = 1 : NumBlocks
% %     cBInds = BlockNMRealTrInds{cB};
% %     cBTrDatas = zsDatas(cBInds,:,:);
% %     TrAvgData_mtx = squeeze(mean(cBTrDatas));
% %     cBlockAvg_datas{cB,1} = TrAvgData_mtx;
% %     [~,MaxInds] = max(TrAvgData_mtx,[],2);
% %     [~,sortInds] = sort(MaxInds);
% %     cBlockAvg_datas{cB,2} = sortInds;
% % end
% NumBlocks = length(BlockNMRealTrInds);
% RawBlockAvgDatas = cell(NumBlocks,1);
% for cB = 1 : NumBlocks
%     cBInds = BlockNMRealTrInds{cB};
%     cBTrDatas = SMBinDataMtx(cBInds,:,:);
%     TrAvgData_mtx = squeeze(mean(cBTrDatas));
%     RawBlockAvgDatas{cB,1} = TrAvgData_mtx'; % nbins * nUnit, for zscore calculation convenience
% end
% AllBlockAvgTraces = cell2mat(RawBlockAvgDatas);
% AllBlockAvgTraces_zs = zscore(AllBlockAvgTraces);
% cBlockAvg_datas = cell(NumBlocks,2); % data and sorting inds
% for cB = 1 : NumBlocks
%     BlockBinInds = (1:BinNumbers)+BinNumbers*(cB-1);
%     cB_zsTrace = (AllBlockAvgTraces_zs(BlockBinInds,:))';
%     %     cB_zsTrace = AllBlockAvgTraces_zs(BlockBinInds,:);
%     %     BaselineAvgs = mean(cB_zsTrace(1:(ProbNPSess.TriggerStartBin{1}-1),:));
%     %     cB_zsTrace = (cB_zsTrace - BaselineAvgs)';
%     cBlockAvg_datas{cB,1} = cB_zsTrace;
%     [~,MaxInds] = max(cB_zsTrace,[],2);
%     [~,sortInds] = sort(MaxInds);
%     cBlockAvg_datas{cB,2} = sortInds;
% end

% %%
% xTimes = ((1:BinNumbers) - ProbNPSess.TriggerStartBin{1})*binTimeStep;
% yNums = 1:UnitNum;
% 
% hf = figure('position',[100 100 1200 360]);
% SortInds = 1; % which block inds is used for sorting
% for cAx = 1 : NumBlocks
%     ax = subplot(1,NumBlocks,cAx);
%     cBlockData = cBlockAvg_datas{cAx,1};
%     imagesc(xTimes,yNums,cBlockData(cBlockAvg_datas{SortInds,2},:),[-0.5 1]);
%     %     colormap gray
%     xlabel('Times (s)');
%     ylabel(sprintf('# ROIs (SortbyBlock #%d)',SortInds));
%     title(num2str(cAx,'Block %d'));
% end
% %% plot the mean traces from different blocks in same axis
RepeatTypeStrs = {'Stim','Choice'};
% if IsBoundshiftSess
%    hf = figure('position',[100 100 400 300]);
%    hold on
NumBlocks = length(BlockSectionInfo.BlockTypes);
PlotColors = purple2green(ceil(NumBlocks/2)*2,0.8);
TotalNumColors = size(PlotColors,1)/2;
lowboundColors = PlotColors(1:TotalNumColors,:);
HighBoundColors = PlotColors((TotalNumColors*2):-1:(TotalNumColors+1),:);
%

[NumUnits, NumEventtype1, NumEventtype2, ~] = size(BlockpsthAvgTrace{1,1});
for cUnit = 1 : NumUnits
    %
    cUnitAllBData = cellfun(@(x) squeeze(x(cUnit,:,:,:)),BlockpsthAvgTrace(:,1),'UniformOutput',false);
    hsumf = figure('position',[100 100 1520 420],'visible','off');
    LowBoundPlottedInds = 1;
    HighBoundPlottedInds = 1;
    AxAll = gobjects(NumEventtype1,NumEventtype2); % to store axess
    hls = gobjects(NumEventtype1,NumEventtype2,NumBlocks); % to store all line plots
    hl_isexists = zeros(NumEventtype1,NumEventtype2,NumBlocks);
    hlsstr = cell(NumEventtype1,NumEventtype2,NumBlocks);
    for cB = 1 : NumBlocks
        cBData = cUnitAllBData{cB};
        cBData_ts = BlockpsthAvgTrace{cB,2};
        cBevent2Types = BlockAlignedEventTypes{cB,2};
        cBTypes = BlockSectionInfo.BlockTypes(cB);
        if cBTypes > 0
            plotColor = HighBoundColors(HighBoundPlottedInds,:);
            HighBoundPlottedInds = HighBoundPlottedInds + 1;
        else
            plotColor = lowboundColors(LowBoundPlottedInds,:);
            LowBoundPlottedInds = LowBoundPlottedInds + 1;
        end
        % the two choices with be plotted in solid and dash lines for
        % discrimination
        
        % loop through event type 1
        
        for cStim = 1 : NumEventtype1
            for cEvent2 = 1 : NumEventtype2
                k = cStim+(cEvent2-1)*NumEventtype1;
                if ~ishandle(AxAll(cStim,cEvent2))
                    ax = subplot(NumEventtype2,NumEventtype1,k);
                    hold on;
                    AxAll(cStim,cEvent2) = ax;
                else
                    ax = AxAll(cStim,cEvent2);
                end
                
                cplot_trace_type2_1 = cBData{cStim,cEvent2,1};
                %                     cplot_trace_type2_2 = cBData{cStim,2,1};
                if ~isempty(cplot_trace_type2_1) && ~any(isnan(cplot_trace_type2_1)) % if there is real data exists
                    BaselineEndsInds = find(cBData_ts>0, 1, 'first');
                    %                         cplot_trace_type2_1 = cplot_trace_type2_1 - mean(cplot_trace_type2_1(1:(BaselineEndsInds-1))); % baseline substraction
                    %                         hl = plot(ax,cBData_ts,smooth(cBData_ts,cplot_trace_type2_1,0.1,'rloess'),'Color',plotColor,'linewidth',1);
                    hl = plot(ax,cBData_ts,cplot_trace_type2_1,'Color',plotColor,'linewidth',1);
                    hls(cStim,cEvent2,cB) = hl;
                    hl_isexists(cStim,cEvent2,cB) = 1;
                    %                     hls = [hls,hl];
                    hlsstr{cStim,cEvent2,cB} = sprintf('Block %d ,%s %d',cBTypes,RepeatTypeStrs{2},cBevent2Types(cEvent2));
                end
                %                     if ~isempty(cplot_trace_type2_2) && ~any(isnan(cplot_trace_type2_2)) % if there is real data exists
                %                         BaselineEndsInds = find(cBData_ts>0, 1, 'first');
                %                         cplot_trace_type2_2 = cplot_trace_type2_2 - mean(cplot_trace_type2_2(1:(BaselineEndsInds-1)));
                %                         hl2 = plot(ax,cBData_ts,smooth(cBData_ts,cplot_trace_type2_2,0.1,'rloess'),'Color',plotColor,'linewidth',1,'linestyle','--');
                %     %                     hls = [hls,hl2];
                %                         hls(cStim,(cB*2)) = hl2;
                %                         hlsstr{cStim,(cB*2)} = sprintf('Block %d ,%s %d',cBTypes,RepeatTypeStrs{2},cBevent2Types(2));
                %                     end
                
            end
        end
    end
    yscales = zeros(NumEventtype1*NumEventtype2,2);
    k = 1;
    for cStim = 1 : NumEventtype1
        for cchoice = 1 : NumEventtype2
            yscales(k,:) = get(AxAll(cStim,cchoice),'ylim');
            k = k + 1;
        end
    end
    UsedScales = [min(yscales(:,1)), max(yscales(:,2))];
    IsLegendSet = zeros(NumEventtype2,1);
    MaxLegendNums = max(sum(hl_isexists,3));
    for cStim = 1 : NumEventtype1
        for cChoice = 1 : NumEventtype2
            set(AxAll(cStim,cChoice),'ylim',UsedScales);
            if ~IsLegendSet(cChoice)
                if sum(ishandle(hls(cStim,cChoice,:))) == MaxLegendNums(cChoice)
                    legend(AxAll(cStim,cChoice),hls(cStim,cChoice,:), hlsstr(cStim,cChoice,:),'location','Northeast','box','off');
                    IsLegendSet(cChoice) = 1;
                end
            end
        end
    end
    
    %
    annotation(hsumf,'textbox',[0.50,0.71,0.3,0.3],'String',sprintf('Unit %d, Chn %d, (Block %d)',...
        ProbNPSess.UsedClus_IDs(cUnit),ProbNPSess.ChannelUseds_id(cUnit),cBTypes),'FitBoxToText','on','EdgeColor',...
        'none','FontSize',12);
    %
    if ~isdir(fullfile(ProbespikeFolder,'BlockmergedMeanTrace'))
        mkdir(fullfile(ProbespikeFolder,'BlockmergedMeanTrace'));
    end
    savename = fullfile(ProbespikeFolder,'BlockmergedMeanTrace',sprintf('Unit%d across block mean trace plot',ProbNPSess.UsedClus_IDs(cUnit)));
    saveas(hsumf,savename);
    saveas(hsumf,savename,'png');
    close(hsumf);
end


%% passive analysis session
PassiveFileFullPath = 'I:\ksOutput_backup\b107a03_ksoutput\A2021230_b107a03_NPSess04_g0_cat\catgt_A2021230_b107a03_NPSess04_g0\A2021230_b107a03_NPSess04_rf.txt';
ProbNPSess.CurrentSessInds = strcmpi('passive',ProbNPSess.SessTypeStrs);

ProbNPSess = ProbNPSess.triggerOnsetTime([],4);  % 4 is the trigger duration, in ms

% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-0.4,3]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [100,20]; % time window for smooth psth, in ms format
ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, []);
%%
% load passive sound results
soundTextfile = PassiveFileFullPath;
Datas = readmatrix(soundTextfile);
BeforeSoundDelay = 1000; % in mili-second
TrFrequency = Datas(:,1);
TrDBs = Datas(:,2);
TrDuration = Datas(:,3);
NumTrials = length(TrFrequency);
TrOnsetVec = repmat(BeforeSoundDelay,NumTrials,1);
AlignEvents = [TrOnsetVec,TrOnsetVec+TrDuration];%,TrOnsetVec+TrDuration+floor((rand(numel(TrDuration),1)*200)+100)


ProbNPSess.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
    {'SOnset','SOffset';'r','m'},[],'Passive_colorplot',[],ProbeChn_regionCells);
PassSoundDatas = Datas;

%
save(fullfile(ProbespikeFolder,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');


