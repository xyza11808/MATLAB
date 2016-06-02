function obj=set(obj, property, val)
% set method for overloaded for the scchannel class
%
% Example:
% obj=set(obj, property, val)
%   see the builtin set for details
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------

varname=inputname(1);

if isempty(inputname(1)) && nargout==0
    error('scchannel.set: You must assign an output');
end

if nargin==2
    obj=property;
else
    try
        obj.(property)=val;
    catch
        if ~isfield(obj, property)
            error('scchannel.set: No such property ''%s''', property);
        else
            rethrow(lasterror)
        end
    end
end

if nargout==0 && ~isempty(varname)
    assignin('caller', varname, obj);
end

return
end