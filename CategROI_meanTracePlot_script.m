%         ColormapNum = 100;
        CusColors = blue2red_2(100,0.7);
        ColormapNum = size(CusColors,1);
        ColorValueScales = linspace(-1,1,ColormapNum);
        %%
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task data');
[Passn,Passp,~] = uigetfile('*.txt','Please select the text file contains the path of all pass data');
%%
clearvars -except Passn Passp fn fp
CusColors = blue2red_2(100,0.7);
ColormapNum = size(CusColors,1);
ColorValueScales = linspace(-1,1,ColormapNum);

fpath = fullfile(fp,fn);
ff = fopen(fpath);
Passtfid = fopen(fullfile(Passp,Passn));
Tasktline = fgetl(ff);
Passtline = fgetl(Passtfid);
nSess = 1;
SessUsedIndsPass = {};
while ischar(Tasktline)
    if isempty(strfind(Tasktline,'NO_Correction\mode_f_change'))
       Tasktline = fgetl(ff);
       Passtline = fgetl(Passtfid);
        continue;
    end
        SessionFitDataPath = fullfile(Tasktline,'Tunning_fun_plot_New1s\Curve fitting plots\NewCurveFitsave.mat');
        SessionTunPath = [Tasktline,'\Tunning_fun_plot_New1s\Curve fitting plots'];
        BehavData = fullfile(Tasktline,'RandP_data_plots\boundary_result.mat');
        
        cd(Tasktline);
        if ~isdir('./Categ_ROI_meanTrace/')
            mkdir('./Categ_ROI_meanTrace/');
        else
            Tasktline = fgetl(ff);
            Passtline = fgetl(Passtfid);
            continue;
        end
        
        ROITypeIndsStrc = load(SessionFitDataPath);
        categROIInds = find(ROITypeIndsStrc.IsCategROI);
        %
        SessFitDataStrc = load(SessionFitDataPath);
        SessBehavStrc = load(BehavData);
        %
        CagCoefFitAll = SessFitDataStrc.LogCoefFit;
        TunCoefFitAll = SessFitDataStrc.GauCoefFit;
        
        
        TaskDataStrc = load(fullfile(Tasktline,'CSessionData.mat'));
        PassDataStrc = load(fullfile(Passtline,'rfSelectDataSet.mat'));
        BehavDataPath = fullfile(Tasktline,'RandP_data_plots','boundary_result.mat');
        BehavDataStrc = load(BehavDataPath);
        BehavBound = BehavDataStrc.boundary_result.Boundary;
        
        % extract Task and passive data, plot it out 
        TaskTrFreq = double(TaskDataStrc.behavResults.Stim_toneFreq);
        TaskOutcome = TaskDataStrc.trial_outcome;
        TaskData = TaskDataStrc.data_aligned;
        nFrames = size(TaskData,3);
        nROIs = size(TaskData,2);
        DataRespWinT = 1; % using only 500ms time window for sensory response
        DataRespWinF = round(DataRespWinT*TaskDataStrc.frame_rate);
        TaskTime = (1:nFrames)/TaskDataStrc.frame_rate;
        NonMissTrInds = TaskOutcome ~= 2;
        CorrectInds = TaskOutcome == 1;

        NonMissFreqs = TaskTrFreq(NonMissTrInds);
        NonMissData = TaskData(NonMissTrInds,:,:);
        CorrTrFreqs = TaskTrFreq(CorrectInds);
        CorrTrData = TaskData(CorrectInds,:,:);

        FreqTypes = unique(TaskTrFreq);
        FreqNum = length(FreqTypes);
        CategROIFreqwiseData = zeros(length(categROIInds),FreqNum,nFrames);
        for cfreq = 1 : FreqNum
            cFreqInds = CorrTrFreqs == FreqTypes(cfreq);
            cFreqData = CorrTrData(cFreqInds,categROIInds,:);
            CategROIFreqwiseData(:,cfreq,:) = squeeze(mean(cFreqData));
        end

        % passive data extaction
        PassiveData = PassDataStrc.f_percent_change;
        nPassROI = size(PassiveData,2);
        if nPassROI > nROIs
            PassiveData = PassiveData(:,1:nROIs,:);
            nPassROI = nROIs;
        end
        PassRespWinT = 1;
        PassRespWinF = round(PassRespWinT*PassDataStrc.frame_rate);
