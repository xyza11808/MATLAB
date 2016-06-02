function varargout = get(obj,property)
% GET method overloaded for tstamp objects
%
% Examples:
% GET(OBJ) displays properties
% A=GET(OBJ) returns a structure
%
% A=GET(OBJ,PROP)
% <m-by-n cell array> = GET(OBJ,<property cell array>)
%   where PROP is a string or cell array of strings
%
% See also GET, TSTAMP/SUBSREF, TSTAMP/SET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006


error(nargchk(1,2,nargin));

% get(obj)
if nargin==1
    switch nargout
        case 0
            display(obj);
        case 1
            varargout{1}.Scale=obj.Scale;
            varargout{1}.Shift=obj.Shift;
            varargout{1}.Func=obj.Func;
            varargout{1}.Units=obj.Units;
            varargout{1}.Map=obj.Map;
        otherwise
            error('tstamp.get: wrong number of output arguments');
    end;
    return;
end;

% get(obj,'prop') or get(obj,{'prop1' 'prop2' ...})
% Convert from string input
if ischar(property)
    property = {property};
end
out=cell(1,length(property));
for i=1:length(property)
    switch lower(property{i})
        case 'scale'
            temp=obj.Scale;
        case 'shift'
            temp=obj.Shift;
        case 'func'
            temp=obj.Func;
        case 'units'
            temp=obj.Units;
        case 'map'
            temp=obj.Map;
        otherwise
            error('tstamp.get: There is no ''%s'' property in the ''tstamp'' class',property{i});
            temp=[];
    end;
    out{i}=temp;
end;

% a=get(...) or get(...)
if nargout<=1
    varargout{1}=out;
else
%[a b...]=get(...)    
    if nargout==length(out)
        for i=1:nargout
            varargout{i}=out{i};
        end;
    else
        error('tstamp.get: wrong number of output arguments');
    end
end;






