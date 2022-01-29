function CCG = CCG_cal_fun(xTrain1, xTrain2,lag_tau,TrialTime,FR1,FR2, spikeBin, IsShiftCCG)
% ref: https://www.jneurosci.org/content/25/14/3661
% the xTrain1 and xTrain2 should have same size, which is usually be a n*1
% cell array. In this case, n is the number of trials with same stimulus.
% Each element of the cell array should be the binned spike train within certain
% trials, the maximum spike bin time should be no more than the trialTime.

% only applied this calculation to those paired units with spike rate large
% than 2Hz

% is the xTrain1 and xTrain2 is the same, then we are calculating the ACG
% for spike train1
if isempty(xTrain2)
    xTrain2 = xTrain1; % calculate the ACG for spike train 1
    FR2 = FR1;
    IsACGCalculation = 1;
    IsShiftCCG = 0;
else
    IsACGCalculation = 0;
end

if ~exist('spikeBin','var') || isempty(spikeBin)
    spikeBin = 1; % binned in 1ms step
end
if ~exist('IsShiftCCG','var') || isempty(IsShiftCCG)
    IsShiftCCG = 0;
end

xTrain1 = xTrain1(:);
xTrain2 = xTrain2(:);
% TrialNums = length(xTrain1);

% the spike time should all in ms unit
% TrTimeBins = 0:spikeBin:TrialTime; % trial time should be ms also
% xt1_counts = cellfun(@(x) double(histcounts(x,TrTimeBins)>0),xTrain1,'UniformOutput',false); % binary vector for each time bin
% xt2_counts = cellfun(@(x) double(histcounts(x,TrTimeBins)>0),xTrain2,'UniformOutput',false);
xt1_count_mtx = double(cell2mat(xTrain1) > 0);
xt2_count_mtx = double(cell2mat(xTrain2) > 0);

lag_tau_bin = ceil(lag_tau/spikeBin);
TrBinNums = size(xt1_count_mtx,2); % trial total bin count
if IsACGCalculation
    bottomValues = 1;
else
    bottomValues = ((TrialTime*1000-abs(lag_tau))*sqrt(FR1*FR2));
end
    
if ~IsShiftCCG
    if lag_tau_bin < 0
        UpperValue = mean(sum(xt1_count_mtx(:,1:(TrBinNums+lag_tau_bin)) .* xt2_count_mtx(:,(abs(lag_tau_bin)+1):end),2));
        CCG = UpperValue/bottomValues;
    else
        UpperValue = mean(sum(xt1_count_mtx(:,(1+lag_tau_bin):TrBinNums) .* xt2_count_mtx(:,1:(end-lag_tau_bin)),2));
        CCG = UpperValue/bottomValues;
    end
else
    if lag_tau_bin < 0
        UpperValue = mean(sum(xt1_count_mtx(1:end-1,1:(TrBinNums+lag_tau_bin)) .* ...
            xt2_count_mtx(2:end,(abs(lag_tau_bin)+1):end),2));
        CCG = UpperValue/bottomValues;
    else
        UpperValue = mean(sum(xt1_count_mtx(1:end-1,(1+lag_tau_bin):TrBinNums) .* ...
            xt2_count_mtx(2:end,1:(end-lag_tau_bin)),2));
        CCG = UpperValue/bottomValues;
    end
    
end





