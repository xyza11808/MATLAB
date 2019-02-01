CusMap = blue2red_2(32,0.8);
% passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'));
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
    ROIcenter = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenter);
    DisMatrix = squareform(ROIdistance);
    
    
%     BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
%     if isempty(BehavBoundData)
    try
        BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
        BehavBoundData = BehavBoundfile.boundary_result.FitModelAll{1}{2}.ffit.u - 1;
    catch
        cd(tline);
        load(fullfile(tline,'CSessionData.mat'),'behavResults');
        rand_plot(behavResults,4,[],1);
        BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
        BehavBoundData = BehavBoundfile.boundary_result.FitModelAll{1}{2}.ffit.u - 1;
    end
%     end
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    Uncertainty = 1 - BehavCorr;
    if ~isdir('NMTuned Meanfreq colormap plot')
        mkdir('NMTuned Meanfreq colormap plot');
    end
    cd('NMTuned Meanfreq colormap plot');
    % plot the behavior result and uncertainty function
    GroupStimsNum = floor(length(BehavCorr)/2);
    BehavOctaves = log2(double(BehavBoundfile.boundary_result.StimType)/BehavBound);
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
    set(gca,'xlim',[-1.2 1.2]);
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
    %  extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    if size(PassTunningfun,2) > size(DisMatrix,2)
        PassROIUsedInds = 1:size(DisMatrix,2);
    else
        PassROIUsedInds = 1:size(PassTunningfun,2);
    end
    UsedOctaveData = PassTunningfun(UsedOctaveInds,PassROIUsedInds);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    PassMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end
    modeFreqInds = PassMaxOct == mode(PassMaxOct);
    PassModeInds = [mode(PassMaxOct),mean(PassMaxOct),BehavBoundData]; 
    PassMaxAmp = MaxAmp;
    
%     [PassClusterInterMean,PassRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix,modeFreqInds,'Rand');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution','png');
%     close(hhf);
%     PreferRandDisSum{m,1} = PassClusterInterMean;
%     PreferRandDisSum{m,2} = PassRandMean;
    %
    AllPassMaxOcts = PassMaxOct;
    PassFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [PassFreqStrs(1:BoundFreqIndex-1);'BehavBound';PassFreqStrs(BoundFreqIndex:end)];
