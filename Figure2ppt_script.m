
[fn,fp,fi] = uigetfile('*.txt','Please select your text file that contains the data file path for multisession data savage');

%%
m = 1;
if ~fi
    return;
else
    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    while ischar(tline)
        if isempty(strfind(tline,'NO_Correction\mode_f_change'))
            tline = fgetl(ff);
            continue;
        else
            if m == 1
                %
                PPTname = input('Please input the name for current PPT file:\n','s');
                if isempty(strfind(PPTname,'.ppt'))
                    PPTname = [PPTname,'.pptx'];
                end
                pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
                %
            end
                cFluoDataPath = [tline,'\Tunning_fun_plot'];
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
                cd(cFluoDataPath);
                filePattern = 'ROI* Tunning curve comparison plot.png';
                Allfiles = dir(filePattern);
                nfiles = length(Allfiles);
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
                
                for cfile = 1:nfiles
                    exportToPPTX('addslide');
                    cPNGfilename = Allfiles(cfile).name;
                    cPNGfullfile = fullfile(cFluoDataPath,cPNGfilename);
                    cPNGSPfullfile = strrep(cPNGfullfile,'Tunning_fun_plot','Spike_Tunfun_plot');
                    FluoFigure = imread(cPNGfullfile);
                    SpikeFigure = imread(cPNGSPfullfile);
                    exportToPPTX('addtext',cPNGfilename(1:end-4),'Position',[5 1 6 2],'FontSize',24);
                    exportToPPTX('addnote',pwd);
                    exportToPPTX('addpicture',cPNGfullfile,'Position',[0 2 8 6]);
                    exportToPPTX('addpicture',SpikeFigure,'Position',[8 2 8 6]);
                end
        end
         m = m + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
end