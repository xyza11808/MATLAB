%
%estimates a PDF, using binned data
%
%see "computational statistics handbook with matlab" book, pp266
%
%parameters
%vals: array of values
%nBins: number of bins to use; if == 0 is provided, the number of bins is
%chosen automatically (estimate using normal reference rule)
%
%returns
%bc: centers of the bin
%fhat: prob of that bin
%h: bin width (automatically chosen)
%
%
%urut/jan05
function [bc,fhat,h] = estimatePDF(vals,nBins)

n=length(vals);

%normal reference rule to choose bin width
h=0;
if nBins==0
    h = 3.5*std(vals)*n^(-1/3);
else
    h = 10/nBins;
end

t0 = min(vals) - 1;
tm = max(vals) + 1;
rng = tm - t0;
nbin = ceil(rng/h);
bins = t0:h:(nbin*h + t0);
% Get the bin counts vk.
vk = histc(vals,bins);


% Normalize to make it a bona fide density.
fhat = vk/(n*h);
fhat(end) = [];

% To plot this, use bar with the bin centers.
tm = max(bins);
bc = (t0+h/2):h:(tm-h/2);

