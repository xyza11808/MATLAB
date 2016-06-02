function varargout=get(obj, property)
% get methods for jpeth class
%
% out=get(obj, propertyname)
%   where obj is a jpeth object and propertyname is a string
%
% See also jpeth
%

if nargin==1
    varargout{1}=struct(obj);
else
    varargout{1}=obj.(property);
end
return
end