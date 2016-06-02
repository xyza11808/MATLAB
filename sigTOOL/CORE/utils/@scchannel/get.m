function varargout = get(obj,property)
% get method for overloaded for the scchannel class
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------
if nargin==1
    varargout{1}=struct(obj);
else
    varargout{1}=obj.(property);
end
return
end