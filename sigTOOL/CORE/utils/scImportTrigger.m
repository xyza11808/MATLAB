function scImportTrigger(fhandle, source, target)
% scImportTrigger imports trigger values
% 
% Example
% scImportTrigger(fhandle, source, target)
% scImportTrigger(channels, source, target)
% 
% Trigger times will be copied form channel "source" to channel "target"
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------


[fhandle channels]=scParam(fhandle);


if size(channels{target}.tim, 1)~=size(channels{source}.tim, 1)
    error('Requires equal number of epochs in source and target');
end

if size(channels{source}.tim)==3
    dim=2;
else
    dim=1;
end

if size(channels{target}.tim, 2)==2
    % Insert trigger column
    channels{target}.tim(:,3)=channels{target}.tim(:,2);
    channels{target}.tim(:,2)=channels{source}.tim(:,dim);
elseif size(channels{target}.tim, 2)==3
    % Replace trigger column
    channels{target}.tim(:,2)=channels{target}.tim(:,2);
else
    error('Target channel must have 2 or 3 columns in tim');
end

channels{target}.channelchangeflag.tim=true;
setappdata(fhandle, 'channels', channels);
return
end