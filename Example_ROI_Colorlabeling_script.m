% example session path
% F:\batch\batch49\anm04\test01\im_data_reg_cpu\result_save\plot_save\NO_Correction
RFdata = 'F:\batch\batch49\anm04\test01\im_data_reg_cpu\result_save\plot_save\NO_Correction\RFtunDataSave.mat';
SessROIPos = 'F:\batch\batch49\anm04\test01\im_data_reg_cpu\result_save\ROIinfoBU_b49a04_test01_2x_rf_240um_20171117_dftReg_.mat';
SessStimData = 'F:\batch\batch49\anm04\test01\im_data_reg_cpu\result_save\plot_save\NO_Correction\rfSelectDataSet.mat';
load(RFdata);
load(SessROIPos);
StimDatas = load(SessStimData);
nROIs = length(RFTunData);
StimArray = double(StimDatas.SelectSArray);
Stimtypes = unique(StimArray);
StimOctTypes = log2(Stimtypes/16000);
ROIMeanTrace = cellfun(@(x) mean(x,2),RFTunData,'UniformOutput',false);
ROITunOcts = zeros(nROIs,1);
ROIIsSigResp = ones(nROIs,1);
for cROI = 1 : nROIs
    cROIData = ROIMeanTrace{cROI};
    [MaxV,MaxInds] = max(cROIData);
    if MaxV < 10
        ROIIsSigResp(cROI) = 0;
    end
    ROITunOcts(cROI) = StimOctTypes(MaxInds);
end

%%
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
AllMasksNonrp = ROIinfoBU.ROImask(~logical(ROIIsSigResp));
AllPosnonRp = ROIinfoBU.ROIpos(~logical(ROIIsSigResp));
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
cCusMaps = blue2red_2(length(StimOctTypes),0.7);
StimStrs = cellstr(num2str(StimTypes(:)/1000,'%.1f'));

hColor = figure('position',[3000 100 530 450]);
ax1=axes;
% h_backf = imagesc(SumROIgraymask,[0 1]);
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
colormap(ax2,cCusMaps);
colormap(ax1,'gray');
set(ax1,'box','off','box','off');
set(ax2,'box','off');
axis(ax1, 'off');
set([ax1,ax2],'position',Cpos+[-0.1 0 0 0]);

ColoraxPos = get(ax2,'position');
hhbar = colorbar(ax2,'position',[ColoraxPos(1)+ColoraxPos(3)+0.03,ColoraxPos(2)+0.2,0.03,ColoraxPos(4)*0.6],...
    'Ticks',StimOctTypes,'TickLabels',StimStrs);
%     'Ticks',[min(ROITunOcts),max(ROITunOcts)],'TickLabels',StimStrs([1,end]));
% alpha(h_frontf,0.4);

% hBar = colorbar(ax1,'westoutside');
% set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
% set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
% title(hBar,'kHz')

% saveas(hColor,'Example ROI colormap plot');
% saveas(hColor,'Example ROI colormap plot','png');
% saveas(hColor,'Example ROI colormap plot','pdf');

