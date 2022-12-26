function varargout = uniAxesAdj(hObj)
% function used to set x and y axis at same scale
if ~ishandle(hObj)
    wawrning('The input must be a handle object');
    return;
end

if isgraphics(hObj,'figure')
    axesObjs = get(h, 'Children');  %axes handles
    nAxes = length(axesObjs);
    for cA = 1 : nAxes
        xscales = get(axesObjs(cA),'xlim');
        yscales = get(axesObjs(cA),'ylim');
        maxScales = [min(xscales(1),yscales(1)), max(xscales(2),yscales(2))];
        set(axesObjs(cA),'xlim',maxScales,'ylim',maxScales);
        line(axesObjs(cA),maxScales,maxScales,'Color','k',...
            'linewidth',1.2,'linestyle','--');
    end
elseif isgraphics(hObj,'axes')
    xscales = get(hObj,'xlim');
    yscales = get(hObj,'ylim');
    maxScales = [min(xscales(1),yscales(1)), max(xscales(2),yscales(2))];
    set(hObj,'xlim',maxScales,'ylim',maxScales);
    line(hObj,maxScales,maxScales,'Color','k',...
        'linewidth',1.2,'linestyle','--');
else
    warning('Unkowned object types');
    maxScales = [];
end

if nargout > 0
    varargout = {maxScales};
end

