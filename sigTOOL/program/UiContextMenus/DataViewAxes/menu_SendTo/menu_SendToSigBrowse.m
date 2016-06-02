function varargout=menu_SendToSigBrowse(varargin)
% menu_SendToSigBrowse send data to the MATLAB SP toolbox signal browser


if nargin==1 && varargin{1}==0
    if isempty(which('sptool'))
        % No Signal Processing Toolbox
        varargout{1}=false;
    else
        varargout{1}=true;
    end
    varargout{2}='MATLAB SigBrowser (SP Toolbox)';
    varargout{3}=@scSendToSigBrowse;
    return
end

[button fhandle]=gcbo;
scSendToExternalInterface(fhandle, get(button,'UserData'));
