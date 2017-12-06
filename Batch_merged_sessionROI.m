% set output folder for single ROI data, using ROI number as subfolder name
UpperFolder = uigetdir(pwd,'Please select the main ROI colorplot save path');
cd(UpperFolder);

%% 
[fn,fp,fi] = uigetfile('*.txt','Please select All session save path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
k = 1;
SessInfo = {};
fid = fopen(fpath);
tline = fgetl(fid);

[Passfn,Passfp,Passfi] = uigetfile('*.txt','Please select Passive session data path');
if ~Passfi
    return;
end
PassSessPath = fullfile(Passfp,Passfn);
Passfid = fopen(PassSessPath);
Passline = fgetl(Passfid);
%%
while ischar(tline)
    if ~isempty(strcmpi(tline,'result_save'))
        tline = fgetl(tline);
        Passline = fgetl(Passfid);
        continue;
    end
    %%
    Anminfo = SessInfoExtraction(tline);
    SessInfo{k} = Anminfo;
    DateNum = str2num(Anminfo.SessionDate);
    if isempty(DateNum) || isnan(DateNum)
        StrSuffix = num2str(k,'Session%d');
    else
        StrSuffix = Anminfo.SessionDate;
    end
%     ROIstateDataPath = dir([tline,filesep,'CaTrialsSIM*.mat']);
%     ROIstateData = load(ROIstateDataPath.name,'ROIstateIndic');
    ROImorphPath = [tline filesep 'ROI_morph_plot'];
    morphPatternStr = 'ROI* morph plot save.png';
    ROIplotPath = [tline filesep 'plot_save\Type2_f0_calculation\NO_Correction\mode_f_change\All BehavType Colorplot'];
    ColorPlotPttnStr = 'ROI* all behavType color plot.png';
    PassMorphPath = [Passline,filesep,'ROI_morph_plot'];
    PassColorPlotPath = [Passline,filesep,'SepFreq_passive_plots'];
    PassColorPttn = 'ROI* SepFreq  Color plot save';
    PassMeanPttn = 'ROI* Mean Trace plot save';
    
    TaskROIcolorP_files = dir([ROIplotPath filesep ColorPlotPttnStr]);
    nROIs = length(TaskROIcolorP_files);
    ROISum_outputPath = cell(nROIs,1);
    for cROI = 1 : nROIs
        if ~isdir([UpperFolder filesep num2str(cROI,'ROI%d_summary')])
            mkdir([UpperFolder filesep num2str(cROI,'ROI%d_summary')]);
        end
        ROISum_outputPath{cROI} = [UpperFolder filesep num2str(cROI,'ROI%d_summary')];
        
        % move files into the summary folder, session-wise rename files and
        % copy with a new file name
        % % % ### copy task colorplot file
%         cTaskColorPlotfile = sprintf(strrep(ColorPlotPttnStr,'*','%d'),cROI);
        cTaskColorPlotfile = strrep(ColorPlotPttnStr,'*',num2str(cROI));
        NewTaskCPfile = sprintf('%s_Task_%s',cTaskColorPlotfile(1:end-4),StrSuffix);
        copyfile(fullfile(ROIplotPath,cTaskColorPlotfile),...
            fullfile(ROISum_outputPath{cROI},NewTaskCPfile));
        % % % ### copy task morph file
%         cTaskMorphfile = sprintf(strrep(morphPatternStr,'*','%d'),cROI);
        cTaskMorphfile = strrep(morphPatternStr,'*',num2str(cROI));
        NewTaskMorphfile = sprintf('%s_Task_%s',cTaskMorphfile(1:end-4),StrSuffix);
        copyfile(fullfile(ROImorphPath,cTaskMorphfile),...
            fullfile(ROISum_outputPath{cROI},NewTaskMorphfile));
        % % % ### copy Passive colorplot file
%         cPassCPlotfile = sprintf(strrep(PassColorPttn,'*','%d'),cROI);
        cPassCPlotfile = strrep(PassColorPttn,'*',num2str(cROI));
        NewPassCPlotfile = sprintf('%s_Pass_%s',cPassCPlotfile(1:end-4),StrSuffix);
        copyfile(fullfile(PassColorPlotPath,cPassCPlotfile),...
            fullfile(ROISum_outputPath{cROI},NewPassCPlotfile));
        % % % ### copy Passive mean trace file
%         cPassMeanTracefile = sprintf(strrep(PassMeanPttn,'*','%d'),cROI);
        cPassMeanTracefile = strrep(PassMeanPttn,'*',num2str(cROI));
        NewPassMeanTrfile = sprintf('%s_Pass_%s',cPassMeanTracefile(1:end-4),StrSuffix);
        copyfile(fullfile(PassColorPlotPath,cPassMeanTracefile),...
            fullfile(ROISum_outputPath{cROI},NewPassMeanTrfile));
        % % % ### copy Passive morph file
        NewPassMorphfile = sprintf('%s_Pass_%s',cTaskMorphfile(1:end-4),StrSuffix);
        copyfile(fullfile(PassMorphPath,NewPassMorphfile),...
            fullfile(ROISum_outputPath{cROI},NewPassMorphfile));
        
        % add to ppt slices
        
    end
    %%
    tline = fgetl(tline);
    Passline = fgetl(Passfid);
    k = k + 1;
end

%%
exportToPPTX('addslide');
PassMorphPlot = imread(fullfile(PassMorphPath,NewPassMorphfile));
TaskMorphPlot = imread(fullfile(ROImorphPath,cTaskMorphfile));
ColorplotFigure = imread(fullfile(ROIplotPath,cTaskColorPlotfile));
PassColorFig = imread(fullfile(PassColorPlotPath,cPassCPlotfile));
PassMeanFig = imread(fullfile(PassColorPlotPath,cPassMeanTracefile));

exportToPPTX('addtext',sprintf('ROI%d \r\n Session%d',cfile,nSession),'Position',[2 0 2 1],'FontSize',24);
exportToPPTX('addnote',pwd);
exportToPPTX('addpicture',PassMorphPlot,'Position',[0.5 1.2 3 2.25]);
exportToPPTX('addpicture',TaskMorphPlot,'Position',[0.5 4.2 3 2.25]);
exportToPPTX('addpicture',ColorplotFigure,'Position',[5 4 7.65 5]);
iminfos = imfinfo(cPassColorPath);
if (iminfos.Width/iminfos.Height) > 5
    exportToPPTX('addpicture',PassColorFig,'Position',[4 1.1 8.4 2.2]);  %1.35
    exportToPPTX('addpicture',PassMeanFig,'Position',[12.9 1.2 3 2.25]);
elseif (iminfos.Width/iminfos.Height) > 3
    exportToPPTX('addpicture',PassColorFig,'Position',[3.8 0.7 8.7 3]);
    exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3.45]);
else
    exportToPPTX('addpicture',PassColorFig,'Position',[5 0.3 7.5 3.5]);
    exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.3 2.29 4]);
end