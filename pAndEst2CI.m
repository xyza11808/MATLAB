function Output = pAndEst2CI(Input, Est, Type)
% calculate the confidence interval from the p value and estimate for a
% difference where data are continuous
% Ref: https://scientificallysound.org/2016/10/20/how-to-calculate-the-confidence-interval-from-a-p-value/
% ref paper: 
 % Altman DG and Bland JM (2011) How to obtain the confidence interval of a p value. BMJ 343:d2090.
 
 z_fun = @(x) -0.862 + sqrt(0.743 - 2.404 * log(x)); % derive z from p value
 CI_fun = @(Est, zz) 1.96*Est/zz;
 
 switch Type
     case 'pcal'
         % calculate p values from CI, the input should be CI
         CI = Input;
         SE = abs(diff(CI))/(2*1.96);
         z = Est / SE;
         syms x
         pp = solve(z_fun(x) == z, x);
         Output = double(pp);
     case 'cical'
         % calculate CI values from p, the input should be p
         p = max(Input, 1e-200);
         z = z_fun(p);
         CI = [Est - CI_fun(Est, z),...
             Est + CI_fun(Est, z)];
         Output = CI;
     otherwise
         error('unknow input calculation type.');
 end
 
         
         
         