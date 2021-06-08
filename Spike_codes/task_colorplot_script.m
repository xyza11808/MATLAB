% load behave structure data
load(BehaviorDataPath);

if ~(isempty(BehaviorExcludeInds) || any(ismissing(BehaviorExcludeInds)))
    if ~isnumeric(BehaviorExcludeInds)
        if strfind(BehaviorExcludeInds, '-')
            BehaviorExcludeInds = strrep(BehaviorExcludeInds,'-',':');
        end

        if isempty(num2str(BehaviorExcludeInds)) && contains(BehaviorExcludeInds,'end')
            TotalTrs = length(behavResults.Trial_inds);
            eval(sprintf('BehaviorExcludeInds = TotalTrs(%s);',BehaviorExcludeInds));
        else
            BehaviorExcludeInds = str2num(BehaviorExcludeInds);
        end
    end
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
if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
   TimeWin = [-2,10]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
    Smoothbin = [50,10]; % time window for smooth psth, in ms format
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
if IsBoundshiftSess 
%    hf = figure('position',[100 100 400 300]);
%    hold on
   NumBlocks = length(BlockSectionInfo.BlockTypes);
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
       if cB == 1 % save channel area infomation in the class handle
           ProbNPSess = ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
               cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
       else
           ProbNPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
               cBNMRealTrInds,BlockNameStr,lick_time_struct,ProbeChn_regionCells);
       end
   end
   
end
