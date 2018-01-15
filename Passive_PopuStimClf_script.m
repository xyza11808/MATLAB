clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the passive session data path');
if ~fi
    return;
end
[Taskfn,Taskfp,~] = uigetfile('*.txt','Please select task data saving path');
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
    %%
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
    %%
    tline = fgetl(fid);
end


clearvars -except Taskfn Taskfp fn fp

%% [Taskfn,Taskfp,~] = uigetfile('*.txt','Please select task data saving path');

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
%%
m = 1;
if ~fi
    return;
else
    Passfpath = fullfile(fp,fn);
    ff = fopen(Passfpath);
    tline = fgetl(ff);
    
    TaskfPath = fullfile(Taskfp,Taskfn);
    Taskff = fopen(TaskfPath);
    Taskline = fgetl(Taskff);
    
    while ischar(tline)
        if isempty(strfind(tline,'plot_save\NO_Correction'))
            tline = fgetl(ff);
            Taskline = fgetl(Taskff);
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
                cFluoDataPath = fullfile(Taskline,'NeuroM_MC_TbyT\AfterTimeLength-1500ms');
                cPassDataPath = fullfile(tline,'NeuroM_MC_TbyT\AfterTimeLength-1000ms');
                BehavfilePath = fullfile(Taskline,'RandP_data_plots\Behav_fit plot.png');
                BehavData = load(fullfile(Taskline,'RandP_data_plots','boundary_result.mat'));
                BehavBoundary = round((2^BehavData.boundary_result.Boundary)*8000);
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
%                 cd(cFluoDataPath);
                filePattern = 'Multi class classification correct rate.png';
                Anminfo = SessInfoExtraction(Taskline);
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
                cPassPNGfile = fullfile(cPassDataPath,filePattern);
                FluoFigure = imread(cPNGfullfile);
                PassPNGfile = imread(cPassPNGfile);
                BehavPNGfile = imread(BehavfilePath);
                exportToPPTX('addtext','Classification correct rate','Position',[4.5 1 6 1],'FontSize',24);
                exportToPPTX('addnote',cFluoDataPath);
                exportToPPTX('addpicture',cPNGfullfile,'Position',[0.5 2 6 4.08]);
                exportToPPTX('addtext','Task','Position',[3 6.5 2 1.5],'FontSize',22);
                exportToPPTX('addpicture',PassPNGfile,'Position',[6 2 6 4.08]);
                exportToPPTX('addtext','Passive','Position',[8 6.5 2 1.5],'FontSize',22);
                exportToPPTX('addpicture',BehavPNGfile,'Position',[12 3 2.5 1.9]);
                exportToPPTX('addtext',sprintf('Boundary = %dHz',BehavBoundary),'Position',[12 5.4 4 2],'FontSize',22);
                exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[12 0.5 3 3],'FontSize',22);
%                 exportToPPTX('addpicture',SpikeFigure,'Position',[8 2 8 6]);
        end
         m = m + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         tline = fgetl(ff);
         Taskline = fgetl(Taskff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
end
