function p = CI2pvalues(mu, CI, StardDevRatio)
% this function is used to calculate the p values while given CI range and
% mean difference
% Ref: https://www.bmj.com/content/343/bmj.d2304
% The value of StardDevRatio is defined as:
%     90% CI: 1.65
%     95% CI: 1.96
%     99% CI: 2.57

% calculate CI from p values 
% Ref: https://www.bmj.com/content/343/bmj.d2090.long

if isempty(StardDevRatio)
    StardDevRatio = 1.96; % default using 95% CI
end

SE = ((CI(2) - CI(1)))/(2 * StardDevRatio); % SE = (u - l)/(2 * StardDevRatio)
z = mu / SE;
p = exp(-0.717*z - 0.416 * z^2);

if p > 1
   fprintf('something wrong!'); 
end

