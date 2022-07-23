function matfileBlockInfos = BlockpsyCurveCalFun(behavResults,varargin)
Isplot = 0;
if nargin > 1
    if ~isempty(varargin{1})
        Isplot = varargin{1};
    end
end
matfileBlockInfos = cell(1,6);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
if isempty(BlockSectionInfo)
    warning('Input variable do not have reversal blocks');
    return;
end

matfileBlockInfos{1} = BlockSectionInfo;

TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrFreqUseds = double(behavResults.Stim_toneFreq(:));
% TrStimOnsets = double(behavResults.Time_stimOnset(:));
% TrTimeAnswer = double(behavResults.Time_answer(:));
% TrTimeReward = double(behavResults.Time_reward(:));
% TrManWaters = double(behavResults.ManWater_choice(:));

% calculate and plot
IsBoundshiftSess = 0;
matfileBlockInfos{2} = 0;
SessFreqTypes = BlockSectionInfo.BlockFreqTypes;
if length(SessFreqTypes) > 4 && BlockSectionInfo.NumBlocks > 1
    IsBoundshiftSess = 1;
end
try
    SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
    NumFreqs = length(SessFreqTypes);
    BlockStartNotUsedTrs = 0; % number of trals not used after block switch
    if IsBoundshiftSess
        matfileBlockInfos{2} = 1;
        
        NumBlocks = length(BlockSectionInfo.BlockTypes);
        BlockPerfs = cell(NumBlocks,5);
        for cB = 1 : NumBlocks
            cBScales = BlockSectionInfo.BlockTrScales(cB,:) + [BlockStartNotUsedTrs,0];
            cBTrFreqs = TrFreqUseds(cBScales(1):cBScales(2));
            cBTrChoices = TrActionChoice(cBScales(1):cBScales(2));
            cBTrPerfs = TrTypes(cBScales(1):cBScales(2)) == cBTrChoices;
            
            cBNMInds = cBTrChoices~= 2;
            cBTrFreqsNM = cBTrFreqs(cBNMInds);
            cBTrChoiceNM = cBTrChoices(cBNMInds);
            cBTrPerfsNM = cBTrPerfs(cBNMInds);
            
            FreqChoiceANDperfs = zeros(NumFreqs,3);
            for ccf = 1 : NumFreqs
                cfcBInds = cBTrFreqsNM == SessFreqTypes(ccf);
                cfcBChoices = cBTrChoiceNM(cfcBInds);
                cfcBPerfs = mean(cBTrPerfsNM(cfcBInds));
                
                FreqChoiceANDperfs(ccf,:) = [mean(cfcBChoices),cfcBPerfs,numel(cfcBChoices)];
            end
            BlockPerfs{cB,1} = FreqChoiceANDperfs;
            
            ChoiceProbs = FreqChoiceANDperfs(:,1);
            UL = [0.5, 0.5, max(SessFreqOcts), 100];
            SP = [min(ChoiceProbs),1 - max(ChoiceProbs)-min(ChoiceProbs), mean(SessFreqOcts), 1];
            LM = [0, 0, min(SessFreqOcts), 0];
            ParaBoundLim = ([UL;SP;LM]);
            cBTrFreqOcts = log2(cBTrFreqsNM/min(SessFreqTypes));
            fit_curveAll = FitPsycheCurveWH_nx(cBTrFreqOcts,cBTrChoiceNM,ParaBoundLim);
            fit_curveAvg = FitPsycheCurveWH_nx(SessFreqOcts,ChoiceProbs,ParaBoundLim);
            if Isplot
                hf = figure('position',[100 100 400 300]);
                hold on
                if ~BlockSectionInfo.BlockTypes(cB) % low bound session
                    plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[.45 .8 0.4],'LineWidth',1.6);
                    plot(SessFreqOcts,ChoiceProbs,'o','Color',[.45 .8 0.4],'MarkerSize',5,'linewidth',1.2);
                else
                    plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[0.94 0.72 0.2],'LineWidth',1.6);
                    plot(SessFreqOcts,ChoiceProbs,'d','Color',[0.94 0.72 0.2],'MarkerSize',5,'linewidth',1.2);
                end
            end
            CurveBounds = fit_curveAll.ffit.u;
            BlockPerfs{cB,2} = fit_curveAll;
            BlockPerfs{cB,3} = CurveBounds;
            BlockPerfs{cB,4} = fit_curveAvg;
            BlockPerfs{cB,5} = fit_curveAvg.ffit.u;
        end
        
        LowBoundInds = BlockSectionInfo.BlockTypes == 0;
        MeanLowBound = mean(cell2mat(BlockPerfs(LowBoundInds,3)));
        MeanHighBound = mean(cell2mat(BlockPerfs(~LowBoundInds,3)));
        if Isplot
            text(median(SessFreqOcts)+0.1,0.4,num2str(abs(BlockPerfs{1,3}-BlockPerfs{2,3}),'First2BoundDiff=%.3f'));
            text(median(SessFreqOcts)+0.1,0.2,num2str(MeanHighBound-MeanLowBound,'AvgBoundDiff=%.3f'));
            xlabel('Octaves');
            ylabel('Rightward prob.');
            set(gca,'ylim',[-0.05 1.05]);
            % title(strrep(cMatfile(1:end-4),'_','\_'));
        end
        matfileBlockInfos{3} = MeanHighBound;
        matfileBlockInfos{4} = MeanLowBound;
        matfileBlockInfos{5} = BlockPerfs;
    end
