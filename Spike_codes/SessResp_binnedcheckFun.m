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
binMaxValues = max(BatchBinnedDatas,[],2);
Isbinlessthanhalfpeak = (BatchBinnedDatas - binMaxValues/2) < 0;
binLessThanhalfPeak = mean(Isbinlessthanhalfpeak, 2);

% %%
% cR = 2;
% % close;
% figure;
% 
% plot(BatchBinnedDatas(cR,:));
% title(num2str(binLessThanhalfPeak(cR),'%.4f'));

%% criterias for unit exclusion
% 1, the binned value should have no more than 80% of the bins have value
% less than half of the maximum value
% 2, for those have less than 80% bins below half-maximum, the consecutive
% bins should not more than 200 trials (normally 20 bins with a bin size of 10 trials)

% criteria 1
UsedInds1 = binLessThanhalfPeak < 0.8;
UsedInds1_Real = find(UsedInds1);

tempUsedUnit_isless = Isbinlessthanhalfpeak(UsedInds1,:);
tempUsed_binlessthanhalf = binLessThanhalfPeak(UsedInds1);

leftUnitNum = length(tempUsed_binlessthanhalf);
for cU = 1 : leftUnitNum
   if tempUsed_binlessthanhalf(cU) > 0.5
       % only use bin number fraction less than 0.8 but more than 0.5
       cunit_binisless =  tempUsedUnit_isless(cU,:);
       binlogi_SM = conv(cunit_binisless, (1/21)*ones(21,1),'same');
       binlogi_SM(1) = 0;
       binlogi_SM(end) = 0;
       Is_consecutiveBins = find(binlogi_SM > 0.99, 1, 'first');
       if ~isempty(Is_consecutiveBins)
           UsedInds1_Real(cU) = NaN;
       end
   end
end


RemainedInds = UsedInds1_Real;
RemainedInds(isnan(RemainedInds)) = [];



