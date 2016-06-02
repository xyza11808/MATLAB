function str=jvMakeFieldName(str)
% jvMakeFieldName helper function
% 
% str=jvMakeFieldName(str)
% removes spaces and anything in brackets from string str
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

str=str((~isspace(str)));
idx=strfind(str,'(');
if ~isempty(idx)
    str=str(1:idx-1);
end
return
end
