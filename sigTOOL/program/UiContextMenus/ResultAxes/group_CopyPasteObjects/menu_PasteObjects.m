function varargout=menu_PasteObjects(varargin)
% menu_PasteObjects helper for pasting graphics objects
% 
% menu_PasteObjects(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Paste MATLAB Objects';
    varargout{3}=0;
    return
end

PasteObjects(gca,[]);
