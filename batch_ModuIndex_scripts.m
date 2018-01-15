clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
 
%%  old method, not used any more
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
%     if exist('./ModuIndex_plot/ModuIndex PopuMean plot.png','file')
%         tline = fgetl(fid);
%         continue;
%     end
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    
    PassUsedOctInds = ~(abs(PassFreqOctave) > 1);
    PassUsedOctaves = PassFreqOctave(PassUsedOctInds);
    PassUsedData = PassTunningfun(PassUsedOctInds,:);
    PassUsedOctaves = PassUsedOctaves(:);
    TaskFreqOctave = TaskFreqOctave(:);

    if length(PassUsedOctaves) == length(TaskFreqOctave)
        if sum(abs(PassUsedOctaves - TaskFreqOctave)) > 0.1
            warning('The passive Octave is not very close to the task octaves');
        end
    else
        warning('Unequal length of octaves used at task and passive session');
        if (length(TaskFreqOctave) > length(PassUsedOctaves)) && mod(length(TaskFreqOctave),2)
            TaskExcludInds = ceil(length(TaskFreqOctave)/2);
            TaskFreqOctave(TaskExcludInds) = [];
            CorrTunningFun(TaskExcludInds,:) = [];
        else
            disp(PassUsedOctaves');
            UsedInds = input(['Please select ',num2str(length(TaskFreqOctave)),' octaves index:\n'],'s');
            if isempty(UsedInds)
                tline = fgetl(fid);
                continue;
            else
                UseInds = str2num(UsedInds);
                PassUsedOctaves = PassUsedOctaves(UseInds);
                PassUsedData = PassUsedData(UseInds,:);
            end
        end
    end
    %
    TaskStrs = cellstr(num2str((2.^TaskFreqOctave)*16,'%.1f'));
    nROIs = size(CorrTunningFun,2);
    NormModuIndexAll = zeros(size(CorrTunningFun));
    if ~isdir('./ModuIndex_plot/')
        mkdir('./ModuIndex_plot/');
    end
    cd('./ModuIndex_plot/');
    for cROI = 1 : nROIs
        %
        cROIPassData = PassUsedData(:,cROI);
        cROITaskData = CorrTunningFun(:,cROI);
        Minvalue = min(min(cROIPassData),min(cROITaskData));
        if Minvalue < 0
            BaseShift = Minvalue*(-1);
        else
            BaseShift = 0;
        end
        PassDataShift = cROIPassData + BaseShift;
        TaskDataShift = cROITaskData + BaseShift;
        if max(max(cROIPassData),max(cROITaskData)) < 20
            UpperThres = 20;
        else
            UpperThres = max(max(cROIPassData),max(cROITaskData))+BaseShift;
        end
        %
        NormModuIndex = ((PassDataShift - TaskDataShift)./(PassDataShift + TaskDataShift))...
            .*(max([PassDataShift,TaskDataShift],[],2)/UpperThres)*(-1);
        NormModuIndexAll(:,cROI) = NormModuIndex;
        %
%         hf = figure('position',[3000 200 380 300]);
% 
%         yyaxis left 
%         hold on
%         plot(PassUsedOctaves,PassDataShift,'k','Linewidth',2);
%         plot(TaskFreqOctave,TaskDataShift,'r','Linewidth',2,'linestyle','-');
%         yscales = get(gca,'ylim');
%         line([BehavBoundData BehavBoundData],yscales,'Color',[0 0.5 0],'linewidth',2,'linestyle','--');
%         set(gca,'yColor','k');
%         ylabel('\DeltaF/F_0');
%         set(gca,'FontSize',16);
% 
%         yyaxis right
%         plot(TaskFreqOctave,NormModuIndex,'b','Linewidth',2);
%         set(gca,'xtick',TaskFreqOctave,'xticklabel',TaskStrs);
%         ylabel('ModuIndex');
%         xlabel('Frequency (kHz)');
%         ylim([-1 1]);
%         set(gca,'yColor','b','ytick',[-1 -0.5 0 0.5 1]);
%         set(gca,'FontSize',16);
% 
%         saveas(hf,sprintf('ROI%d Modu Index plot save',cROI));
%         saveas(hf,sprintf('ROI%d Modu Index plot save',cROI),'png');
%         close(hf);
       %
    end

    %
    NormModuIndexAll = NormModuIndexAll';
    PopuModuIndexSEM = std(NormModuIndexAll)/sqrt(size(NormModuIndexAll,1));
%
    hf = figure('position',[100 100 450 380]);
    hold on
    errorbar(TaskFreqOctave',mean(NormModuIndexAll),PopuModuIndexSEM,'k-o','linewidth',2);
    yscales = get(gca,'ylim');
    line([BehavBoundData BehavBoundData],yscales,'Color',[0 0.5 0],'linewidth',2,'linestyle','--');
    set(gca,'xtick',TaskFreqOctave,'xticklabel',TaskStrs);
    xlabel('Frequency (kHz)');
    ylabel('Norm. ModuIndex');
    set(gca,'FontSize',18);
    %
    saveas(hf,'ModuIndex PopuMean plot');
    saveas(hf,'ModuIndex PopuMean plot','png');
    close(hf);
    
    save ModuIndexSave.mat NormModuIndexAll BehavBoundData -v7.3
    cd ..;
    
    tline = fgetl(fid);
end

%% New summarized calculation
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
nSess = 1;
SessModuIndex = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    if ~isdir('./Uncertainty_plot/')
        mkdir('./Uncertainty_plot/');
    end
    cd('./Uncertainty_plot/');
    %
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavStimulus = double(BehavBoundfile.boundary_result.StimType);
    BehavOctaves = log2(BehavStimulus/min(BehavStimulus));
    FitResult = BehavBoundfile.boundary_result.FitModelAll{1}{2};
    BehavFit = feval(FitResult.ffit,BehavOctaves);
    cUsedOctaves = BehavOctaves - 1;
    FitBound = BehavBoundfile.boundary_result.Boundary - 1;
%     UnvertaintyV = BehavFit;
%     UnvertaintyV(cUsedOctaves > FitBound) = 1 - UnvertaintyV(cUsedOctaves > FitBound);
    UnvertaintyV = abs(cUsedOctaves - FitBound);
    [DisValue,IndsDiff] = sort(UnvertaintyV); 
    TaskTunData = CorrTunningFun;
    PeakNorData = TaskTunData./repmat(max(abs(TaskTunData)),size(TaskTunData,1),1);
    %
    Colors = jet(length(IndsDiff)-1);
    hhf = figure('position',[3100 100 480 380]);
    hold on
    hl = [];
    PairedPAll = zeros(length(IndsDiff) - 1,1);
    LegStrs = cell(length(IndsDiff) - 1,1);
    for nDis = 2:length(IndsDiff);
        csHl = scatter(TaskTunData(IndsDiff(1),:),TaskTunData(IndsDiff(nDis),:),30,Colors(nDis-1,:),'o','Linewidth',1.5);
        hl = [hl,csHl];
        [~,pairedps] = ttest(TaskTunData(IndsDiff(1),:),TaskTunData(IndsDiff(nDis),:));
        PairedPAll(nDis - 1) = pairedps;
        LegStrs{nDis - 1} = sprintf('Dis%d-%d p = %.3e',1,nDis,pairedps);
        [~,lmFitData] = lmFunCalPlot(TaskTunData(IndsDiff(1),:),TaskTunData(IndsDiff(nDis),:),0);
        plot(lmFitData{1},lmFitData{2},'Color',Colors(nDis-1,:),'linewidth',1.6);
    end
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    CommonScales = [min(xscales(1),yscales(1)),max(max(xscales(2)),max(yscales(2)))];
    set(gca,'xlim',CommonScales,'ylim',CommonScales);
    xlabel('Nearest bound response');
    ylabel('Away from bound response');
    line(CommonScales,CommonScales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
    set(gca,'FontSize',12)
    legend(hl,LegStrs,'FontSize',6)
    legend('boxoff')
    
    saveas(hhf,'BoundDis response compare plot all');
    saveas(hhf,'BoundDis response compare plot all','png');
    close(hhf);
    %
    ROITypeDatafile = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    IIsResponsiveROI = logical(ROITypeDataStrc.ROIisResponsive);
    
    [DisSeq,DisSeqInds] = sort(UnvertaintyV);
    DisMtx = repmat(UnvertaintyV',1,size(TaskTunData,2));
    
    hf = figure('position',[400 320 980 730]);
    subplot(2,2,1);
    hold on
    % plot all ROI response value with uncertainty value, raw value
    plot(DisSeq,TaskTunData(DisSeqInds,:),'o','MarkerSize',6,'linewidth',0.6,'Color',[.8 .8 .8]);
    [MeanData,MeanCI] = MeanANDCIcalFun(TaskTunData(DisSeqInds,:)');
    errorbar(DisSeq+0.03,MeanData,MeanCI(:,1),MeanCI(:,2),'k-o','linewidth',1.6);
    [tbl,lmFitData] = lmFunCalPlot(DisMtx(:),TaskTunData(:),0);
    plot(lmFitData{1},lmFitData{2},'r','linewidth',1,'linestyle','--');
    yscales = get(gca,'ylim');
    text(1,yscales(2)*0.8,{sprintf('Slope = %.4f',tbl.Coefficients.Estimate(2)),...
        sprintf('P = %.3e',tbl.Coefficients.pValue(2))},'Color',[0.1 0.6 0.1]);
%     set(gca,'xlim',[-0.05,0.55],'xtick',0:0.1:0.5);
    xlabel('DistanceToBound');
    ylabel('\DeltaF/F_0 (%)');
    title('All ROIs');
    
    subplot(2,2,3)
    hold on
    % plot all ROI PeakNorm. response value with uncertainty value, raw value
    plot(DisSeq,PeakNorData(DisSeqInds,:),'o','MarkerSize',6,'linewidth',0.6,'Color',[.8 .8 .8]);
    cxDataMtx = repmat(DisSeq',1,size(PeakNorData,2));
    [NorMeanData,NorMeanCI] = MeanANDCIcalFun(PeakNorData(DisSeqInds,:)');
    errorbar(DisSeq+0.03,NorMeanData,NorMeanCI(:,1),NorMeanCI(:,2),'k-o','linewidth',1.6);
    [tbl,lmFitData] = lmFunCalPlot(cxDataMtx(:),reshape(PeakNorData(DisSeqInds,:),[],1),0);
    plot(lmFitData{1},lmFitData{2},'r','linewidth',1,'linestyle','--');
    yscales = get(gca,'ylim');
    text(1,yscales(2)*0.8,{sprintf('Slope = %.4f',tbl.Coefficients.Estimate(2)),...
        sprintf('P = %.3e',tbl.Coefficients.pValue(2))},'Color',[0.1 0.6 0.1]);
%     set(gca,'xlim',[-0.05,0.55],'xtick',0:0.1:0.5);
    xlabel('DistanceToBound');
    ylabel('Norm. \DeltaF/F_0 (%)');
    title('All ROIs');
    
    subplot(2,2,2)
    hold on
    % plot the tuning ROI raw response against uncertainty value
    plot(DisSeq,TaskTunData(DisSeqInds,TunedROIInds),'o','MarkerSize',6,'linewidth',0.6,'Color',[.8 .8 .8]);
    cxDataMtx = repmat(DisSeq',1,sum(TunedROIInds));
    [TunMeanData,TunMeanCI] = MeanANDCIcalFun(TaskTunData(DisSeqInds,TunedROIInds)');
    errorbar(DisSeq+0.03,TunMeanData,TunMeanCI(:,1),TunMeanCI(:,2),'k-o','linewidth',1.6);
    [tbl,lmFitData] = lmFunCalPlot(cxDataMtx(:),reshape(TaskTunData(DisSeqInds,TunedROIInds),[],1),0);
    plot(lmFitData{1},lmFitData{2},'r','linewidth',1,'linestyle','--');
    yscales = get(gca,'ylim');
    text(1,yscales(2)*0.8,{sprintf('Slope = %.4f',tbl.Coefficients.Estimate(2)),...
        sprintf('P = %.3e',tbl.Coefficients.pValue(2))},'Color',[0.1 0.6 0.1]);
%     set(gca,'xlim',[-0.05,0.55],'xtick',0:0.1:0.5);
    xlabel('DistanceToBound');
    ylabel('\DeltaF/F_0 (%)');
    title('Tuning ROIs');
    
    subplot(2,2,4)
    hold on
    % plot the tuning ROI peakNorm. response against uncertainty value
    plot(DisSeq,PeakNorData(DisSeqInds,TunedROIInds),'o','MarkerSize',6,'linewidth',0.6,'Color',[.8 .8 .8]);
    cxDataMtx = repmat(DisSeq',1,sum(TunedROIInds));
    [TunNorMeanData,TunNorMeanCI] = MeanANDCIcalFun(PeakNorData(DisSeqInds,TunedROIInds)');
    errorbar(DisSeq+0.03,TunNorMeanData,TunNorMeanCI(:,1),TunNorMeanCI(:,2),'k-o','linewidth',1.6);
    [tbl,lmFitData] = lmFunCalPlot(cxDataMtx(:),reshape(PeakNorData(DisSeqInds,TunedROIInds),[],1),0);
    plot(lmFitData{1},lmFitData{2},'r','linewidth',1,'linestyle','--');
    yscales = get(gca,'ylim');
    text(1,yscales(2)*0.8,{sprintf('Slope = %.4f',tbl.Coefficients.Estimate(2)),...
        sprintf('P = %.3e',tbl.Coefficients.pValue(2))},'Color',[0.1 0.6 0.1]);
%     set(gca,'xlim',[-0.05,0.55],'xtick',0:0.1:0.5);
    xlabel('DistanceToBound');
    ylabel('Norm. \DeltaF/F_0 (%)');
    title('Tuning ROIs');
    %
    saveas(hf,'ROI response against Distance level plot');
    saveas(hf,'ROI response against Distance level plot','png');
    close(hf);
    
    %
    PassUsedOctInds = ~(abs(PassFreqOctave) > 1);
    PassUsedOctaves = PassFreqOctave(PassUsedOctInds);
    PassUsedData = PassTunningfun(PassUsedOctInds,:);
    PassUsedOctaves = PassUsedOctaves(:);
    TaskFreqOctave = cUsedOctaves(:);

    if length(PassUsedOctaves) == length(TaskFreqOctave)
        if sum(abs(PassUsedOctaves - TaskFreqOctave)) > 0.1
            warning('The passive Octave is not very close to the task octaves');
        end
    else
        warning('Unequal length of octaves used at task and passive session');
        if (length(TaskFreqOctave) > length(PassUsedOctaves)) && mod(length(TaskFreqOctave),2)
            TaskExcludInds = ceil(length(TaskFreqOctave)/2);
            TaskFreqOctave(TaskExcludInds) = [];
            TaskTunData(TaskExcludInds,:) = [];
        else
            disp(PassUsedOctaves');
            disp(TaskFreqOctave');
            UsedInds = input(['Please select ',num2str(length(TaskFreqOctave)),' octaves index:\n'],'s');
            if isempty(UsedInds)
                tline = fgetl(fid);
                nSess = nSess + 1;
                continue;
            else
                UseInds = str2num(UsedInds);
                PassUsedOctaves = PassUsedOctaves(UseInds);
                PassUsedData = PassUsedData(UseInds,:);
            end
        end
    end
    [PassMaxResp,PassMaxRespInds] = max(PassUsedData);
    PassMaxTaskValue = zeros(size(PassMaxRespInds));
    PassMaxUncertainty = zeros(size(PassMaxRespInds));
    for croi = 1 : length(PassMaxRespInds)
        cPassData = PassUsedData(:,croi);
        cTaskData = TaskTunData(:,croi);
        if min(cPassData) < 0 || min(cTaskData) < 0
            cIncreaseLevel = min(min(cPassData),min(cTaskData))*(-1);
            PassMaxResp(croi) = PassMaxResp(croi) + cIncreaseLevel;
            PassMaxTaskValue(croi) = PassMaxTaskValue(croi) + cIncreaseLevel;
        else
            PassMaxTaskValue(croi) = cTaskData(PassMaxRespInds(croi));
        end
        PassMaxUncertainty(croi) = UnvertaintyV(PassMaxRespInds(croi));
    end
    %
    PassMaxModuIndex = (PassMaxTaskValue - PassMaxResp)./(PassMaxResp + PassMaxTaskValue);
    AbnormalInds = find(abs(PassMaxModuIndex) > 1);
    if ~isempty(AbnormalInds)
        return;
    end
    hmoduf = figure('position',[100 100 380 300]);
    hold on
    plot(PassMaxUncertainty,PassMaxModuIndex,'ko','linewidth',0.8)
    [tbl,lmFitData] = lmFunCalPlot(PassMaxUncertainty,PassMaxModuIndex,0);
    plot(lmFitData{1},lmFitData{2},'r','linewidth',1.6);
    yscales = get(gca,'ylim');
    text(1,yscales(2)-0.15,{sprintf('Slope = %.4f',tbl.Coefficients.Estimate(2)),...
        sprintf('P = %.3e',tbl.Coefficients.pValue(2))},'Color',[0.1 0.6 0.1]);
%     set(gca,'xlim',[-0.05,0.55],'xtick',0:0.1:0.5,'ylim',[-1 1.4]);
    xlabel('DistanceToBound');
    ylabel('ModuIndex');
    title({'Pos. = enhance','Neg. = supress'});
    set(gca,'FontSize',16);
    %
    saveas(hmoduf,'Distance against moduindex plot');
    saveas(hmoduf,'Distance against moduindex plot','png');
    close(hmoduf);
    %
    SessModuIndex{nSess,1} = PassMaxUncertainty;
    SessModuIndex{nSess,2} = PassMaxModuIndex;
    
    save ModuIndexData.mat PassMaxUncertainty PassMaxModuIndex -v7.3
    tline = fgetl(fid);
    nSess = nSess + 1;
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
            PPTname = 'Uncertainty_moduIndex';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'F:\TestOutputSave';
            %
        end
            Anminfo = SessInfoExtraction(tline);
            cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'Uncertainty_plot'];
            UncertaintyResp = fullfile(cTunDataPath,'ROI response against uncertainty level plot.png');
            UncertaintyModu = fullfile(cTunDataPath,'uncertainty against moduindex plot.png');
            RespCompareFile = fullfile(cTunDataPath,'BoundDis response compare plot all.png');
            if exist(UncertaintyModu,'file')
                IsModeLoad = 1;
            else
                IsModeLoad = 0;
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
            %
            cBehavPlotPath = fullfile(tline,filesep,'Tunning_fun_plot_New1s',filesep,...
                'Tuned freq colormap plot',filesep,'Behavior and uncertainty curve plot.png');
            BehavPlotf = imread(cBehavPlotPath);
            exportToPPTX('addslide');

            UncertaintyRespIm = imread(UncertaintyResp);
%             UncertaintyModuIM = imread(UncertaintyModu);

            % Anminfo
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[2 0 2 1],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',UncertaintyRespIm,'Position',[0.1 1.5 8.05 6]);
            if IsModeLoad
                exportToPPTX('addpicture',imread(UncertaintyModu),'Position',[9.5 1 3.8 3]);
            end
            exportToPPTX('addpicture',imread(RespCompareFile),'Position',[9.5 4 5.68 4.5]);
%                 exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 5 4.19]);
%                 exportToPPTX('addtext','Task','Position',[11 2 1 2],'FontSize',22);
%                 exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4.5 5 4.19]);
%                 exportToPPTX('addtext','Passive','Position',[11 5.5 3 2],'FontSize',22);
%                 exportToPPTX('addpicture',BoundDiffIM,'Position',[12 4.5 4 3.35]);
% %                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
            exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[14 0.5 2 3],'FontSize',22);
    end
     m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);

%%
SessModuIndex = SessModuIndex';
DisDataAll = cell2mat(SessModuIndex(1,:));
ModuIndexAll = cell2mat(SessModuIndex(2,:));
