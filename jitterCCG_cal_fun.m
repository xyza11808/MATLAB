function RePeatCCGs = jitterCCG_cal_fun(xTrain1, xTrain2,lag_tau,TrialTime,FR1,FR2, spikeBin, IsShiftCCG, jitterRange)
% this function is used to calculate a jittered version of the CCG values,
% will call the normal CCG calculation function during calculation
% normally the jittering is applied to the second cell

NumOfRepeats = 100;
RePeatCCGs = zeros(NumOfRepeats,1);
for cRe = 1 : NumOfRepeats    
    xTrain2_shifts = cellfun(@(x) circshift(x,round(rand(1)*jitterRange)),xTrain2,'UniformOutput',false);
    RePeatCCGs(cRe) = CCG_cal_fun(xTrain1, xTrain2_shifts,lag_tau,TrialTime,FR1,FR2, spikeBin, IsShiftCCG);
end

    













