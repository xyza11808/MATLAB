function varargout=menu_FastOpen(varargin)

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Fast Open';
    varargout{3}=[];
    return
end

scFastOpen();

return
end
