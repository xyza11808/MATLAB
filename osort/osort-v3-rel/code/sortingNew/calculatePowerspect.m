%
%calculate powerspectrum and autocorrelation
%
function [f,Pxxn,tvect,Cxx] = calculatePowerspect(n, binsize)
if nargin<2
    binsize=1; %1ms
end

[f,Pxxn,tvect,Cxx] = psautospk(n,binsize);%1=binsize
