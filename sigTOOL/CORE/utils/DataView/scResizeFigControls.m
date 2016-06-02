function scResizeFigControls()
% scResizeFigControls resizes the uicontrols in the current figure
% 
% Example
% scResizeFigControls
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

[button fhandle]=gcbo;

if isempty(fhandle)
    fhandle=gcf;
end

set(fhandle,'Units','pixels');
pos=get(fhandle,'position');
set(fhandle,'Units','normalized');

h=findobj(fhandle, 'Tag','sigTOOL:Logo');
if ~isempty(h)
set(h,'Units','pixels',...
    'Position',[pos(3)-84,pos(4)-42,80,40]);
end
set(h,'Units','normalized');

h=findall(fhandle,'Type','uipanel');
set(h,'Units','normalized');





