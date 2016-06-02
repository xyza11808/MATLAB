function isappdata(obj, name)
% ISAPPDATA function oveloaded for the JCONTROL class
%
% Examples:
% isappdata(obj)
% isappdata(obj, FieldName);
%
% See also: JCONTROL, JCONTROL/GETAPPDATA, JCONTROL/GETAPPDATA
% JCONTROL/ISAPPDATA ISAPPDATA
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

isappdata(obj.hgcontrol, name);
return
end
