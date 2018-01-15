
ExampROIinds = [4,9,17,18,19,31,43,50,76,84];
TempROIs = length(ExampROIinds);
ExampleROIOcts = ROITunOcts(ExampROIinds);
% MapTypes = unique(ROITunOcts);
% responsive ROI inds
AllMasks = ROIinfoBU.ROImask(ExampROIinds);
% MaxIndsOctave = 1:TempROIs;
% TempROIs = length(AllMasks);
SumROImask = double(AllMasks{1});
SumROIcolormask = SumROImask * ExampleROIOcts(1);
for cROI = 2 : TempROIs
    cROINewMask = double(AllMasks{cROI});
    TempSumMask = SumROImask + cROINewMask;
    OverLapInds = find(TempSumMask > 1);
    if ~isempty(OverLapInds)
        cROINewMask(OverLapInds) = 0;
    end
    SumROImask = double(TempSumMask > 0);
    SumROIcolormask = SumROIcolormask + cROINewMask * ExampleROIOcts(cROI);
end

% non-responsive ROI colormap generation
AllMasksNonrp = ROIinfoBU.ROImask;
GrayScale = 0.7;
%         MaxIndsOctave = AllMaxIndsOctaves(GrayNonRespROIs);
nROIsNonrp = length(AllMasksNonrp);
SumROImaskNonrp = double(AllMasksNonrp{1});
SumROIgraymask = SumROImaskNonrp * GrayScale;
for cROI = 2 : nROIsNonrp
    cROINewMask = double(AllMasksNonrp{cROI});
    TempSumMask = SumROImaskNonrp + cROINewMask;
    OverLapInds = find(TempSumMask > 1);
    if ~isempty(OverLapInds)
        cROINewMask(OverLapInds) = 0;
    end
    SumROImaskNonrp = double(TempSumMask > 0);
    SumROIgraymask = SumROIgraymask + cROINewMask * GrayScale;
end

StimStrs = cellstr(num2str(StimTypes(:)/1000,'%.1f'));

hColor = figure('position',[3000 100 530 450]);
ax1=axes;
h_backf = imagesc(SumROIgraymask,[0 1]);
Cpos=get(ax1,'position');
view(2);
ax2=axes;
h_frontf = imagesc(SumROIcolormask,[min(ROITunOcts),max(ROITunOcts)]);  %[min(ROITunOcts),max(ROITunOcts)]
% set(h_frontf,'alphadata',SumROImaskNonrp~=0);
set(h_frontf,'alphadata',SumROImask~=0);
linkaxes([ax1,ax2]);
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
colormap(ax2,cCusMaps');
colormap(ax1,'gray');
set(ax1,'box','off','box','off');
set(ax2,'box','off');
axis(ax1, 'off');
set([ax1,ax2],'position',Cpos+[-0.1 0 0 0]);

ColoraxPos = get(ax2,'position');
hhbar = colorbar(ax2,'position',[ColoraxPos(1)+ColoraxPos(3)+0.03,ColoraxPos(2)+0.2,0.03,ColoraxPos(4)*0.6],...
    'Ticks',[min(ROITunOcts),max(ROITunOcts)],'TickLabels',StimStrs([1,end]));
% alpha(h_frontf,0.4);

% hBar = colorbar(ax1,'westoutside');
% set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
% set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
% title(hBar,'kHz')
saveas(hColor,'Example ROI colormap plot');
saveas(hColor,'Example ROI colormap plot','png');
saveas(hColor,'Example ROI colormap plot','pdf');
