% originally modified by GY from GCD (cum_gaussfit_max.m)
function [alpha, beta] = cum_gaussfit_max1(data_cum)
% Gaussian fits a accumulative Gaussian function to data using maximum likelihood
%	maximization under binomial assumptions.  It uses Gaussian_Fun for
%	error calculation.  Data must be in 3 columns: x, %-correct, Nobs
%	usage: [alpha, beta] = cum_gaussfit_max1(data)
%		alpha and beta are the bias and standard deviation parameters.
% global Data_cum;
Data_cum = data_cum;

% generate guess
q = ones(2,1);

% get a starting threshold estimate by testing a bunch of values
% bias range from [-100,-10,-1,0,1,10,100]
% threshold ranges from [0.1,1,10,100]
bias_e = [-100,-10,-1,0,1,10,100];
threshold_e = [0.1,1,10,100];
errors=[];
for i=1:length(bias_e)
    for j=1:length(threshold_e)
       q(1,1) = bias_e(i); 
       q(2,1) = threshold_e(j);
       errors(i,j) = cum_gaussfit_max(q,Data_cum);
    end
end
[min_indx1,min_indx2] = find(errors==min(min(errors)));
q(1,1) = bias_e(min_indx1(1));
q(2,1) = threshold_e(min_indx2(1));

OPTIONS = optimset('MaxIter', 5000);
quick = fminsearch('cum_gaussfit_max',q);
% quick
alpha = quick(1,1);
beta = quick(2,1);


