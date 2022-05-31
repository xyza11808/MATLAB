
% cclr

% cSessFolder = pwd;
clearvars ProbNPSess AUCValuesAll ChnArea_Strings BaselineFRANDchoice SigUnitCrossCoef
cSessFolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');

load(fullfile(cSessFolder,'NPClassHandleSaved.mat'));
load(fullfile(cSessFolder,'BaselinePredofBlocktype','SingleUnitAUC.mat'),'AUCValuesAll');
load(fullfile(cSessFolder,'Chnlocation.mat'), 'ChnArea_Strings');
%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
ExcludedInds = (behavResults.Action_choice(:) == 2);

if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
SMBinDataMtx = SMBinDataMtx(~ExcludedInds,:,:);
[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

%%

BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
BlockTypesAll = double(behavResults.BlockType(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
RevFreqChoices = TrialAnmChoice(RevFreqInds);
NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
% halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtxRaw(:,:,1:TriggerAlignBin),3);

% AUCValuesAll = zeros(unitNum,3);
smoothed_baseline_resp = zeros(size(BaselineResp_First));
for cUnit = 1 : unitNum
    cUnitDatas = BaselineResp_First(:,cUnit);
%     [AUC, IsMeanRev] = AUC_fast_utest(cUnitDatas, BlockTypesAll);
    
%     [~,~,SigValues] = ROCSiglevelGeneNew([cUnitDatas, BlockTypesAll],500,1,0.001);
%     AUCValuesAll(cUnit,:) = [AUC, IsMeanRev, SigValues];
    
    smoothed_baseline_resp(:,cUnit) = smooth(cUnitDatas,7);
end

% load(fullfile(cSessFolder,'BaselinePredofBlocktype','SingleUnitAUC.mat'));
%%
PlotSaveNames = fullfile(cSessFolder,'Old_BaselinePredofBT','SigUnitAUCCrosscorr');
if ~isfolder(PlotSaveNames)
    mkdir(PlotSaveNames);
end

%%
UnitSigInds = find(AUCValuesAll(:,1) > AUCValuesAll(:,3)); 
NumSigUnits = length(UnitSigInds);
SigUnit_clusIDs = ProbNPSess.UsedClus_IDs(UnitSigInds);

SigUnitCrossCoef = cell(NumSigUnits, 7);
BaselineFRANDchoice = cell(NumSigUnits,5);
for cU = 1 : NumSigUnits
    %
    cUnit = UnitSigInds(cU);
    cUnit_ClusID = SigUnit_clusIDs(cU);
    cClus_SampleTime = ProbNPSess.SpikeTimeSample(ProbNPSess.SpikeClus == cUnit_ClusID);
    
    RealUnitInds = ProbNPSess.UsedClusinds(cUnit);
    RealUnitMaxChn = ProbNPSess.ChannelUseds_id(cUnit);
    RealUnitBrainUnit = ChnArea_Strings{RealUnitMaxChn+1,3};
    huf = figure('position',[100 100 1200 320]);
    ax1 = subplot(1,4,[1,2]);
    hold on
    yyaxis left
    plot(smoothed_baseline_resp(:,cUnit),'Color','b','linewidth',1)
    BlockSectionInfo = Bev2blockinfoFun(behavResults);
    yaxiss = get(gca,'ylim');
    if size(BlockSectionInfo.BlockTrScales,1) == 1
        BlockEndInds = BlockSectionInfo.BlockTrScales(2);
    else
        BlockEndInds = BlockSectionInfo.BlockTrScales(1:end-1,2);
    end
    NearBlockBaselineResp = zeros(length(BlockEndInds),3);
    NearBlockTrNum = 30; % the 30 trials near blockswitch position
    MiddleBlockTrInds = [70,120];
    for cB = 1 : length(BlockEndInds)
        line([BlockEndInds(cB) BlockEndInds(cB)],yaxiss,...
            'Color','k','linewidth',1.2);
        cNearBlockInds = BlockEndInds(cB) + [-1*NearBlockTrNum,NearBlockTrNum];
        cBfMiddleBlockTrs = BlockEndInds(cB) - fliplr(MiddleBlockTrInds);
        cAfMiddleBlockTrs = BlockEndInds(cB) + MiddleBlockTrInds;
        
        NearBlock_FRAvg = mean(BaselineResp_First(cNearBlockInds(1):cNearBlockInds(2),cUnit));
        BfMidBlock_FRAvg = mean(BaselineResp_First(cBfMiddleBlockTrs(1):cBfMiddleBlockTrs(2),cUnit));
        AfMidBlock_FRAvg = mean(BaselineResp_First(cAfMiddleBlockTrs(1):cAfMiddleBlockTrs(2),cUnit));
        
        
    end
    ylabel('Baseline FR');

    yyaxis right
    plot(NMRevFreqIndedx,1-smooth(NMRevFreqChoice,7),'Color',[0.9 0.6 0.2],'linewidth',1.5);
    ylabel('RevFreq choice');
    
    set(gca,'xlim',[0 size(smoothed_baseline_resp,1)]);
    xlabel('# Trials');
    title(sprintf('Unit %d, AUC = %.3f, (%s)',RealUnitInds,AUCValuesAll(cUnit,1),RealUnitBrainUnit));
    axpos = get(ax1,'position');
    set(ax1,'position',axpos+[-0.05 0.03 0 -0.05]);
    
    
    ax2 = subplot(143);
    TrialFR = smoothed_baseline_resp(NMRevFreqIndedx,cUnit);
    [xcf,lags,bounds] = crosscorr(NMRevFreqChoice,TrialFR,'NumLags',50,'NumSTD',3);
    crosscorr(NMRevFreqChoice,TrialFR,'NumLags',50,'NumSTD',3);
    if max(abs(xcf)) > abs(bounds(1))
       [MaxCoefPeak, PeakInds] = max(abs(xcf)); 
       peakLag = lags(PeakInds);
       
    else
        MaxCoefPeak = NaN;
        peakLag = NaN;
    end
    title(ax2, sprintf('PeakCoef = %.3f, lag = %d',MaxCoefPeak,peakLag));
    SigUnitCrossCoef(cU,:) = {cUnit,xcf,lags,bounds,MaxCoefPeak, peakLag,ChnArea_Strings(RealUnitMaxChn+1,:)};
    
    BaselineFRANDchoice(cU,:) = {BeforeTrig_BinSP_FR, AfterTask_BinSP_FR, NMRevFreqChoice,TrialFR,NMRevFreqIndedx};
    
    subplot(144);
    hold on
    hl1 = plot(BeforeTrig_BinSP_FR,'b-o','linewidth',1.2,'MarkerSize',8);
    hl2 = plot(AfterTask_BinSP_FR,'r-o','linewidth',1.2,'MarkerSize',8);
    legend([hl1 hl2],{'BeforeSP','AfterSP'},'Box','off','location','northeast');
    xlabel('Bins');
    ylabel('Firing rates');
    title('Bf and Af baseline SP');
    cU_savename = fullfile(PlotSaveNames,sprintf('Unit%d FR and revfreqChoice crosscorr plot',cUnit));
    saveas(huf, cU_savename);
    print(huf,cU_savename,'-dpng','-r0');
    print(huf,cU_savename,'-dpdf','-bestfit');
%     saveas(huf, cU_savename,'png');
%     saveas(huf, cU_savename,'pdf');
    close(huf);
end
%%
datasaveName = fullfile(PlotSaveNames,'SigUnitCoefDatas.mat');
save(datasaveName,'SigUnitCrossCoef','BaselineFRANDchoice','-v7.3');


