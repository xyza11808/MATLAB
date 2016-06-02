%
%distance between two means, F distributed
%
%eq 6.23 on pp284 of Johnson&Wichern
%
%params:
%p: dimensionality (number datapoints per sample)
%n1/n2: number items in mean1/2
%sp1/sp2: mean waveforms
%Cinv: inverse covariance matrix
%alpha:significance values
%
%returns:
%dist -> left hand side of eq6.23
%c2 -> c2 value, right hand side of eq6.23
%
%urut/nov05
function [dist, c2] = calcFDist( p, n1, n2, sp1, sp2, Cinv, alpha)
dist = (sp1-sp2) * Cinv * (sp1-sp2)';

%only if enough samples are available
if n1+n2>p+2  %>50 && n2>50
    c2 = (n1+n2-2)*p/(n1+n2-p-1) * finv(1-alpha, p, n1+n2-p-1);
else
    c2=10000;
end
