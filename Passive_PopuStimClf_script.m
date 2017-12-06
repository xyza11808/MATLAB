
[fn,fp,fi] = uigetfile('*.txt','Please select the passive session data path');
if ~fi
    return;
end
%%
fPath = fullfile(fp,fn);
fid = fopen(fPath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        fprintf('Current Path:\n%s\nhave no valuable data contains.\n',tline);
        tline = fgetl(fid);
        continue;
    end
    cd(tline);
    clearvars SelectSArray SelectData frame_rate
    load('rfSelectDataSet.mat');
    StimTypes = length(unique(SelectSArray));
    StimRepNum = length(SelectSArray)/StimTypes;
    IsTrSmallRepeat = 0;
    if StimRepNum < 10
        warning('Trial repeat number is quiet small, the classification result may not accurate.');
        IsTrSmallRepeat = StimRepNum;
    end
    PseudoTroutcome = ones(length(SelectSArray),1);
    
    multiCClass(SelectData,SelectSArray,PseudoTroutcome,frame_rate,frame_rate,1);
    
    tline = fgetl(fid);
end

%%
m = 1;
if ~fi
    return;
else
    fpath = fullfile(fp,fn);
    ff = fopen(fpath);
    tline = fgetl(ff);
    while ischar(tline)
        if isempty(strfind(tline,'plot_save\NO_Correction'))
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
                cFluoDataPath = fullfile(tline,'NeuroM_MC_TbyT\AfterTimeLength-1500ms');
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
%                 cd(cFluoDataPath);
                filePattern = 'Multi class classification error rate.png';
                Anminfo = SessInfoExtraction(tline);
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
                
                exportToPPTX('addslide');
                cPNGfullfile = fullfile(cFluoDataPath,filePattern);
                FluoFigure = imread(cPNGfullfile);
                exportToPPTX('addtext','Classification correct rate','Position',[5 1 6 2],'FontSize',24);
                exportToPPTX('addnote',cFluoDataPath);
                exportToPPTX('addpicture',cPNGfullfile,'Position',[2 2 8 5.44]);
                exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[12 3 3 3],'FontSize',22);
%                 exportToPPTX('addpicture',SpikeFigure,'Position',[8 2 8 6]);
        end
         m = m + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
end

%%
clear
clc
[Taskfn,Taskfp,~] = uigetfile('*.txt','Please select task data saving path');

fpath = fullfile(Taskfp,Taskfn);
fid = fopen(fpath);
tline = fgetl(fid);

while ischar(tline)
    if isempty(strfind(tline,'\NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    
    TaskPath = tline;
    cd(TaskPath);
    clearvars smooth_data
    
    load('CSessionData.mat');
    ProbInds = double(behavResults.Trial_isProbeTrial);
    if sum(ProbInds)
        radom_inds = ProbInds == 0;
    else
        radom_inds = true(size(ProbInds));
    end
    multiCClass(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1.5);
    
    tline = fgetl(fid);
end
