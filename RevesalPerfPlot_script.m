

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
BlockStartNotUsedTrs = 0; % number of trals not used after block switch
if IsBoundshiftSess 
   hf = figure('position',[100 100 400 300]);
   hold on
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
       fit_curveAvg = FitPsycheCurveWH_nx(SessFreqOcts,ChoiceProbs,ParaBoundLim);
       
       if ~BlockSectionInfo.BlockTypes(cB) % low bound session
          plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[.45 .8 0.4],'LineWidth',1.6);
          plot(SessFreqOcts,ChoiceProbs,'o','Color',[.45 .8 0.4],'MarkerSize',5,'linewidth',1.2);
       else
           plot(fit_curveAvg.curve(:,1),fit_curveAvg.curve(:,2),'color',[0.94 0.72 0.2],'LineWidth',1.6);
           plot(SessFreqOcts,ChoiceProbs,'d','Color',[0.94 0.72 0.2],'MarkerSize',5,'linewidth',1.2);
       end
       CurveBounds = fit_curveAll.ffit.u;
       BlockPerfs{cB,2} = fit_curveAll;
       BlockPerfs{cB,3} = CurveBounds;
       BlockPerfs{cB,4} = fit_curveAvg;
       BlockPerfs{cB,5} = fit_curveAvg.ffit.u;
   end
   text(median(SessFreqOcts)+0.1,0.4,num2str(abs(BlockPerfs{1,3}-BlockPerfs{2,3}),'First2BoundDiff=%.3f'));
   LowBoundInds = BlockSectionInfo.BlockTypes == 0;
   MeanLowBound = mean(cell2mat(BlockPerfs(LowBoundInds,3)));
   MeanHighBound = mean(cell2mat(BlockPerfs(~LowBoundInds,3)));
   text(median(SessFreqOcts)+0.1,0.2,num2str(MeanHighBound-MeanLowBound,'AvgBoundDiff=%.3f'));
   xlabel('Octaves');
   ylabel('Rightward prob.');
   set(gca,'ylim',[-0.05 1.05]);
   title(strrep(fn(1:end-4),'_','\_'));
end
%%
saveas(gcf,fullfile(fp,[fn(1:end-4),'_Boundshift_plot']));
saveas(gcf,fullfile(fp,[fn(1:end-4),'_Boundshift_plot']),'png');

%%

% TrFreqUseds = double(behavResults.Stim_toneFreq(:));
% TrTypes = double(behavResults.Trial_Type(:));
% Freqs = unique(TrFreqUseds);
% FreqNums = zeros(length(Freqs),1);
% FreqTrTypes = zeros(length(Freqs),2);
% for cf = 1 : length(Freqs)
%     FreqInds = TrFreqUseds == Freqs(cf);
%     FreqNums(cf) = sum(FreqInds);
%     FreqTypes = TrTypes(FreqInds);
%     FreqTrTypes(cf,1) = sum(FreqTypes == 0);
%     FreqTrTypes(cf,2) = sum(FreqTypes == 1);
% end
cclr;
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

%% choice prob compare plot at different block positions

% Blocksegments_early = [50,100,120];
Blocksegments_early = [20,50,70];
EarlySegNum = length(Blocksegments_early);
% Blocksegments_late = [50,100,120];
Blocksegments_late = [30,50,70];
LateSegNum = length(Blocksegments_late);

RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
NumRevFreqs = length(RevFreqs);

EarlySegChoices = zeros(BlockSectionInfo.NumBlocks,EarlySegNum,2);
LateSegChoices = zeros(BlockSectionInfo.NumBlocks,LateSegNum,2);
for cB = 1 : BlockSectionInfo.NumBlocks
    cBInds = BlockSectionInfo.BlockTrScales(cB,:);
    cBTrTypes = TrTypes(cBInds(1):cBInds(2));
    cBTrChoices = TrActionChoice(cBInds(1):cBInds(2));
    cBRevfreqInds = BlockSectionInfo.RevFreqTrInds(cBInds(1):cBInds(2));
    
    for cEInds = 1 : EarlySegNum
        cUsedTrInds = 1:Blocksegments_early(cEInds);
        cUsedChoice = cBTrChoices(cUsedTrInds);
        cRevChoice = cUsedChoice(cUsedChoice ~= 2 & cBRevfreqInds(cUsedTrInds));
        EarlySegChoices(cB,cEInds,:) = [mean(cRevChoice),numel(cRevChoice)];
    end
    
    BlockLen = BlockSectionInfo.BlockLens(cB);
    for cEInds = 1 : LateSegNum
        cUsedTrInds = (BlockLen - Blocksegments_late(cEInds)+1):BlockLen;
        cUsedChoice = cBTrChoices(cUsedTrInds);
        cRevChoice = cUsedChoice(cUsedChoice ~= 2 & cBRevfreqInds(cUsedTrInds));
