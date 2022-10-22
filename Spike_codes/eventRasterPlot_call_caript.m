
clearvars ProbNPSess
if isfolder(fullfile(ksfolder,'RawRasterPlot'))
    return;
end
% cSessPath = strrep(SessionFolders{31},'F:','E:\NPCCGs');
% cd(fullfile(cSessPath,'ks2_5'));
load(fullfile(ksfolder,'NPClassHandleSaved.mat'))

%%
% ksfolder = pwd;
ProbNPSess.ksFolder = ksfolder;

%%
AllTrStimOnTime = double(behavResults.Time_stimOnset(:));
AllTrAnsTime = double(behavResults.Time_answer(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrBlockTypes = double(behavResults.BlockType(:));
TrStimFreqs = double(behavResults.Stim_toneFreq(:));

NMTrInds = TrActionChoice ~= 2;
NMTrStimOnTime = AllTrStimOnTime(NMTrInds);
NMTrAnsTime = AllTrAnsTime(NMTrInds);
NMTrChoices = TrActionChoice(NMTrInds);
NMBlockTypes = TrBlockTypes(NMTrInds);
NMTrFreqs = TrStimFreqs(NMTrInds);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockSecEdgeInds = [0.5;BlockSectionInfo.BlockTrScales(:,2)+0.5;numel(NMTrInds)+0.5];
BlockMissTrCount = histcounts(find(~NMTrInds),BlockSecEdgeInds);
BlockEndTrInds = BlockSectionInfo.BlockTrScales(:,2) - BlockMissTrCount(1:end-1)';

EventAignTimes = NMTrAnsTime - NMTrStimOnTime; % time difference between stim-on and answer
ChoiceTypeColors = {'b','r'};
BlockTypeColors = {[0.2 0.6 0.2],[0.7 0.4 0.1]};
ExtraEventStrs = {'Choice'};
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

cFolderChnAreaStrc = load(fullfile(ksfolder,'Chnlocation.mat'),'AlignedAreaStrings');
ChnAreaStrs = cFolderChnAreaStrc.AlignedAreaStrings{2};
ProbNPSess.ChannelAreaStrs = ChnAreaStrs;
ProbNPSess.RawRasterplot(EventAignTimes,NMTrFreqs,...
    {NMTrChoices,ChoiceTypeColors}, NMBlockTypes, BlockTypeColors,NMTrInds);








