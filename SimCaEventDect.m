function SimCaEventDect(Data,FrameRate,varargin)
% this function is tried to using most simplified methods to find a calcium
% events within each single trial trace
%
% events constraints: 
%       % smoothed peak amplitude must excceed three times of std
%       % peak value excceeds ont time of std should last for at least 1.5s
%       % Decay period must exists and last longer than onset time scale
