function cvRawDataAxis(fhandle, startindex)

[fhandle channels]=scParam(fhandle);
chan=getappdata(fhandle, 'thisChannel');

% Extract the data
data=channels{chan};
y=data.adc();
x=getTimeVector(data, 'seconds');

% TODO: This temporary fix ensures data always starts at time zero
x=x-x(1);


setappdata(fhandle, 'xdata', x);
setappdata(fhandle, 'ydata', y);

% Find or set up the raw data panel
datapanel=findobj(fhandle, 'Tag', 'CV:RawDataPanel');
if isempty(datapanel)
    h=findobj(fhandle, 'Tag', 'CV:ManagerPanel');
    pos=get(h, 'Position');
    datapanel=uipanel('Position', [pos(3) 0.3 1-pos(3) 0.7],...
        'Title', 'Raw Data',...
        'ForegroundColor', [0 0 0.7],...
        'BackgroundColor', [1 1 1],...
        'Tag', 'CV:RawDataPanel');
end

% Raw data axes
ax=subplot(1,1,1, 'Parent', datapanel,...
    'Position', [0.05 0.05 0.9 0.9],...
    'Tag', 'CV:RawDataAxes');

yrange=abs(max(y)-min(y));
setappdata(fhandle, 'YRange', yrange);

% Set Timebase
th=findobj(fhandle, 'Tag', 'Timebase');
th=get(th, 'UserData');
xrange=th.getSelectedItem();

idx=GenerateSectionIndices(x, xrange);
if nargin>1
    idx=idx+startindex;
end

th=findobj(fhandle, 'Tag', 'Numberoftraces');
th=get(th, 'UserData');
targetsections=th.getSelectedItem();
sections=size(idx,1);
nl=min(targetsections,sections);
lh=zeros(1, nl);
for k=nl:-1:1
    idx2=idx(k,1):idx(k,2);
    if ~isempty(idx2)
    xl=x(idx2)-(k*xrange)+xrange;
    yl=y(idx2)-((k-1)*yrange);
    lh(k)=line(xl,  yl, 'Tag', 'DataLine',...
        'UserData', [k x(idx2(1)) x(idx2(end)) idx2(1) idx2(end)]);
    end        
end
UpdateUitable(fhandle, idx2(1), idx2(end));
h=get(findobj(fhandle, 'Tag', 'UserMessage'), 'UserData');
if ~isempty(h)
    h.setText('');
end
setappdata(fhandle, 'LineHandles', lh);
axis('tight');
YLim=get(ax, 'YLim');
YLim(1)=YLim(1)-yrange;
set(ax, 'YLim', YLim);
axis('off');
LocalCreateScaleBar(ax, channels{chan}.adc.Units);
setappdata(fhandle, 'LineIndices', idx);
setappdata(fhandle, 'CurrentStartTime', x(1));
setappdata(fhandle, 'CurrentStartIndex', 1);

CreateVerticalScroll(datapanel, x)
return
end


function CreateVerticalScroll(panel, x)
v=findobj(panel, 'Tag','VerticalScroll');
if isempty(v)
v=jcontrol(panel, 'javax.swing.JScrollBar',...
    'Position', [0.98 0.01 0.02 0.99],...
    'Minimum', 1,...
    'Maximum', length(x),...
    'Value', 0,...
    'UnitIncrement', 1000,...
    'AdjustmentValueChangedCallback', {@LocalVerticalScroll},...
    'MouseReleasedCallback', @LocalMouseRelease,...
    'Tag', 'VerticalScroll');
    v.setValue(1);
else
    hObject=get(v, 'UserData');
    hObject.setValue(1);
end
return
end
    
function LocalVerticalScroll(hObject, EventData)
if isMultipleCall() || hObject.isEnabled()==0
    % If a previous LocalVerticalScroll call is still being serviced,
    % dismiss this one
    return
end
fhandle=ancestor(hObject.hghandle, 'figure');
new=hObject.getValue();
old=getappdata(fhandle, 'CurrentStartIndex');
step=new-old;
cvScroll(fhandle, step,1);
%fprintf('%d\t%d\t%d\n', new, old,getappdata(fhandle, 'CurrentStartIndex'));
return
end

function LocalMouseRelease(hObject, EventData)
return
end

function LocalCreateScaleBar(ax, units)

XLim=get(ax, 'XLim');
YLim=get(ax, 'YLim');

% X-axis scale bar
tk=get(ax, 'XTick');
sc=tk(2)-tk(1);
line([XLim(2)-sc XLim(2)], [YLim(1) YLim(1)],...
    'LineWidth', 2,...
    'Color', [0 0 0]);
text(XLim(2)-sc/2, YLim(1), sprintf('%4.1f ms', 1000*sc),...
    'HorizontalAlignment', 'Center',...
    'VerticalAlignment', 'Top');

% Y-axis scale bar
tk=get(ax, 'YTick');
sc=tk(2)-tk(1);
line([XLim(2) XLim(2)], [YLim(1) YLim(1)+sc],...
    'LineWidth', 2,...
    'Color', [0 0 0]);
text(XLim(2), YLim(1)+sc/2, sprintf('%g %s', sc, units),...
    'Rotation', 90,...
    'HorizontalAlignment', 'Center',...
    'VerticalAlignment', 'top');
return
end