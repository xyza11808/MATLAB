% data path is
% 'X:\Lab_Members\Xin_Y\behavior_rig06_backup\behaviro_data\batch55\anm03\UsedData';
UsedFiles = {'55a03_2afc_20180814strc.mat',...
    '55a03_2afc_20180815strc.mat',...
    '55a03_2afc_20180816strc.mat',...
    '55a03_2afc_20180817strc.mat',...
    '55a03_2afc_20180818strc.mat',...
    '55a03_2afc_20180819strc.mat',...
    '55a03_2afc_20180820strc.mat'};
NumFiles = length(UsedFiles);
UsedBehavDatas = cell(NumFiles,1);
for cf = 1 : NumFiles
    cData = load(UsedFiles{cf});
    DataBehav_TrTypes = double(cData.behavResults.Trial_Type(:));
    DataBehav_Choices = double(cData.behavResults.Action_choice(:));
    TrNum = length(DataBehav_Choices);
    
    cfData.Behav_TrTypes = DataBehav_TrTypes;
    cfData.Behav_TrChoice = DataBehav_Choices;
    cfData.BehavCorrs = double(DataBehav_TrTypes == DataBehav_Choices);
    cfData.NMBehavCorrs = cfData.BehavCorrs(DataBehav_Choices~=2);
    cfData.BehavTrNum = TrNum;
    cfData.NMBehavTrNum = length(cfData.NMBehavCorrs);
    
    UsedBehavDatas{cf} = cfData;
end
%%
hhhf = figure('position',[200 100 200*NumFiles 250],'Color','w');
axBase = 0;
StartInds = 15;
EndExInds = 15;
for cff = 1 : NumFiles
    ax = subplot(1,NumFiles,cff);
    cTrs = UsedBehavDatas{cff}.NMBehavTrNum;
    SmoothData =smooth(UsedBehavDatas{cff}.NMBehavCorrs,31); 
    plot(SmoothData(StartInds:end-EndExInds),'k','linewidth',1.4);
    xUsedTick = 0:200:cTrs;
    set(gca,'box','off','ylim',[-0.02 1.05],'xlim',[0 cTrs-EndExInds-StartInds+1],'xtick',xUsedTick);
    if cff > 1
        set(gca,'ycolor','w');
    end
    
    AxPos = get(ax,'position');
    if cff == 1
        axBase = AxPos(1) + AxPos(3);
        ylabel('Corrext rate');
    else
        set(ax,'position',[axBase+0.02 AxPos(2) AxPos(3) AxPos(4)]);
        axBase = axBase+0.01+AxPos(3);
    end
    set(gca,'Fontsize',12,'ytick',[0 0.5 1]);
    
end

    

