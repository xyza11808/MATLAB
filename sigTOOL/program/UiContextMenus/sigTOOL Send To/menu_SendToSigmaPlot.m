function varargout=menu_SendToSigmaPlot(hObject, EventData) %#ok<INUSD>

% Initialize
if nargin==1 && hObject==0
    if ispc==1
%% Uncomment this block if you have SigmaPot but the tests are failing to show it
%        varargout{1}=true;
%% Test for presence of SigmaPlot
        try
            % Look for SigmaPlot Version 9.0
            winqueryreg('name','HKEY_CURRENT_USER','Software\SPSS\SigmaPlot\');
            varargout{1}=true;
        catch
            try
                % Version 10
                winqueryreg('name','HKEY_LOCAL_MACHINE','Software\SYSTAT Software Inc.\SigmaPlot\');
                varargout{1}=true;
            catch
                varargout{1}=false;
            end
        end
    end
%%
    varargout{2}='SigmaPlot';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;
scSendToExternalInterface(fhandle, @scSendToSigmaPlot);

end