function ChanList=scChannelTreeRowToChannelList(fhandle, rows)
% scChannelTreeRowToChannelList returns a channel list from the channel tree
%
% ChanList=scChannelTreeRowToChannelList(fhandle, rows)
%         fhandle is the handle of a sigTOOL data view
%         rows are the indices of the rows in the JTree
%
% For the following tree:
%    FileName                               Row 0
%           [1] Chan #1                         1
%           [2] Chan #2                         2
%           [3] Chan #3                         3
%                     adc                       4
%                     tim                       5
%                     mrk                       6
%           [32] Chan #32                       7
%           [33] Chan #33                       8
%           [34] Chan #34                       9
% scChannelTreeRowToChannelList(handle,[1:7,9] would return [1 2 3 32 34].
% Note that row indices change on-the-fly depending on how the JTree has
% been expanded. scChannelTreeRowToChannelList takes account of this.
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------

cs=getappdata(fhandle, 'ChannelManager');
if isempty(cs)
    return
end
ChanList=zeros(1,length(rows));
for i=1:length(rows)
    % Get the path corresponding to the indices in rows
    treePath=cs.Tree.getPathForRow(rows(i));
    % Expand the path
    paths=treePath.getPath();
    % Convert the channel number to a MATLAB string...
    % 09.12.09
        chanstr=char(paths(end));
        % ... and get the channel number
        idx1=strfind(chanstr, '[');
        idx2=strfind(chanstr, ']');
        ChanList(i)=str2double(chanstr(idx1+1:idx2-1));
end
% Get rid of zero (the tree root) and duplicates (e.g. because adc,
% mrk etc rows were included) and sort the result
ChanList=ChanList(ChanList>0);
ChanList=sort(unique(ChanList));
return
end

