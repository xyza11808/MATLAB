function win=wvHamming(n)
% wvHamming returns an n-point Haming window
%       w=0.54 - 0.46*cos(2*pi*(0:m-1)'/(n-1)) n=0..N
%
% Example:
% w=wvHanning(n)
% returns an n-point hanning window

win=(54 - 46*cos(2*pi*(0:n-1)'/(n-1)))/100;
return
end