% plot the colormap plot according to different cell types
% three neuron types will be considered, 
% categorical neuron, tuning neurons, no significantly selective neurons
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the session path save file');
if ~fi
    return;
end

%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
%
nSess = 1;
SessBehavBoundModeOctave = [];
SessROItypeFrac = [];  % CategFrac.  TuningFrac.  NoSelectiveFrac.  NonRespFrac. TotalROInumber
SessColDescription = {'CategFrac','TuningFrac','NoSelectiveFrac','NonRespFrac','TotalROInumber'};
SessBehavAll = {};
SessDataStrcAll = {};
cMap = blue2red_2(100,0.9);
PreferC = [0 0.5 0.1];
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    % passive tuning frequency colormap plot
    TunDataAllStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
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
    SessBehavAll{nSess} = BehavCorr;
    
    GrNum = floor(length(BehavCorr)/2);
    BehavPsycho = BehavCorr;
    BehavPsycho(1:GrNum) = 1 - BehavPsycho(1:GrNum);
    BehavStims = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
    ROIcenters = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenters);
    DisMatrix = squareform(ROIdistance);

    ROITypeDatafile = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    IIsResponsiveROI = logical(ROITypeDataStrc.ROIisResponsive);
    SessROItypeFrac(nSess,:) = [sum(CategROIInds),sum(TunedROIInds),sum(IIsResponsiveROI) - sum(CategROIInds) - sum(TunedROIInds),...
        sum(~IIsResponsiveROI),length(CategROIInds)];
    if ~isdir('CellType CP plot mean')
        mkdir('CellType CP plot mean');
    end
    cd('CellType CP plot mean');
    
    % plot the tuning ROI tuning peak color plot
    PassUsedOctavesInds = ~(abs(TunDataAllStrc.PassFreqOctave) > 1);
    PassUsedOctaves = TunDataAllStrc.PassFreqOctave(PassUsedOctavesInds);
    PassUsedOctaves = PassUsedOctaves(:);
    PassUsedOctData = TunDataAllStrc.PassTunningfun(PassUsedOctavesInds,:);
    nTotalROIs = size(PassUsedOctData,2);
    [MaxAmp,MaxInds] = max(PassUsedOctData);
    MaxIndsOctave = zeros(nTotalROIs,1);
    for n = 1 : nTotalROIs
        MaxIndsOctave(n) = PassUsedOctaves(MaxInds(n));
    end
    
    cTunedROIinds = TunedROIInds;
    TunedROImask = ROIinfoData.ROImask(cTunedROIinds);
    TunedROIOctaves = MaxIndsOctave(cTunedROIinds);
    PassOctaves = TunedROIOctaves;
    cTunedROIs = length(TunedROImask);
    
    SumROImask = double(TunedROImask{1});
    SumROIcolormask = SumROImask * TunedROIOctaves(1);
    for cROI = 2 : cTunedROIs
        cROINewMask = double(TunedROImask{cROI});
        TempSumMask = SumROImask + cROINewMask;
        OverLapInds = find(TempSumMask > 1);
        if ~isempty(OverLapInds)
            cROINewMask(OverLapInds) = 0;
        end
        SumROImask = double(TempSumMask > 0);
        SumROIcolormask = SumROIcolormask + cROINewMask * TunedROIOctaves(cROI);
    end
%
    hColor = figure('position',[300 100 530 450]);
    ha = axes;
    h_im = imagesc(SumROIcolormask,[-1 1]);
    set(h_im,'AlphaData',SumROImask>0);
    set(gca,'box','off');
    axis off
    hBar = colorbar('westoutside');
    set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.15 0 0],'TickLength',0);
    set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
    title(hBar,'kHz')
    title('Passive Tuned ROIs');
    h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
    hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
%     ModeTunedOctaves = mode(TunedROIOctaves);
%     cPassOctave = [ModeTunedOctaves,mean(TunedROIOctaves)];
    ModeTunedOctaves = mode(TunedROIOctaves);
    cPassOctave = [ModeTunedOctaves,mean(TunedROIOctaves)];
    h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', PreferC, 'parent', h_axes,'LineWidth',4);
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
        annotation('arrow',ModeArrowx,ModeArrowy,'Color',PreferC,'Linewidth',2);
        annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
            'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
        annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
            'Color',PreferC,'HorizontalAlignment','left','VerticalAlignment','middle');
    else
        TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
        TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
        annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
        annotation('arrow',ModeArrowx,ModeArrowy,'Color',PreferC,'Linewidth',2);
        annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
            'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
        annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
            'Color',PreferC,'HorizontalAlignment','left','VerticalAlignment','middle');
    end
    set(ha,'position',get(ha,'position')+[0.1 0 0 0]);
    set(gca,'FontSize',15);
    colormap(cMap);
