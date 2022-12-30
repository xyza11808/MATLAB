% AllPairInfos(cPairInds,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
%         TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2}; % A1_info_BT,A2_info_BT,A1_info_choice,A2_info_choice
load(fullfile(ksfolder,'jeccAnA','RawDataInfo','RawData_CCACorr_AllInfo.mat'));

CalDataTypeStrs = {'Base_BVar','Base_TrVar','Af_BVar','Af_TrVar'};
BaseValidTimeCents = -0.95:0.1:1;
AfValidTimeCents = -0.95:0.1:2;
ResidueFolder = fullfile(ksfolder,'jeccAnA','RawDataInfo');
if ~isfolder(ResidueFolder)
    mkdir(ResidueFolder);
end

ValidTimes = AllTimeWins{3};

NumPairs  = size(AllPairInfos,1);
AllPair_TypesInfo_area = cell(NumPairs, 6, 2);
AllPair_AreaStrs = cell(NumPairs,3);

A1_BT_InfoDatas = cat(1,AllPairInfos{:,1});
A2_BT_InfoDatas = cat(1,AllPairInfos{:,2});

A1_Choice_InfoDatas = cat(1,AllPairInfos{:,3});
A2_Choice_InfoDatas = cat(1,AllPairInfos{:,4});

A1_preCh_InfoDatas = cat(1,AllPairInfos{:,5});
A2_preCh_InfoDatas = cat(1,AllPairInfos{:,6});
%%
for cPair = 1 : NumPairs
    cPairStrs = AllPairStrs(cPair,:);
    cPairedAreaStr = [cPairStrs{1},'-',cPairStrs{2}];
    AllPair_AreaStrs(cPair,1:2) = cPairStrs;
    cpairCorrs = PairedAreaAvgs(cPair,:);
    
    hf = figure('position',[100 100 720 500]);
    
    ax1 = subplot(4,4,1);% correlation coefficient plot for base kernal
    hold on
    baseCorrs = cpairCorrs{1};
    AfCorrs = cpairCorrs{2};
    MeanSemPlot(baseCorrs(2),[],ax1,[],[.7 .7 .7],'Color','k','linewidth',1.4);
    MeanSemPlot(AfCorrs(2),[],ax1,[],[.7 .2 .2],'Color','r','linewidth',1.4);
    plot(baseCorrs{5},'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
    plot(AfCorrs{5},'Color',[.7 .2 .2],'linewidth',1.2,'linestyle','--');
    set(ax1,'xlim',[0 size(baseCorrs{2},2)+1]);
    title(ax1,sprintf('%s-%s',cPairStrs{1},cPairStrs{2}));
    
    baseValidCorrs = baseCorrs{3};
    AfValidCorrs = AfCorrs{3};
    ColorLims = prctile([baseValidCorrs(:);AfValidCorrs(:)],[50 98]);
    
    ax2 = subplot(4,4,2);% base kernal validation correlations
    NumComponents = size(baseValidCorrs,1);
    imagesc(ax2,ValidTimes,1:NumComponents,baseValidCorrs,ColorLims);
    line(ax2,[0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.6,'linestyle','--');
    set(ax2,'ylim',[0.5 NumComponents+0.5]);
    axsPos = get(ax2,'position');
    set(ax2,'position',axsPos);
    title(ax2,'baseKernal corrs');
    
    ax3 = subplot(4,4,3);% base kernal validation correlations
    NumComponents = size(AfValidCorrs,1);
    imagesc(ax3,ValidTimes,1:NumComponents,AfValidCorrs,ColorLims);
    line(ax3,[0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.6,'linestyle','--');
    set(ax3,'ylim',[0.5 NumComponents+0.5]);
    title(ax3,'Afterkernal corrs');
    axsPos = get(ax3,'position');
    hbar = colorbar;
    set(ax3,'position',axsPos);
    
    
    %BT info plots
%     ax_A1_BT_base = subplot(4,4,5);
%     ax_A1_BT_Af = subplot(4,4,6);
%     ax_A1_Ch_base = subplot(4,4,9);
%     ax_A1_Ch_Af = subplot(4,4,10);
%     ax_A1_preCh_base = subplot(4,4,13);
%     ax_A1_preCh_Af = subplot(4,4,14);
    A1_AxesInds = [5,6,9,10,13,14];
    A2_AxesInds = A1_AxesInds+2;
    A1BT_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A1_BT_InfoDatas(cPair,:),'un',0);
    A2BT_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A2_BT_InfoDatas(cPair,:),'un',0); % base and after kernal
    A1Ch_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A1_Choice_InfoDatas(cPair,:),'un',0);
    A2Ch_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A2_Choice_InfoDatas(cPair,:),'un',0); % base and after kernal
    A1preCh_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A1_preCh_InfoDatas(cPair,:),'un',0);
    A2preCh_infos_Nor = cellfun(@(x) x(:,:,2)./x(:,:,3),A2_preCh_InfoDatas(cPair,:),'un',0); % base and after kernal
    
    A1BTColorlim = prctile(cat(1,A1BT_infos_Nor{:}),[50 98],'all');
    A1ChColorlim = prctile(cat(1,A1Ch_infos_Nor{:}),[50 98],'all');
    A1preChColorlim = prctile(cat(1,A1preCh_infos_Nor{:}),[50 98],'all');
    
    A2BTColorlim = prctile(cat(1,A2BT_infos_Nor{:}),[50 98],'all');
    A2ChColorlim = prctile(cat(1,A2Ch_infos_Nor{:}),[50 98],'all');
    A2preChColorlim = prctile(cat(1,A2preCh_infos_Nor{:}),[50 98],'all');
    
