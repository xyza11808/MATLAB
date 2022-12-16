
% first, save behavData into file 'BehavData.mat' within the ks output
% folder

ksfolder = pwd;

%%
% then run this script
batchClusMerge_callScript

%%
probeNPSess = NPspikeDataMining(ksfolder,'Task');

%%
BehavDataFile = dir(fullfile(ksfolder,'..','mouse*.mat'));
BehavDataPath = **;
BehavDataStrc = load(BehavDataPath);
if ~isfield(BehavDataStrc,'behavResults')
    [behavResults,behavSettings] = behav_cell2struct(BehavDataStrc.SessionResults,BehavDataStrc.SessionSettings);
else
    behavResults = BehavDataStrc.behavResults;
    behavSettings = BehavDataStrc.behavResults;
end


%%
probeNPSess = probeNPSess.triggerOnsetTime([],[6,2],[]);
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TimeWin = [-1.5,4]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
% if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
    probeNPSess = probeNPSess.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);
% end
%%
probeNPSess.CurrentSessInds = strcmpi('passive',probeNPSess.SessTypeStrs);
probeNPSess = probeNPSess.triggerOnsetTime([],4);

TimeWin = [-0.4,3];
probeNPSess = probeNPSess.TrigPSTH(TimeWin, []);
probeNPSess.CurrentSessInds = strcmpi('Task',probeNPSess.SessTypeStrs);

%%
probeNPSess.CurrentSessInds = strcmpi('Task',probeNPSess.SessTypeStrs);
probeNPSess.ksFolder = ksfolder;
probeNPSess = probeNPSess.ClusScreeningFun;
fprintf('\nNew cluster screening left units is %d/%d.\n',numel(probeNPSess.UsedClus_IDs),numel(probeNPSess.GoodClusIDs));

%%
NewNPClusHandle.SpikeTimes = [];
behavResults = PreNPClusHandle.behavResults;
PassSoundDatas = PreNPClusHandle.PassSoundDatas;
save(fullfile(ksfolder,'NewClassHandle2.mat'),'NewNPClusHandle','behavResults','PassSoundDatas','-v7.3');


