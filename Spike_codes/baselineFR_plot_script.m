
% cclr

% cSessFolder = pwd;
clearvars ProbNPSess AUCValuesAll ChnArea_Strings

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
PlotSaveNames = fullfile(cSessFolder,'BaselinePredofBlocktype','SigUnitAUCCrosscorr');
if ~isfolder(PlotSaveNames)
    mkdir(PlotSaveNames);
end

%%
UnitSigInds = find(AUCValuesAll(:,1) > AUCValuesAll(:,3)); 
NumSigUnits = length(UnitSigInds);

SigUnitCrossCoef = cell(NumSigUnits, 7);
for cU = 1 : NumSigUnits
    
    cUnit = UnitSigInds(cU);
    
    RealUnitInds = ProbNPSess.UsedClusinds(cUnit);
    RealUnitMaxChn = ProbNPSess.ChannelUseds_id(cUnit);
    RealUnitBrainUnit = ChnArea_Strings{RealUnitMaxChn+1,3};
    huf = figure('position',[100 100 1000 420],'Paperpositionmode','manual');
    ax1 = subplot(121);
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
    for cB = 1 : length(BlockEndInds)
        line([BlockEndInds(cB) BlockEndInds(cB)],yaxiss,...
            'Color','k','linewidth',1.2);
    end
    ylabel('Baseline FR');

    yyaxis right
    plot(NMRevFreqIndedx,1-smooth(NMRevFreqChoice,7),'Color',[0.9 0.6 0.2],'linewidth',1.5);
    ylabel('RevFreq choice');

    set(gca,'xlim',[0 size(smoothed_baseline_resp,1)]);
    xlabel('# Trials');
    title(sprintf('Unit %d, AUC = %.3f, (%s)',RealUnitInds,AUCValuesAll(cUnit,1),RealUnitBrainUnit));

    ax2 = subplot(122);
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
    
    cU_savename = fullfile(PlotSaveNames,sprintf('Unit%d FR and revfreqChoice crosscorr plot',cUnit));
    saveas(huf, cU_savename);
    saveas(huf, cU_savename,'png');
    saveas(huf, cU_savename,'pdf');
    close(huf);
end

datasaveName = fullfile(PlotSaveNames,'SigUnitCoefDatas.mat');
save(datasaveName,'SigUnitCrossCoef','-v7.3');


