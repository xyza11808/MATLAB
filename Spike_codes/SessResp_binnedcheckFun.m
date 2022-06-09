function RemainedInds = SessResp_binnedcheckFun(ProbNPSess)

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);

TrBatchSize = 10;
TrAvgSPnums = mean(SMBinDataMtx,3);
[TrNums, ROINums] = size(TrAvgSPnums);
%%
BatchNums = round(TrNums/TrBatchSize);
BatchBinnedDatas = zeros(ROINums, BatchNums);
ybase = 1;
for cy = 1 : BatchNums
    yend = min(TrBatchSize*cy, TrNums);
    BatchBinnedDatas(:,cy) = mean(TrAvgSPnums(ybase:yend,:));
    ybase = TrBatchSize*cy+1;
end

%%
binMaxValues = prctile(BatchBinnedDatas,95,2);
Isbinlessthanhalfpeak = (BatchBinnedDatas - binMaxValues/2) < 0;
binLessThanhalfPeak = mean(Isbinlessthanhalfpeak, 2);

FRBasedInds = mean(BatchBinnedDatas > 0.1,2);
% %%
% cR = 2;
% % close;
% figure;
% 
% plot(BatchBinnedDatas(cR,:));
% title(num2str(binLessThanhalfPeak(cR),'%.4f'));

%% criterias for unit exclusion
% 1, the binned value should have no more than 70% of the bins have value
% less than half of the maximum value
% 2, for those have less than 70% bins below half-maximum, the consecutive
% bins should not more than 200 trials (normally 20 bins with a bin size of 10 trials)

% criteria 1
criteria1_inds = binLessThanhalfPeak < 0.3;


% criteria 2
UsedInds2 = binLessThanhalfPeak >= 0.3;
UsedInds2_Real = find(UsedInds2);

tempUsedUnit_isless = Isbinlessthanhalfpeak(UsedInds2,:);
tempUsed_binlessthanhalf = binLessThanhalfPeak(UsedInds2);

leftUnitNum = length(tempUsed_binlessthanhalf);
IsGivenasNaN = zeros(leftUnitNum, 1);
for cU = 1 : leftUnitNum
   if tempUsed_binlessthanhalf(cU) < 0.8
       % only use bin number fraction less than 0.5 but more than 0.3
       cunit_binisless =  tempUsedUnit_isless(cU,:);
       binlogi_SM = conv(cunit_binisless, (1/21)*ones(21,1),'same');
       binlogi_SM(1) = 0;
       binlogi_SM(end) = 0;
       Is_consecutiveBins = find(binlogi_SM > 0.99, 1, 'first');
       if ~isempty(Is_consecutiveBins)
           if ~(all(cunit_binisless(1:3) == 0) && all(cunit_binisless(end-2:end) == 0))
               IsGivenasNaN(cU) = NaN;
           end
           if FRBasedInds(UsedInds2_Real(cU)) > 0.6
               IsGivenasNaN(cU) = 0;
           end
       end
   else
       IsGivenasNaN(cU) = NaN;
   end
end

criteria2_inds = true(size(criteria1_inds));
criteria2_inds(UsedInds2_Real(isnan(IsGivenasNaN))) = false;

% TotalUnits = size(SMBinDataMtx,2);
% RemainedInds = true(TotalUnits,1);
% RemainedInds(isnan(UsedInds1_Real)) = false;
RemainedInds = criteria1_inds | criteria2_inds;



