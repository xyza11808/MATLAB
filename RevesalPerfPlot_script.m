

BlockSectionInfo = Bev2blockinfoFun(behavResults);

TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrTimeAnswer = double(behavResults.Time_answer(:));
TrTimeReward = double(behavResults.Time_reward(:));
TrManWaters = double(behavResults.ManWater_choice(:));

%% choice switch line plot
BeforeSwTrNum = 20;
AfterSwTrNum = 60;

swOverChoices = nan(BlockSectionInfo.NumBlocks,BeforeSwTrNum+AfterSwTrNum);
SwRevFreqChoice = nan(BlockSectionInfo.NumBlocks,BeforeSwTrNum+AfterSwTrNum);
SwitchPerfs = nan(BlockSectionInfo.NumBlocks,BeforeSwTrNum+AfterSwTrNum);
SwitchRevFreqPerfs = nan(BlockSectionInfo.NumBlocks,BeforeSwTrNum+AfterSwTrNum);
BeforeSWTrtypes = nan(BlockSectionInfo.NumBlocks,1);
% ChoiceSWs = nan(BlockSectionInfo.NumBlocks,BeforeSwTrNum+AfterSwTrNum);
for cB = 1 : BlockSectionInfo.NumBlocks
    cBStartInds = BlockSectionInfo.BlockTrScales(cB,1);
    if cBStartInds > (BeforeSwTrNum+1)
        BeforeswIndex = (cBStartInds-BeforeSwTrNum):((cBStartInds-1));
        BIndsTrChoice = TrActionChoice(BeforeswIndex);
        BIndsTrTypes = TrTypes(BeforeswIndex);
        BNMChoiceInds = BIndsTrChoice ~= 2;
        NumNMChoices = sum(BNMChoiceInds);
        swOverChoices(cB,(BeforeSwTrNum-NumNMChoices+1):BeforeSwTrNum) = ...
            BIndsTrChoice(BNMChoiceInds);
        SwitchPerfs(cB,(BeforeSwTrNum-NumNMChoices+1):BeforeSwTrNum) = ...
            BIndsTrChoice(BNMChoiceInds) == BIndsTrTypes(BNMChoiceInds);
        
        AfterswIndex = cBStartInds:(cBStartInds+AfterSwTrNum-1);
        AIndsTrChoice = TrActionChoice(AfterswIndex);
        AIndsTrTypes = TrTypes(AfterswIndex);
        ANMChoiceInds = AIndsTrChoice ~= 2;
        ANumNMChoices = sum(ANMChoiceInds);
        swOverChoices(cB,(BeforeSwTrNum+1):(BeforeSwTrNum+ANumNMChoices)) = ...
            AIndsTrChoice(ANMChoiceInds);
        SwitchPerfs(cB,(BeforeSwTrNum+1):(BeforeSwTrNum+ANumNMChoices)) = ...
            AIndsTrChoice(ANMChoiceInds) == AIndsTrTypes(ANMChoiceInds);
        
        MergedTrInds = (cBStartInds-BeforeSwTrNum):(cBStartInds+AfterSwTrNum-1);
        swOverTrFreqs = TrFreqUseds(MergedTrInds);
        swOverTrTypes = TrTypes(MergedTrInds);
        swChoices = TrActionChoice(MergedTrInds);
        swOverCorr_rate = swOverTrTypes == swChoices;
        RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
        IsRevFreqs = false(numel(MergedTrInds),1);
        for cf = 1 : length(RevFreqs)
            IsRevFreqs = IsRevFreqs | (swOverTrFreqs == RevFreqs(cf) & swChoices ~= 2); % find all reversal trial inds 
        end
        BeforeRevFreqInds = IsRevFreqs;
        BeforeRevFreqInds((1+BeforeSwTrNum):(AfterSwTrNum+BeforeSwTrNum)) = false;
        AfterRevFreqInds = IsRevFreqs;
        AfterRevFreqInds(1:BeforeSwTrNum) = false;
        
        BefRevFreqPrefs = IsRevFreqs(1:BeforeSwTrNum);
        AfRevFreqPrefs = IsRevFreqs((1+BeforeSwTrNum):(AfterSwTrNum+BeforeSwTrNum));
        
        SwitchRevFreqPerfs(cB,(BeforeSwTrNum-sum(BefRevFreqPrefs)+1):...
            BeforeSwTrNum) = swOverCorr_rate(BeforeRevFreqInds);
        
        SwitchRevFreqPerfs(cB,(BeforeSwTrNum+1):...
            (BeforeSwTrNum+sum(AfRevFreqPrefs))) = swOverCorr_rate(AfterRevFreqInds);
        
        SwRevFreqChoice(cB,(BeforeSwTrNum-sum(BefRevFreqPrefs)+1):...
            BeforeSwTrNum) = swChoices(BeforeRevFreqInds);
        SwRevFreqChoice(cB,(BeforeSwTrNum+1):(BeforeSwTrNum+sum(AfRevFreqPrefs)))...
            = swChoices(AfterRevFreqInds);
        
        BeforeSWTrtypes(cB) = unique(swOverTrTypes(BeforeRevFreqInds));
    else
        MergedTrInds = cBStartInds:(cBStartInds+AfterSwTrNum-1);
        SelectInsertInds = (BeforeSwTrNum+1):(BeforeSwTrNum+AfterSwTrNum);
        
        swOverTrFreqs = TrFreqUseds(MergedTrInds);
        swChoices = TrActionChoice(MergedTrInds);
        swTrTypes = TrTypes(MergedTrInds);
        
        swOverCorr_rate = swTrTypes == swChoices;
        
        swNMChoiceInds = swChoices ~= 2;
        swOverChoices(cB,(BeforeSwTrNum+1):(BeforeSwTrNum+sum(swNMChoiceInds))) = ...
            swChoices(swNMChoiceInds);
        SwitchPerfs(cB,(BeforeSwTrNum+1):(BeforeSwTrNum+sum(swNMChoiceInds))) = ...
            swOverCorr_rate(swNMChoiceInds);
        
        RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
        IsRevFreqs = false(numel(MergedTrInds),1);
        for cf = 1 : length(RevFreqs)
            IsRevFreqs = IsRevFreqs | (swOverTrFreqs == RevFreqs(cf)  & swChoices ~= 2); % find all reversal trial inds 
        end
        RealInds = (1:numel(swOverCorr_rate(IsRevFreqs))) + BeforeSwTrNum;
        SwitchRevFreqPerfs(cB,RealInds) = swOverCorr_rate(IsRevFreqs);
        SwRevFreqChoice(cB,RealInds) = swChoices(IsRevFreqs);
    end
    
