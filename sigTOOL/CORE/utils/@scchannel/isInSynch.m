function TF=isInSynch(chan1, chan2)
% isInSynch method for scchannel objects
% 
% Example
% TF=isInSynch(chan1, chan2)
%     where chan1 and chan2 are scchanel objects
%     
% isInSynch returns true if the adc data in the channels share the same
% sampling rate and the beginning and end of each epoch are within 1 sample
% interval of each other
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% Check units
if chan1.tim.Units~=chan2.tim.Units
    TF=false;
    warning('isInSynch: these channels may be in synch but their tim fields use different units'); %#ok<WNTAG>
    return
end

% Get sample intervals
s1=prod(chan1.hdr.adc.SampleInterval);
s2=prod(chan2.hdr.adc.SampleInterval);
if s1~=s2
    % Unequal Fs
    TF=false;
    return
end

if size(chan1.tim,1)==1 || size(chan1.tim,2)==1
    % Equal Fs, and one or both channels are continuously sampled
    TF=true;
    return
end

% Both channels are episodic
t1=chan1.tim();
t2=chan2.tim();
if any(abs(t1(:,1)-t2(:,1))>s1) || any(abs(t1(:,2)-t2(:,2))>s1)
    % Unsynchronized sampling start or stop times
    TF=false;
else
    % Synchronized
    TF=true;
end
return
end



