function [TF match]=matchall(channel, match)
% matchall - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=matchall(channel, match)
%
% See also matchany
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if nargin==1
    match=GetMatch('Match each marker');
end

TF=zeros(size(channel.mrk, 1),1);
for k=1:size(channel.mrk, 1)
    TF(k)=all(channel.mrk(k,1:end)==match(1:end));
end

return  
end