function varargout=menu_FastSave(varargin)
% menu_FastSave menu callback to invoke the sigTOOL scFastSave Function


if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Fast Save';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

scExecute(@scFastSave, {fhandle}, false)

return
end


