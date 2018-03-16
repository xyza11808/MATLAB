clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    load(fullfile(tline,'CSessionData.mat'),'behavResults','smooth_data','start_frame','frame_rate');
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    RespDataStrc = load(fullfile(pwd,'Curve fitting plots','NewCurveFitsave.mat'));
    RespInds = RespDataStrc.ROIisResponsive;
    ROI_IsSigResp_script
    [~,EndInds] = regexp(tline,'result_save');
    ROIposfilePath = tline(1:EndInds);
    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
    if isfield(ROIdataStrc,'ROIinfoBU')
        ROIinfoData = ROIdataStrc.ROIinfoBU;
    elseif isfield(ROIdataStrc,'ROIinfo')
        ROIinfoData = ROIdataStrc.ROIinfo(1);
    else
        error('No ROI information file detected, please check current session path.');
    end
    ROIcenter = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenter);
    DisMatrix = squareform(ROIdistance);
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    Uncertainty = 1 - BehavCorr;
    if ~isdir('Tuned freq NewSig grayCP plot')
        mkdir('Tuned freq NewSig grayCP plot');
    end
    cd('Tuned freq NewSig grayCP plot');
    % plot the behavior result and uncertainty function
    GroupStimsNum = floor(length(BehavCorr)/2);
    BehavOctaves = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
    FreqStrs = cellstr(num2str(BehavBoundfile.boundary_result.StimType(:)/1000,'%.1f'));
    FitoctaveData = BehavCorr;
    FitoctaveData(1:GroupStimsNum) = 1 - FitoctaveData(1:GroupStimsNum);
    
    UL = [0.5, 0.5, max(BehavOctaves), 100];
    SP = [FitoctaveData(1),1 - FitoctaveData(end)-FitoctaveData(1), mean(BehavOctaves), 1];
    LM = [0, 0, min(BehavOctaves), 0];
    ParaBoundLim = ([UL;SP;LM]);
    fit_ReNew = FitPsycheCurveWH_nx(BehavOctaves, FitoctaveData, ParaBoundLim);
    UncertainCurve = 0.5 - (abs(0.5 - fit_ReNew.curve(:,2)));
    [~,BoundInds] = min(abs(fit_ReNew.curve(:,2) - 0.5));
    internal_boundary = fit_ReNew.curve(BoundInds,1);
    % ###############################################################################
    % plot the uncertainty curve with psychometric curve
    hf = figure('position',[100 100 400 300]);
    yyaxis left
    hold on
    plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'color','k','LineWidth',2.4);
    plot(BehavOctaves, FitoctaveData,'bo','MarkerSize',12,'linewidth',2.5);
%     line([fit_ReNew.ffit.u fit_ReNew.ffit.u],[0 1],'Color',[1 0.4 0.4],'linestyle','--','LineWidth',2);
    line([internal_boundary internal_boundary],[0 1],'Color',[1 0.4 0.4],'linestyle','--','LineWidth',2);
    text(internal_boundary,0.1,'BehavBound','HorizontalAlignment','center','Color','g');
    set(gca,'YColor','k','Ylim',[0 1]);
    ylabel('Right Probability');
    
    yyaxis right
    plot(fit_ReNew.curve(:,1),UncertainCurve,'color',[.7 .7 .7],'LineWidth',2.4);
    set(gca,'YColor',[.7 .7 .7],'ylim',[0 0.5],'Ytick',[0 0.25 0.5],'YtickLabel',[0 0.5 1]);
    ylabel('Norm. uncertainty');
    set(gca,'xtick',BehavOctaves,'xTickLabel',FreqStrs);
    xlabel('Frequency (kHz)');
    set(gca,'FontSize',18);
    
    saveas(hf,'Behavior and uncertainty curve plot');
    saveas(hf,'Behavior and uncertainty curve plot','png');
    close(hf);
    %  ######################################################################################
    % extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    MaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        MaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
    ROIsigResp = RespInds;
