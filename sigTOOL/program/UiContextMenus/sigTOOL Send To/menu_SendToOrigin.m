function varargout=menu_SendToOrigin(hObject, EventData)

% Initialize
if nargin==1 && hObject==0
    if ispc
        varargout{1}=true;
    else
        varargout{1}=false;
    end
    varargout{2}='Origin';
    varargout{3}=[];
    return
end

% Called from GUI
[button fhandle]=gcbo;
scSendToExternalInterface(fhandle, @scSendToOrigin);

end