%     AxisAll = [ax_A1_BT_base,ax_A1_BT_Af,ax_A1_Ch_base,ax_A1_Ch_Af,ax_A1_preCh_base,ax_A1_preCh_Af];
    A1_datas = {A1BT_infos_Nor{1},A1BT_infos_Nor{2},A1Ch_infos_Nor{1},A1Ch_infos_Nor{2},A1preCh_infos_Nor{1},A1preCh_infos_Nor{2}};
    A2_datas = {A2BT_infos_Nor{1},A2BT_infos_Nor{2},A2Ch_infos_Nor{1},A2Ch_infos_Nor{2},A2preCh_infos_Nor{1},A2preCh_infos_Nor{2}};
    A1_clims = {A1BTColorlim,A1BTColorlim,A1ChColorlim,A1ChColorlim,A1preChColorlim,A1preChColorlim};
    A2_clims = {A2BTColorlim,A2BTColorlim,A2ChColorlim,A2ChColorlim,A2preChColorlim,A2preChColorlim};
    TypeDespStr = {'base','Af','base','Af','base','Af'};
    InfoTypeStr = {'BTinfo','Chinfo','preChinfo'};
    k = 1;
    for cAx = 1 : 6
        % plot for area 1
        cAx_axes = subplot(4,4,A1_AxesInds(cAx));
        NumComponents = size(A1_datas{cAx},1);
        imagesc(cAx_axes,ValidTimes,1:NumComponents,A1_datas{cAx},A1_clims{cAx}');
        line(cAx_axes,[0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.6,'linestyle','--');
        set(cAx_axes,'ylim',[0.5 NumComponents+0.5]);
        if mod(A1_AxesInds(cAx),2) == 0
            axPos = get(cAx_axes,'position');
            hbar = colorbar;
            oldBarPos = get(hbar, 'position');
            set(cAx_axes,'position',axPos);
            set(hbar,'position',[axPos(1)+axPos(3)+0.002, axPos(2) oldBarPos(3)*0.5 oldBarPos(4)*0.3]);
        else
            axPos = get(cAx_axes,'position');
            set(cAx_axes,'position',axPos);
            
            ylabel(InfoTypeStr{k});
            k = k + 1;
        end
        title(cAx_axes,sprintf('A1 %s',TypeDespStr{cAx}));
        
        % plot for area 2
        cAx_axes2 = subplot(4,4,A1_AxesInds(cAx)+2);
        NumComponents = size(A2_datas{cAx},1);
        imagesc(cAx_axes2,ValidTimes,1:NumComponents,A2_datas{cAx},A2_clims{cAx}');
        line(cAx_axes2,[0 0],[0.5 NumComponents+0.5],'Color','m','linewidth',0.6,'linestyle','--');
        set(cAx_axes2,'ylim',[0.5 NumComponents+0.5]);
        if mod(A1_AxesInds(cAx),2) == 0
            axPos = get(cAx_axes2,'position');
            hbar = colorbar;
            oldBarPos = get(hbar, 'position');
            set(cAx_axes2,'position',axPos);
            set(hbar,'position',[axPos(1)+axPos(3)+0.02, axPos(2) oldBarPos(3)*0.5 oldBarPos(4)*0.3]);
        else
            axPos = get(cAx_axes2,'position');
            set(cAx_axes2,'position',axPos);
        end
        title(cAx_axes2,sprintf('A2 %s',TypeDespStr{cAx}));
        
        
        
    end
    %
    saveName = fullfile(ksfolder,'jeccAnA','RawDataInfo',sprintf('Area %s RawData info plots',cPairedAreaStr));
    saveas(hf,saveName);
    print(hf,saveName,'-dpng','-r350');
    close(hf);
    
    AllPair_TypesInfo_area(cPair,1,:) = {A1BT_infos_Nor,A2BT_infos_Nor};
    AllPair_TypesInfo_area(cPair,2,:) = {A1Ch_infos_Nor,A2Ch_infos_Nor};
    AllPair_TypesInfo_area(cPair,3,:) = {A1preCh_infos_Nor,A2preCh_infos_Nor};
    
    
    AllPair_AreaStrs{cPair,3} = ValidTimes;
    
end
%%
dataSavePath = fullfile(ResidueFolder,'AreaResidue_info.mat');
save(dataSavePath,'AllPair_TypesInfo_area','AllPair_AreaStrs','-v7.3');
