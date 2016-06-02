function [tp]=cvManager(fhandle, updateflag)

figure(fhandle);

% Check if tree is already present
s=getappdata(fhandle, 'cvManager');

if nargin==1 && ~isempty(s) || nargin==2 && updateflag==false
    tp=s.Panel;
    return
elseif nargin==2 && updateflag==true
    % Delete and recreate
    delete(s.Panel);
end


if scverLessThan('MATLAB','7.6')
    % Not available in R2007b or earlier
    tp=uitable('Parent', fhandle,...
        'ColumnWidth', 1);
    thandle=tp;
    set(thandle, 'Units', 'normalized',...
        'Position', [0 0 0.15 1],...
        'NumColumns',2,...
        'ColumnNames', {'Time(s)', 'Data'});
    h=get(thandle, 'UIContainer');
    set(h, 'Tag', 'CV:ManagerPanel',...
        'UserData', thandle);
else
    % Add tree to a GUI
    % Create a panel
    tp=uipanel(fhandle,...
        'Tag', 'CV:ManagerPanel',...
        'Title','Channel Viewer',...
        'ForegroundColor', [0 0 0.7],...
        'Position', [0 0 0.15 1]);
    set(tp, 'Units', 'character');
    pos=get(tp, 'Position');
    pos(3)=30;
    set(tp, 'Position', pos);
    set(tp, 'Units', 'normalized');
    
    thandle=uitable(tp);
    h=uicontextmenu();
    uimenu(h, 'Label', 'Copy Table', 'Callback', {@LocalCallback thandle});
    set(thandle, 'Units', 'normalized',...
        'RowName',[],...
        'ColumnWidth', {70 70},...
        'Position',[0.0 0.0 1 1],...
        'UiContextMenu', h);
end

setappdata(fhandle,'cvManager',tp);
setappdata(fhandle,'cvUitable', thandle);

return
end

function LocalCallback(hObject, Eventdata, thandle)
data=get(thandle, 'Data')';
str=sprintf('%g\t%g\n', data);
clipboard('copy', str);
return
end