%
    saveas(hColor,'Passive Tuned ROIs colormap save');
    saveas(hColor,'Passive Tuned ROIs colormap save','png');
    close(hColor);
    
    % plot the task data tuning colormap
    TaskUsedOctaves = TunDataAllStrc.TaskFreqOctave(:);
    TaskUsedData = TunDataAllStrc.CorrTunningFun;
    TotalROIs = size(TaskUsedData,2);
    [MaxAmp,MaxInds] = max(TaskUsedData);
    TaskMaxOctaves = zeros(TotalROIs,1);
    for n = 1 : TotalROIs
        TaskMaxOctaves(n) = TaskUsedOctaves(MaxInds(n));
    end
    TunedROIOctaves = TaskMaxOctaves(TunedROIInds);
    TaskOctaves = TunedROIOctaves;
    TunedROIindex = find(cTunedROIinds);  % real index value for each ROI
    % try to distinguish boundary tuning data and sensory tuning data
    % define within 0.2 Octave Tuning peak as boundary tuning ROIs
    BoundTunROIinds = TunedROIindex(abs(TaskOctaves - BehavBoundData) < 0.2);
    BoundTunROIindsConst = TunedROIindex(abs(TaskOctaves - BehavBoundData) < 0.1);
    PassMaxOct = MaxIndsOctave;
    
    save TuningTypeIndexSave.mat CategROIInds  TunedROIInds  IIsResponsiveROI PassMaxOct TaskMaxOctaves  BoundTunROIinds BoundTunROIindsConst -v7.3
    
    TunedROImask = ROIinfoData.ROImask(TunedROIInds);
    cTunedROIs = length(TunedROImask);
    SumROImask = double(TunedROImask{1});
    SumROIcolormask = SumROImask * TunedROIOctaves(1);
    for cROI = 2 : cTunedROIs
        cROINewMask = double(TunedROImask{cROI});
        TempSumMask = SumROImask + cROINewMask;
        OverLapInds = find(TempSumMask > 1);
        if ~isempty(OverLapInds)
            cROINewMask(OverLapInds) = 0;
        end
        SumROImask = double(TempSumMask > 0);
        SumROIcolormask = SumROIcolormask + cROINewMask * TunedROIOctaves(cROI);
    end
    % %
    hColor = figure('position',[300 100 530 450]);
    ha = axes;
    h_im = imagesc(SumROIcolormask,[-1 1]);
    set(h_im,'AlphaData',SumROImask>0);
    set(gca,'box','off');
    axis off
    hBar = colorbar('westoutside');
    set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.15 0 0],'TickLength',0);
    set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
    title(hBar,'kHz')
    title('Task Tuned ROIs');
    h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
    hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
%     ModeTunedOctaves = mode(TunedROIOctaves);
%     cTaskOctave = [ModeTunedOctaves,mean(TunedROIOctaves)];
    ModeTunedOctaves = mode(TunedROIOctaves);
    cTaskOctave = [ModeTunedOctaves,mean(TunedROIOctaves)];
    h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', PreferC, 'parent', h_axes,'LineWidth',4);
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
        annotation('arrow',ModeArrowx,ModeArrowy,'Color',PreferC,'Linewidth',2);
        annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
            'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
        annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
            'Color',PreferC,'HorizontalAlignment','left','VerticalAlignment','middle');
    else
        TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
        TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
        annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
        annotation('arrow',ModeArrowx,ModeArrowy,'Color',PreferC,'Linewidth',2);
        annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
            'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
        annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
            'Color',PreferC,'HorizontalAlignment','left','VerticalAlignment','middle');
    end
    set(ha,'position',get(ha,'position')+[0.1 0 0 0]);
    set(gca,'FontSize',15)
    colormap(cMap);
