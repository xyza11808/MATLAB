function InputAxes = figaxesScaleUni(InputAxes)
xscales = get(InputAxes,'xlim');
yscales = get(InputAxes,'ylim');
MaxScales = [xscales,yscales];
UsedScale = [min(MaxScales),max(MaxScales)];
set(InputAxes,'xlim',UsedScale,'ylim',UsedScale);
