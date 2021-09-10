function [p, mu, CI] = bootstrapmeanDiff_p(Data1, Data2)

meandiffstat = bootstrp(100,@mean, Data1) - bootstrp(100,@mean, Data2);
% if mean(meandiffstat) < 0
%     meandiffstat = meandiffstat * (-1);
% end
% calculate the mu and 95% CI
mu = mean(meandiffstat);
CI = prctile(meandiffstat,[0.025, 0.975]);
stdRatio = []; % using default 95% CI ratio
p = CI2pvalues(mu, CI, stdRatio);

