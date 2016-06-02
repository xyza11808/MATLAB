function [isOk] = checkPowerspectrum(Pxxn,f, lower, upper)
%
%verifies whether a cell has sharp peaks in the power spektrum in the range
%of 20...10 hz. a sharp peak is defined as more than 3*std away from mean.
%
%input:
%Pxxn: powerspect (output of psautosp)
%f: freq (output of psautosp)
%timestamps: series of timestamps, at each of which a spike occured
%lower/upper: lower/upper limit of where to filter noise
%
%urut

isOk=true;

m=mean(Pxxn);
s=std(Pxxn);

lookAt = Pxxn(find(f>lower & f<=upper));

if length ( find ( lookAt > m+5*s ) ) > 0
    isOk=false;
end
