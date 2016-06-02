function f=lead_ts(TS,Lead)

%LEAD_TS - this function leads time series TS by leads in vector LEAD
%   f=LEAD_TS(TS,LEAD)
%   TS is a time series (row vector) and LEAD is a vector of leads (either
%   row or column vector). The resulting time series is padded by zeros, 
%   and max(LEAD) should be less than length(TS), if not the leads will be 
%   calculated up to length(TS)-1.

%   Zoran Nenadic
%   California Institute of Technology
%   May 2003

if size(TS,1)>1
    error('TS must be a row vector');
end

for i=1:length(Lead)
    if Lead(i)<length(TS)
        f(i,:)=[TS(Lead(i)+1:end) zeros(1,Lead(i))];    %pad by zeros
    else
        f(i,:)=[TS(end) zeros(1,length(TS)-1)];
    end
end
