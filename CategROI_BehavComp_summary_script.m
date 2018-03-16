clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the session pathsave file');
if ~fi
    return;
end

%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSess = 1;
SessBehavAll = {};
SessCategROIBound = {};
SessCategROISlope = {};
xData = linspace(-1,1,500);
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    % passive tuning frequency colormap plot
    TunDataAllStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots'));
%     [~,EndInds] = regexp(tline,'result_save');
%     ROIposfilePath = tline(1:EndInds);
%     ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
%     ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
%     if isfield(ROIdataStrc,'ROIinfoBU')
%         ROIinfoData = ROIdataStrc.ROIinfoBU;
%     elseif isfield(ROIdataStrc,'ROIinfo')
%         ROIinfoData = ROIdataStrc.ROIinfo(1);
%     else
%         error('No ROI information file detected, please check current session path.');
%     end
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    
    GrNum = floor(length(BehavCorr)/2);
    BehavPsycho = BehavCorr;
    BehavPsycho(1:GrNum) = 1 - BehavPsycho(1:GrNum);
    BehavOctaves = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
    BehavFreqStrs = cellstr(num2str(BehavBoundfile.boundary_result.StimType(:)/1000,'%.1f'));
    
    UL = [0.5, 0.5, max(BehavOctaves), 100];
    SP = [BehavPsycho(1),1 - BehavPsycho(end)-BehavPsycho(1), mean(BehavOctaves), 1];
    LM = [0, 0, min(BehavOctaves), 0];
    ParaBoundLim = ([UL;SP;LM]);
    fit_ReNew = FitPsycheCurveWH_nx(BehavOctaves, BehavPsycho, ParaBoundLim);
    BehavCalBound = fit_ReNew.ffit.u;
    
    SessBehavAll{nSess,1} = BehavPsycho;
    SessBehavAll{nSess,2} = BehavOctaves;
    SessBehavAll{nSess,3} = BehavCalBound;

    ROITypeDatafile = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    IIsResponsiveROI = logical(ROITypeDataStrc.ROIisResponsive);
    
    CellBoundAll = cellfun(@(x) x.b3,ROITypeDataStrc.LogCoefFit);
    CategROIBound = CellBoundAll(CategROIInds);
    CategROIMd = ROITypeDataStrc.LogCoefFit(CategROIInds);
    SlopeAll = cellfun(@(x) CategSlope(x,xData),CategROIMd);
    SessCategROIBound{nSess} = CategROIBound;
    SessCategROISlope{nSess} = SlopeAll;
    %
%     hf = figure('position',[3000 300 400 350]);
%     hold on
%     plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'Color',[0.5 0.5 1],'Linewidth',3);
%     plot(BehavOctaves, BehavPsycho,'ro','MarkerSize',12);
%     plot(CategROIBound,0.5*ones(size(CategROIBound)),'k*','MarkerSize',8);
%     hl1 = line([BehavCalBound BehavCalBound],[0 1],'Color',[.7 .7 .7],'Linewidth',2,'linestyle','--');
%     hl2 = line([mean(CategROIBound) mean(CategROIBound)],[0 1],'Color',[0 0.6 0],'Linewidth',2,'linestyle','--');
%     set(gca,'xtick',BehavOctaves,'xticklabel',BehavFreqStrs,'ytick',[0 0.5 1],'xlim',[-1 1],'ylim',[0 1]);
%     xlabel('Frequency (kHz)');
%     ylabel('RightProb');
%     set(gca,'FontSize',16);
%     legend([hl1,hl2],{'BehavBound','AvgROIBound'},'location','Northwest','FontSize',8,'TextColor','m');
%     legend('boxoff');
%     saveas(hf,'Behav and CategROI bound compare plot');
%     saveas(hf,'Behav and CategROI bound compare plot','png');
%     close(hf);
    
    nSess = nSess + 1;
    tline = fgetl(fid);
end
%%
cd('E:\DataToGo\data_for_xu\CategROI_summary');
save CategROIsummary.mat SessCategROIBound SessBehavAll -v7.3

%%
BehavCalculateBound = cell2mat(SessBehavAll(:,3));
CategROIBoundAvg = cellfun(@mean,SessCategROIBound);
hf = figure('position',[3000 300 400 350]);
hold on
plot(CategROIBoundAvg,BehavCalculateBound,'ro')

%%
% clearvars -except fn fp
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
            PPTname = 'CategBoundROI_summary';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'E:\DataToGo\data_for_xu\CategROI_summary';
            %
        end
            Anminfo = SessInfoExtraction(tline);
            cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s',filesep,'Curve fitting plots'];
            CategROIBoundf = fullfile(cTunDataPath,'Behav and CategROI bound compare plot.png');
            TuningPeakf = fullfile(cTunDataPath,'Tuning ROI TunedPeak index distribution.png');

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

                % Anminfo
                exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[1 0 2 1],'FontSize',24);
                exportToPPTX('addnote',tline);
                exportToPPTX('addpicture',BehavPlotf,'Position',[0 2 5 3.75]);
                exportToPPTX('addpicture',imread(CategROIBoundf),'Position',[5.1 2 5 4.38]);
                exportToPPTX('addpicture',imread(TuningPeakf),'Position',[10.5 1.2 4.3 5]);

                exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %sField: %s',...
                    Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                    'Position',[5 7 4 2],'FontSize',22);
    end
     m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);