%%
%%
ExampROIinds = [4,9,17,18,19,31,43,50,76,84]; % position labeled specifically
TempROIs = length(ExampROIinds);
ExampleROIOcts = ROITunOcts(ExampROIinds);
[ExampleOctValue,ExampleInds] = sort(ExampleROIOcts,'descend');
% MapTypes = unique(ROITunOcts);
% responsive ROI inds
AllExamplePos = ROIinfoBU.ROIpos(ExampROIinds);
AllMasks = ROIinfoBU.ROImask(logical(ROIIsSigResp));
SigROINum = length(AllMasks);
SigROITuns = ROITunOcts(logical(ROIIsSigResp));
ROICenterPos = cellfun(@mean,ROIinfoBU.ROIpos,'Uniformoutput',false);
ROICenterPosMtx = cell2mat(ROICenterPos');
% MaxIndsOctave = 1:TempROIs;
% TempROIs = length(AllMasks);
SumROImask = double(AllMasks{1});
SumROIcolormask = SumROImask * SigROITuns(1);
for cROI = 2 : SigROINum
    cROINewMask = double(AllMasks{cROI});
    TempSumMask = SumROImask + cROINewMask;
    OverLapInds = find(TempSumMask > 1);
    if ~isempty(OverLapInds)
        cROINewMask(OverLapInds) = 0;
    end
    SumROImask = double(TempSumMask > 0);
    SumROIcolormask = SumROIcolormask + cROINewMask * SigROITuns(cROI);
end
StimStrs = cellstr(num2str(Stimtypes(:)/1000,'%.1f'));
hColor = figure('position',[100 100 480 400]);
ax2 = axes;
hold on
him = imagesc(SumROIcolormask,[min(ROITunOcts),max(ROITunOcts)]);
set(him,'alphaData',SumROImask);
set(gca,'box','off','xlim',[0 512],'ylim',[0 512],'YDir','reverse');
axis off
% non-responsive ROI colormap generation
AllMasksNonrp = ROIinfoBU.ROImask(~logical(ROIIsSigResp));
AllPosnonRp = ROIinfoBU.ROIpos(~logical(ROIIsSigResp));
ExampleROIPos = ROIinfoBU.ROIpos(ExampROIinds);
ExampleROIPosSort = ExampleROIPos(ExampleInds);
GrayScale = 0.7;
GrStimNum = ceil(length(StimOctTypes)/2);
ColormapUsed = blue2red_2(length(StimOctTypes),GrayScale);
[BinC,BinInds] = histc(ExampleROIOcts,unique(ROITunOcts));
CircleMap = parula(length(StimOctTypes));
UniqueCoMap = CircleMap(BinInds,:);
% ColormapTypes = size(ColormapUsed,1);
% UsedInds = [1:GrStimNum,ColormapTypes-GrStimNum+1:ColormapTypes];
% RealMaps = ColormapUsed(UsedInds,:);
colormap(ColormapUsed);
for cNonSigROI = 1 : length(AllPosnonRp)
    ExamplePos = AllPosnonRp{cNonSigROI};
    patch(ExamplePos(:,1),ExamplePos(:,2),1,'FaceColor','none','EdgeColor',[1 0.7 0.2],'linewidth',2);%[1 0.7 0.4]
end
% plot example ROI boundary
cCusMaps = flipud(gray(length(ExampROIinds))*0.7+0.3);
ExampleROINum = length(AllExamplePos);
CenterPos = cellfun(@mean,AllExamplePos,'Uniformoutput',false);
CenterPosMtx = cell2mat(CenterPos');
scatter(CenterPosMtx(ExampleInds,1),CenterPosMtx(ExampleInds,2),100,UniqueCoMap(ExampleInds,:),'linewidth',2);
%%
% for croi = 1 : length(ExampleInds)
%     text(CenterPosMtx(ExampleInds(croi),1),CenterPosMtx(ExampleInds(croi),2)+10,[num2str(croi),' - ',num2str(ExampROIinds(ExampleInds(croi)))],'Color','c');  %ExampleInds(
% %     cROIpos = ExampleROIPosSort{croi};
% %     patch(ExamplePos(:,1),ExamplePos(:,2),1,'FaceColor','none','EdgeColor',UniqueCoMap(croi,:),'linewidth',2);%[1 0.7 0.4]
% end
% for AllROI = 1 : size(ROICenterPosMtx,1)
%     text(ROICenterPosMtx(AllROI,1)+8,ROICenterPosMtx(AllROI,2),num2str(AllROI),'Color','m');  %ExampleInds(
%     text(ROICenterPosMtx(AllROI,1)+16,ROICenterPosMtx(AllROI,2),num2str(ROITunOcts(AllROI),'%.3f'),'Color','g');  %ExampleInds(
% end
ColoraxPos = get(ax2,'position');
set(ax2,'position',ColoraxPos + [-0.1 0 0 0]);
ColoraxPos = ColoraxPos + [-0.1 0 0 0];
hhbar = colorbar(ax2,'position',[ColoraxPos(1)+ColoraxPos(3)+0.03,ColoraxPos(2)+0.2,0.03,ColoraxPos(4)*0.6],...
    'Ticks',StimOctTypes);%,'TickLabels',StimStrs([1,end])
% saveas(hColor,'New Example ROI colormap plot');
% saveas(hColor,'New Example ROI colormap plot','png');
% saveas(hColor,'New Example ROI colormap plot','pdf');

%%
% for cExampleROI = 1 : ExampleROINum 
%     cExamplePos = AllExamplePos{cExampleROI};
%     cposMaxBoundx = [min(cExamplePos(:,1)),max(cExamplePos(:,1)),max(cExamplePos(:,1)),min(cExamplePos(:,1))] + [-1 1 1 -1]; % [minx,maxx,miny,maxy]
%     cposMaxBoundy = [min(cExamplePos(:,2)),min(cExamplePos(:,2)),max(cExamplePos(:,2)),max(cExamplePos(:,2))] + [-1 1 1 -1]; % [minx,maxx,miny,maxy]
%     patch(cposMaxBoundx,cposMaxBoundy,1,'FaceColor','none','EdgeColor','c','linewidth',2);
% end
%         MaxIndsOctave = AllMaxIndsOctaves(GrayNonRespROIs);
% nROIsNonrp = length(AllMasksNonrp);
% SumROImaskNonrp = double(AllMasksNonrp{1});
% SumROIgraymask = SumROImaskNonrp * GrayScale;
% for cROI = 2 : nROIsNonrp
%     cROINewMask = double(AllMasksNonrp{cROI});
%     TempSumMask = SumROImaskNonrp + cROINewMask;
%     OverLapInds = find(TempSumMask > 1);
%     if ~isempty(OverLapInds)
%         cROINewMask(OverLapInds) = 0;
%     end
%     SumROImaskNonrp = double(TempSumMask > 0);
%     SumROIgraymask = SumROIgraymask + cROINewMask * GrayScale;
% end
% figure;
% him = imagesc(SumROIgraymask);
% set(him,'alphaData',SumROImaskNonrp);
%%
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