%
    saveas(hColor,'Task Tuned ROIs colormap save');
    saveas(hColor,'Task Tuned ROIs colormap save','png');
    close(hColor);
    
    SessBehavBoundModeOctave(nSess,:) = [BehavBoundData,cPassOctave,cTaskOctave,mean(TaskOctaves - PassOctaves)];
    
    % categorical ROI plots, calculate the CI and prefered direction
    if sum(CategROIInds)
        nCategROIs = sum(CategROIInds);
        TaskCategData = TaskUsedData(:,CategROIInds);
        PassCategData = PassUsedOctData(:,CategROIInds);
        GrNum = floor(length(TaskUsedOctaves)/2);
        ROICIs = zeros(nCategROIs,1);
        CategRPreferData = zeros(size(TaskCategData));
        PassCategPreferD = zeros(size(PassCategData));
        for cNumROI = 1 : nCategROIs
            cROIdata = TaskCategData(:,cNumROI);
            HighGroupData = mean(cROIdata(end-GrNum+1:end));
            LowGroupData = mean(cROIdata(1:GrNum));
            if min(LowGroupData,HighGroupData) < 0
                ABSCI = 1;
            else
                ABSCI = abs((HighGroupData - LowGroupData)/(HighGroupData + LowGroupData));
            end
            cPassData = PassCategData(:,cNumROI);
            if LowGroupData > HighGroupData
                ROICIs(cNumROI) = 1-ABSCI;
                CategRPreferData(:,cNumROI) = flipud(cROIdata);
                PassCategPreferD(:,cNumROI) = flipud(cPassData);
            else
                ROICIs(cNumROI) = ABSCI;
                CategRPreferData(:,cNumROI) = cROIdata;
                PassCategPreferD(:,cNumROI) = cPassData;
            end
        end
        CategROImask = ROIinfoData.ROImask(CategROIInds);
