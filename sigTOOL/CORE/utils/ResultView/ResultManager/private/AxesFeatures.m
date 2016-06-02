function tp=AxesFeatures(tp)
Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);

p=uipanel('Parent', tp.Panel.uipanel,...
    'Units', 'normalized',...
    'Position',[0.05 0.18 0.85 0.24],...
    'Tag', 'sigTOOLResultManagerAxesFeatures');

tp.AxesFeatures.Panel=jcontrol(p, 'javax.swing.JPanel',...
    'Units', 'normalized',...
    'Position',[0 0 1 1],...
    'Foreground', Foreground,...
    'Background', Background,...
    'Border',javax.swing.BorderFactory.createTitledBorder('Axes Features'));


% Font
tp.AxesFeatures.Font=jcontrol(tp.AxesFeatures.Panel, 'javax.swing.JComboBox',...
    'Units', 'normalized',...
    'Position',[0.1 0.7 0.8 0.1],...
    'Foreground', Foreground,...
    'Background', Background,...
    'Name', 'Font');
addLabel(tp.AxesFeatures.Font, 'Font');

% Create list of fonts
list=listfonts();
for k=1:length(list)
    tp.AxesFeatures.Font.addItem(list{k});
end
tp.AxesFeatures.Font.setSelectedItem(get(gca, 'FontName'));


% Font Size
tp.AxesFeatures.FontSize=jcontrol(tp.AxesFeatures.Panel, 'javax.swing.JComboBox',...
    'Units', 'normalized',...
    'Position',[0.1 0.5 0.8 0.1],...
    'Foreground', Foreground,...
    'Background', Background,...
    'Name', 'Size');
addLabel(tp.AxesFeatures.FontSize, 'Size');

% Create list of size
for k=1:64
    tp.AxesFeatures.FontSize.addItem(num2str(k));
end
tp.AxesFeatures.FontSize.setSelectedItem(num2str(get(gca, 'FontSize')));
tp.AxesFeatures.FontSize.setEditable(true);

% Aspect ratio for axes
tp.AxesFeatures.AspectRatio=jcontrol(tp.AxesFeatures.Panel, 'javax.swing.JComboBox',...
    'Units', 'normalized',...
    'Position',[0.1 0.3 0.8 0.1],...
    'Foreground', Foreground,...
    'Background', Background,...
    'Name', 'AspectRatio');
[fhandle ax]=LocalGetHandles(tp.AxesFeatures.AspectRatio);
set(ax(1), 'Units', 'pixels');
pos=get(ax(1), 'Position');
set(ax(1), 'Units', 'normalized');
list=[0.1 0.2 0.4 0.5 0.8 1.0 pos(3)/pos(4)];
list=sort(list);
tp.AxesFeatures.AspectRatio.addItem('No change');
for k=1:length(list)
    tp.AxesFeatures.AspectRatio.addItem(num2str(list(k)));
end
addLabel(tp.AxesFeatures.AspectRatio, 'Aspect Ratio');
tp.AxesFeatures.AspectRatio.setSelectedItem(num2str(pos(3)/pos(4)));
tp.AxesFeatures.AspectRatio.setEditable(true);


% Apply To All button


tp.AxesFeatures.ApplyToAll=jcontrol(tp.AxesFeatures.Panel, 'javax.swing.JButton',...
    'Units', 'normalized',...
    'Position',[0.05 0.05 0.9 0.1],...
    'MouseClickedCallback', {@LocalApply, true},...
    'Text', 'Apply To All');

set(tp.AxesFeatures.Font, 'ActionPerformedCallback', @LocalApplyFont);
set(tp.AxesFeatures.FontSize, 'ActionPerformedCallback', @LocalApplyFontSize);
set(tp.AxesFeatures.AspectRatio, 'ActionPerformedCallback', @LocalApplyAspectRatio);

return
end

function LocalApply(hObject, EventData, flag)
[fhandle ax]=LocalGetHandles(hObject);
tp=getappdata(fhandle, 'ResultManager');
if flag==true
    ax=findall(fhandle, 'Type', 'axes', 'Selected', 'on');
    set(ax, 'Selected', 'off');
end
LocalApplyFont(tp.AxesFeatures.Font, EventData);
LocalApplyFontSize(tp.AxesFeatures.FontSize, EventData);
LocalApplyAspectRatio(tp.AxesFeatures.AspectRatio, EventData);
set(ax, 'Selected', 'on');
return
end

function LocalApplyFont(hObject, EventData)
[fhandle ax]=LocalGetHandles(hObject);
font=hObject.getSelectedItem();
set(ax, 'FontName', font);
if ~isscalar(ax)
    xl=cell2mat(get(ax,'YLabel'));
    yl=cell2mat(get(ax,'Xlabel'));
else
    xl=get(ax,'YLabel');
    yl=get(ax,'Xlabel');
end
set(xl, 'FontName', font);
set(yl, 'FontName', font);
return
end


function LocalApplyFontSize(hObject, EventData)
[fhandle ax]=LocalGetHandles(hObject);
fontsize=str2double(hObject.getSelectedItem());
set(ax, 'FontSize', fontsize);
if ~isscalar(ax)
    xl=cell2mat(get(ax,'YLabel'));
    yl=cell2mat(get(ax,'Xlabel'));
else
    xl=get(ax,'YLabel');
    yl=get(ax,'Xlabel');
end
set(xl, 'FontSize', fontsize);
set(yl, 'FontSize', fontsize);
return
end

function LocalApplyAspectRatio(hObject, EventData)
[fhandle ax]=LocalGetHandles(hObject);
set(ax, 'Units', 'pixels');
pos=get(ax, 'Position');
nr=str2double(hObject.getSelectedItem());
if ~isnan(nr)
    if iscell(pos)
        for k=1:length(pos)
            p=pos{k};
            p(3)=p(4)*nr;
            set(ax(k), 'Position',p);
        end
    else
        pos(3)=pos(4)*nr;
        set(ax, 'Position', pos);
    end
end
set(ax, 'Units', 'normalized');
return
end


function [fhandle ax]=LocalGetHandles(hObject)
fhandle=ancestor(hObject.hghandle,'figure');
ax=findall(fhandle, 'Type', 'axes');
return
end