%     RespROIInds = (MaxAmp > 10);
    RespROIInds = logical(ROIsigResp);
    modeFreqInds = MaxIndsOctave(RespROIInds) == mode(MaxIndsOctave(RespROIInds));
    [PassClusterInterMean,PassRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix(RespROIInds,RespROIInds),modeFreqInds,'Rand');
    saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution');
    saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution','png');
    close(hhf);
    AllMaxIndsOctaves = MaxIndsOctave;
    PassFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [PassFreqStrs(1:BoundFreqIndex-1);'BehavBound';PassFreqStrs(BoundFreqIndex:end)];
    NonRespROIInds = ~RespROIInds;
    %
    PercentileNum = 0;
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        %
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        GrayNonRespROIs = cROIinds(:) & NonRespROIInds;
        ColorRespROIs = cROIinds(:) & ~NonRespROIInds;
        
        % plot the responsive ROIs with color indicates tuning octave
        AllMasks = ROIinfoData.ROImask(ColorRespROIs);
        MaxIndsOctave = AllMaxIndsOctaves(ColorRespROIs);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * MaxIndsOctave(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * MaxIndsOctave(cROI);
        end
        
        if sum(GrayNonRespROIs)
            % generate the non-responsive ROIs, gray map
            AllMasksNonrp = ROIinfoData.ROImask(GrayNonRespROIs);
    %         MaxIndsOctave = AllMaxIndsOctaves(GrayNonRespROIs);
            nROIsNonrp = length(AllMasksNonrp);
            SumROImaskNonrp = double(AllMasksNonrp{1});
            SumROIcolormaskNonrp = SumROImaskNonrp * 0.5;
            for cROI = 2 : nROIsNonrp
                cROINewMask = double(AllMasksNonrp{cROI});
                TempSumMask = SumROImaskNonrp + cROINewMask;
                OverLapInds = find(TempSumMask > 1);
                if ~isempty(OverLapInds)
                    cROINewMask(OverLapInds) = 0;
                end
                SumROImaskNonrp = double(TempSumMask > 0);
                SumROIcolormaskNonrp = SumROIcolormaskNonrp + cROINewMask * 0.8;
            end
        else
            SumROImaskNonrp = zeros(size(SumROImask));
            SumROIcolormaskNonrp = zeros(size(SumROImask));
        end
        %
        hColor = figure('position',[3000 100 530 450]);
        ax1=axes;
        h_backf=imagesc(SumROIcolormask,[-1 1]);
        Cpos=get(ax1,'position');
        view(2);
        ax2=axes;
        h_frontf=imagesc(SumROIcolormaskNonrp,[0 1]);
        set(h_frontf,'alphadata',SumROImaskNonrp~=0);
        set(h_backf,'alphadata',SumROImask~=0);
        linkaxes([ax1,ax2]);
        ax2.Visible = 'off';
        ax2.XTick = [];
        ax2.YTick = [];
        colormap(ax2,'gray');
        set(ax1,'box','off');
        axis(ax1, 'off');
        
        % alpha(h_frontf,0.4);
        set([ax1,ax2],'position',Cpos);
        hBar = colorbar(ax1,'westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(MaxIndsOctave);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ax1,'position',get(ax1,'position')+[0.1 0 0 0])
        set(ax2,'position',get(ax2,'position')+[0.1 0 0 0])
   
%
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    PassROITunedOctave = AllMaxIndsOctaves;
    PassOctaves = UsedOctave;
    Octaves = unique(AllMaxIndsOctaves);
    PassOctaveTypeNum = zeros(length(PassOctaves),1);
    for n = 1 : length(PassOctaves)
        PassOctaveTypeNum(n) = sum(AllMaxIndsOctaves == PassOctaves(n));
    end

    %
    % extract task session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = TaskFreqOctave;
    UsedOctave = UsedOctave(:);
    UsedOctaveData = CorrTunningFun;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    MaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        MaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
%     RespROIinds = MaxAmp > 10;
    RespROIinds = logical(ROIsigResp);
    modeFreqInds = MaxIndsOctave(RespROIinds) == mode(MaxIndsOctave(RespROIinds));
    [TaskClusterInterMean,TaskRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix(RespROIinds,RespROIinds),modeFreqInds,'Rand');
    saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution');
    saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution','png');
    close(hhf);
    %
    AllMaxIndsOctaves = MaxIndsOctave;
    TaskFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [TaskFreqStrs(1:BoundFreqIndex-1);'BehavBound';TaskFreqStrs(BoundFreqIndex:end)];
    NonRespROIInds = (~RespROIinds);
    PercentileNum = 0;
    %
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        
        
        ColorRespROIs = cROIinds(:) & ~NonRespROIInds;
        GrayNonRespROIs = cROIinds(:) & NonRespROIInds;
        
        % responsive ROI inds
        AllMasks = ROIinfoData.ROImask(ColorRespROIs);
        MaxIndsOctave = AllMaxIndsOctaves(ColorRespROIs);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * MaxIndsOctave(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * MaxIndsOctave(cROI);
        end
        
        % non-responsive ROI colormap generation
        AllMasksNonrp = ROIinfoData.ROImask(GrayNonRespROIs);
%         MaxIndsOctave = AllMaxIndsOctaves(GrayNonRespROIs);
        nROIsNonrp = length(AllMasksNonrp);
        SumROImaskNonrp = double(AllMasksNonrp{1});
        SumROIcolormaskNonrp = SumROImaskNonrp * 0.8;
        for cROI = 2 : nROIsNonrp
            cROINewMask = double(AllMasksNonrp{cROI});
            TempSumMask = SumROImaskNonrp + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImaskNonrp = double(TempSumMask > 0);
            SumROIcolormaskNonrp = SumROIcolormaskNonrp + cROINewMask * 0.8;
        end
        %
         hColor = figure('position',[3000 100 530 450]);
        ax1=axes;
        h_backf=imagesc(SumROIcolormask,[-1 1]);
        Cpos=get(ax1,'position');
        view(2);
        ax2=axes;
        h_frontf=imagesc(SumROIcolormaskNonrp,[0 1]);
        set(h_frontf,'alphadata',SumROImaskNonrp~=0);
        set(h_backf,'alphadata',SumROImask~=0);
        linkaxes([ax1,ax2]);
        ax2.Visible = 'off';
        ax2.XTick = [];
        ax2.YTick = [];
        colormap(ax2,'gray');
        set(ax1,'box','off');
        axis(ax1, 'off');
        
        % alpha(h_frontf,0.4);
        set([ax1,ax2],'position',Cpos);
        hBar = colorbar(ax1,'westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(MaxIndsOctave);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ax1,'position',get(ax1,'position')+[0.1 0 0 0])
        set(ax2,'position',get(ax2,'position')+[0.1 0 0 0])
%
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    TaskROITunedOctave = AllMaxIndsOctaves;
    TaskOctaves = UsedOctave;
    %
%     Octaves = unique(MaxIndsOctave);
    TaskOctaveTypeNum = zeros(length(UsedOctave),1);
    for n = 1 : length(UsedOctave)
        TaskOctaveTypeNum(n) = sum(AllMaxIndsOctaves == UsedOctave(n));
    end
    %
    if mod(length(UsedOctave),2)
        cSessDatafile = load(fullfile(tline,'CSessionData.mat'),'behavResults');
        FreqTypes = double(cSessDatafile.behavResults.Stim_toneFreq);
        ChoiceTypes = double(cSessDatafile.behavResults.Action_choice);
        AllFreqType = unique(FreqTypes);
        CenterFreq = AllFreqType(ceil(length(AllFreqType)/2));
        CenterFreqChoice = ChoiceTypes(FreqTypes == CenterFreq);
        MissChoice = CenterFreqChoice == 2;
        CenterFreqChoice(MissChoice) = [];
        CenterUncertainty = 1 - mean(CenterFreqChoice);
        Uncertainty = (Uncertainty(:))';
        GrFreqNum = length(Uncertainty)/2;
        newUncertainty = [Uncertainty(1:GrFreqNum),CenterUncertainty,Uncertainty(1+GrFreqNum:end)];
        Uncertainty = newUncertainty;
    end
    
    % set boundary color
    ColorIndex = parula(256);
    IndexScale = linspace(min(TaskOctaves),max(TaskOctaves),256);
    [~,BoundaryInds] = min(abs(IndexScale - BehavBoundData));
    BoundaryColor = ColorIndex(BoundaryInds,:);
    
    %
    % Task2BehavBoundDiff = (TaskROITunedOctave - BehavBoundData);
    % Pass2BehavBoundDiff = (PassROITunedOctave - BehavBoundData);
    % 
    % TaskTunBoundSEM = std(Task2BehavBoundDiff)/sqrt(length(Task2BehavBoundDiff));
    % ts = tinv([0.025  0.975],length(Task2BehavBoundDiff)-1);
    % TaskCI = mean(Task2BehavBoundDiff) + ts*TaskTunBoundSEM;
    % PassTunBoundSEM = std(Pass2BehavBoundDiff)/sqrt(length(Pass2BehavBoundDiff));
    % PassCI = mean(Pass2BehavBoundDiff) + ts*PassTunBoundSEM;
    % 
    % hhf = figure('position',[750 250 430 500]);
    % hold on
    % plot(ones(size(Task2BehavBoundDiff)),Task2BehavBoundDiff,'*','Color',[1 .5 .5],'MarkerSize',10,'Linewidth',1.4);
    % plot(ones(size(Task2BehavBoundDiff))+1,Task2BehavBoundDiff,'*','Color',[.7 .7 .7],'MarkerSize',10,'Linewidth',1.4);
    % patch([0.9 1.1 1.1 0.9],[PassCI(1) PassCI(1) PassCI(2) PassCI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
    % patch([0.9 1.1 1.1 0.9]+1,[TaskCI(1) TaskCI(1) TaskCI(2) TaskCI(2)],1,'EdgeColor','r','FaceColor','none','linewidth',2);
    % errorbar([1,2],[mean(Task2BehavBoundDiff),mean(Pass2BehavBoundDiff)],[TaskTunBoundSEM,PassTunBoundSEM],'bo','linewidth',1.8);
    % set(gca,'xlim',[0.5,2.5]);
    % ll = line([1.8 2.2],[mean(Pass2BehavBoundDiff) mean(Pass2BehavBoundDiff)],'Color','k','linewidth',2,'linestyle','--');
    % ll2 = line([0.8 1.2],[mean(Task2BehavBoundDiff) mean(Task2BehavBoundDiff)],'Color','r','linewidth',2,'linestyle','--');
    % set(gca,'xtick',[1,2],'xticklabel',{'TaskDiff','PassDiff'},'FontSize',18);
    % legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest');
    % legend('boxoff')
    % legend({},'FontSize',10)

    % plot the tuning peak distribution with uncertainty curve
    TaskFreqStrs = num2str((2.^TaskOctaves(:))*BoundFreq/1000,'%.1f');
    hf = figure('position',[600 300 400 300]);
%     yyaxis left
    hold on
    ll1 = plot(PassOctaves,PassOctaveTypeNum,'k-*','linewidth',1.8,'MarkerSize',10);
    ll2 = plot(TaskOctaves,TaskOctaveTypeNum,'r-o','linewidth',1.8,'MarkerSize',10);
    ylabel('Cell Count');

%     yyaxis right
%     ll3 = plot(TaskOctaves,Uncertainty,'m-o','linewidth',1.8,'MarkerSize',10);
    set(gca,'xtick',TaskOctaves,'xticklabel',TaskFreqStrs);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'linewidth',2.1,'Color',BoundaryColor,'Linestyle','--');
    text(BehavBoundData,yscales(1)+diff(yscales*0.1),'BehavBound','Color','g','FontSize',10,'HorizontalAlignment','center');
    set(gca,'ylim',yscales);
%     ylabel('Uncertainty level');
    xlabel('Frequency (kHz)');

    title('Tuned Inds vs uncertainty');
    set(gca,'FontSize',16);
    if BehavBoundData < 0
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northeast','FontSize',8);
        legend([ll1,ll2],{'Passive','Task'},'Location','Northeast','FontSize',8);
    else
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northwest','FontSize',8);
        legend([ll1,ll2],{'Passive','Task'},'Location','Northwest','FontSize',8);
    end
    legend('boxoff');
    %
    saveas(hf,'Uncertainty curve vs cell count plot');
    saveas(hf,'Uncertainty curve vs cell count plot','png');
    close(hf);
    %
    TaskDiff2Bound = abs(TaskROITunedOctave - BehavBoundData); 
    PassDiff2Bound = abs(PassROITunedOctave - BehavBoundData); 
    TaskDiffTypes = unique(TaskDiff2Bound);
    PassDiffTypes = unique(PassDiff2Bound);
    CombinationNum = length(TaskDiffTypes) * length(PassDiffTypes);
    TypeCellCounts = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellPassx = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellTasky = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    for nType = 1 : CombinationNum
        [TaskInds,PassiveInds] = ind2sub([length(TaskDiffTypes) , length(PassDiffTypes)],nType);
        cTypeInds = TaskDiff2Bound == TaskDiffTypes(TaskInds) & PassDiff2Bound == PassDiffTypes(PassiveInds);
        TypeCellCounts(TaskInds,PassiveInds) = sum(cTypeInds);
        TypeCellPassx(TaskInds,PassiveInds) = PassDiffTypes(PassiveInds);
        TypeCellTasky(TaskInds,PassiveInds) = TaskDiffTypes(TaskInds);
    end
    TypeCellCountsVec = TypeCellCounts(:);
    TypeCellPassxVec = TypeCellPassx(:);
    TypeCellTaskyVec = TypeCellTasky(:);
    EmptyData = TypeCellCountsVec == 0;
    hf = figure('position',[600 350 450 400],'Paperpositionmode','auto');
    scatter(TypeCellPassxVec(~EmptyData),TypeCellTaskyVec(~EmptyData),80,TypeCellCountsVec(~EmptyData),'filled','o','linewidth',2);
%     hf = figure('position',[600 350 450 350],'Paperpositionmode','auto');
%     scatter(PassDiff2Bound,TaskDiff2Bound,50,'ro','linewidth',2);
    xyscales = [get(gca,'xlim');get(gca,'ylim')]; 
    CommonScale = [min(xyscales(:,1)),max(xyscales(:,2))];
    set(gca,'xlim',CommonScale,'ylim',CommonScale);
    line(CommonScale,CommonScale,'Linewidth',2,'Color',[.7 .7 .7],'lineStyle','--');
    [~,p] = ttest2(PassDiff2Bound,TaskDiff2Bound);
    title(sprintf('p = %.3e',p));
    hBar = colorbar;
    set(hBar,'position',get(hBar,'position').*[1.1 1 0.3 0.8]+[0.03 0.1 0 0]);
    xlabel('Passive Diff');
    ylabel('Task Diff');
    set(gca,'FontSize',18);
    %
    saveas(hf,'Bound2Behav diff compare scatter plot');
    saveas(hf,'Bound2Behav diff compare scatter plot','png');
    close(hf);
    
    save PreferVsRandDisMeanSave.mat TaskClusterInterMean TaskRandMean PassClusterInterMean PassRandMean -v7.3
    %
    tline = fgetl(fid);
end

%%
clearvars -except fn fp
m = 1;
nSession = 1;

    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    
    while ischar(tline)
        if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
            tline = fgetl(ff);

            continue;
        else
            %
            if m == 1
                %
%                 PPTname = input('Please input the name for current PPT file:\n','s');
                PPTname = 'testuncertaintySave_20171214Add_GrayColor';
                if isempty(strfind(PPTname,'.ppt'))
                    PPTname = [PPTname,'.pptx'];
                end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
                pptSavePath = 'F:\TestOutputSave\SigROITest';
                %
            end
                Anminfo = SessInfoExtraction(tline);
                cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'Tuned freq NewSig grayCP plot'];
                UncertaintyImPath = fullfile(cTunDataPath,'Uncertainty curve vs cell count plot.png');
                TaskRespMap = fullfile(cTunDataPath,'Task top Prc100 colormap save.png');
                PassRespMap = fullfile(cTunDataPath,'Passive top Prc100 colormap save.png');
                if ~exist(PassRespMap,'file')
                    tline = fgetl(ff);
                    continue;
                end
                BoundDifffig = fullfile(cTunDataPath,'Bound2Behav diff compare scatter plot.png');
                PassRandInterRatio = fullfile(cTunDataPath,'Passive Rand_vs_intermodeROIs distance ratio distribution.png');
                TaskRandInterRatio = fullfile(cTunDataPath,'Task Rand_vs_intermodeROIs distance ratio distribution.png');
                pptFullfile = fullfile(pptSavePath,PPTname);
                if ~exist(pptFullfile,'file')
                    NewFileExport = 1;
                else
                    NewFileExport = 0;
                end
                if NewFileExport
                    exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
                else
                    exportToPPTX('open',pptFullfile);
                end
                %
                cBehavPlotPath = fullfile(cTunDataPath,'Behavior and uncertainty curve plot.png');
                BehavPlotf = imread(cBehavPlotPath);
                    exportToPPTX('addslide');
                    
                    UncertaintyIm = imread(UncertaintyImPath);
                    TaskRespMapIM = imread(TaskRespMap);
                    PassRespMapIM = imread(PassRespMap);
                    BoundDiffIM = imread(BoundDifffig);
                    
                    % Anminfo
                    exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
                    exportToPPTX('addnote',tline);
                    exportToPPTX('addpicture',BehavPlotf,'Position',[0.3 1 5 3.75]);
                    exportToPPTX('addpicture',UncertaintyIm,'Position',[0.3 5 5 3.75]);
                    exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 4.2 3.5]);
                    exportToPPTX('addtext','Task','Position',[10.5 2 1 1],'FontSize',22,'Color','r');
                    exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4 4.2 3.5]);
                    exportToPPTX('addtext','Passive','Position',[10.5 5.5 2 1],'FontSize',22);
                    exportToPPTX('addpicture',BoundDiffIM,'Position',[12.3 0 3 2.52]);
                    exportToPPTX('addpicture',imread(TaskRandInterRatio),'Position',[12.2 2.8 3.5 2.52]);
                    exportToPPTX('addtext','Task','Position',[13.5 5.35 1 0.6],'FontSize',20,'Color','r');
                    exportToPPTX('addpicture',imread(PassRandInterRatio),'Position',[12.2 5.9 3.5 2.52]);
                    exportToPPTX('addtext','Passive','Position',[13.5 8.4 2 0.6],'FontSize',20);
                    
