function [TF match]=matchany(channel, match)
% matchany - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=matchany(channel)
%
% See also matchall
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
if nargin==1
    match=GetMatch('Match any marker');
end
mem=ismember(channel.mrk(), match);
TF=zeros(size(channel.mrk, 1), 1);
for k=1:size(channel.mrk, 1)
    TF(k)=any(mem(k,1:end));
end
return  
end