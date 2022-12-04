function hf = AreaValueDispFun(UsedAreaFracs, NEBrainStrs, ...
    st,av,BrainRegionIndex,ColorTypeStr)

Value2Colors = linearValue2colorFun(UsedAreaFracs);

% SliceName = 'sagittal';
hf = figure('position',[100 100 980 220]);
sagAx = subplot(141);
sagAx2 = subplot(142);
topdownAx = subplot(143);

%     sagAx2 = subplot(223);
% plotRecLocsMapByColor(sagAx,topdownAx,{'AUD'},[1 0 0],st,av); % color should have same rows as number of brain regions
OverAllNotshow = plotRecLocsMapByColor3A(sagAx,topdownAx,sagAx2,NEBrainStrs,Value2Colors,st,av,BrainRegionIndex);  % BrainRegionIndex % color should have same rows as number of brain regions

[~,ValueInds] = sort(UsedAreaFracs);
set(gca,'CLim',[min(UsedAreaFracs) max(UsedAreaFracs)])
colormap(Value2Colors(ValueInds,:))
hbar = colorbar;
set(get(hbar,'title'),'String',ColorTypeStr);
%
if sum(OverAllNotshow)
    % extra areas showing in text color
    ax3 = subplot(144);
    hold on
    ExtraAreasIndex = find(OverAllNotshow);
    ExtraAreaNames = NEBrainStrs(ExtraAreasIndex);
    ExtraAreaColors = Value2Colors(ExtraAreasIndex,:);
    NumEA = length(ExtraAreasIndex);
    for cA = 1 : NumEA
        xInds = floor(cA/10)+1;
        yInds = mod(cA,10);
        if yInds == 0
            yInds = 10;
            xInds = xInds - 1;
        end
        text(ax3,xInds,yInds,ExtraAreaNames{cA},'Color',ExtraAreaColors(cA,:),'FontSize',10);
    end
    set(ax3,'xlim',[0 xInds+1],'ylim',[0 11]);
    set(ax3,'xtick',[],'ytick',[],'xColor','none','yColor','none')
end

