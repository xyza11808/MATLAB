function CommonScales = UniAxesScale(GivenAxes)
xscales = get(GivenAxes,'xlim');
yscales = get(GivenAxes,'ylim');
CommonScaleMtx = [xscales;yscales];
CommonScales = [min(CommonScaleMtx(:,1)),max(CommonScaleMtx(:,2))];
set(GivenAxes,'xlim',CommonScales,'ylim',CommonScales);

