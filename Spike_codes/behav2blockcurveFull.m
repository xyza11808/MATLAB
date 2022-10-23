function [OverAllBoundShift, BlockCurveFitAll, BlockSectionInfo] = ...
    behav2blockcurveFull(behavResults,isplot)
% function to calculate block wise psychometric curve

if ~exist('isplot','Var')
    isplot = 0;
end
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
% TrBlocksAll = double(behavResults.BlockType(:));
TrChoicesAll = double(behavResults.Action_choice(:));

FreqTypes = unique(TrFreqsAll);
NumFreqTypes = length(FreqTypes);
TrOctsAll = log2(TrFreqsAll/FreqTypes(1));
OctTypes = log2(FreqTypes/FreqTypes(1));

BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockCurveFitAll = cell(BlockSectionInfo.NumBlocks,4);
LowANDHighColor = {[0.2 0.8 0.2],[0.8 0.5 0.2]};
BlockLabel_xPos = linspace(0.4,1.6,BlockSectionInfo.NumBlocks);
for cB = 1 : BlockSectionInfo.NumBlocks
    cB_trInds = BlockSectionInfo.BlockTrScales(cB,1):BlockSectionInfo.BlockTrScales(cB,2);
    cB_OctavAll = TrOctsAll(cB_trInds);
    cB_ChoiceAll = TrChoicesAll(cB_trInds);
    [Blockfit_curveAll, CurveBounds, BlockChoiceProbs,BlockChoiceProbCI] ...
        = CurveAndOctProbCal(cB_OctavAll, cB_ChoiceAll, OctTypes);
    BlockCurveFitAll(cB,:) = {BlockSectionInfo.BlockTypes(cB),...
        Blockfit_curveAll, CurveBounds, [BlockChoiceProbs,BlockChoiceProbCI]};
    
    if isplot
        if cB == 1
            hf = figure('position',[100 100 420 350]);
            hold on;
        end
        cBColor = LowANDHighColor{BlockSectionInfo.BlockTypes(cB)+1};
        plot(Blockfit_curveAll.curve(:,1),Blockfit_curveAll.curve(:,2),'Color',cBColor,'linewidth',1.2);
        errorbar(OctTypes,BlockChoiceProbs,BlockChoiceProbCI(:,1),BlockChoiceProbCI(:,2),...
            'o','Color',cBColor,'linewidth',1)
        line([CurveBounds CurveBounds],[0 1],'Color',cBColor,'linewidth',0.75,'linestyle','--');
        BlockIndex_label_y = feval(Blockfit_curveAll.ffit,BlockLabel_xPos(cB));
        text(BlockLabel_xPos(cB),BlockIndex_label_y,num2str(cB,'%d'),'Color','m','FontSize',...
            14,'HorizontalAlignment','center');
    end
end
AllBlockTypes = cat(1,BlockCurveFitAll{:,1});
AllBlockBounds = cat(1,BlockCurveFitAll{:,3});
ConsecBoundDiffs = abs(diff(AllBlockBounds));
lowCurveBounds = AllBlockBounds(AllBlockTypes == 0);
HighCurveBounds = AllBlockBounds(AllBlockTypes == 1);
OverAllBoundShift = mean(HighCurveBounds)-mean(lowCurveBounds);

if isplot
    title(sprintf('AvgShift = %.4f, MaxShift = %.4f',OverAllBoundShift,max(ConsecBoundDiffs)));
    set(gca,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
    xlabel('Frequency (kHz)');
    ylabel('Rightward Choice');
    set(gca,'FontSize',12);
end
% if isplot
%     hf = figure('position',[100 100 420 350]);
%     hold on
%     plot(Highfit_curveAll.curve(:,1),Highfit_curveAll.curve(:,2),'Color',[0.8 0.5 0.2],'linewidth',1.2);
%     errorbar(OctTypes,HighChoiceProbs,HighChoiceProbCI(:,1),HighChoiceProbCI(:,2),...
%         'o','Color',[0.8 0.5 0.2],'linewidth',1)
%     line([HighCurveBounds HighCurveBounds],[0 1],'Color',[0.8 0.5 0.2],'linewidth',0.75,'linestyle','--');
% %     plot(OctTypes,HighChoiceProbs,'o','Color',[0.8 0.5 0.2],'linewidth',1);
%     plot(lowfit_curveAll.curve(:,1),lowfit_curveAll.curve(:,2),'Color',[0.2 0.8 0.2],'linewidth',1.2)
%     errorbar(OctTypes,LowChoiceProbs,LowChoiceProbCI(:,1),LowChoiceProbCI(:,2),...
%         'o','Color',[0.2 0.8 0.2],'linewidth',1);
%     line([lowCurveBounds lowCurveBounds],[0 1],'Color',[0.2 0.8 0.2],'linewidth',0.75,'linestyle','--');
%     title(sprintf('BoundaryShift = %.4f',HighCurveBounds-lowCurveBounds));
%     set(gca,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
%     xlabel('Frequency (kHz)');
%     ylabel('Rightward Choice');
%     set(gca,'FontSize',12);
% end

function [Blockfit_curveAll, CurveBounds, BlockChoiceProbs,BlockChoiceProbCI] ...
    = CurveAndOctProbCal(TrOctaves, TrChoices, OctTypes)
% the input choice should be non-miss trials only

% block 0 (low bound block) psychometric curves
blockNMInds = TrChoices ~= 2;
blockTrOcts = TrOctaves(blockNMInds);
blockTrChoices = TrChoices(blockNMInds);
NumFreqTypes = numel(OctTypes);

BlockChoiceProbs = zeros(NumFreqTypes,1);
BlockChoiceProbCI = zeros(NumFreqTypes,2);
for cf = 1 : NumFreqTypes
    cfTypeChoice = blockTrChoices(OctTypes(cf) == blockTrOcts);
    [phat,pci] = binofit(sum(cfTypeChoice),numel(cfTypeChoice));
    BlockChoiceProbs(cf) = phat;
    BlockChoiceProbCI(cf,:) = abs(pci-phat);
end

UL = [0.5, 0.5, max(OctTypes), 100];
SP = [min(BlockChoiceProbs),1 - max(BlockChoiceProbs)-min(BlockChoiceProbs), mean(OctTypes), 1];
LM = [0, 0, min(OctTypes), 0];
ParaBoundLim = ([UL;SP;LM]);
Blockfit_curveAll = FitPsycheCurveWH_nx(blockTrOcts,blockTrChoices,ParaBoundLim);
CurveBounds = Blockfit_curveAll.ffit.u;