%         PassRespData = max(PassiveData(:,:,(PassDataStrc.frame_rate+1):(PassDataStrc.frame_rate+PassRespWinF)),[],3);
%         PassFreqTypes = unique(PassDataStrc.sound_array(:,1));
        if length(unique(PassDataStrc.sound_array(:,2))) > 1
            UsedDBinds = PassDataStrc.sound_array(:,2) == 70 | PassDataStrc.sound_array(:,2) == 75;
            PassRespData = PassiveData(UsedDBinds,:,:);
            PassTrFreqAll = PassDataStrc.sound_array(UsedDBinds,1);
            PassFreqTypes = unique(PassDataStrc.sound_array(UsedDBinds,1));
        else
            PassRespData = PassiveData;
            PassFreqTypes = unique(PassDataStrc.sound_array(:,1));
            PassTrFreqAll = PassDataStrc.sound_array(:,1);
        end
        nPassFreq = length(PassFreqTypes);
%
        PassnFrames = size(PassRespData,3);
        PassTime = (1:PassnFrames)/PassDataStrc.frame_rate;
        nFreqs = length(PassFreqTypes);
        PassCategROIData = zeros(length(categROIInds),nFreqs,PassnFrames);
        
        for cFreq = 1 : nFreqs
            cFreqInds = PassTrFreqAll == PassFreqTypes(cFreq);
            cFreqData = PassRespData(cFreqInds,categROIInds,:);
            PassCategROIData(:,cFreq,:) = squeeze(mean(cFreqData));
        end
        %
        
        TaskOctaves = (log2(FreqTypes(:)/16000))';
        PassOctaves = (log2(PassFreqTypes(:)/16000))';
        PassWithinOctavesIn = find(abs(PassOctaves) < 1.02);
        PassWinOct = PassOctaves(PassWithinOctavesIn);
        disp(TaskOctaves);
        disp(PassWinOct);
        UsedInds = input('Please input the used freq Inds:\n','s');
        UseIndex = str2num(UsedInds);
        if ~isempty(UseIndex)
            PassUseFreqs = PassOctaves(UseIndex);
            PassUseData = PassRespData(:,UseIndex,:);
        else
            PassUseFreqs = PassOctaves;
            PassUseData = PassRespData;
        end
        nPassFreqNum = length(PassUseFreqs);
        
        cd('./Categ_ROI_meanTrace/');
        
