function [huf, AreaDataStrc] = CCAPorjInfo_plot_fun(figpos,A1_BT_InfoDatas,A2_BT_InfoDatas,cPair,cPairStrs,InfoTypeStr)
BaseValidTimeCents = -0.95:0.1:1;
AfValidTimeCents = -0.95:0.1:2;

huf = figure('position',figpos);
% plots for section 1
% Plottype = 3; % 1 is train, 2 is test, 3 is shuffle
cPair_A1_BTinfo_BaseBVar = A1_BT_InfoDatas{cPair,1}(:,:,2)./A1_BT_InfoDatas{cPair,1}(:,:,3); % test info
cPair_A1_BTinfo_BaseTrVar = A1_BT_InfoDatas{cPair,2}(:,:,2)./A1_BT_InfoDatas{cPair,2}(:,:,3);
NumComponents = size(cPair_A1_BTinfo_BaseBVar,1);
if NumComponents > 20
    ytickStep = 4;
elseif NumComponents > 8
    ytickStep = 2;
else
    ytickStep = 1;
end
cPair_A1_BTinfo_AfBVar = A1_BT_InfoDatas{cPair,3}(:,:,2)./A1_BT_InfoDatas{cPair,3}(:,:,3); % test info
cPair_A1_BTinfo_AfTrVar = A1_BT_InfoDatas{cPair,4}(:,:,2)./A1_BT_InfoDatas{cPair,4}(:,:,3);

A1_allDatas = cat(3,cPair_A1_BTinfo_BaseBVar,cPair_A1_BTinfo_BaseTrVar,cPair_A1_BTinfo_AfBVar,cPair_A1_BTinfo_AfTrVar);

AllDatas = [cPair_A1_BTinfo_BaseBVar(:);cPair_A1_BTinfo_BaseTrVar(:);...
    cPair_A1_BTinfo_AfBVar(:);cPair_A1_BTinfo_AfTrVar(:)];
DataClim = prctile(AllDatas,[10 98]);

% plot the BT info for A1
ax1_1 = subplot(421);
hold on
imagesc(BaseValidTimeCents,1:NumComponents,cPair_A1_BTinfo_BaseBVar,DataClim);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s BaseBVar %s',cPairStrs{1},InfoTypeStr));
set(ax1_1,'xlim',[-1 1],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
ylabel('Components');
ax1Pos = get(ax1_1,'position');
set(ax1_1,'position',ax1Pos+[-0.05 0 0 0]);

ax1_2 = subplot(422);
hold on
imagesc(AfValidTimeCents,1:NumComponents,cPair_A1_BTinfo_AfBVar,DataClim);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s AfBVar %s',cPairStrs{1},InfoTypeStr));
set(ax1_2,'xlim',[-1 2],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
ax2Pos = get(ax1_2,'position');
set(ax1_2,'position',ax2Pos+[-0.06 0 0 0]);

ax1_3 = subplot(423);
hold on
imagesc(BaseValidTimeCents,1:NumComponents,cPair_A1_BTinfo_BaseTrVar,DataClim);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s BaseTrVar %s',cPairStrs{1},InfoTypeStr));
set(ax1_3,'xlim',[-1 1],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
ylabel('Components');
ax3Pos = get(ax1_3,'position');
set(ax1_3,'position',ax3Pos+[-0.05 0 0 0]);

ax1_4 = subplot(424);
hold on
imagesc(AfValidTimeCents,1:NumComponents,cPair_A1_BTinfo_AfTrVar,DataClim);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s AfTrVar %s',cPairStrs{1},InfoTypeStr));
set(ax1_4,'xlim',[-1 2],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
axPos = get(ax1_4,'position');
hbar = colorbar;
set(ax1_4,'position',axPos+[-0.06 0 0 0]);


% plots for section 1
cPair_A2_BTinfo_BaseBVar = A2_BT_InfoDatas{cPair,1}(:,:,2)./A2_BT_InfoDatas{cPair,1}(:,:,3); % test info
cPair_A2_BTinfo_BaseTrVar = A2_BT_InfoDatas{cPair,2}(:,:,2)./A2_BT_InfoDatas{cPair,2}(:,:,3);
% NumComponents = size(cPair_A1_BTinfo_BaseBVar,1);
cPair_A2_BTinfo_AfBVar = A2_BT_InfoDatas{cPair,3}(:,:,2)./A2_BT_InfoDatas{cPair,3}(:,:,3); % test info
cPair_A2_BTinfo_AfTrVar = A2_BT_InfoDatas{cPair,4}(:,:,2)./A2_BT_InfoDatas{cPair,4}(:,:,3);

A2_allDatas = cat(3,cPair_A2_BTinfo_BaseBVar,cPair_A2_BTinfo_BaseTrVar,cPair_A2_BTinfo_AfBVar,cPair_A2_BTinfo_AfTrVar);

AllDatas2 = [cPair_A2_BTinfo_BaseBVar(:);cPair_A2_BTinfo_BaseTrVar(:);...
    cPair_A2_BTinfo_AfBVar(:);cPair_A2_BTinfo_AfTrVar(:)];
DataClim2 = prctile(AllDatas2,[10 98]);

% plot the BT info for A2
ax1_1 = subplot(425);
hold on
imagesc(BaseValidTimeCents,1:NumComponents,cPair_A2_BTinfo_BaseBVar,DataClim2);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s BaseBVar %s',cPairStrs{2},InfoTypeStr),'Color',[0.9 0.4 0.2]);
set(ax1_1,'xlim',[-1 1],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
ylabel('Components');
ax1Pos = get(ax1_1,'position');
set(ax1_1,'position',ax1Pos+[-0.05 0 0 0]);

ax1_2 = subplot(426);
hold on
imagesc(AfValidTimeCents,1:NumComponents,cPair_A2_BTinfo_AfBVar,DataClim2);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s AfBVar %s',cPairStrs{2},InfoTypeStr),'Color',[0.9 0.4 0.2]);
set(ax1_2,'xlim',[-1 2],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
ax2Pos = get(ax1_2,'position');
set(ax1_2,'position',ax2Pos+[-0.06 0 0 0]);

ax1_3 = subplot(427);
hold on
imagesc(BaseValidTimeCents,1:NumComponents,cPair_A2_BTinfo_BaseTrVar,DataClim2);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s BaseTrVar %s',cPairStrs{2},InfoTypeStr),'Color',[0.9 0.4 0.2]);
set(ax1_3,'xlim',[-1 1],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
xlabel('Time (s)');
ylabel('Components');
ax3Pos = get(ax1_3,'position');
set(ax1_3,'position',ax3Pos+[-0.05 0 0 0]);

ax1_4 = subplot(428);
hold on
imagesc(AfValidTimeCents,1:NumComponents,cPair_A2_BTinfo_AfTrVar,DataClim2);
line([0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.75);
title(sprintf('%s AfTrVar %s',cPairStrs{2},InfoTypeStr),'Color',[0.9 0.4 0.2]);
set(ax1_4,'xlim',[-1 2],'ylim',[0.5 NumComponents+0.5],'ydir','Reverse','ytick',1:ytickStep:NumComponents);
axPos = get(ax1_4,'position');
hbar = colorbar;
set(ax1_4,'position',axPos+[-0.06 0 0 0]);
xlabel('Time (s)');

AreaDataStrc = struct();
AreaDataStrc.A1Datas = A1_allDatas;
AreaDataStrc.A2Datas = A2_allDatas;
AreaDataStrc.BaselineTimes = BaseValidTimeCents;
AreaDataStrc.AfterTimes = AfValidTimeCents;
