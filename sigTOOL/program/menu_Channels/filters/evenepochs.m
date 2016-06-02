function [TF unused]=evenepochs(obj)
% evenepochs - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=evenepochs(channel)
%
% See also oddepochs
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

TF=zeros(1, size(obj.tim,1));
TF(2:2:end)=true;
unused=[];
return
end