function [ci, ybar] = ci_moving_avg(y, span, conf_level)
% Compute confidence interver for the moving average value of a vector
% span, the window for moving average.
% ci, confidence intervel computed for the sample mean from the 'span'.
% ybar, moving average of the input vector y.

ci = zeros(1,length(y));
if nargin<3
   conf_level = 0.95;
end
alpha = 1 - conf_level;
for i = 1:length(y)
    if i<=16
        inds = 1:i+floor(span/2);
    elseif i+16>=length(y)
        inds = i:length(y);
    else
        inds = i-16:i+16;
    end
    y_win = y(inds);
    ybar(i) = mean(y(inds));
    s = std(y_win);
    n = length(y_win); %number of elements in the data vector
    T_multiplier = tinv(1-alpha/2, n-1);
    % the multiplier is large here because there is so little data. That means
    % we do not have a lot of confidence on the true average or standard
    % deviation
    ci(i) = T_multiplier*s/sqrt(n);
end