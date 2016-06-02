function varargout=menu_ExportToAdobeIllustrator(varargin)
% menu_ExportToAdobeIllustrator sigTOOL menu callback: exports a vector
% graphic
% 
% Example:
% menu_ExportToAdobeIllustrator(hObject, EventData)
%       standard callback
%
% Output is to a legacy Illustrator format (1988)which will need to be
% updated when loaded.
%
% This is a callback designed specifically for sigTOOL data views
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006-
%--------------------------------------------------------------------------


% Called as menu_ImportSMR(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Adobe Illustrator';
    varargout{3}=[];
    return
end

[button, handle]=gcbo;
scExportFigure(handle, 'ai');
end