function fhandle=plot(varargin)
% plot method overloaded for scchannel class
%
% Example:
% figurehandle=plot(object)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------
%
% Revisions:
% Version 0.81 introduced a bug calling setappdata (fixed in 0.82)

fhandle=sigTOOL();

set(fhandle, 'Units', 'normalized',...
    'Position',[0.1 0.1 0.8 0.8],...
    'Name','');
setappdata(fhandle, 'channels', varargin);
scCreateDataView(fhandle);
sigTOOLDataView(fhandle);
return
end