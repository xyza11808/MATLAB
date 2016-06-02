function varargout=menu_Print(varargin)
% menu_Print sigTOOL menu callback
% 
% Example:
% menu_Print(hObject, EventData)
%       standard callback
%
% This is a print function designed specifically for sigTOOL data views
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006-
%--------------------------------------------------------------------------


% Called as menu_Print(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Print';
    tmp.Icon=scGetIcon('Print.png');
    tmp.Tip='Print';
    varargout{3}=tmp;
    return
end


[button fhandle]=gcbo;
[fhandle, AxesPanel, annot, pos]=printprepare(getappdata(fhandle, 'sigTOOLDataView'));
orient(fhandle, 'landscape');
printdlg(fhandle);
postprinttidy(getappdata(fhandle, 'sigTOOLDataView'), AxesPanel, annot, pos);
end