end
        
%% performance plot
LowBoundBlockInds = BlockSectionInfo.BlockTypes == 0;
HighBoundBlockInds = BlockSectionInfo.BlockTypes == 1;

LowBoundswPerf = SwitchPerfs(LowBoundBlockInds,:);
HighBoundswPerf = SwitchPerfs(HighBoundBlockInds,:);

LowBoundswFreqPerf = SwitchRevFreqPerfs(LowBoundBlockInds,:);
HighBoundswFreqPerf = SwitchRevFreqPerfs(HighBoundBlockInds,:);
xInds = 1:size(LowBoundswPerf,2);

hf = figure('position',[100 100 680 300]);
subplot(121)
hold on
% plot(smooth(mean(LowBoundswPerf,'omitnan'),5),'k');
plot(mean(LowBoundswPerf,'omitnan'),'k');
swFreqPerfmean = mean(LowBoundswFreqPerf,'omitnan');
xInds(isnan(swFreqPerfmean)) = [];
swFreqPerfmean(isnan(swFreqPerfmean)) = [];
% plot(xInds,smooth(swFreqPerfmean,5),'b');
plot(xInds,swFreqPerfmean,'b');
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','k','linestyle','--');
title('Low bound block');

xInds = 1:size(LowBoundswPerf,2);
subplot(122)
hold on
% plot(smooth(mean(HighBoundswPerf,'omitnan'),5),'k');
plot(mean(HighBoundswPerf,'omitnan'),'k');
swFreqPerfmeanH = mean(HighBoundswFreqPerf,'omitnan');
xInds(isnan(swFreqPerfmeanH)) = [];
swFreqPerfmeanH(isnan(swFreqPerfmeanH)) = [];
% plot(xInds,smooth(swFreqPerfmeanH,5),'b');
plot(xInds,swFreqPerfmeanH,'b');
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','k','linestyle','--');
title('High bound block');

%% switch choice plot
LowBoundBlockInds = BlockSectionInfo.BlockTypes == 0;
HighBoundBlockInds = BlockSectionInfo.BlockTypes == 1;

LowBoundswChoice = SwRevFreqChoice(LowBoundBlockInds,:);
HighBoundswChoice = SwRevFreqChoice(HighBoundBlockInds,:);

xInds = 1:size(SwitchPerfs,2);

hf2 = figure('position',[100 100 680 300]);
subplot(121)
hold on
for clowInds = 1:sum(LowBoundBlockInds)
    nanInds = isnan(LowBoundswChoice(clowInds,:));
    plot(xInds(~nanInds),LowBoundswChoice(clowInds,~nanInds),'Color',[.7 .7 .7],'MarkerSize',6,'linewidth',1);
end
plot(xInds,mean(LowBoundswChoice,'omitnan'),'k','MarkerSize',6,'linewidth',1.4);
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','c','linestyle','--','linewidth',1.2);
title('Low bound block');

% xInds = 1:size(LowBoundswPerf,2);
subplot(122)
hold on
for chighInds = 1:sum(HighBoundBlockInds)
    nanInds = isnan(HighBoundswChoice(chighInds,:));
    plot(xInds(~nanInds),HighBoundswChoice(chighInds,~nanInds),'Color',[1 0.4 0.4],'MarkerSize',6,'linewidth',1);
end
plot(xInds,mean(HighBoundswChoice,'omitnan'),'r','MarkerSize',6,'linewidth',1.4);
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','c','linestyle','--','linewidth',1.2);
title('High bound block');