%                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
                    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %s Field: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[6 7.3 5 1.5],'FontSize',22);
        end
         m = m + 1;
         nSession = nSession + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
%%

%% performing high responsive ROIs tuning curve analysis
%% ##############################################################################################
% ##############################################################################################
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    [~,EndInds] = regexp(tline,'result_save');
    ROIposfilePath = tline(1:EndInds);
    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
    if isfield(ROIdataStrc,'ROIinfoBU')
        ROIinfoData = ROIdataStrc.ROIinfoBU;
    elseif isfield(ROIdataStrc,'ROIinfo')
        ROIinfoData = ROIdataStrc.ROIinfo(1);
    else
        error('No ROI information file detected, please check current session path.');
    end
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    Uncertainty = 1 - BehavCorr;
    if ~isdir('HighAmp Tuned colormap plot')
        mkdir('HighAmp Tuned colormap plot');
    end
    cd('HighAmp Tuned colormap plot');
    % extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    HighAmpROIinds = (max(CorrTunningFun) > 20 | max(UsedOctaveData) > 20);
    UsedOctaveData = UsedOctaveData(:,HighAmpROIinds);
%     UsedOctaveData = PassTunningfun(UsedOctaveInds,HighAmpROIinds);
    PassiveHighAmpData = UsedOctaveData;
    %
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    MaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        MaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
    AllMaxIndsOctaves = MaxIndsOctave;
    PassFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [PassFreqStrs(1:BoundFreqIndex-1);'BehavBound';PassFreqStrs(BoundFreqIndex:end)];
    
    PercentileNum = 100 - [0.1,0.25,0.5,0.75,1]*100;
    for cPrc = 1 : length(PercentileNum)
        cPrcvalue = PercentileNum(cPrc);
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        AllMasks = ROIinfoData.ROImask(cROIinds);
        MaxIndsOctave = AllMaxIndsOctaves(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * MaxIndsOctave(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * MaxIndsOctave(cROI);
        end
        %
        hColor = figure('position',[600 300 530 450]);
        ha = axes;
%         axis square
        h_im = imagesc(SumROIcolormask,[-1 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.2 0 0]);
        set(hBar,'ytick',UsedOctave([1,end]),'yticklabel',PassFreqStrs([1,end]));
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
         h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(MaxIndsOctave);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ha,'position',get(ha,'position')+[0.1 0 0 0]);

        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    PassROITunedOctave = MaxIndsOctave;
    PassOctaves = UsedOctave;
    Octaves = unique(MaxIndsOctave);
    PassOctaveTypeNum = zeros(length(PassOctaves),1);
    for n = 1 : length(PassOctaves)
        PassOctaveTypeNum(n) = sum(MaxIndsOctave == PassOctaves(n));
    end

    %
    % extract passive session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = TaskFreqOctave;
    UsedOctave = UsedOctave(:);
    TaskHighAmpData = CorrTunningFun(:,HighAmpROIinds);
    UsedOctaveData = TaskHighAmpData;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    MaxIndsOctave = zeros(nROIs,1);
    for cROI = 1 : nROIs
        MaxIndsOctave(cROI) = UsedOctave(maxInds(cROI));
    end
    AllMaxIndsOctaves = MaxIndsOctave;
    TaskFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [TaskFreqStrs(1:BoundFreqIndex-1);'BehavBound';TaskFreqStrs(BoundFreqIndex:end)];
    PercentileNum = 100 - [0.1,0.25,0.5,0.75,1]*100;
    for cPrc = 1 : length(PercentileNum)
        cPrcvalue = PercentileNum(cPrc);
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        AllMasks = ROIinfoData.ROImask(cROIinds);
        MaxIndsOctave = AllMaxIndsOctaves(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * MaxIndsOctave(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * MaxIndsOctave(cROI);
        end
        %
        hColor = figure('position',[600 300 530 450]);
        ha = axes;
%         axis square
        h_im = imagesc(SumROIcolormask,[-1,1]);
       
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.2 0 0]);
        set(hBar,'ytick',UsedOctave([1,end]),'yticklabel',TaskFreqStrs([1,end]),'FontSize',10);
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
         h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(MaxIndsOctave);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ha,'position',get(ha,'position')+[0.1 0 0 0])
