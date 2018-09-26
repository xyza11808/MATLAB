function [f_, stats] = getBaseline_customWeightFun(f)
% To do:
% - do binning instead of smoothing to speed up calculations
% - change code to deal with different frame rates, rather than having
% hard-coded time windows etc...

x = linspace(-1, 1, length(f));
xExp = exp(-x);

function w = wfun(r)
    % Get rough estimate of baseline by taking 10th percentile in
    % successive time windows:
    nR = numel(r);
    rOrig = r;
    r(end+3600-rem(nR, 3600)) = 0;
    r = reshape(r, 3600, []);
    baseEstimate = prctile(r, 10, 1);
    baseEstimate = repmat(baseEstimate, 3600, 1);
    baseEstimate = baseEstimate(1:nR)';

    % Inliers are points where residuals (i.e. baseline-subtracted F)
    % are close to local 8th percentile of residuals.
    w = 1 * (abs(rOrig - baseEstimate)<prctile(abs(rOrig - baseEstimate), 10));
    %w = 1 * (abs(rOrig - baseEstimate)<prctile(abs(rOrig - baseEstimate), 25));
end

% Maybe bin instead of smooth?
winSize = 60;
f = conv(f, ones(winSize, 1)/winSize, 'same');

warnState = warning('off', 'stats:statrobustfit:IterationLimit');
[b, stats] = robustfit([x',xExp'],f', @wfun, 1.5);
warning(warnState);
% disp(b(1));

f_ = [ones(length(f), 1), x', xExp'] * b;
f_ = f_';
end