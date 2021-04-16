function p = AssumpTest(Data1,Data2)
% test whether the two data group is normal distribution, if not, using
% ranksum test for median value test

if ~kstest(Data1) && ~kstest(Data2)
    isNormalDistri = 1;
else
    isNormalDistri = 0;
end

if isNormalDistri
    [~,p] = ttest2(Data1,Data2);
else
    p = ranksum(Data1,Data2);
end


