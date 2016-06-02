function varargout=menu_SendToExcel(hObject, EventData)

% Initialize
if nargin==1 && hObject==0
    if ispc==1
        varargout{1}=true;
    else
        varargout{1}=false;
    end
    varargout{2}='Excel';
    % Put the appropriate function handle in the UserData area of the
    % uimenu item
    varargout{3}=[];
    return
end

% Called form GUI
[button fhandle]=gcbo;
scSendToExternalInterface(fhandle, @scSendToExcel);

end