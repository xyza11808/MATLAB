% load behave structure data
load(BehaviorDataPath);

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
% if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
   TimeWin = [-1.5,5]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
    Smoothbin = [50,10]; % time window for smooth psth, in ms format
    ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);
% end
[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,TimeWin(2)); 

IsBoundshiftSess = 0;
SessFreqTypes = BlockSectionInfo.BlockFreqTypes;
if length(SessFreqTypes) > 3
    IsBoundshiftSess = 1;
end
SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
NumFreqs = length(SessFreqTypes);
BlockStartNotUsedTrs = 0; % number of trals not used after block switch
if IsBoundshiftSess 
%    hf = figure('position',[100 100 400 300]);
%    hold on
   NumBlocks = length(BlockSectionInfo.BlockTypes);
   BlockNMRealTrInds = cell(NumBlocks,1);
   BlockpsthAvgTrace = cell(NumBlocks,2);
   BlockAlignedEventTypes = cell(NumBlocks,2);
   for cB = 1 : NumBlocks
       cBScales = [max(BlockSectionInfo.BlockTrScales(cB,1),ExcludeFirstNumofInds),...
           BlockSectionInfo.BlockTrScales(cB,2)];
       cBScales = cBScales+[BlockStartNotUsedTrs,0];
       
       UsedTrRealInds = cBScales(1):cBScales(2);
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
       if strcmpi(ProbNPSess.TrigAlignType,'trigger') 
           BlockNameStr = sprintf('Block%d_plot_trigBin',cB);
       else
           BlockNameStr = sprintf('Block%d_plot_stimBin',cB);
       end
       EventsDelay = [TrStimOnsets,TrTimeAnswer];
       AlignEvent = 1;
       RepeatTypes = [TrFreqUseds,TrActionChoice];
       RepeatStr = {'Sounds','Choice'};
       EventColors = {'SOnset','AnswerT';'r','m'};
       %
       ProbNPSess.SessBlockTypes = BlockSectionInfo.BlockTypes(cB);
       if cB == 1 % save channel area infomation in the class handle
           [ProbNPSess,StimAvgTrace,StimTypes] = ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
               cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
       else
           [~,StimAvgTrace, StimTypes]= ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
               cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
       end
       ProbNPSess.SessBlockTypes = [];
       BlockpsthAvgTrace(cB,:) = StimAvgTrace;
       BlockAlignedEventTypes(cB,:) = StimTypes;
   end
   
end

% save task data within current sessions
TaskDataSavePath = fullfile(ProbespikeFolder,'TaskSessData.mat');
save(TaskDataSavePath,'BlockSectionInfo','behavResults','BlockNMRealTrInds',...
    'BlockpsthAvgTrace','BlockAlignedEventTypes','-v7.3');

%% plot the mean traces from different blocks in same axis
RepeatTypeStrs = {'Stim','Choice'};
if IsBoundshiftSess 
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
       AxAll = gobjects(NumEventtype1,1); % to store axess
       hls = gobjects(NumEventtype1,NumBlocks*NumEventtype2); % to store all line plots
       hlsstr = cell(NumEventtype1,NumBlocks*NumEventtype2);
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
                if sum(ishandle(AxAll)) < NumEventtype1
                    ax = subplot(1,NumEventtype1,cStim);
                    AxAll(cStim) = ax;
                else
                   ax = AxAll(cStim);
                end
                axes(ax);
                hold on;
                
                cplot_trace_type2_1 = cBData{cStim,1,1};
                cplot_trace_type2_2 = cBData{cStim,2,1};
                if ~isempty(cplot_trace_type2_1) && ~any(isnan(cplot_trace_type2_1)) % if there is real data exists
                    BaselineEndsInds = find(cBData_ts>0, 1, 'first');
                    cplot_trace_type2_1 = cplot_trace_type2_1 - mean(cplot_trace_type2_1(1:(BaselineEndsInds-1))); % baseline substraction
                    hl = plot(cBData_ts,smooth(cBData_ts,cplot_trace_type2_1,0.1,'rloess'),'Color',plotColor,'linewidth',1);
                    hls(cStim,((cB-1)*2+1)) = hl;
%                     hls = [hls,hl];
                    hlsstr{cStim,((cB-1)*2+1)} = sprintf('Block %d ,%s %d',cBTypes,RepeatTypeStrs{2},cBevent2Types(1));
                end
                if ~isempty(cplot_trace_type2_2) && ~any(isnan(cplot_trace_type2_2)) % if there is real data exists
                    BaselineEndsInds = find(cBData_ts>0, 1, 'first');
                    cplot_trace_type2_2 = cplot_trace_type2_2 - mean(cplot_trace_type2_2(1:(BaselineEndsInds-1)));
                    hl2 = plot(cBData_ts,smooth(cBData_ts,cplot_trace_type2_2,0.1,'rloess'),'Color',plotColor,'linewidth',1,'linestyle','--');
%                     hls = [hls,hl2];
                    hls(cStim,(cB*2)) = hl2;
                    hlsstr{cStim,(cB*2)} = sprintf('Block %d ,%s %d',cBTypes,RepeatTypeStrs{2},cBevent2Types(2));
                end
                
            end
            
            
       end
       yscales = zeros(NumEventtype1,2);
        for cStim = 1 : NumEventtype1
            yscales(cStim,:) = get(AxAll(cStim),'ylim');
        end
        UsedScales = [min(yscales(:,1)), max(yscales(:,2))];
        IsLegendSet = 0;
        MaxLegendNums = max(sum(ishandle(hls),2));
        for cStim = 1 : NumEventtype1
            set(AxAll(cStim),'ylim',UsedScales);
            if ~IsLegendSet
               if sum(ishandle(hls(cStim,:))) == MaxLegendNums
                  legend(hls(cStim,:), hlsstr(cStim,:),'location','Northeast','box','off'); 
                  IsLegendSet = 1;
               end
            end
        end
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
end




