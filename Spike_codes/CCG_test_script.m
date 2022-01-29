% test of the calculation of the CCG values

SMBinDataMtx_pass = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);

%% extract spike time and calculate the firing rate and binned spike times
ProbNPSess.CurrentSessInds = strcmpi('passive',ProbNPSess.SessTypeStrs);
SessSPTimes = ProbNPSess.TrTrigSpikeTimes{ProbNPSess.CurrentSessInds};
[UnitNums, TrNums] = size(SessSPTimes);
TrialTimeScale = ProbNPSess.psthTimeWin{ProbNPSess.CurrentSessInds};
[binnedSPAll, SpikeCounts] = cellfun(@(x) Sptime2bins(x,0.001,TrialTimeScale),...
    SessSPTimes,'UniformOutput',false);
spFireRate = mean(cell2mat(SpikeCounts),2)/diff(TrialTimeScale);
CalUnitInds = find(spFireRate >= 2); % only use unit firing rate larger than 2Hz
NumCaledUnits = length(CalUnitInds);


%%
TauValuesAll = -500:500;
NumTauValues = length(TauValuesAll);
AllPairedUnit_CCGs = cell(NumCaledUnits,NumCaledUnits,2);
TrialTime = diff(TrialTimeScale);
for cUsedUnit = 1 : NumCaledUnits
    for cUnit = (cUsedUnit+1):NumCaledUnits
        
%         Cell1Data1 = squeeze(SMBinDataMtx_pass(:,CalUnitInds(cUsedUnit),:));
%         Cell1Data2 = squeeze(SMBinDataMtx_pass(:,CalUnitInds(cUnit),:));
% 
%         Data_2_cells_1 = mat2cell(Cell1Data1,ones(1,size(Cell1Data1,1)),size(Cell1Data1,2));
%         Data_2_cells_2 = mat2cell(Cell1Data1,ones(1,size(Cell1Data2,1)),size(Cell1Data2,2));
        Data_2_cells_1 = (binnedSPAll(CalUnitInds(cUsedUnit),:))';
        Data_2_cells_2 = (binnedSPAll(CalUnitInds(cUnit),:))';
        
        Cell1FR = spFireRate(CalUnitInds(cUsedUnit));
        Cell2FR = spFireRate(CalUnitInds(cUnit));
%
        TauCCGs = zeros(NumTauValues,1);
        jitterAllCCGs = cell(1,NumTauValues);
        for cTau = 1 : NumTauValues
            cTauValue = TauValuesAll(cTau);
            TauCCGs(cTau) = CCG_cal_fun(Data_2_cells_1, Data_2_cells_2,cTauValue,TrialTime,Cell1FR,Cell2FR);
            jitterAllCCGs{cTau} = jitterCCG_cal_fun(Data_2_cells_1, Data_2_cells_2,cTauValue,TrialTime,Cell1FR,Cell2FR,[],[],25);
        end
        %
        AllPairedUnit_CCGs(cUsedUnit, cUnit, :) = {TauCCGs, cell2mat(jitterAllCCGs)};
    end
    
end
%%
% figure('position',[2000, 200 1300 480]);
% subplot(121)
% hold on
% plot(TauValuesAll,TauCCGs, 'k-o') 
% JitterAllAvg = mean(cell2mat(jitterAllCCGs));
% plot(TauValuesAll,JitterAllAvg,'r--o');
% 
% subplot(122)
% plot(TauValuesAll,TauCCGs' -JitterAllAvg ,'k-o')

unit1jitterCCG_Cell = cellfun(@mean,Unit1AllpairedCCGs(:,2),'UniformOutput',false);
Unit_jitterCorrect_cell = cellfun(@(x,y) (x'-y),Unit1AllpairedCCGs(:,1),unit1jitterCCG_Cell,'UniformOutput',false);
unit1CCG_mtx = cell2mat(Unit_jitterCorrect_cell);




