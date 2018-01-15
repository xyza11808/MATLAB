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
Taskid = fopen(fullfile(Taskfp,Taskfn));
Taskline = fgetl(Taskid);
while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        fprintf('Current Path:\n%s\nhave no valuable data contains.\n',tline);
        tline = fgetl(fid);
        Taskline = fgetl(Taskid);
        continue;
    end
    %
    ROITypeDatafile = fullfile(Taskline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    
    cd(tline);
    clearvars SelectSArray SelectData frame_rate smooth_data
    load('rfSelectDataSet.mat');
    StimTypes = length(unique(SelectSArray));
    StimRepNum = length(SelectSArray)/StimTypes;
    IsTrSmallRepeat = 0;
    if StimRepNum < 10
        warning('Trial repeat number is quiet small, the classification result may not accurate.');
        IsTrSmallRepeat = StimRepNum;
    end
    PseudoTroutcome = ones(length(SelectSArray),1);
    
    multiCClass(SelectData,SelectSArray,PseudoTroutcome,frame_rate,frame_rate,1,[],CategROIInds);

    
    TaskPath = Taskline;
    cd(TaskPath);
    
    load('CSessionData.mat');
    ProbInds = double(behavResults.Trial_isProbeTrial);
    if sum(ProbInds)
        radom_inds = ProbInds == 0;
    else
        radom_inds = true(size(ProbInds));
    end
    multiCClass(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
        start_frame,frame_rate,1);
    multiCClass(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
        start_frame,frame_rate,1,[],CategROIInds);
    
    tline = fgetl(fid);
    Taskline = fgetl(Taskid);
end
%% select only similar octaves as task tones
m = 1;
PairedStimDataSave = {};
PairedStimPassInds = {};
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
        end
        %
        cFluoDataPath = fullfile(Taskline,'NeuroM_MC_TbyT\AfterTimeLength-1000ms');
        cPassDataPath = fullfile(tline,'NeuroM_MC_TbyT\AfterTimeLength-1000ms');
        TaskDataStrc = load(fullfile(cFluoDataPath,'PairedClassResult.mat'));
        TaskStims = log2(TaskDataStrc.StimTypesAll/16000);
        UsedInds = false(length(TaskStims),1);
%         if mod(length(TaskStims),2)
%             UsedInds(ceil(length(TaskStims)/2)) = true;
%             UsedStims = TaskStims(~UsedInds);
%             UsedFreqs = TaskDataStrc.StimTypesAll(~UsedInds);
%             UsedMtxData = TaskDataStrc.matrixData(~UsedInds,~UsedInds);
%         end
        if length(TaskStims) > 6
            UsedInds = abs(TaskStims) > 0.19;
            UsedStims = TaskStims(UsedInds);
            UsedFreqs = TaskDataStrc.StimTypesAll(UsedInds);
            UsedMtxData = TaskDataStrc.matrixData(UsedInds,UsedInds);
        else
            UsedStims = TaskStims;
            UsedFreqs = TaskDataStrc.StimTypesAll(:);
            UsedMtxData = TaskDataStrc.matrixData;
        end
        
        PassDataStrc = load(fullfile(cPassDataPath,'PairedClassResult.mat'));
        PassStims = log2(PassDataStrc.StimTypesAll/16000);
        disp((UsedStims(:))');
        disp((PassStims(:))');
        InputStrs = input('Please select passive stim used inds:\n','s');
        InputInds = str2num(InputStrs);
        if isempty(InputInds)
            m = m + 1;
            tline = fgetl(ff);
            Taskline = fgetl(Taskff);
%             continue;
        end
        PassUsedInds = false(size(PassStims));
        PassUsedInds(InputInds) = true;
        PassUsedStims = PassStims(PassUsedInds);
        PassUsedFreqs = PassDataStrc.StimTypesAll(PassUsedInds);
        PassUsedData = PassDataStrc.matrixData(PassUsedInds,PassUsedInds);
        %
        hf = figure('position',[100 100 680 260]);
        ax1 = subplot(121);
        imagesc(UsedMtxData,[0.5 1]);
        set(gca,'xtick',1:length(UsedStims),'ytick',1:length(UsedStims),'xticklabel',cellstr(num2str(UsedFreqs(:)/1000,'%.1f')),...
            'yticklabel',cellstr(num2str(UsedFreqs(:)/1000,'%.1f')));
        set(ax1,'box','off','TickLength',[0 0]);
        title('Task');
        
        ax2 = subplot(122);
        imagesc(PassUsedData,[0.5 1]);
        set(gca,'xtick',1:length(PassUsedStims),'ytick',1:length(PassUsedStims),'xticklabel',cellstr(num2str(PassUsedFreqs(:)/1000,'%.1f')),...
            'yticklabel',cellstr(num2str(PassUsedFreqs(:)/1000,'%.1f')));
        set(ax2,'box','off','TickLength',[0 0]);
        title('Pass');
        AxesPos = get(ax2,'position');
        hbar = colorbar;
        barPos = get(hbar,'position');
        set(hbar,'position',barPos.*[1.12,1,0.3,0.6]+[0 0.2 0 0]);
        
        cd(cFluoDataPath);
        saveas(hf,'Select Stims task and passive compare plot');
        saveas(hf,'Select Stims task and passive compare plot','png');
        close(hf);
        %
        PairedStimDataSave{m,1} = UsedMtxData;
        PairedStimDataSave{m,2} = PassUsedData;
        PairedStimPassInds{m} = PassUsedInds;
        
        m = m + 1;
        tline = fgetl(ff);
        Taskline = fgetl(Taskff);
    end 
end
%%
save('E:\DataToGo\data_for_xu\PopoStimClf_multisessionTogether\New_method\SaveStim_Clf\SessPopuClfSum.mat','PairedStimDataSave',...
    'PairedStimPassInds','-v7.3');
cd('E:\DataToGo\data_for_xu\PopoStimClf_multisessionTogether\New_method\SaveStim_Clf');

%%
clear
clc

[Taskfn,Taskfp,~] = uigetfile('*.txt','Please select task data saving path');
%%
m = 1;
if ~fi
    return;
else

    TaskfPath = fullfile(Taskfp,Taskfn);
    Taskff = fopen(TaskfPath);
    Taskline = fgetl(Taskff);
    
    while ischar(Taskline)
        if isempty(strfind(Taskline,'NO_Correction\mode_f_change'))
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
                cFluoDataPath = fullfile(Taskline,'NeuroM_MC_TbyT\AfterTimeLength-1000ms');
                BehavfilePath = fullfile(Taskline,'RandP_data_plots\Behav_fit plot.png');
                BehavData = load(fullfile(Taskline,'RandP_data_plots','boundary_result.mat'));
                BehavBoundary = round((2^BehavData.boundary_result.Boundary)*8000);
%                 cSPDataPath = [tline,'\Spike_Tunfun_plot'];
%                 cd(cFluoDataPath);
                filePattern = 'Select Stims task and passive compare plot.png';
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
                FluoFigure = imread(cPNGfullfile);
                BehavPNGfile = imread(BehavfilePath);
                exportToPPTX('addtext','Classification correct rate','Position',[4.5 1 6 1],'FontSize',24);
                exportToPPTX('addnote',cFluoDataPath);
                exportToPPTX('addpicture',FluoFigure,'Position',[0.5 2 10.2 4.08]);
                exportToPPTX('addtext','Task','Position',[3 6.5 2 1.5],'FontSize',22);
                exportToPPTX('addtext','Passive','Position',[7.5 6.5 2 1.5],'FontSize',22);
                exportToPPTX('addpicture',BehavPNGfile,'Position',[12 3 2.5 1.9]);
                exportToPPTX('addtext',sprintf('Boundary = %dHz',BehavBoundary),'Position',[12 5.4 4 2],'FontSize',22);
                exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                        'Position',[12 0.5 3 3],'FontSize',22);
%                 exportToPPTX('addpicture',SpikeFigure,'Position',[8 2 8 6]);
        end
         m = m + 1;
         saveName = exportToPPTX('saveandclose',pptFullfile);
         Taskline = fgetl(Taskff);
    end
    fprintf('Current figures saved in file:\n%s\n',saveName);
    cd(pptSavePath);
end
