function out=scGetChannelTree(fhandle, option)

% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
switch lower(option)
    case 'selected'
        t=getappdata(fhandle,'ChannelManager');
        rows=t.Tree.getSelectionRows();
        out=scChannelTreeRowToChannelList(fhandle, rows);
    otherwise
        return
end