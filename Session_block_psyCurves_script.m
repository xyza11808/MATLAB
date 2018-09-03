MouseWeight = 24;

%%
nTrsAll = length(behavResults.Stim_toneFreq);
BlockNum = floor(nTrsAll/100);
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
TrChoiceAll = double(behavResults.Action_choice(:));
TrTypesAll = double(behavResults.Trial_Type(:));

TrOctaveAll = log2(TrFreqsAll/min(TrFreqsAll))-1;
StimTypes = unique(TrOctaveAll);
StimTypeNum = length(StimTypes);

BlockFitData = cell(BlockNum,1);
PlotHandle = [];
BlockInds = 1 : BlockNum;

PlotColor = cool(BlockNum);
hf = figure('position',[100 100 380 320]);
hold on
for cBlock = 1 : BlockNum
    cBlockInds = [1+(cBlock - 1)*100,nTrsAll];
    if cBlock == BlockNum
        cBlockInds = [1+(cBlock - 1)*100,cBlock*100];
    end
    cBlockFreqs = TrOctaveAll(cBlockInds(1):cBlockInds(2));
    cBlockChoice = TrChoiceAll(cBlockInds(1):cBlockInds(2));
    NMChoiceInds = cBlockChoice ~= 2;
    
    FitData = FitPsycheCurveWH_nx(cBlockFreqs(NMChoiceInds),cBlockChoice(NMChoiceInds));
    BlockFitData{cBlock} = FitData;
    hl = plot(FitData.curve(:,1),FitData.curve(:,2),'Color',PlotColor(cBlock,:),'linewidth',2.4);
    PlotHandle = [PlotHandle,hl];
    
end
Linestr = cellstr(num2str(BlockInds(:),'B%d'));
legend(PlotHandle,Linestr,'Box','off','location','NorthWest');

