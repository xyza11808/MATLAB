% load behave structure data
load(BehaviorDataPath);
%
if ~(isempty(BehaviorExcludeInds) || any(ismissing(BehaviorExcludeInds)))
    %
    if ~isnumeric(BehaviorExcludeInds)
        if contains(BehaviorExcludeInds, '-')
            BehaviorExcludeInds = strrep(BehaviorExcludeInds,'-',':');
        end

        if isempty(str2num(BehaviorExcludeInds)) && contains(BehaviorExcludeInds,'end')
            TotalTrs = 1:length(behavResults.Trial_inds);
            eval(sprintf('BehaviorExcludeInds = TotalTrs(%s);',BehaviorExcludeInds));
        else
            BehaviorExcludeInds = str2num(BehaviorExcludeInds);
        end
    end
    %
    behavFieldNames = fieldnames(behavResults);
    for cf = 1 : length(behavFieldNames)
       if length(behavResults.(behavFieldNames{cf})) == numel(behavResults.(behavFieldNames{cf}))
           behavResults.(behavFieldNames{cf})(BehaviorExcludeInds) = [];
       else
           behavResults.(behavFieldNames{cf})(BehaviorExcludeInds,:) = [];
       end
    end
end
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

ExcludeFirstNumofInds = 10; 
%% if using stim aligned PSTH data
% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-1.5,5]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
    ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);
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
%%
if IsBoundshiftSess 
%    hf = figure('position',[100 100 400 300]);
%    hold on
   NumBlocks = length(BlockSectionInfo.BlockTypes);
   BlockNMRealTrInds = cell(NumBlocks,1);
   BlockpsthAvgTrace = cell(NumBlocks,2);
   BlockAlignedEventTypes = cell(NumBlocks,2);
   BlockNMTrRealInds = cell(NumBlocks,1);
   
   EventsDelay = [TrStimOnsets,TrTimeAnswer];
   %%
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
       BlockNMRealTrInds{cB} = cBNMRealTrInds;
%        cBTrFreqsNM = cBTrFreqs(cBNMInds);
%        cBTrChoiceNM = cBTrChoices(cBNMInds);
%        cBTrPerfsNM = cBTrPerfs(cBNMInds);
       AlignEvent = 2;
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
       
%        ProbNPSess.SessBlockTypes = BlockSectionInfo.BlockTypes(cB);
%        %
%        
%        if cB == 1 % save channel area infomation in the class handle
%            %
%            [ProbNPSess,StimAvgTrace,StimTypes] = ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
%                cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
%            %
%        else
%            [~,StimAvgTrace, StimTypes]= ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
%                cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
%        end
%        ProbNPSess.SessBlockTypes = [];
%        BlockpsthAvgTrace(cB,:) = StimAvgTrace;
%        BlockAlignedEventTypes(cB,:) = StimTypes;
%        
%        % plot the stim aligned spike raster plot
%        if strcmpi(ProbNPSess.TrigAlignType,'trigger') 
%            BlockNameStr2 = sprintf('Block%d_spRaster_trigBin',cB);
%        else
%            BlockNameStr2 = sprintf('Block%d_spRaster_stimBin',cB);
%        end
%        %
%        ProbNPSess.EventRasterplot(EventsDelay,[1,2],RepeatTypes,RepeatStr,EventColors,...
%             cBNMRealTrInds,BlockNameStr2,lick_time_struct,ProbeChn_regionCells);
        
       BlockNMTrRealInds{cB} = cBNMRealTrInds(:);
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
    
%% Extract block trial response values
BlockNMTrAlls = cell2mat(BlockNMTrRealInds);

%  EventsDelay = [TrStimOnsets,TrTimeAnswer];

% calculate baseline response value
baselineRespWin = -1; % use all values before stim onset to calculate baseline
[baselineRespData, ProbNPSess] = ProbNPSess.EventRespFR([],baselineRespWin,BlockNMTrAlls,TrStimOnsets);

% calculate stim response data
stimRespWin = 0.5;
[StimRespData, ~] = ProbNPSess.EventRespFR(TrStimOnsets,stimRespWin,BlockNMTrAlls);

%% calculate the answer response data
AnsRespWin = 0.5;
[AnsRespData, ~] = ProbNPSess.EventRespFR(TrStimOnsets,AnsRespWin,BlockNMTrAlls);

% calculate the answer response window 2 data
AnsRespWin2 = 1;
[AnsRespData2, ~] = ProbNPSess.EventRespFR(TrStimOnsets,AnsRespWin2,BlockNMTrAlls);


%% plot the mean traces from different blocks in same axis
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
       %%
       cUnitAllBData = cellfun(@(x) squeeze(x(cUnit,:,:,:)),BlockpsthAvgTrace(:,1),'UniformOutput',false);
       hsumf = figure('position',[100 100 1520 420],'visible','on');
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
        
        %%
        annotation(hsumf,'textbox',[0.50,0.71,0.3,0.3],'String',sprintf('Unit %d, Chn %d, (Block %d)',...
                    ProbNPSess.UsedClus_IDs(cUnit),ProbNPSess.ChannelUseds_id(cUnit),cBTypes),'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',12);
   %    
       if ~isdir(fullfile(ProbespikeFolder,'BlockmergedMeanTrace'))
           mkdir(fullfile(ProbespikeFolder,'BlockmergedMeanTrace'));
       end
       savename = fullfile(ProbespikeFolder,'BlockmergedMeanTrace',sprintf('Unit%d across block mean trace plot',ProbNPSess.UsedClus_IDs(cUnit)));
%        saveas(hsumf,savename);
%        saveas(hsumf,savename,'png');
%        close(hsumf);
   end
% end