%         TunedROIOctaves = TaskMaxOctaves(CategROIInds);
        cTunedROIs = length(CategROImask);

        SumROImask = double(CategROImask{1});
        SumROIcolormask = SumROImask * ROICIs(1);
        for cROI = 2 : cTunedROIs
            cROINewMask = double(CategROImask{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * ROICIs(cROI);
        end
        
%         CusMap = ([linspace(0,1,64);zeros(1,64);linspace(1,0,64)])';
        hColor = figure('position',[300 100 530 450]);
        ha = axes;
        h_im = imagesc(SumROIcolormask,[0 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.15 0 0],'TickLength',0);
        set(hBar,'ytick',[0 1],'yticklabel',{'Left','Right'});
%         title(hBar,'kHz')
        title(hBar,{'Category','Preference'});
        title('Categorical ROIs');
        set(gca,'FontSize',15)
        set(ha,'position',get(ha,'position')+[0.1 0 0 0]);
        colormap(cMap);
%
        saveas(hColor,'Categorical ROIs CI Colormap plot');
        saveas(hColor,'Categorical ROIs CI Colormap plot','png');
        close(hColor);
    else
        warning('No categorical ROI exists within current session.\n');
    end
    %
    % No Significantly selective ROIs maxium value tuning octaves
    SigNonSelective = ~CategROIInds & ~TunedROIInds & IIsResponsiveROI;
    if sum(SigNonSelective)
        %
        NonSigSelectiveMask = ROIinfoData.ROImask(SigNonSelective);
        NonSigSelectROIOct = TaskMaxOctaves(SigNonSelective);
        cTunedROIs = length(NonSigSelectiveMask);

        SumROImask = double(NonSigSelectiveMask{1});
        SumROIcolormask = SumROImask * NonSigSelectROIOct(1);
        for cROI = 2 : cTunedROIs
            cROINewMask = double(NonSigSelectiveMask{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * NonSigSelectROIOct(cROI);
        end
        
%         CusMap = ([linspace(0,1,64);zeros(1,64);linspace(1,0,64)])';
        hColor = figure('position',[300 100 530 450]);
        ha = axes;
        h_im = imagesc(SumROIcolormask,[-1 1]);
        set(h_im,'AlphaData',SumROImask>0);
        set(gca,'box','off');
        axis off
        hBar = colorbar('westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.1 0.15 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
%         title(hBar,'kHz')
        title(hBar,'kHz');
        title('No selectivity ROIs maxium response');
        set(gca,'FontSize',15)
        set(ha,'position',get(ha,'position')+[0.1 0 0 0]);
        colormap(cMap);
%         colormap(CusMap);
        saveas(hColor,'NonSig selective ROIs Colormap plot');
        saveas(hColor,'NonSig selective ROIs Colormap plot','png');
        close(hColor);
    end
    
    % #####################################################################
%     TunROIIndsAll = find(cTunedROIinds);
%     TunROIOctAll = TaskMaxOctaves(TunROIIndsAll);
%     PreferROIinds = TunROIIndsAll(TunROIOctAll == mode(TunROIOctAll));
%     
%     TunMtxData = DisMatrix(PreferROIinds,PreferROIinds);  % prefered octave tuning ROIs
%     TunedROIDisVec = TunMtxData(logical(tril(ones(size(TunMtxData)),-1)));
%     OtherTuningROIs = cTunedROIinds;
%     OtherTuningROIs(PreferROIinds) = false;
%     TunedWithOtherTunData = DisMatrix(PreferROIinds,OtherTuningROIs);
%     TunedWithOtherTunVec = TunedWithOtherTunData(:);
%     TunedWithNoTunData = reshape(DisMatrix(PreferROIinds,~cTunedROIinds),[],1);
%     OtherTunWithNoTun = reshape(DisMatrix(OtherTuningROIs,~cTunedROIinds),[],1);
%     GrData = {TunedROIDisVec,TunedWithOtherTunVec,TunedWithNoTunData,OtherTunWithNoTun};
%     hf = GrdistPlot(GrData,{'PreTunSelf','PTuneOtherT','PTNoTun','OtherTNoTun'});
    
    % session categorical ROI summary plot
    CategMaxMtx = repmat(max(CategRPreferData),size(CategRPreferData,1),1);
    PassCategMaxMtx = repmat(max(PassCategPreferD),size(PassCategPreferD,1),1);
    MaxNorMtxData = CategRPreferData./CategMaxMtx;
    MaxNorSEMData = std(MaxNorMtxData,[],2)/sqrt(size(MaxNorMtxData,2));
    PassMaxNorMtxData = PassCategPreferD./PassCategMaxMtx;
    PassMaxNorDataSEM = std(PassMaxNorMtxData,[],2)/sqrt(size(PassMaxNorMtxData,2));
    TaskFreqStr = cellstr(num2str(floor(16*(2.^(TaskUsedOctaves(:)))),'%.1f'));
    
    hf = figure('position',[3000 100 450 400]);
    hold on
    plot(TaskUsedOctaves,MaxNorMtxData,'color',[0.9 0.7 0.7],'Linewidth',0.8);
    plot(PassUsedOctaves,PassMaxNorMtxData,'color',[.7 .7 .7],'Linewidth',0.8,'linestyle','--');
    ll1 = plot(TaskUsedOctaves,mean(MaxNorMtxData,2),'Color','r','Linewidth',1.8);
    ll2 = plot(BehavStims,BehavPsycho,'Color',[0.2 0.2 0.8],'Linewidth',1.8);
    ll3 = plot(PassUsedOctaves,mean(PassMaxNorMtxData,2),'Color','k','Linewidth',1.8,'linestyle','--');
    set(gca,'xlim',[-1 1],'ylim',[0 1],'xtick',TaskUsedOctaves,'xticklabel',TaskFreqStr,...
        'ytick',[0 0.5 1]);
    xlabel('Frequency (kHz)');
    ylabel('Response (Nor.)');
    title('Popu. Categorical ROIs')
    set(gca,'FontSize',18);
    legend([ll1,ll2,ll3],{'Task','Behavior','Pass'},'FontSize',10,'Location','northwest');
%     legend([ll1,ll2],{'Task','Behavior'},'FontSize',10,'Location','northwest');
    legend('boxoff');
    %
    saveas(hf,'Categprical ROIs NorMean trace plot');
    saveas(hf,'Categprical ROIs NorMean trace plot','png');
    close(hf);
    % #####################################################################
    % without passive data
    hf = figure('position',[3000 100 450 400]);
    hold on
    plot(TaskUsedOctaves,MaxNorMtxData,'color',[0.9 0.7 0.7],'Linewidth',0.8);
%     plot(PassUsedOctaves,PassMaxNorMtxData,'color',[.7 .7 .7],'Linewidth',0.8,'linestyle','--');
    ll1 = plot(TaskUsedOctaves,mean(MaxNorMtxData,2),'Color','r','Linewidth',1.8);
    ll2 = plot(BehavStims,BehavPsycho,'Color',[0.2 0.2 0.8],'Linewidth',1.8);
%     ll3 = plot(PassUsedOctaves,mean(PassMaxNorMtxData,2),'Color','k','Linewidth',1.8,'linestyle','--');
    set(gca,'xlim',[-1 1],'ylim',[0 1],'xtick',TaskUsedOctaves,'xticklabel',TaskFreqStr,...
        'ytick',[0 0.5 1]);
    xlabel('Frequency (kHz)');
    ylabel('Response (Nor.)');
    title('Popu. Categorical ROIs')
    set(gca,'FontSize',18);
%     legend([ll1,ll2,ll3],{'Task','Behavior','Pass'},'FontSize',10,'Location','northwest');
    legend([ll1,ll2],{'Task','Behavior'},'FontSize',10,'Location','northwest');
    legend('boxoff');
    %
    saveas(hf,'Categprical ROIs NorMean trace plot without pass');
    saveas(hf,'Categprical ROIs NorMean trace plot without pass','png');
    close(hf);
    
    % Aligned tuning ROIs response to behavior boundary
    % for task and passive session, plot together
    PassTunedData = PassUsedOctData(:,TunedROIInds);
    PassTunedDataNor = (zscore(PassTunedData))'; % nROIs by nOctaves
    TaskTunedData = TaskUsedData(:,TunedROIInds);
    TaskTunedDataNor = (zscore(TaskTunedData))'; % nROIs by nOctaves
    PassOctave2Bound = PassUsedOctaves - BehavBoundData;
    TaskOctave2Bound = TaskUsedOctaves - BehavBoundData;
    PassSEM = std(PassTunedDataNor)/sqrt(size(PassTunedDataNor,1));
    TaskSEM = std(TaskTunedDataNor)/sqrt(size(TaskTunedDataNor,1));
    
    hAlignf = figure('position',[200 200 450 400]);
    hold on
    l1 = errorbar(PassOctave2Bound,mean(PassTunedDataNor),PassSEM,'k-o','linewidth',2);
    l2 = errorbar(TaskOctave2Bound,mean(TaskTunedDataNor),TaskSEM,'r-o','linewidth',2);
    yscales = get(gca,'ylim');
    line([0 0],yscales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
    set(gca,'xlim',[min(PassOctave2Bound(1),TaskOctave2Bound(1)),...
        max(PassOctave2Bound(end),TaskOctave2Bound(end))]+[-0.1 0.1],'ylim',yscales);
    xlabel('Octave from Boundary');
    ylabel('Response (Nor.)')
    set(gca,'FontSize',16);
    legend([l1,l2],{'Passive','Task'},'Location','NorthWest','FontSize',10);
    legend('boxoff');
    %
    saveas(hAlignf,'Task passive aligned to Boundary population response');
    saveas(hAlignf,'Task passive aligned to Boundary population response','png');
    close(hAlignf);
    
    %
    save cellTypeDataSave.mat CategRPreferData BehavBoundData TunedROIInds PassUsedOctaves ...
        PassUsedOctData TaskUsedOctaves TaskUsedData CategROIInds IIsResponsiveROI -v7.3
    %
    SessDataStrc.BehavBound = BehavBoundData;
    SessDataStrc.PassOct = PassUsedOctaves;
    SessDataStrc.TaskOct = TaskUsedOctaves;
    SessDataStrc.TunROITaskdata = TaskTunedData ;
    SessDataStrc.TunROIPassdata = PassTunedData;
    SessDataStrc.CategROITaskData = CategRPreferData;
    SessDataStrc.CategROIPassData = PassCategPreferD;
    SessDataStrcAll{nSess} = SessDataStrc;
    
    tline = fgetl(fid);
    nSess = nSess + 1;
end

%%
cd('E:\DataToGo\data_for_xu\SingleCell_RespType_summary');
save SummarizedTypeFracNew.mat SessROItypeFrac SessBehavBoundModeOctave SessColDescription SessBehavAll SessDataStrcAll -v7.3
%%
clearvars -except fn fp SessROItypeFrac SessBehavAll
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSession = 1;
m = 1;
SessData = {};
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
%     DatPath = fullfile(tline,'Tunning_fun_plot_New1s','CellType colormap plot');
    DatPath = fullfile(tline,'Tunning_fun_plot_New1s','CellType CP plot mean');
    Anminfo = SessInfoExtraction(tline);
    TasktunColorMapf = fullfile(DatPath,'Task Tuned ROIs colormap save.png');
    PasstunColorMapf = fullfile(DatPath,'Passive Tuned ROIs colormap save.png');
    TaskCategColorf = fullfile(DatPath,'Categorical ROIs CI Colormap plot.png');
    
    TaskCategMeanf = fullfile(DatPath,'Categprical ROIs NorMean trace plot.png');
    PassCategMeanf = fullfile(DatPath,'Categprical ROIs NorMean trace plot without pass.png');
    NoSelectColorMf = fullfile(DatPath,'NonSig selective ROIs Colormap plot.png');
    TunedTaskPassMean = fullfile(DatPath,'Task passive aligned to Boundary population response.png');
    
    FitTunBoundMf = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','Tuning ROI TunedPeak index distribution.png');
    if m == 1
        PPTname = 'CellType_CP_sum_modeBound_NewMap'; 
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        pptSavePath = 'F:\TestOutputSave';
    end
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
    cSessTypeNum = SessROItypeFrac(nSession,:);
    RespROInum = sum(cSessTypeNum(1:3));
    
    exportToPPTX('addslide');
    exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
    exportToPPTX('addnote',tline);
    exportToPPTX('addpicture',imread(TasktunColorMapf),'Position',[0.3 1 4.12 3.5]);
    exportToPPTX('addtext','Task','Position',[2 4.5 2 0.5],...
        'FontSize',20,'Color','r');
    exportToPPTX('addpicture',imread(PasstunColorMapf),'Position',[0.3 5 4.12 3.5]);
    exportToPPTX('addtext','Passive','Position',[2 8.5 2 0.5],'FontSize',20);
    exportToPPTX('addpicture',imread(TaskCategColorf),'Position',[4.5 1 3.8 3.23]);
    exportToPPTX('addpicture',imread(TaskCategMeanf),'Position',[4.5 4 3.95 3.5]);
    exportToPPTX('addpicture',imread(PassCategMeanf),'Position',[8.5 4 3.5 3.5]);
    exportToPPTX('addtext',sprintf('%d/%d = %.3f',cSessTypeNum(1),RespROInum,cSessTypeNum(1)/RespROInum),...
        'Position',[5.2 7.8 3 1.2],'FontSize',20);
    exportToPPTX('addpicture',imread(NoSelectColorMf),'Position',[8.5 0.8 3.5 3]);
    exportToPPTX('addpicture',imread(FitTunBoundMf),'Position',[12.3 0 3.5 4.2]);
    exportToPPTX('addpicture',imread(TunedTaskPassMean),'Position',[12 4.5 3.5 3.1]);
    exportToPPTX('addtext',sprintf('%d/%d = %.3f',cSessTypeNum(2),RespROInum,cSessTypeNum(2)/RespROInum),...
        'Position',[14 8 2 1],'FontSize',20);
    exportToPPTX('addtext',sprintf('Batch:%s  Anm: %s\r\nDate: %s  Field: %s',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[8 8 5 1],'FontSize',22);
    
    m = m + 1;
    nSession = nSession + 1;
    saveName = exportToPPTX('saveandclose',pptFullfile);
    tline = fgetl(fid);
end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
    
    %%
%     % session categorical ROI summary plot
%     CategMaxMtx = repmat(max(CategRPreferData),size(CategRPreferData,1),1);
%     PassCategMaxMtx = repmat(max(PassCategPreferD),size(PassCategPreferD,1),1);
%     MaxNorMtxData = CategRPreferData./CategMaxMtx;
%     MaxNorSEMData = std(MaxNorMtxData,[],2)/sqrt(size(MaxNorMtxData,2));
%     PassMaxNorMtxData = PassCategPreferD./PassCategMaxMtx;
%     PassMaxNorDataSEM = std(PassMaxNorMtxData,[],2)/sqrt(size(PassMaxNorMtxData,2));
%     
%     TaskFreqStr = cellstr(num2str(floor(16*(2.^(TaskUsedOctaves(:)))),'%.1f'));
%     
%     hf = figure('position',[3000 100 450 400]);
%     hold on
% %     plot(TaskUsedOctaves,MaxNorMtxData,'color',[0.9 0.7 0.7],'Linewidth',0.8);
% %     plot(PassUsedOctaves,PassMaxNorMtxData,'color',[.7 .7 .7],'Linewidth',0.8,'linestyle','--');
%     ll1 = errorbar(TaskUsedOctaves,mean(MaxNorMtxData,2),MaxNorSEMData,'Color','r','Linewidth',1.8);
% %     ll2 = plot(BehavStims,BehavPsycho,'Color',[0.2 0.2 0.8],'Linewidth',1.8);
%     ll3 = errorbar(PassUsedOctaves,mean(PassMaxNorMtxData,2),PassMaxNorDataSEM,'Color','k','Linewidth',1.8,'linestyle','-');
%     set(gca,'xlim',[-1 1],'ylim',[0 1],'xtick',TaskUsedOctaves,'xticklabel',TaskFreqStr,...
%         'ytick',[0 0.5 1]);
%     xlabel('Frequency (kHz)');
%     ylabel('Response (Nor.)');
%     title('Popu. Categorical ROIs')
%     set(gca,'FontSize',18);
% %     legend([ll1,ll2,ll3],{'Task','Behavior','Pass'},'FontSize',10,'Location','northwest');
%     legend([ll1,ll3],{'Task','Pass'},'FontSize',10,'Location','northwest');
%     legend('boxoff');
%     
%      saveas(hf,'Categprical ROIs NorMean trace errorbar plot withoutbehav');
%      saveas(hf,'Categprical ROIs NorMean trace errorbar plot withoutbehav','png');

%% ROI type fraction plot

% plot the categorical ROI fraction across session
hf = figure('position',[100 100 380 310]);
hold on
[CategCout,CategCent] = hist(CategFrac);
FracSEM = std(CategFrac)/sqrt(numel(CategFrac));
bar(CategCent,CategCout,0.8,'EdgeColor','none','FaceColor',[.8 .8 .8]);
yscales = get(gca,'ylim');
line([mean(CategFrac) mean(CategFrac)],yscales+[0 1],'Color',[0.2 0.7 0.3],'linewidth',1.6,'linestyle','--');
line([-1,1]*FracSEM+mean(CategFrac),[max(CategCout)+0.5,max(CategCout)+0.5],'linewidth',2.4,'Color','k');
xlabel('Frac.');
ylabel('# Session');
title('Categ ROI fraction');
set(gca,'FontSize',14);
text(mean(CategFrac)+0.02,yscales(2)*0.9,sprintf('%.4f',mean(CategFrac)),'Color',[0.2 0.7 0.3]);

saveas(hf,'Session Categorical ROI fraction');
saveas(hf,'Session Categorical ROI fraction','png');
saveas(hf,'Session Categorical ROI fraction','pdf');

% plot the categorical ROI fraction across session
hf = figure('position',[500 100 380 310]);
hold on
[TunCout,TunCent] = hist(TunFrac);
FracSEM = std(TunFrac)/sqrt(numel(TunFrac));
bar(TunCent,TunCout,0.8,'EdgeColor','none','FaceColor',[.8 .8 .8]);
yscales = get(gca,'ylim');
line([mean(TunFrac) mean(TunFrac)],yscales+[0 1],'Color',[0.2 0.7 0.3],'linewidth',1.6,'linestyle','--');
line([-1,1]*FracSEM+mean(TunFrac),[max(TunCout)+0.5,max(TunCout)+0.5],'linewidth',2.4,'Color','k');
xlabel('Frac.');
ylabel('# Session');
title('Tuned ROI fraction');
set(gca,'FontSize',14);
text(mean(TunFrac)+0.02,yscales(2)*0.9,sprintf('%.4f',mean(TunFrac)),'Color',[0.2 0.7 0.3]);

saveas(hf,'Session Tuning ROI fraction');
saveas(hf,'Session Tuning ROI fraction','png');
saveas(hf,'Session Tuning ROI fraction','pdf');

