clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select your text file that contains the data file path for multisession data savage');
[Passfn,Passfp,Passfi] = uigetfile('*.txt','Please select passive session data path');
Pfn = fn;
Pfp = fp;
% PPTname = 'NewlySingleNeuTunSum';
% pptSavePath = 'F:\';
%%

ErrorSessPath = {};
ErrorSessNum = 0;
ErrorSessMessage = {};
ffullpath = fullfile(Pfp,Pfn);
%
ffid = fopen(ffullpath);
tline = fgetl(ffid);
%parameter struc

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ffid);
        continue;
    end
    cPath = tline;
    cd(cPath);
    
    if ~exist('CSessionData.mat','file')
        ErrorSessNum = ErrorSessNum + 1;
        ErrorSessPath{ErrorSessNum} = pwd;
    else
        clearvars data
        load('CSessionData.mat');

        if exist('ROIstate','var')
            AlignedSortPlotAll(data,behavResults,frame_rate,FRewardLickT,frame_lickAllTrials,[],ROIstate); % plot lick frames
        else
            AlignedSortPlotAll(data,behavResults,frame_rate,FRewardLickT,frame_lickAllTrials);
        end

    end
    tline = fgetl(ffid);
end

%%
clearvars -except fn fp Passfn Passfp Passfi fi
m = 1;
nSession = 1;
if ~fi || ~Passfi
    return;
else
    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    
    PassfPath = fullfile(Passfp,Passfn);
    Passf = fopen(PassfPath);
    Passline = fgetl(Passf);
    while ischar(tline)
        if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
            tline = fgetl(ff);
            Passline = fgetl(Passf);
            continue;
        else
            %
            if m == 1
                %
                PPTname = input('Please input the name for current PPT file:\n','s');
                if isempty(strfind(PPTname,'.ppt'))
                    PPTname = [PPTname,'.pptx'];
                end
                pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
                %
            end
                Anminfo = SessInfoExtraction(tline);
                cTunDataPath = [tline,filesep,'Tunning_fun_plot_New1s'];
                BehavPlotPath = [tline,filesep,'RandP_data_plots'];
                ColorPlotPath = [tline,filesep,'All BehavType Colorplot'];
                ColorplotStr = 'ROI* all behavType color plot.png';
                TuningPlotStr = 'ROI* Tunning curve comparison plot.png';
                BehavPlotStr = 'RandP_data_plots\Behav_fit plot.png';
                
                PassColorPPath = [Passline,filesep,'SepFreq_passive_plots'];
                PassColorPPttn = 'ROI* SepFreq  Color plot save.png';
                PassMeanTrPttn = 'ROI* Mean Trace plot save.png';
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
                cd(cTunDataPath);
%                 filePattern = 'ROI* Tunning curve comparison plot.png';
                Allfiles = dir(fullfile(cTunDataPath,TuningPlotStr));
                nfiles = length(Allfiles);  % also as nROIs
                fprintf('Totally %d files will be loaded within current folder path.\n',nfiles);
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
                cBehavPlotPath = [tline,filesep,BehavPlotStr];
                BehavPlotf = imread(cBehavPlotPath);
                for cfile = 1:nfiles
                    %
                    exportToPPTX('addslide');
                    cTunfPath = [cTunDataPath,filesep,strrep(TuningPlotStr,'*',num2str(cfile))];
                    cColorPlotPath = [ColorPlotPath,filesep,strrep(ColorplotStr,'*',num2str(cfile))];
                    cPassColorPath = [PassColorPPath filesep strrep(PassColorPPttn,'*',num2str(cfile))];
                    cPassMeanPath = [PassColorPPath filesep strrep(PassMeanTrPttn,'*',num2str(cfile))];
%                     cPNGfilename = Allfiles(cfile).name;
%                     cPNGfullfile = fullfile(cTunDataPath,cPNGfilename);
%                     cPNGSPfullfile = strrep(cPNGfullfile,'Tunning_fun_plot','Spike_Tunfun_plot');
                    TunFigure = imread(cTunfPath);
                    ColorplotFigure = imread(cColorPlotPath);
                    PassColorFig = imread(cPassColorPath);
                    PassMeanFig = imread(cPassMeanPath);
                    % Anminfo
                    exportToPPTX('addtext',sprintf('ROI%d \r\n Session%d',cfile,nSession),'Position',[2 0 2 1],'FontSize',24);
                    exportToPPTX('addnote',pwd);
                    exportToPPTX('addpicture',BehavPlotf,'Position',[0.8 1.3 2.5 1.9]);
                    exportToPPTX('addpicture',TunFigure,'Position',[0.6 4 5 3.82]);
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
%                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
                    exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[13 5.5 3 3],'FontSize',22);
                    %
                end
        end
         m = m + 1;
         nSession = nSession + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
         Passline = fgetl(Passf);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
