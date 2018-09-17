
% script for summarize all tuning plots together
nSess = length(NormSessPathTask);

for cSess = 1 : nSess
    
    cSessPath = NormSessPathTask{cSess};
    
    PPTname = 'Tuning map color plots';
    if isempty(strfind(PPTname,'.ppt'))
        PPTname = [PPTname,'.pptx'];
    end
    %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');

        if ismac
            pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
        elseif ispc
            pptSavePath = 'N:\PlotSummary_folder';
        end
    
    Anminfo = SessInfoExtraction(cSessPath);
    cSessBehavPath = fullfile(cSessPath,'RandP_data_plots','Behav_fit plot.png');
    cSessColorTuningPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot');
    TaskColorTun = fullfile(cSessColorTuningPath,'Task top Prc100 colormap save.png');
    PassColorTun = fullfile(cSessColorTuningPath,'Passive top Prc100 colormap save.png');
    SingleNeuTunDatapath = fullfile(cSessColorTuningPath,'TaskPassBFDis.mat');
    SingleNeuTunData = load(SingleNeuTunDatapath);
    
    pptFullfile = fullfile(pptSavePath,PPTname);
    if ~exist(pptFullfile,'file')
        NewFileExport = 1;
    else
        NewFileExport = 0;
    end
    if cSess == 1
        if NewFileExport
            exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
        else
            exportToPPTX('open',pptFullfile);
        end
    end
    
    exportToPPTX('addslide');
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
    Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
    'Position',[2 0.3 4 1.5],'FontSize',20);
    
    exportToPPTX('addtext','Task','Position',[1.5 1.5 2 0.5],'FontSize',24);
    exportToPPTX('addtext','Passive','Position',[6.5 1.5 2 0.5],'FontSize',24);
    
    exportToPPTX('addpicture',imread(TaskColorTun),'Position',[0.5 2 4.5 3.82]);
    exportToPPTX('addpicture',imread(PassColorTun),'Position',[5 2 4.5 3.82]);
    exportToPPTX('addpicture',imread(cSessBehavPath),'Position',[11 2 4 3]);
    
    exportToPPTX('addtext',sprintf('MeanDiff = %.4f\r\nModeDiff = %.4f',mean(SingleNeuTunData.TaskMaxOct) - SingleNeuTunData.BehavBoundData,...
        mode(SingleNeuTunData.TaskMaxOct) - SingleNeuTunData.BehavBoundData),'Position',[2 6 3.5 2],'FontSize',20);
    exportToPPTX('addtext',sprintf('MeanDiff = %.4f\r\nModeDiff = %.4f',mean(SingleNeuTunData.PassMaxOct) - SingleNeuTunData.BehavBoundData,...
        mode(SingleNeuTunData.PassMaxOct) - SingleNeuTunData.BehavBoundData),'Position',[6 6 3.5 2],'FontSize',20);
    
    exportToPPTX('addnote',cSessPath);
    
end
saveName = exportToPPTX('saveandclose',pptFullfile);

%% calculate the slope value and tuning difference relationships
nSess = length(NormSessPathTask);
OctDiffAll = zeros(nSess,4);
SlopeValueAll = zeros(nSess,1);
for cSess = 1 : nSess
    %
    cSessPath = NormSessPathTask{cSess};
    cSessColorTuningPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot');
    SingleNeuTunDatapath = fullfile(cSessColorTuningPath,'TaskPassBFDis.mat');
    SingleNeuTunData = load(SingleNeuTunDatapath);
    
    cSessBehavPath = fullfile(cSessPath,'RandP_data_plots','boundary_result.mat');
    cSessBehavData = load(cSessBehavPath);
    
    MaxSlopeValue = max(cSessBehavData.boundary_result.SlopeCurve);
    OctDiffAll(cSess,:) = [mean(SingleNeuTunData.TaskMaxOct) - SingleNeuTunData.BehavBoundData,mode(SingleNeuTunData.TaskMaxOct) - SingleNeuTunData.BehavBoundData,...
        mean(SingleNeuTunData.PassMaxOct) - SingleNeuTunData.BehavBoundData,mode(SingleNeuTunData.PassMaxOct) - SingleNeuTunData.BehavBoundData];
    SlopeValueAll(cSess) = MaxSlopeValue;
   %
end

%%
% script for summarize all tuning plots together
nSess = length(NormSessPathTask);

for cSess = 1 : nSess
    
    cSessPath = NormSessPathTask{cSess};
    
    PPTname = 'Tuning graymap color plots';
    if isempty(strfind(PPTname,'.ppt'))
        PPTname = [PPTname,'.pptx'];
    end
    %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');

        if ismac
            pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
        elseif ispc
            pptSavePath = 'N:\PlotSummary_folder';
        end
    
    Anminfo = SessInfoExtraction(cSessPath);
    cSessBehavPath = fullfile(cSessPath,'RandP_data_plots','Behav_fit plot.png');
    cSessColorTuningPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','Tuned freq NewSig grayCP plot');
    TaskColorTun = fullfile(cSessColorTuningPath,'Task top Prc100 colormap save.png');
    PassColorTun = fullfile(cSessColorTuningPath,'Passive top Prc100 colormap save.png');
    SingleNeuTunDatapath = fullfile(cSessColorTuningPath,'TaskPassBFDis.mat');
    SingleNeuTunData = load(SingleNeuTunDatapath);
    
    pptFullfile = fullfile(pptSavePath,PPTname);
    if ~exist(pptFullfile,'file')
        NewFileExport = 1;
    else
        NewFileExport = 0;
    end
    if cSess == 1
        if NewFileExport
            exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
        else
            exportToPPTX('open',pptFullfile);
        end
    end
    
    exportToPPTX('addslide');
    exportToPPTX('addtext',sprintf('Batch:%s Anm: %s Date: %s Field: %s',...
    Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
    'Position',[2 0.3 4 1.5],'FontSize',20);
    
    exportToPPTX('addtext','Task','Position',[1.5 1.5 2 0.5],'FontSize',24);
    exportToPPTX('addtext','Passive','Position',[6.5 1.5 2 0.5],'FontSize',24);
    
    exportToPPTX('addpicture',imread(TaskColorTun),'Position',[0.5 2 4.5 3.82]);
    exportToPPTX('addpicture',imread(PassColorTun),'Position',[5 2 4.5 3.82]);
    exportToPPTX('addpicture',imread(cSessBehavPath),'Position',[11 2 4 3]);
    
    exportToPPTX('addtext',sprintf('MeanDiff = %.4f\r\nModeDiff = %.4f',mean(SingleNeuTunData.TaskRespMaxOct) - SingleNeuTunData.BehavBoundData,...
        mode(SingleNeuTunData.TaskRespMaxOct) - SingleNeuTunData.BehavBoundData),'Position',[2 6 3.5 2],'FontSize',20);
    exportToPPTX('addtext',sprintf('MeanDiff = %.4f\r\nModeDiff = %.4f',mean(SingleNeuTunData.PassRespMaxOct) - SingleNeuTunData.BehavBoundData,...
        mode(SingleNeuTunData.PassRespMaxOct) - SingleNeuTunData.BehavBoundData),'Position',[6 6 3.5 2],'FontSize',20);
    
    exportToPPTX('addnote',cSessPath);
    
end
saveName = exportToPPTX('saveandclose',pptFullfile);
