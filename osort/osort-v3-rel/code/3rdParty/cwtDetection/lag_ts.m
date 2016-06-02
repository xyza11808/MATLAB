function f=lag_ts(TS,Lag)

%LAG_TS - this function lags time series TS by lags in vector LAG
%   f=LAG_TS(TS,LAG)
%   TS is a time series (row vector) and LAG is a vector of lags (either
%   row or column vector). The resulting time series is padded by zeros, 
%   and max(LAG) should be less than length(TS), if not the lags will be 
%   calculated up to length(TS)-1.

%   Zoran Nenadic
%   California Institute of Technology
%   May 2003

if size(TS,1)>1
    error('TS must be a row vector');
end

for i=1:length(Lag)
    if Lag(i)<length(TS)
        f(i,:)=[zeros(1,Lag(i)) TS(1:end-Lag(i))];    %pad by zeros
    else
        f(i,:)=[zeros(1,length(TS)-1) TS(1)];
    end
end