%% switch choice plot
LowBoundBlockInds = BlockSectionInfo.BlockTypes == 0;
HighBoundBlockInds = BlockSectionInfo.BlockTypes == 1;

LowBoundswPerf = swOverChoices(LowBoundBlockInds,:);
HighBoundswPerf = swOverChoices(HighBoundBlockInds,:);

xInds = 1:size(LowBoundswPerf,2);

hf = figure('position',[100 100 680 300]);
subplot(121)
hold on
swFreqPerfmean = mean(LowBoundswPerf,'omitnan');
xInds(isnan(swFreqPerfmean)) = [];
swFreqPerfmean(isnan(swFreqPerfmean)) = [];
plot(xInds,smooth(swFreqPerfmean,5),'b');
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','k','linestyle','--');
title('Low bound block Choice');

xInds = 1:size(HighBoundswPerf,2);
subplot(122)
hold on
swFreqPerfmeanH = mean(HighBoundswPerf,'omitnan');
xInds(isnan(swFreqPerfmeanH)) = [];
swFreqPerfmeanH(isnan(swFreqPerfmeanH)) = [];
plot(xInds,smooth(swFreqPerfmeanH,5),'b');
line([BeforeSwTrNum BeforeSwTrNum],[0 1],'Color','k','linestyle','--');
title('High bound block Choice');

%% boundary shift session plots
IsBoundshiftSess = 0;
SessFreqTypes = BlockSectionInfo.BlockFreqTypes;
if length(SessFreqTypes) > 3
    IsBoundshiftSess = 1;
end
SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
NumFreqs = length(SessFreqTypes);
if IsBoundshiftSess 
   hf = figure('position',[100 100 400 300]);
   hold on
   NumBlocks = length(BlockSectionInfo.BlockTypes);
   BlockPerfs = cell(NumBlocks,3);
   for cB = 1 : NumBlocks
       cBScales = BlockSectionInfo.BlockTrScales(cB,:);
       cBTrFreqs = TrFreqUseds(cBScales(1):cBScales(2));
       cBTrChoices = TrActionChoice(cBScales(1):cBScales(2));
       cBTrPerfs = TrTypes(cBScales(1):cBScales(2)) == cBTrChoices;
       
       cBNMInds = cBTrChoices~= 2;
       cBTrFreqsNM = cBTrFreqs(cBNMInds);
       cBTrChoiceNM = cBTrChoices(cBNMInds);
       cBTrPerfsNM = cBTrPerfs(cBNMInds);
       
       FreqChoiceANDperfs = zeros(NumFreqs,3);
       for cf = 1 : NumFreqs
          cfcBInds = cBTrFreqsNM == SessFreqTypes(cf);
          cfcBChoices = cBTrChoiceNM(cfcBInds);
          cfcBPerfs = mean(cBTrPerfsNM(cfcBInds));
          
          FreqChoiceANDperfs(cf,:) = [mean(cfcBChoices),cfcBPerfs,numel(cfcBChoices)]; 
       end
       BlockPerfs{cB,1} = FreqChoiceANDperfs;
       
       ChoiceProbs = FreqChoiceANDperfs(:,1);
       UL = [0.5, 0.5, max(SessFreqOcts), 100];
       SP = [min(ChoiceProbs),1 - max(ChoiceProbs)-min(ChoiceProbs), mean(SessFreqOcts), 1];
       LM = [0, 0, min(SessFreqOcts), 0];
       ParaBoundLim = ([UL;SP;LM]);
       cBTrFreqOcts = log2(cBTrFreqsNM/min(SessFreqTypes));
       fit_curveAll = FitPsycheCurveWH_nx(cBTrFreqOcts,cBTrChoiceNM,ParaBoundLim);
       
       if ~BlockSectionInfo.BlockTypes(cB) % low bound session
          plot(fit_curveAll.curve(:,1),fit_curveAll.curve(:,2),'color',[.45 .8 0.4],'LineWidth',1.6);
          plot(SessFreqOcts,ChoiceProbs,'o','Color',[.45 .8 0.4],'MarkerSize',5,'linewidth',1.2);
       else
           plot(fit_curveAll.curve(:,1),fit_curveAll.curve(:,2),'color',[0.94 0.72 0.2],'LineWidth',1.6);
           plot(SessFreqOcts,ChoiceProbs,'d','Color',[0.94 0.72 0.2],'MarkerSize',5,'linewidth',1.2);
       end
       CurveBounds = fit_curveAll.ffit.u;
       BlockPerfs{cB,2} = fit_curveAll;
       BlockPerfs{cB,3} = CurveBounds;
       
   end

end

%%

TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrTypes = double(behavResults.Trial_Type(:));
Freqs = unique(TrFreqUseds);
FreqNums = zeros(length(Freqs),1);
FreqTrTypes = zeros(length(Freqs),2);
for cf = 1 : length(Freqs)
    FreqInds = TrFreqUseds == Freqs(cf);
    FreqNums(cf) = sum(FreqInds);
    FreqTypes = TrTypes(FreqInds);
    FreqTrTypes(cf,1) = sum(FreqTypes == 0);
    FreqTrTypes(cf,2) = sum(FreqTypes == 1);
end

