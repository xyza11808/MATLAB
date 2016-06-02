function [TF unused]=oddepochs(obj)
% oddepochs - sigTOOL event/epoch filter function
%
% Example:
% [TF match]=evenepochs(channel)
%
% See also evenepochs
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
TF=zeros(1, size(obj.tim,1));
TF(1:2:end)=true;
unused=[];
return
end