end

%%
clearvars -except fn fp Passfn Passfp PPTname pptSavePath Passfi fi
m = 1;
nSession = 1;
% if ~fi || ~Passfi
%     return;
% else
    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    
    PassfPath = fullfile(Passfp,Passfn);
    Passf = fopen(PassfPath);
    Passline = fgetl(Passf);
    while ischar(tline)
        if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
            tline = fgetl(ff);
            Passline = fgetl(Passf);
            continue;
        else
            %
            if m == 1
                %
%                 PPTname = input('Please input the name for current PPT file:\n','s');
%                 if isempty(strfind(PPTname,'.ppt'))
%                     PPTname = [PPTname,'_old.pptx'];
%                 end
                PPTname = strrep(PPTname,'New','Old');
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
                %
            end
                Anminfo = SessInfoExtraction(tline);
                cTunDataPath = [tline,filesep,'Tunning_fun_plot_1s'];
                BehavPlotPath = [tline,filesep,'RandP_data_plots'];
                ColorPlotPath = [tline,filesep,'All BehavType Colorplot'];
                ColorplotStr = 'ROI* all behavType color plot.png';
                TuningPlotStr = 'ROI* Tunning curve comparison plot.png';
                BehavPlotStr = 'RandP_data_plots\Behav_fit plot.png';
                
                PassColorPPath = [Passline,filesep,'SepFreq_passive_plots'];
                PassColorPPttn = 'ROI* SepFreq  Color plot save.png';
                PassMeanTrPttn = 'ROI* Mean Trace plot save.png';
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
                cd(cTunDataPath);
%                 filePattern = 'ROI* Tunning curve comparison plot.png';
                Allfiles = dir(fullfile(cTunDataPath,TuningPlotStr));
                nfiles = length(Allfiles);  % also as nROIs
                fprintf('Totally %d files will be loaded within current folder path.\n',nfiles);
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
                cBehavPlotPath = [tline,filesep,BehavPlotStr];
                BehavPlotf = imread(cBehavPlotPath);
                for cfile = 1:nfiles
                    %
                    exportToPPTX('addslide');
                    cTunfPath = [cTunDataPath,filesep,strrep(TuningPlotStr,'*',num2str(cfile))];
                    cColorPlotPath = [ColorPlotPath,filesep,strrep(ColorplotStr,'*',num2str(cfile))];
                    cPassColorPath = [PassColorPPath filesep strrep(PassColorPPttn,'*',num2str(cfile))];
                    cPassMeanPath = [PassColorPPath filesep strrep(PassMeanTrPttn,'*',num2str(cfile))];
%                     cPNGfilename = Allfiles(cfile).name;
%                     cPNGfullfile = fullfile(cTunDataPath,cPNGfilename);
%                     cPNGSPfullfile = strrep(cPNGfullfile,'Tunning_fun_plot','Spike_Tunfun_plot');
                    TunFigure = imread(cTunfPath);
                    ColorplotFigure = imread(cColorPlotPath);
                    PassColorFig = imread(cPassColorPath);
                    PassMeanFig = imread(cPassMeanPath);
                    % Anminfo
                    exportToPPTX('addtext',sprintf('ROI%d \r\n Session%d',cfile,nSession),'Position',[2 0 2 1],'FontSize',24);
                    exportToPPTX('addnote',pwd);
                    exportToPPTX('addpicture',BehavPlotf,'Position',[0.8 1.3 2.5 1.9]);
                    exportToPPTX('addpicture',TunFigure,'Position',[0.6 4 5 3.82]);
                    exportToPPTX('addpicture',ColorplotFigure,'Position',[5 4 7.65 5]);
                    iminfos = imfinfo(cPassColorPath);
                    if (iminfos.Width/iminfos.Height) > 5
                        exportToPPTX('addpicture',PassColorFig,'Position',[4 1.1 8.4 2.2]);
                        exportToPPTX('addpicture',PassMeanFig,'Position',[12.9 1.2 3 2.25]);
                    elseif (iminfos.Width/iminfos.Height) > 3
                        exportToPPTX('addpicture',PassColorFig,'Position',[3.8 0.7 8.7 3]);
                        exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3.45]);
                    else
                        exportToPPTX('addpicture',PassColorFig,'Position',[5 0.3 7.5 3.5]);
                        exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.3 2.29 4]);
                    end
%                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
                    exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[13 5 3 3],'FontSize',22);
                    %
                end
        end
         m = m + 1;
         nSession = nSession + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
         Passline = fgetl(Passf);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
% end