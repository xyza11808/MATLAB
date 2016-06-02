function s=ScrollControls(panel)
s.scroll=uipanel(panel, 'Units', 'normalized',...
    'Position', [0.9-0.225 0.375 0.225 0.1],...
    'ForeGroundColor', [0 0 0.7],...
    'Title', 'Scroll');
if ismac
    set(s.scroll, 'BackgroundColor', [.95 .95 .95]);
end

set(s.scroll, 'Units', 'pixels');
pos=get(s.scroll, 'Position');
pos(4)=80;
pos(1)=pos(1)+pos(3)-175;
pos(3)=175;
set(s.scroll, 'Position', pos);
set(s.scroll, 'Units', 'normalized');

imagepath=fullfile(scGetBaseFolder(),'CORE','icons');

s.fastback=jcontrol(s.scroll, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [5 35 25 25],...
    'ActionPerformedCallback', @FastLocalScrollBack);
s.fastback.setIcon(javax.swing.ImageIcon(fullfile(imagepath,'fastbackward.gif')));

s.scrollback=jcontrol(s.scroll, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [35 35 25 25],...
    'ActionPerformedCallback', @LocalScrollBack);
s.scrollback.setIcon(javax.swing.ImageIcon(fullfile(imagepath,'scrollback.gif')));

s.scrollpause=jcontrol(s.scroll, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [65 35 25 25],...
    'ActionPerformedCallback', @LocalScrollPause);
s.scrollpause.setIcon(javax.swing.ImageIcon(fullfile(imagepath,'pause.gif')));

s.scrollforward=jcontrol(s.scroll, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [100 35 25 25],...
    'ActionPerformedCallback', @LocalScroll);
s.scrollforward.setIcon(javax.swing.ImageIcon(fullfile(imagepath,'scrollforward.gif')));

s.fastforward=jcontrol(s.scroll, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [135 35 25 25],...
    'ActionPerformedCallback', @FastLocalScroll);
s.fastforward.setIcon(javax.swing.ImageIcon(fullfile(imagepath,'fastforward.gif')));

s.scrollspeed=jcontrol(s.scroll, javax.swing.JSlider(1,400,10),...
    'Name', 'Speed',...
    'MouseReleasedCallback', @LocalSlider,...
    'Position', [.05 .1 .9 .35]);

fnames=fieldnames(s);
for k=1:length(fnames)
    set(s.(fnames{k}), 'Units', 'normalized');
end

setappdata(ancestor(panel, 'figure'), 'ScrollControls',s);
return
end

function LocalScroll(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
ControlControl(fhandle, 0);
step=getappdata(fhandle, 'ScrollSpeed');
cvScroll(hObject, step);
return
end

function FastLocalScroll(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
ControlControl(fhandle, 0);
step=getappdata(fhandle, 'ScrollSpeed');
cvScroll(hObject, step*10);
return
end

function LocalScrollBack(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
ControlControl(fhandle, 0);
step=getappdata(fhandle, 'ScrollSpeed');
cvScroll(hObject, -step);
return
end

function FastLocalScrollBack(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
ControlControl(fhandle, 0);
step=getappdata(fhandle, 'ScrollSpeed');
cvScroll(hObject, -step*10);
return
end

function LocalScrollPause(hObject, EventData)
drawnow();
fhandle=ancestor(hObject.hghandle, 'figure');
ControlControl(fhandle, 1);
setappdata(fhandle, 'ScrollStepSize', NaN);
lh=getappdata(fhandle, 'LineHandles');
for k=1:length(lh)
    if isempty(get(lh(k), 'UserData'));
        set(lh(k), 'XData', [], 'YData', []);
    end
end
return
end


function LocalSlider(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
step=hObject.getValue();
setappdata(fhandle, 'ScrollSpeed', step);
return
end

function ControlControl(fhandle, flag)
s=getappdata(fhandle, 'ViewerControls');
s.channelselector.setEnabled(flag);
s.inverttrace.setEnabled(flag);
s.Timebase.setEnabled(flag);
s.Numberoftraces.setEnabled(flag);
return
end