%
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    TaskROITunedOctave = MaxIndsOctave;
    TaskOctaves = UsedOctave;
    %
%     Octaves = unique(MaxIndsOctave);
    TaskOctaveTypeNum = zeros(length(UsedOctave),1);
    for n = 1 : length(UsedOctave)
        TaskOctaveTypeNum(n) = sum(MaxIndsOctave == UsedOctave(n));
    end
    %
    if mod(length(UsedOctave),2)
        cSessDatafile = load(fullfile(tline,'CSessionData.mat'),'behavResults');
        FreqTypes = double(cSessDatafile.behavResults.Stim_toneFreq);
        ChoiceTypes = double(cSessDatafile.behavResults.Action_choice);
        AllFreqType = unique(FreqTypes);
        CenterFreq = AllFreqType(ceil(length(AllFreqType)/2));
        CenterFreqChoice = ChoiceTypes(FreqTypes == CenterFreq);
        MissChoice = CenterFreqChoice == 2;
        CenterFreqChoice(MissChoice) = [];
        CenterUncertainty = 1 - mean(CenterFreqChoice);
        Uncertainty = (Uncertainty(:))';
        GrFreqNum = length(Uncertainty)/2;
        newUncertainty = [Uncertainty(1:GrFreqNum),CenterUncertainty,Uncertainty(1+GrFreqNum:end)];
        Uncertainty = newUncertainty;
    end
    
    % set boundary color
    ColorIndex = parula(256);
    IndexScale = linspace(min(TaskOctaves),max(TaskOctaves),256);
    [~,BoundaryInds] = min(abs(IndexScale - BehavBoundData));
    BoundaryColor = ColorIndex(BoundaryInds,:);
    
    %
    % Task2BehavBoundDiff = (TaskROITunedOctave - BehavBoundData);
    % Pass2BehavBoundDiff = (PassROITunedOctave - BehavBoundData);
    % 
    % TaskTunBoundSEM = std(Task2BehavBoundDiff)/sqrt(length(Task2BehavBoundDiff));
    % ts = tinv([0.025  0.975],length(Task2BehavBoundDiff)-1);
    % TaskCI = mean(Task2BehavBoundDiff) + ts*TaskTunBoundSEM;
    % PassTunBoundSEM = std(Pass2BehavBoundDiff)/sqrt(length(Pass2BehavBoundDiff));
    % PassCI = mean(Pass2BehavBoundDiff) + ts*PassTunBoundSEM;
    % 
    % hhf = figure('position',[750 250 430 500]);
    % hold on
    % plot(ones(size(Task2BehavBoundDiff)),Task2BehavBoundDiff,'*','Color',[1 .5 .5],'MarkerSize',10,'Linewidth',1.4);
    % plot(ones(size(Task2BehavBoundDiff))+1,Task2BehavBoundDiff,'*','Color',[.7 .7 .7],'MarkerSize',10,'Linewidth',1.4);
    % patch([0.9 1.1 1.1 0.9],[PassCI(1) PassCI(1) PassCI(2) PassCI(2)],1,'EdgeColor','k','FaceColor','none','linewidth',2);
    % patch([0.9 1.1 1.1 0.9]+1,[TaskCI(1) TaskCI(1) TaskCI(2) TaskCI(2)],1,'EdgeColor','r','FaceColor','none','linewidth',2);
    % errorbar([1,2],[mean(Task2BehavBoundDiff),mean(Pass2BehavBoundDiff)],[TaskTunBoundSEM,PassTunBoundSEM],'bo','linewidth',1.8);
    % set(gca,'xlim',[0.5,2.5]);
    % ll = line([1.8 2.2],[mean(Pass2BehavBoundDiff) mean(Pass2BehavBoundDiff)],'Color','k','linewidth',2,'linestyle','--');
    % ll2 = line([0.8 1.2],[mean(Task2BehavBoundDiff) mean(Task2BehavBoundDiff)],'Color','r','linewidth',2,'linestyle','--');
    % set(gca,'xtick',[1,2],'xticklabel',{'TaskDiff','PassDiff'},'FontSize',18);
    % legend([ll,ll2],{'Behav Boundary','Mean Boundary'},'location','NorthWest');
    % legend('boxoff')
    % legend({},'FontSize',10)

    % plot the tuning peak distribution with uncertainty curve
    TaskFreqStrs = num2str((2.^TaskOctaves(:))*BoundFreq/1000,'%.1f');
    hf = figure('position',[600 300 400 300]);
    yyaxis left
    hold on
    ll1 = plot(PassOctaves,PassOctaveTypeNum,'k-*','linewidth',1.8,'MarkerSize',10);
    ll2 = plot(TaskOctaves,TaskOctaveTypeNum,'r-o','linewidth',1.8,'MarkerSize',10);
    ylabel('Cell Count');

    yyaxis right
    ll3 = plot(TaskOctaves,Uncertainty,'m-o','linewidth',1.8,'MarkerSize',10);
    set(gca,'xtick',TaskOctaves,'xticklabel',TaskFreqStrs);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'linewidth',2.1,'Color',BoundaryColor,'Linestyle','--');
    text(BehavBoundData,yscales(1)+diff(yscales*0.1),'BehavBound','Color','g','FontSize',10,'HorizontalAlignment','center');
    set(gca,'ylim',yscales);
    ylabel('Uncertainty level');
    xlabel('Frequency (kHz)');

    title('Tuned Inds vs uncertainty');
    set(gca,'FontSize',16);
    if BehavBoundData < 0
        legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northeast','FontSize',8);
    else
        legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northwest','FontSize',8);
    end
    legend('boxoff');
    %
    saveas(hf,'Uncertainty curve vs cell count plot');
    saveas(hf,'Uncertainty curve vs cell count plot','png');
    close(hf);
    
    %
    TaskDiff2Bound = abs(TaskROITunedOctave - BehavBoundData); 
    PassDiff2Bound = abs(PassROITunedOctave - BehavBoundData); 
    TaskDiffTypes = unique(TaskDiff2Bound);
    PassDiffTypes = unique(PassDiff2Bound);
    CombinationNum = length(TaskDiffTypes) * length(PassDiffTypes);
    TypeCellCounts = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellPassx = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    TypeCellTasky = zeros(length(TaskDiffTypes) , length(PassDiffTypes));
    for nType = 1 : CombinationNum
        [TaskInds,PassiveInds] = ind2sub([length(TaskDiffTypes) , length(PassDiffTypes)],nType);
        cTypeInds = TaskDiff2Bound == TaskDiffTypes(TaskInds) & PassDiff2Bound == PassDiffTypes(PassiveInds);
        TypeCellCounts(TaskInds,PassiveInds) = sum(cTypeInds);
        TypeCellPassx(TaskInds,PassiveInds) = PassDiffTypes(PassiveInds);
        TypeCellTasky(TaskInds,PassiveInds) = TaskDiffTypes(TaskInds);
    end
    TypeCellCountsVec = TypeCellCounts(:);
    TypeCellPassxVec = TypeCellPassx(:);
    TypeCellTaskyVec = TypeCellTasky(:);
    EmptyData = TypeCellCountsVec == 0;
    hf = figure('position',[600 350 450 350],'Paperpositionmode','auto');
    scatter(TypeCellPassxVec(~EmptyData),TypeCellTaskyVec(~EmptyData),50,TypeCellCountsVec(~EmptyData),'filled','o','linewidth',2);
    %