%     NonRespROIInds = (MaxAmp < 20);
    PercentileNum = 0;
    %
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        %
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
%         GrayNonRespROIs = cROIinds & NonRespROIInds;
%         ColorRespROIs = cROIinds & ~NonRespROIInds;
        
        % plot the responsive ROIs with color indicates tuning octave
        AllMasks = ROIinfoData.ROImask(cROIinds);
        cPrcPassMaxOct = PassMaxOct(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * cPrcPassMaxOct(1);
        TestOcts = zeros(nROIs,1);
%         TestOcts(1) = PassMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * cPrcPassMaxOct(cROI);
%             TestOcts(cROI) = PassMaxOct(cROI);
        end
        
        %
        hColor = figure('position',[100 100 530 450]);
        ha = axes;
%         axis square
        h_im = imagesc(SumROIcolormask,[-1 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
%         title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(PassMaxOct);
        MeanPopuOcts = mean(PassMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        LineStartPosMean = [hBar.Position(1)+hBar.Position(3),(MeanPopuOcts-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)]; % position for mean BFs
        
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        MeanArrowx = [LineStartPosMean(1) + 0.03,LineStartPosMean(1)];
        MeanWrrowy = [LineStartPosMean(2),LineStartPosMean(2)];
        
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
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
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
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
%         annotation('textbox',[LineStartPosMean(1),LineStartPosMean(2),0.1 0.1],'String','*','Box','off','Color','k','FontSize',10);
        set(ha,'position',get(ha,'position')+[0.1 0 0 0])
        colormap(CusMap);
%
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    %
    PassROITunedOctave = AllPassMaxOcts;
    PassOctaves = UsedOctave;
    Octaves = unique(AllPassMaxOcts);
    PassOctaveTypeNum = zeros(length(PassOctaves),1);
    for n = 1 : length(PassOctaves)
        PassOctaveTypeNum(n) = sum(AllPassMaxOcts == PassOctaves(n));
    end

    %
    % extract task session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = TaskFreqOctave(:);
    CorrUsedTrNumbers = CorrTypeNum;
    FewTrNumInds = CorrUsedTrNumbers < 5;
    if ~sum(FewTrNumInds)
        UsedOctaveData = CorrTunningFun;
    else  % in case of few correct trials available, NM data will be replaced for correct datas
        UsedOctaveData = CorrTunningFun;
        AdditionalData = NonMissTunningFun(FewTrNumInds,:);
        UsedOctaveData(FewTrNumInds,:) = AdditionalData;
    end
%     UsedOctaveData = NonMissTunningFun;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    TaskMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end
    modeFreqInds = TaskMaxOct == mode(TaskMaxOct);
    TaskModeInds = [mode(TaskMaxOct),mean(TaskMaxOct),BehavBoundData];
    TaskMaxAmp = MaxAmp;
    
    save TaskPassBFDis.mat  TaskMaxOct PassMaxOct BehavBoundData TaskMaxAmp PassMaxAmp -v7.3
%     [TaskClusterInterMean,TaskRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix,modeFreqInds,'Rand');
%     saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution');
%     saveas(hhf,'Task Rand_vs_intermodeROIs distance ratio distribution','png');
%     close(hhf);
    
%     PreferRandDisSum{m,3} = TaskClusterInterMean;
%     PreferRandDisSum{m,4} = TaskRandMean;
    
    AllTaskMaxOcts = TaskMaxOct;
    TaskFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [TaskFreqStrs(1:BoundFreqIndex-1);'BehavBound';TaskFreqStrs(BoundFreqIndex:end)];
    PercentileNum = 0;
    %
    for cPrc = 1 : length(PercentileNum)
        %
        cPrcvalue = PercentileNum(cPrc);
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        AllMasks = ROIinfoData.ROImask(cROIinds);
        TaskMaxOct = AllTaskMaxOcts(cROIinds);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * TaskMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * TaskMaxOct(cROI);
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
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
%         title(sprintf('Prc%d map',cPrcvalue));
         h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(TaskMaxOct);
        MeanPopuOcts = mean(TaskMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
         LineStartPosMean = [hBar.Position(1)+hBar.Position(3),(MeanPopuOcts-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)]; 
         
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        MeanArrowx = [LineStartPosMean(1) + 0.03,LineStartPosMean(1)];
        MeanWrrowy = [LineStartPosMean(2),LineStartPosMean(2)];
        
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
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
            annotation('arrow',MeanArrowx,MeanWrrowy,'Color','m');
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
        colormap(CusMap)
%
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    end
    TaskROITunedOctave = AllTaskMaxOcts;
    TaskOctaves = UsedOctave;
    %
%     Octaves = unique(TaskMaxOct);
    TaskOctaveTypeNum = zeros(length(UsedOctave),1);
    for n = 1 : length(UsedOctave)
        TaskOctaveTypeNum(n) = sum(AllTaskMaxOcts == UsedOctave(n));
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
    hf = figure('position',[3000 300 400 300]);
%     yyaxis left
    hold on
%     ll1 = plot(PassOctaves,PassOctaveTypeNum,'k-*','linewidth',1.8,'MarkerSize',10);
%     ll2 = plot(TaskOctaves,TaskOctaveTypeNum,'r-o','linewidth',1.8,'MarkerSize',10);
    bb1 = bar(PassOctaves-0.08,PassOctaveTypeNum,0.4,'EdgeColor','none','FaceColor',[.7 .7 .7]);
    bb2 = bar(TaskOctaves+0.08,TaskOctaveTypeNum,0.4,'EdgeColor','none','FaceColor',[1 .7 .2]);
    ylabel('Cell Count');

%     yyaxis right
%     ll3 = plot(TaskOctaves,Uncertainty,'m-o','linewidth',1.8,'MarkerSize',10);
%     set(gca,'xtick',TaskOctaves,'xticklabel',TaskFreqStrs);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'linewidth',2.1,'Color',BoundaryColor,'Linestyle','--');
    text(BehavBoundData,yscales(1)+diff(yscales*0.95),'BehavBound','Color','g','FontSize',10,'HorizontalAlignment','center');
    set(gca,'ylim',yscales,'xlim',[-1.5 1.5]);
%     ylabel('Uncertainty level');
    xlabel('Frequency (kHz)');

    title('Tuned Inds vs uncertainty');
    set(gca,'FontSize',16);
    if BehavBoundData < 0
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northeast','FontSize',8);
        legend([bb1,bb2],{'Passive','Task'},'Location','Northeast','FontSize',8);
    else
%         legend([ll1,ll2,ll3],{'Passive','Task','Uncertainty'},'Location','Northwest','FontSize',8);
        legend([bb1,bb2],{'Passive','Task'},'Location','Northwest','FontSize',8);
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
    
    