%         LateRevChoices(cEInds,:) = [mean(cRevChoice),numel(cRevChoice)];
        LateSegChoices(cB,cEInds,:) = [mean(cRevChoice),numel(cRevChoice)];
    end

end

%% 
LowBoundBlockInds = BlockSectionInfo.BlockTypes == 0;
HighBoundBlockInds = BlockSectionInfo.BlockTypes == 1;

LowBoundEarlyChoices = EarlySegChoices(LowBoundBlockInds,:,:);
LowBoundLateChoices = LateSegChoices(LowBoundBlockInds,:,:);
HighBoundEarlyChoices = EarlySegChoices(HighBoundBlockInds,:,:);
HighBoundLateChoices = LateSegChoices(HighBoundBlockInds,:,:);
LowBoundNum = sum(LowBoundBlockInds);
HighBoundNum = sum(HighBoundBlockInds);
%
hcf = figure('position',[200 200 1100 320]);
EarlySegNum = numel(Blocksegments_early);
for cEInds = 1 : EarlySegNum
    ax = subplot(1,EarlySegNum,cEInds);
    hold on
    % early choice plot
    plot(ones(LowBoundNum,1)+(rand(LowBoundNum,1)-0.5)*0.2, squeeze(LowBoundEarlyChoices(:,cEInds,1)),...
        'ko','MarkerSize',6);
    plot(ones(HighBoundNum,1)+(rand(HighBoundNum,1)-0.5)*0.2+1, squeeze(HighBoundEarlyChoices(:,cEInds,1)),...
        'mo','MarkerSize',6);
    
    % late choice plot
    plot(ones(LowBoundNum,1)+(rand(LowBoundNum,1)-0.5)*0.2+3, squeeze(LowBoundLateChoices(:,cEInds,1)),...
        'ko','MarkerSize',6);
    plot(ones(HighBoundNum,1)+(rand(HighBoundNum,1)-0.5)*0.2+4, squeeze(HighBoundLateChoices(:,cEInds,1)),...
        'mo','MarkerSize',6);
    set(ax,'xtick',[1.5 4.5],'xticklabel',{'Early','Late'},'xlim',[0 6],'ylim',[-0.1 1.1]);
    ylabel(ax,'Right Prob.');
    title(sprintf('SegTrNum = %d',Blocksegments_early(cEInds)));
    
end
%%
saveas(hcf,fullfile(fp,[fn(1:end-4),'_BlockswPerf_plot']));
saveas(hcf,fullfile(fp,[fn(1:end-4),'_BlockswPerf_plot']),'png');



%%
save data1.mat LowBoundEarlyChoices LowBoundLateChoices HighBoundEarlyChoices HighBoundLateChoices LowBoundNum HighBoundNum Blocksegments_early -v7.3


%% random puretone psy curve plot

TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
try 
    TrFreqUseds = double(behavResults.Stim_toneFreq(:));
catch
    TrFreqUseds = double(behavResults.Stim_Type(:));
end
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrTimeAnswer = double(behavResults.Time_answer(:));
TrTimeReward = double(behavResults.Time_reward(:));
TrManWaters = double(behavResults.ManWater_choice(:));

NMTrInds = TrActionChoice ~= 2;
NMTrTypes = TrTypes(NMTrInds);
NMTrChoices = TrActionChoice(NMTrInds);
NMTrFreqs = TrFreqUseds(NMTrInds);

FreqTypesAll = unique(NMTrFreqs);
FreqAllOcts = log2(NMTrFreqs/min(FreqTypesAll));
FreqTypeOcts = log2(FreqTypesAll/min(FreqTypesAll));

NumFreqs = numel(FreqTypesAll);
FreqChoiceProbs = zeros(NumFreqs,1);
for cf = 1 : NumFreqs
    cfInds = NMTrFreqs == FreqTypesAll(cf);
    FreqChoiceProbs(cf) = mean(NMTrChoices(cfInds));
end

UL = [0.5, 0.5, max(FreqTypeOcts), 100];
SP = [min(FreqChoiceProbs),1 - max(FreqChoiceProbs)-min(FreqChoiceProbs), mean(FreqTypeOcts), 1];
LM = [0, 0, min(FreqTypeOcts), 0];
ParaBoundLim = ([UL;SP;LM]);

fit_curveAll = FitPsycheCurveWH_nx(FreqAllOcts,NMTrChoices,ParaBoundLim);
fit_curveAvg = FitPsycheCurveWH_nx(FreqTypeOcts,FreqChoiceProbs,ParaBoundLim);
hf = figure;
hold on
plot(fit_curveAll.curve(:,1),fit_curveAll.curve(:,2),'color','k','LineWidth',1.6);
plot(FreqTypeOcts,FreqChoiceProbs,'o','Color','k','MarkerSize',5,'linewidth',1.2);

    
    





