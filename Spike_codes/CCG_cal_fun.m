function CCG_cal_fun(xTrain1, xTrain2,lag_tau,TrialTime,FR1,FR2, spikeBin)
% ref: https://www.jneurosci.org/content/25/14/3661
% the xTrain1 and xTrain2 should have same size, which is usually be a n*1
% cell array. In this case, n is the number of trials with same stimulus.
% Each element of the cell array should be the binned spike train within certain
% trials, the maximum spike bin time should be no more than the trialTime.

if ~exist('spikeBin','var')
    spikeBin = 1; % binned in 1ms step
end
    
xTrain1 = xTrain1(:);
xTrain2 = xTrain2(:);
TrialNums = length(xTrain1);

% the spike time should all in ms unit
TrTimeBins = 0:spikeBin:TrialTime; % trial time should be ms also
xt1_counts = cellfun(@(x) his)