%     hf = figure('position',[600 350 450 350],'Paperpositionmode','auto');
%     scatter(PassDiff2Bound,TaskDiff2Bound,50,'ro','linewidth',2);
    xyscales = [get(gca,'xlim');get(gca,'ylim')]; 
    CommonScale = [min(xyscales(:,1)),max(xyscales(:,2))];
    set(gca,'xlim',CommonScale,'ylim',CommonScale);
    line(CommonScale,CommonScale,'Linewidth',2,'Color',[.7 .7 .7],'lineStyle','--');
    [~,p] = ttest2(PassDiff2Bound,TaskDiff2Bound);
    title(sprintf('p = %.3e',p));
    xlabel('Passive Diff');
    ylabel('Task Diff');
    set(gca,'FontSize',18);
    %
    saveas(hf,'Bound2Behav diff HighAmp compare scatter plot');
    saveas(hf,'Bound2Behav diff HighAmp compare scatter plot','png');
    close(hf);
    %
    tline = fgetl(fid);
end

%
clearvars -except fn fp
m = 1;
nSession = 1;

    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    
    while ischar(tline)
        if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
            tline = fgetl(ff);

            continue;
        else
            %
            if m == 1
                %
%                 PPTname = input('Please input the name for current PPT file:\n','s');
                PPTname = 'UncertaintySaveHighAmp';
                if isempty(strfind(PPTname,'.ppt'))
                    PPTname = [PPTname,'.pptx'];
                end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
                pptSavePath = 'F:\TestOutputSave';
                %
            end
                Anminfo = SessInfoExtraction(tline);
                cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'HighAmp Tuned colormap plot'];
                UncertaintyImPath = fullfile(cTunDataPath,'Uncertainty curve vs cell count plot.png');
                TaskRespMap = fullfile(cTunDataPath,'Task top Prc100 colormap save.png');
                PassRespMap = fullfile(cTunDataPath,'Passive top Prc100 colormap save.png');
                BoundDifffig = fullfile(cTunDataPath,'Bound2Behav diff HighAmp compare scatter plot.png');

                pptFullfile = fullfile(pptSavePath,PPTname);
                if ~exist(pptFullfile,'file')
                    NewFileExport = 1;
                else
                    NewFileExport = 0;
                end
                if NewFileExport
                    exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
                else
                    exportToPPTX('open',pptFullfile);
                end
                %
                cBehavPlotPath = fullfile(tline,filesep,'Tunning_fun_plot_New1s',filesep,...
                    'Tuned freq colormap plot',filesep,'Behavior and uncertainty curve plot.png');
                BehavPlotf = imread(cBehavPlotPath);
                    exportToPPTX('addslide');
                    
                    UncertaintyIm = imread(UncertaintyImPath);
                    TaskRespMapIM = imread(TaskRespMap);
                    PassRespMapIM = imread(PassRespMap);
                    BoundDiffIM = imread(BoundDifffig); 
                    
                    % Anminfo
                    exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
                    exportToPPTX('addnote',tline);
                    exportToPPTX('addpicture',BehavPlotf,'Position',[0.3 1 5 3.75]);
                    exportToPPTX('addpicture',UncertaintyIm,'Position',[0.3 5 5 3.75]);
                    exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 5 4.19]);
                    exportToPPTX('addtext','Task','Position',[11 2 1 2],'FontSize',22);
                    exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4.5 5 4.19]);
                    exportToPPTX('addtext','Passive','Position',[11 5.5 3 2],'FontSize',22);
                    exportToPPTX('addpicture',BoundDiffIM,'Position',[12 4.5 4 3.35]);
