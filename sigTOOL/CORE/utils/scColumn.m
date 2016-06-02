function out=scColumn(ax, data)
% scColumn generates a column of  traces 
% 
% Example
% scColumn(ax, data)
% where ax is the target axes (defaults to gca)
% data is an element from a sigTOOLResultData.Data field
% 
% In addition:
% fcn=scColumn()
%   returns the handle to the local function to edit the display properties
%   from a sigTOOL result view.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%
% Revisions:
%   07/10/09    Add local options function


if nargin==0
    out=@LocalCallback;
    return
end

if nargin==1
    ax=gca;
    data=ax;
end



set(ax, 'XLimMode', 'auto');
set(ax, 'YLimMode', 'auto');


x=data.tdata;
y=data.rdata;

range=0;
for k=1:size(y, 1)
    r=max(y(k,:))-min(y(k,:));
    if r>range
        range=r;
    end   
end

range=0.25*range;

for k=1:size(y, 1)
                offset=((k-1)*range);
                line('Parent', ax,...
                'XData',x,...
                'YData', y(k,:)-offset,...
                'Color',[0.1 0.1 0.5],...
                'Tag', 'sigTOOL:ResultData',...
                'Visible', 'on',...
                'UserData', [k offset]);
end


fhandle=ancestor(ax,'figure');
setappdata(fhandle, 'sigTOOLViewStyle', '2D')

return
end


function LocalCallback(hObject, EventData)
offset=str2double(inputdlg('Offset between lines','Column Options'));
if isempty(offset)
    return
end
fhandle=ancestor(hObject.hghandle,'figure');
li=findobj(fhandle, 'Type', 'line', 'Tag', 'sigTOOL:ResultData');
for k=1:length(li)
    y=get(li(k), 'YData');
    temp=get(li(k), 'UserData');
    y=y+temp(2);
    y=y-((temp(1)-1)*offset);
    set(li(k), 'YData',y);
    set(li(k),'UserData', [temp(1) ((temp(1)-1)*offset)]);
end
ax=findobj(fhandle, 'Type', 'axes');
for k=1:length(ax)
    ylim(ax(k), 'auto');
end
return
end



