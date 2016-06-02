function SmoothingContextMenu(h)
% SmoothingContextMenu: helper function adds data smoothing to a uicontextmenu
% 
% SmoothingContextMenu(h)
%     Populates uimenu object h with the basic smoothing callbacks
%
% The smoothing window is a gaussian with SD of 0.5 [equivalent to 
% gausswin(n,2) with the SP Toolbox]
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

uimenu(h, 'Label', 'Smooth w=3', 'Callback', {@LocalSmooth, 3});
uimenu(h, 'Label', 'Smooth w=5', 'Callback', {@LocalSmooth, 5});
uimenu(h, 'Label', 'Smooth w=7', 'Callback', {@LocalSmooth, 7});
uimenu(h, 'Label', 'Smooth w=9', 'Callback', {@LocalSmooth, 9});
return
end

%--------------------------------------------------------------------------
function LocalSmooth(hObject, EventData, Width) %#ok<INUSL>
%--------------------------------------------------------------------------
% Callback to do the work
[fhandle, ax, result, subs, data]=callbackgetparam(hObject);
x=data.tdata;
y=data.rdata;
w=gausswindow(Width);
w=w/sum(w);
i=floor(length(w)/2)+1;
y=conv(w, y);
y=y(i:i+length(x)-1);
newax=scAddPlot(ax);
[x2, y2]=stairs(x(i:end-i+1), y(i:end-i+1));
h=line(x2, y2,'Parent', newax, 'Color', [0 0 0], 'LineWidth', 2);
set(h, 'Tag', 'AddedPlot',...
    'UserData', [x(i:end-i+1)', y(i:end-i+1)'],...
    'ButtonDownFcn', @scWindowButtonDownFcn);
set(newax, 'XLim', get(ax, 'XLim'));
set(newax, 'YLim', get(ax, 'YLim'));
ylabel(newax, 'Smoothed');
return
end
%--------------------------------------------------------------------------