%                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
                    exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[12 1 3 2.5],'FontSize',22);
        end
         m = m + 1;
         nSession = nSession + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);

%%
clearvars -except fn fp
%%
ROI_info = ROIinfoBU;
ROIcenter = ROI_insite_label(ROI_info,0);
ROIdistance = pdist(ROIcenter);
DisMatrix = squareform(ROIdistance);

%%
% cModeOct = mode(MaxIndsOctave);
% ModeInds = MaxIndsOctave == cModeOct;
% PreferedOctDisMtx = DisMatrix(ModeInds,ModeInds);
% PreferedOctDisVec = PreferedOctDisMtx(logical(tril(ones(size(PreferedOctDisMtx)),-1)));
% InterMean = mean(PreferedOctDisVec);
% nIters = 1000;
% RandMean = zeros(nIters,1);
% DeviateScale = zeros(nIters,1);
% parfor n = 1 : nIters
%     RandInds = randsample(length(MaxIndsOctave),sum(ModeInds));
%     RandIndsDisMtx = DisMatrix(RandInds,RandInds);
%     RandIndsDisVec = RandIndsDisMtx(logical(tril(ones(size(RandIndsDisMtx)),-1)));
%     RandMean(n) = mean(RandIndsDisVec);
%     DeviateScale(n) = sqrt(sum((MaxIndsOctave(RandInds) - cModeOct).^2)/sum(ModeInds));
% end
%
% DisRatio = RandMean/InterMean;
% [~,p] = ttest(DisRatio,1);
% [RatioCount,RatioCent] = hist(DisRatio,min(DisRatio):0.01:max(DisRatio));
% hhf = figure('position',[100,200,450,380]);
% plot(RatioCent,RatioCount/nIters,'k','linewidth',2);
% yscales = get(gca,'ylim');
% line([1,1],yscales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
% line([mean(DisRatio),mean(DisRatio)],yscales,'Color','r','linewidth',1.6,'linestyle','--');
% xlabel('Rand/Inter Distance ratio');
% ylabel('Fraction');
% title(sprintf('p = %.3e',p));
% ylim(yscales);
% set(gca,'FontSize',16);
% text(mean(DisRatio),yscales(2)*0.2+yscales(1)*0.8,{'Mean=';sprintf('%.3f',mean(DisRatio))},...
%     'FontSize',10,'Color','b','HorizontalAlignment','center');
% saveas(hhf,'Prefered frequency within distance with random distance ratio');
% saveas(hhf,'Prefered frequency within distance with random distance ratio','png');
% close(hhf);