%     if Isplot
%         saveas(hf,fullfile(datafolders,[cMatfile(1:end-4),'_Boundshift_plot']));
%         saveas(hf,fullfile(datafolders,[cMatfile(1:end-4),'_Boundshift_plot']),'png');
%         close(hf);
%     end
    %
end
%
try
    if IsBoundshiftSess
        RevFreqNums = sum(BlockSectionInfo.IsFreq_asReverse);
        RevFreqInds = find(BlockSectionInfo.IsFreq_asReverse);
        
        RevFreq_choices = cell(RevFreqNums+1,3);
        for ccf = 1 : RevFreqNums
            cfInds = RevFreqInds(ccf);
            cRevFreq_logis = BlockSectionInfo.RevFreqTrInds(:, cfInds+1);
            cRevFreq_logis(TrActionChoice == 2) = false;
            cRevFreq_trRealIndex = find(cRevFreq_logis);
            cFreq_realChoices = TrActionChoice(cRevFreq_trRealIndex);
            
            RevFreq_choices(ccf,:) = {cRevFreq_trRealIndex, cFreq_realChoices, num2str(BlockSectionInfo.BlockFreqTypes(cfInds),'%d')};
        end
        
        AllRevFreq_logis = BlockSectionInfo.RevFreqTrInds(:, 1);
        AllRevFreq_logis(TrActionChoice == 2) = false;
        AllRevFreq_trRealIndex = find(AllRevFreq_logis);
        AllFreq_realchoices = TrActionChoice(AllRevFreq_trRealIndex);
        RevFreq_choices(end,:) = {AllRevFreq_trRealIndex, AllFreq_realchoices, 'AllRevFreqs'};
        
        matfileBlockInfos{6} = RevFreq_choices;
        
        RevStimNums = size(RevFreq_choices,1); % which usually should be 4, including three freqs and all of the rev freqs
        BlockSwitchInds = BlockSectionInfo.BlockTrScales(1:end-1,2) + 0.5;
        NumswitchInds = length(BlockSwitchInds);
        
        FreqSelfSwitchInds = cell(RevStimNums, 1);
        for cax = 1 : RevStimNums
            
            c_freq_RealTrInds = RevFreq_choices{cax, 1};
            
            SwitchIndsAll = zeros(NumswitchInds,1);
            for cSwitch = 1 : NumswitchInds
                cSwitchInds = find(c_freq_RealTrInds > BlockSwitchInds(cSwitch), 1, 'first') - 1; % the last trial lower than switch inds
                SwitchIndsAll(cSwitch) = cSwitchInds;
                
            end
            FreqSelfSwitchInds{cax} = SwitchIndsAll;
            
        end
        matfileBlockInfos{7} = FreqSelfSwitchInds;
        %
        
    end

end
%




