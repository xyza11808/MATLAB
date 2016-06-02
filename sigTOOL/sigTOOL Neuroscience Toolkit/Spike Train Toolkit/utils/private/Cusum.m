%--------------------------------------------------------------------------
function Cusum(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
[fhandle, ax, result, subs, data]=callbackgetparam(hObject);
x=data.tdata;
% Find bins at t<0, use only first half
idx=data.tdata<0;
m=mean(data.rdata(1:sum(idx)/2));
if isnan(m)
    % No pre-time period
    return
end
y=data.rdata-m;
y=cumsum(y);
newax=scAddPlot(ax);
[x2, y2]=stairs(x, y);
h=line(x2, y2,'Parent', newax, 'Color', [0 0 0], 'LineWidth', 2);
set(h, 'Tag', 'AddedPlot',...
    'UserData', [x(:), y(:)],...
    'ButtonDownFcn', @scWindowButtonDownFcn);
set(newax, 'XLim', get(ax, 'XLim'));
set(newax, 'YLim', [min(y) max(y)]);
ylabel(newax, 'Cusum');
return
end
%--------------------------------------------------------------------------