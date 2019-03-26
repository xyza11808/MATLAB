function varargout = BlockWisePsyPlot(behavStruct)
% used for plot the psychometric curve seperately while multi-block exists
if ~isfield(behavStruct,'Block_Type')
    error('Block indicator is not exists in current input.');
end
TrActInds = behavStruct.Action_choice(:);
NMChoiceInds = TrActInds ~= 2;
NMChoice = double(behavStruct.Action_choice(NMChoiceInds));
NMTrTypes = double(behavStruct.Trial_Type(NMChoiceInds));
NMFreqs = double(behavStruct.Stim_toneFreq(NMChoiceInds));
TotalNMTrNum = numel(NMChoice);
BaseFreqs = min(NMFreqs);
OctAlls = log2(NMFreqs/BaseFreqs);

BlockInds = double(behavStruct.Block_Type(NMChoiceInds));
BlockShiftIndic = find(abs(diff(BlockInds)))+1;
BlockNum = length(BlockShiftIndic) + 1;

BlockColor = linspecer(BlockNum);
BlockData = struct('FreqTypes',[],'Corrs',[],'RProbs',[],'fits',[],'Curves',[],...
    'BlockType',[],'BlockInds',[],'FreqOcts',[]);
hf = figure('position',[100 100 480 350]);
hold on
hlAll = [];
for cBlock = 1 : BlockNum
    if cBlock == 1
        cBlockInds = 1:BlockShiftIndic(cBlock)-1;
    elseif cBlock == BlockNum
        cBlockInds = BlockShiftIndic(cBlock-1):TotalNMTrNum;
    else
        cBlockInds = BlockShiftIndic(cBlock-1):(BlockShiftIndic(cBlock)-1);
    end
    cBlockFreqs = NMFreqs(cBlockInds);
    cBlockChoice = NMChoice(cBlockInds);
    cBlockTrTypes = NMTrTypes(cBlockInds);
    
    FreqTypes = unique(cBlockFreqs);
    nFreqs = length(FreqTypes);
    FreqCorrRate = zeros(nFreqs,1);
    FreqRProb = zeros(nFreqs,1);
    for cF = 1 : nFreqs
        cfInds = cBlockFreqs == FreqTypes(cF);
        cfChoices = cBlockChoice(cfInds);
        cfTrTypes = cBlockTrTypes(cfInds);
        
        cfCorrRate = mean(cfChoices(:) == cfTrTypes(:));
        cfRProb = mean(cfChoices);
        FreqCorrRate(cF) = cfCorrRate;
        FreqRProb(cF) = cfRProb;
    end
    BlockFreqOcts = log2(cBlockFreqs/BaseFreqs);
    fit_ReNewAll = FitPsycheCurveWH_nx(BlockFreqOcts, cBlockChoice);
    
    % value assignment
    BlockData(cBlock).FreqTypes = FreqTypes;
    BlockData(cBlock).Corrs = FreqCorrRate;
    BlockData(cBlock).RProbs = FreqRProb;
    BlockData(cBlock).fits = fit_ReNewAll.ffit;
    BlockData(cBlock).Curves = fit_ReNewAll.curve;
    BlockData(cBlock).BlockType = BlockInds(cBlockInds(2));
    BlockData(cBlock).BlockInds = cBlockInds;
    BlockData(cBlock).FreqOcts = log2(FreqTypes/BaseFreqs);
    
    hl = plot(fit_ReNewAll.curve(:,1),fit_ReNewAll.curve(:,2),'Color',BlockColor(cBlock,:),'linewidth',1.5);
    hlAll = [hlAll,hl];
    plot(BlockData(cBlock).FreqOcts,FreqRProb,'o','Color',BlockColor(cBlock,:));
    line([fit_ReNewAll.ffit.u fit_ReNewAll.ffit.u],[0 1],'Color',BlockColor(cBlock,:),'linewidth',1.2,'linestyle','--');
    
end
BlockStr = cellstr(num2str((1:BlockNum)','Block%d'));
legend(hlAll,BlockStr,'Box','off','location','SouthEast','FontSize',8);
set(gca,'xlim',[min(OctAlls)-0.1 max(OctAlls)+0.1],'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
xTTicks = [0 1 2];
xTickLabels = (2.^xTTicks)*BaseFreqs;
set(gca,'xtick',xTTicks,'xticklabel',xTickLabels);
xlabel('Freq (Hz)');
ylabel('R Prob.')
set(gca,'FontSize',14);

if ~isdir('./BlockSwitchPsyPlot/')
    mkdir('./BlockSwitchPsyPlot/');
end
cd('./BlockSwitchPsyPlot/');

saveas(hf,'Block Switch curve plots');
saveas(hf,'Block Switch curve plots','png');
saveas(hf,'Block Switch curve plots','pdf');
close(hf);

save BlockPsyDataSave.mat BlockData -v7.3

if nargout > 0
    varargout{1} = BlockData;
end