%        ColorValueScales
        for cROI = 1 : length(categROIInds)
            %
            cROITData = squeeze(CategROIFreqwiseData(cROI,:,:));
            cROIPData = squeeze(PassCategROIData(cROI,:,:));
            
            hf = figure('position',[3000 100 640 340]);
            subplot(121);
            hold on
            for cTFreq = 1 : FreqNum
                cTFreqTrace = cROITData(cTFreq,:);
                [~,NearCIndex] = min(abs(ColorValueScales - TaskOctaves(cTFreq)));
                cTFreqColor = CusColors(NearCIndex,:);
                plot(TaskTime,cTFreqTrace,'Color',cTFreqColor,'linewidth',1.6);
            end
            yscales = get(gca,'ylim');
            FrameOnTime = TaskDataStrc.start_frame/TaskDataStrc.frame_rate;
            patch([FrameOnTime FrameOnTime FrameOnTime+0.3 FrameOnTime+0.3],[yscales(1) yscales(2) yscales(2) yscales(1)],...
                1,'FaceColor',[0 1 0],'EdgeColor','none','facealpha',0.4);
            xlabel('Time (s)');
            ylabel('\DeltaF/F (%)');
            title('Task');
            set(gca,'ylim',yscales);
            set(gca,'FontSize',14);
            
            subplot(122);
            hold on
            for cPFreq = 1 : nPassFreqNum
                cPFreqTrace = cROIPData(cPFreq,:);
                [~,NearCI] = min(abs(ColorValueScales - PassUseFreqs(cPFreq)));
                cPFreqColor = CusColors(NearCI,:);
                plot(PassTime,cPFreqTrace,'Color',cPFreqColor,'linewidth',1.6);
            end
            yscales = get(gca,'ylim');
            FrameOnTime = 1; %second
            patch([FrameOnTime FrameOnTime FrameOnTime+0.3 FrameOnTime+0.3],[yscales(1) yscales(2) yscales(2) yscales(1)],...
                1,'FaceColor',[0 1 0],'EdgeColor','none','facealpha',0.4);
            xlabel('Time (s)');
            ylabel('\DeltaF/F (%)');
            title('Passive');
            set(gca,'ylim',yscales);
            set(gca,'FontSize',14);
            
            suptitle(sprintf('ROI%d plot',categROIInds(cROI)));
            
            saveas(hf,sprintf('CategROI%d mean trace plot save',categROIInds(cROI)));
            saveas(hf,sprintf('CategROI%d mean trace plot save',categROIInds(cROI)),'png');
            close(hf);
        end
        cd ..;
        
        Tasktline = fgetl(ff);
        Passtline = fgetl(Passtfid);
end
        

%% export the data plots into a ppt file
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task data');

%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
ff = fopen(fpath);
Tasktline = fgetl(ff);
nSession = 1;

while ischar(Tasktline)
    if isempty(strfind(Tasktline,'NO_Correction\mode_f_change'))
       Tasktline = fgetl(ff);
        continue;
    end
    if nSession == 1
            %
%                 PPTname = input('Please input the name for current PPT file:\n','s');
            PPTname = 'CategROI_MeanTrace_plotSum';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'E:\DataToGo\data_for_xu\CategROI_MeanTrace';
            %
    end
    Anminfo = SessInfoExtraction(Tasktline);
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
    CategMeanTracePath = fullfile(Tasktline,'Categ_ROI_meanTrace');
    TunCurvePath = fullfile(Tasktline,'Tunning_fun_plot_New1s');
    Files = dir(fullfile(CategMeanTracePath,'CategROI* mean trace plot save.png'));
    BehavFpath = fullfile(Tasktline,'Tunning_fun_plot_New1s','Tuned freq colormap plot','Behavior and uncertainty curve plot.png');
    BehavIm = imread(BehavFpath);
    
    NF = length(Files);
    for cf = 1 : NF
        cfName = Files(cf).name;
        [StInds,EnInds] = regexp(cfName,'ROI\d{1,3}');
        cROINum = str2num(cfName(StInds+3:EnInds));
        MeanTraceIm = imread(fullfile(Tasktline,'Categ_ROI_meanTrace',cfName));
        TunPlotIm = imread(fullfile(Tasktline,'Tunning_fun_plot_New1s',sprintf('ROI%d Tunning curve comparison plot.png',cROINum)));
        
        
        exportToPPTX('addslide');
        exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[7.5 0 2 1],'FontSize',24);
        exportToPPTX('addnote',Tasktline);
        exportToPPTX('addpicture',MeanTraceIm,'Position',[0 1.5 6 3.2]);
        exportToPPTX('addpicture',TunPlotIm,'Position',[6.2 1.2 5 3.82]);
        exportToPPTX('addpicture',BehavIm,'Position',[12 1.5 4 3]);

        exportToPPTX('addtext',sprintf('Batch:%s Anm: %s\r\nDate: %sField: %s',...
            Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
            'Position',[7.5 5.5 4 3.5],'FontSize',22);
    end

%      m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     Tasktline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);
    