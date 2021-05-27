

% NPspikeDataMining processing pipeline
NPprocessks3_pass = NPspikeDataMining('G:\AuD_PASSIVE_TEST_g0\kilosort3'); % input the ks analysis folder path as start

%% load trigger onset times
NPprocessks3_pass = NPprocessks3_pass.triggerOnsetTime([],4);  % 4 is the trigger duration, in ms

%% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-0.4,1.8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
NPprocessks3_pass = NPprocessks3_pass.TrigPSTH(TimeWin, Smoothbin);

%% load passive sound results
soundTextfile = 'G:\AuD_PASSIVE_TEST_g0\passive tones20210316.txt';
Datas = readmatrix(soundTextfile);
BeforeSoundDelay = 1000; % in mili-second
TrFrequency = Datas(:,1);
TrDBs = Datas(:,2);
TrDuration = Datas(:,3);
NumTrials = length(TrFrequency);
TrOnsetVec = repmat(BeforeSoundDelay,NumTrials,1);
AlignEvents = [TrOnsetVec,TrOnsetVec+TrDuration];%,TrOnsetVec+TrDuration+floor((rand(numel(TrDuration),1)*200)+100)

%% raster plot of the raw spike datas
% Passive_preprocessing; % calculate the aligned events and trial repeats values

NPprocessks3_pass.RawRasterplot(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% binned spike color plots
NPprocessks3_pass.RawRespPreview(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% Events sort color plots
% NPprocessks3_pass.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},{'SOnset','SOffset','sTest';'r','m','c'});
NPprocessks3_pass.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
    {'SOnset','SOffset';'r','m'},[],'Passive_colorplot');

%% #######################################################################################################################
%% #######################################################################################################################
%% Task analysis sessions
% ###############################################################################################################################
NPprocessks3 = NPspikeDataMining('N:\NPDatas\b103a04_20210408_NPSess01_g0\b103a04_20210408_NPSess01_g0_imec0\kilosort3'); % input the ks analysis folder path as start

%% load trigger onset times
% NPprocessks3 = NPprocessks3.triggerOnsetTime([],[6,2]);  % 2 is the trigger duration, in ms
NPprocessks3 = NPprocessks3.triggerOnsetTime([],[2,6]);  % 2 is the trigger duration, in ms %%% !!!for session b103a04_20210408_NPSess01_g0_imec0 Only!!!!!
% %% given trigger time windows, and then calculate trigger onset PSTHs
% TimeWin = [-2,10]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [30,5]; % time window for smooth psth, in ms format
% NPprocessks3 = NPprocessks3.TrigPSTH(TimeWin, Smoothbin);

%%
% load behavio datas
% cclr;
[fn,fp,fi] = uigetfile('*.mat','Please select session analized mat file');
if ~fi
    return;
end
cd(fp);

load(fullfile(fp,fn));

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
%% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-2,10]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
NPprocessks3 = NPprocessks3.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);


%% lick time calculations
[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,TimeWin(2)); 

%%
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
       if strcmpi(NPprocessks3.TrigAlignType,'trigger') 
           BlockNameStr = sprintf('Block%d_plot_trigBin',cB);
       else
           BlockNameStr = sprintf('Block%d_plot_stimBin',cB);
       end
       EventsDelay = [TrStimOnsets,TrTimeAnswer];
       AlignEvent = 1;
       RepeatTypes = [TrFreqUseds,TrActionChoice];
       RepeatStr = {'Sounds','Choice'};
       EventColors = {'SOnset','AnswerT';'r','m'};
       
       NPprocessks3.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
           cBNMRealTrInds,BlockNameStr,lick_time_struct);
       
   end
   
end








