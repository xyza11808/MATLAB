
AllTrStimOnTime = double(behavResults.Time_stimOnset(:));
AllTrAnsTime = double(behavResults.Time_answer(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrBlockTypes = double(behavResults.BlockType(:));

NMTrInds = TrActionChoice ~= 2;
NMTrStimOnTime = AllTrStimOnTime(NMTrInds);
NMTrAnsTime = AllTrAnsTime(NMTrInds);
NMTrChoices = TrActionChoice(NMTrInds);
NMBlockTypes = TrBlockTypes(NMTrInds);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockSecEdgeInds = [0.5;BlockSectionInfo.BlockTrScales(:,2)+0.5;numel(NMTrInds)+0.5];
BlockMissTrCount = histcounts(find(~NMTrInds),BlockSecEdgeInds);
BlockEndTrInds = BlockSectionInfo.BlockTrScales(:,2) - BlockMissTrCount(1:end-1)';

EventAignTimes = NMTrAnsTime - NMTrStimOnTime; % time difference between stim-on and answer
ChoiceTypeColors = {'b','r'};
BlockTypeColors = {[0.2 0.6 0.2],[0.7 0.4 0.1]};
ExtraEventStrs = {'Choice'};
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);


ProbNPSess.RawRasterplot(EventAignTimes,ExtraEventStrs,...
    {NMTrChoices,ChoiceTypeColors}, NMBlockTypes, BlockTypeColors,NMTrInds);








