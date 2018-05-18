% batched tuning curve task and passive compare
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[TaskPathfn,TaskPathfp,TaskPathfi] = uigetfile('*.txt','Please select the Task session path save file');
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the corresponded passive session path save file');
if ~TaskPathfi || ~PassPathfi
    return;
end
%%
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
Tasktline = fgetl(Taskfid);
Passtline = fgetl(Passfid);
%%
SessionNum = 1;
ErrorNum = 0;
ErrorSess = {};
ErrorMess = {};
%%
while ischar(Tasktline) && ischar(Passtline)
    if isempty(strfind(Tasktline,'NO_Correction\mode_f_change'))  
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
        continue;
    end
    %
    try
        %%
        TaskDataStrc = load(fullfile(Tasktline,'CSessionData.mat'));
        PassDataStrc = load(fullfile(Passtline,'rfSelectDataSet.mat'));
        BehavDataPath = fullfile(Tasktline,'RandP_data_plots','boundary_result.mat');
        BehavDataStrc = load(BehavDataPath);
        BehavBound = BehavDataStrc.boundary_result.Boundary;
        cd(Tasktline);
        % extract Task and passive data, plot it out 
        TaskTrFreq = double(TaskDataStrc.behavResults.Stim_toneFreq);
        TaskOutcome = TaskDataStrc.trial_outcome;
        TaskData = TaskDataStrc.smooth_data;
        nROIs = size(TaskData,2);
        DataRespWinT = 1; % using only 500ms time window for sensory response
        DataRespWinF = round(DataRespWinT*TaskDataStrc.frame_rate);
        BaseResp = squeeze(mean(TaskData(:,:,1:TaskDataStrc.start_frame),3));
        TaskDataResp = max(TaskData(:,:,(TaskDataStrc.start_frame+1):(TaskDataStrc.start_frame+DataRespWinF)),[],3);
        %
        TaskDataResp = TaskDataResp - BaseResp;
        
        NonMissTrInds = TaskOutcome ~= 2;
        CorrectInds = TaskOutcome == 1;

        NonMissFreqs = TaskTrFreq(NonMissTrInds);
        NonMissData = TaskDataResp(NonMissTrInds,:);
        CorrTrFreqs = TaskTrFreq(CorrectInds);
        CorrTrData = TaskDataResp(CorrectInds,:);

        FreqTypes = unique(TaskTrFreq);
        FreqNum = length(FreqTypes);

        NonMissTunningFun = zeros(FreqNum,nROIs);
        NonMissTunningFunSEM = zeros(FreqNum,nROIs);
        CorrTunningFun = zeros(FreqNum,nROIs);
        CorrTunningFunSEM = zeros(FreqNum,nROIs);

        for nTFreq = 1 : FreqNum
            cfreq = FreqTypes(nTFreq);
            % non-miss data
            cfreqInds = NonMissFreqs == cfreq;
            cFreqDataNM = NonMissData(cfreqInds,:);
            MeanROIResp = mean(cFreqDataNM);
            NonMissTunningFun(nTFreq,:) = MeanROIResp;
            NonMissTunningFunSEM(nTFreq,:) = std(cFreqDataNM)/sqrt(size(cFreqDataNM,1));

            %correct data
            cfreqInds = CorrTrFreqs == cfreq;
            cFreqDataCorr = CorrTrData(cfreqInds,:);
            CorrTunningFun(nTFreq,:) = mean(cFreqDataCorr);
            CorrTunningFunSEM(nTFreq,:) = std(cFreqDataCorr)/sqrt(size(cFreqDataCorr,1));
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
            PassRespData = max(PassiveData(UsedDBinds,:,(PassDataStrc.frame_rate+1):(PassDataStrc.frame_rate+PassRespWinF)),[],3);
            PassTrFreqAll = PassDataStrc.sound_array(UsedDBinds,1);
            PassFreqTypes = unique(PassDataStrc.sound_array(UsedDBinds,1));
        else
            PassRespData = max(PassiveData(:,:,(PassDataStrc.frame_rate+1):(PassDataStrc.frame_rate+PassRespWinF)),[],3);
            PassFreqTypes = unique(PassDataStrc.sound_array(:,1));
            PassTrFreqAll = PassDataStrc.sound_array(:,1);
        end
        nPassFreq = length(PassFreqTypes);
%
        PassTunningfun = zeros(nPassFreq,nPassROI);
        PassTunningfunSEM = zeros(nPassFreq,nPassROI);
        for nnfreq = 1 : nPassFreq
            cPasFreq = PassFreqTypes(nnfreq);
            cFreqInds = PassTrFreqAll == cPasFreq;
            PassTunningfun(nnfreq,:) = mean(PassRespData(cFreqInds,:));
            PassTunningfunSEM(nnfreq,:) = std(PassRespData(cFreqInds,:))/size(PassRespData(cFreqInds,:),1);
        end
        %
        BoundFreq = 16000;
        TaskFreqOctave = log2(FreqTypes/BoundFreq);
        FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
        PassFreqOctave = log2(PassFreqTypes/BoundFreq);
        BehavBound = BehavBound - 1; % convert into positive-negtive value
        if ~isdir('./Tunning_fun_plot_1s/')
            mkdir('./Tunning_fun_plot_1s/');
        end
        cd('./Tunning_fun_plot_1s/');

        save TunningDataSave.mat NonMissTunningFun CorrTunningFun PassTunningfun TaskFreqOctave ...
            PassFreqOctave BoundFreq NonMissTunningFunSEM CorrTunningFunSEM PassTunningfunSEM -v7.3
        %
        for cROI = 1 : nROIs
            %
            PlotInds = abs(PassFreqOctave) < 1.01;
            h = figure('position',[220 300 550 420]);
            hold on;
            cROItaskNM = NonMissTunningFun(:,cROI);
            cROItaskCorr = CorrTunningFun(:,cROI);
            cROIpass = PassTunningfun(:,cROI);
            l1 = errorbar(TaskFreqOctave,cROItaskNM,NonMissTunningFunSEM(:,cROI),'c-o','LineWidth',1.6);
            l2 = errorbar(TaskFreqOctave,cROItaskCorr,CorrTunningFunSEM(:,cROI),'r-o','LineWidth',1.6);
            l3 = errorbar(PassFreqOctave(PlotInds),cROIpass(PlotInds),PassTunningfunSEM(PlotInds,cROI),'k-o','LineWidth',1.6);
            xlabel('Frequency (kHz)');
            ylabel('Mean \DeltaF/F (%)');
            title(sprintf('ROI%d Tunning, Session%d',cROI,SessionNum));
            set(gca,'FontSize',14);
            if max(abs(PassFreqOctave)) > 1.5
                set(gca,'xlim',[-2 2],'xtick',TaskFreqOctave,'xticklabel',FreqStrs);
            else
                set(gca,'xlim',[-1.5 1.5],'xtick',TaskFreqOctave,'xticklabel',FreqStrs);
            end
            legend([l1,l2,l3],{'Task Non-miss','Task Corr','Passive'},'FontSize',8,'location','NorthWest','FontSize',12);
            legend('boxoff')
            yscales = get(gca,'ylim');
            xscales = get(gca,'xlim');
            BoundPos = (BehavBound - xscales(1))/diff(xscales);
            line([BehavBound BehavBound],yscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
            if BehavBound < -1
                Arrowx = [BoundPos+0.2,BoundPos+0.1];
            elseif BehavBound < 0
                Arrowx = [BoundPos+0.2,BoundPos+0.03];
            else
                Arrowx = [BoundPos+0.2,BoundPos+0.01];
            end
            Arrowy = [0.85 0.85];
            a = annotation('textarrow',Arrowx,Arrowy,'String',{'Behav';'Bound'},'Color','m','FontSize',14);
            %
            saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI));
            saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI),'png');
            close(h);
        end
    %
        SessionNum = SessionNum + 1;
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
    catch ME
        ErrorNum = ErrorNum + 1;
        ErrorSess{ErrorNum} = Tasktline;
        ErrorMess{ErrorNum} = ME;
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
%         continue;
    end
    %
end

%%  test with mean trace calculation first
clearvars -except TaskPathfp TaskPathfn PassPathfp PassPathfn
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
Tasktline = fgetl(Taskfid);
Passtline = fgetl(Passfid);
%
SessionNum = 1;
ErrorNumNew = 0;
ErrorSessNew = {};
ErrorMessNew = {};
%
while ischar(Tasktline) && ischar(Passtline)
    if isempty(strfind(Tasktline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
        continue;
    end
    try
        %%
        clearvars -except Tasktline Passtline
        TaskDataStrc = load(fullfile(Tasktline,'CSessionData.mat'));
        PassDataStrc = load(fullfile(Passtline,'rfSelectDataSet.mat')); 
        BehavDataPath = fullfile(Tasktline,'RandP_data_plots','boundary_result.mat');
        cd(Tasktline);
        if ~exist(BehavDataPath,'file')
            BehavStrc = load(fullfile(Tasktline,'CSessionData.mat'),'behavResults');
            rand_plot(BehavStrc.behavResults,4,[],1);
        end
        BehavDataStrc = load(BehavDataPath);
        BehavBound = BehavDataStrc.boundary_result.Boundary;
        if isempty(BehavBound)
            BehavBound = BehavDataStrc.boundary_result.FitModelAll{1}{2}.ffit.u;
        end
%         AlignedSortPlotAll(TaskDataStrc.data,TaskDataStrc.behavResults,TaskDataStrc.frame_rate,TaskDataStrc.FRewardLickT,TaskDataStrc.frame_lickAllTrials);
        
        % extract Task and passive data, plot it out 
        TaskTrFreq = double(TaskDataStrc.behavResults.Stim_toneFreq);
        TaskOutcome = TaskDataStrc.trial_outcome;
        TaskData = TaskDataStrc.data_aligned;
        nTrials = size(TaskData,1);
        TestData = squeeze(TaskData(1,1,:));
        if sum(isnan(TestData))
            warning('Nan data exists.');
            TrFrameNums = zeros(nTrials,1);
            for cTr = 1 : nTrials
                cTrData = squeeze(TaskData(cTr,1,:));
                if isempty(find(isnan(cTrData),1,'first'))
                    TrFrameNums(cTr) = length(cTrData);
                else
                    TrFrameNums(cTr) = find(isnan(cTrData),1,'first') - 1;
                end
            end
            UsedFrame = min(TrFrameNums);
            BackData = TaskData;
            UsedTaskData = TaskData(:,:,1:UsedFrame);
        else
            UsedTaskData = TaskData;
        end
        
        BefStimBase = repmat(mean(UsedTaskData(:,:,1:TaskDataStrc.start_frame),3),1,1,size(UsedTaskData,3));
        UsedTaskData = UsedTaskData - BefStimBase;
        
        %
        nROIs = size(UsedTaskData,2);
        DataRespWinT = [0 1]; % using only 1s time window for sensory response
        DataRespWinF = round(DataRespWinT*TaskDataStrc.frame_rate);
        % TaskDataResp = max(TaskData(:,:,(TaskDataStrc.start_frame+1):(TaskDataStrc.start_frame+DataRespWinF)),[],3);
        NonMissTrInds = TaskOutcome ~= 2;
        CorrectInds = TaskOutcome == 1;

        NonMissFreqs = TaskTrFreq(NonMissTrInds);
        NonMissData = UsedTaskData(NonMissTrInds,:,:);
        CorrTrFreqs = TaskTrFreq(CorrectInds);
        CorrTrData = UsedTaskData(CorrectInds,:,:);

        FreqTypes = unique(TaskTrFreq);
        FreqNum = length(FreqTypes);

        NonMissTunningFun = zeros(FreqNum,nROIs);
        NonMissTunningFunSEM = zeros(FreqNum,nROIs);
        CorrTunningFun = zeros(FreqNum,nROIs);
        CorrTunningFunSEM = zeros(FreqNum,nROIs);
        %
        Framescales = [(TaskDataStrc.start_frame+1+DataRespWinF(1)),(TaskDataStrc.start_frame+DataRespWinF(2))];
        
%         for nTFreq = 1 : FreqNum
%             cfreq = FreqTypes(nTFreq);
%             % non-miss data
%             cfreqInds = NonMissFreqs == cfreq;
%             cFreqDataNM = NonMissData(cfreqInds,:,:);
            DataStrcNM = MeanMaxSEMCal(NonMissData,NonMissFreqs,Framescales);
            NonMissTunningFun = DataStrcNM.MeanValue;
            NonMissTunningFunSEM = DataStrcNM.SEMValue;
            NonMissTunningCellData = DataStrcNM.MaxIndsDataAll;

            %correct data
%             cfreqInds = CorrTrFreqs == cfreq;
%             cFreqDataCorr = CorrTrData(cfreqInds,:,:);
            DataStrcCorr = MeanMaxSEMCal(CorrTrData,CorrTrFreqs,Framescales);
            CorrTunningFun = DataStrcCorr.MeanValue;
            CorrTunningFunSEM = DataStrcCorr.SEMValue;
            CorrTunningCellData = DataStrcCorr.MaxIndsDataAll;
%         end

        % passive data extaction
        PassiveData = PassDataStrc.f_percent_change;
        nPassROI = size(PassiveData,2);
        if nPassROI > nROIs
            PassiveData = PassiveData(:,1:nROIs,:);
            nPassROI = nROIs;
        end
%         PassRespWinT = 1;
%         PassRespWinF = round(PassRespWinT*PassDataStrc.frame_rate);
        PassFrameScale = [(PassDataStrc.frame_rate+1+DataRespWinF(1)),(PassDataStrc.frame_rate++DataRespWinF(2))];
        if length(unique(PassDataStrc.sound_array(:,2))) > 1
            UsedDBinds = PassDataStrc.sound_array(:,2) == 70 | PassDataStrc.sound_array(:,2) == 75;
            PassRespData = MeanMaxSEMCal(PassiveData(UsedDBinds,:,:),PassDataStrc.sound_array(UsedDBinds,1),PassFrameScale);
            PassFreqTypes = unique(PassDataStrc.sound_array(UsedDBinds,1));
            nPassFreq = length(PassFreqTypes);
        else
            PassRespData = MeanMaxSEMCal(PassiveData,PassDataStrc.sound_array(:,1),PassFrameScale);
            PassFreqTypes = unique(PassDataStrc.sound_array(:,1));
            nPassFreq = length(PassFreqTypes);
        end
%         PassRespData = max(PassiveData(:,:,(PassDataStrc.frame_rate+1):(PassDataStrc.frame_rate+PassRespWinF)),[],3);
        

%         PassTunningfun = zeros(nPassFreq,nPassROI);
%         PassTunningfunSEM = zeros(nPassFreq,nPassROI);
%         for nnfreq = 1 : nPassFreq
%             cPasFreq = PassFreqTypes(nnfreq);
%             cFreqInds = PassDataStrc.sound_array(:,1) == cPasFreq;
            PassTunningfun = PassRespData.MeanValue;
            PassTunningfunSEM = PassRespData.SEMValue;
            PassTunCellData = PassRespData.MaxIndsDataAll;
%         end
        %
        BoundFreq = 16000;
        TaskFreqOctave = log2(FreqTypes/BoundFreq);
        FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
        PassFreqOctave = log2(PassFreqTypes/BoundFreq);
        BehavBound = BehavBound - 1; % convert into positive-negtive value
        if ~isdir('./Tunning_fun_plot_New1s/')
            mkdir('./Tunning_fun_plot_New1s/');
        end
        cd('./Tunning_fun_plot_New1s/');

        save TunningDataSave.mat NonMissTunningFun CorrTunningFun PassTunningfun TaskFreqOctave ...
            PassFreqOctave BoundFreq NonMissTunningFunSEM CorrTunningFunSEM PassTunningfunSEM ...
            PassTunCellData CorrTunningCellData NonMissTunningCellData -v7.3
        IsModuIndexExists = 0;
        if exist('NearBoundAmpDiffSig.mat','file')
            load('NearBoundAmpDiffSig.mat','TaskBoundModuIndex');
            IsModuIndexExists = 1;
        end
        for cROI = 1 : nROIs
            %
            PassPlotInds = abs(PassFreqOctave) < 1.03;
            h = figure('position',[220 300 550 420]);
            hold on;
            cROItaskNM = NonMissTunningFun(:,cROI);
            cROItaskCorr = CorrTunningFun(:,cROI);
            cROIpass = PassTunningfun(:,cROI);
            l1 = errorbar(TaskFreqOctave,cROItaskNM,NonMissTunningFunSEM(:,cROI),'c-o','LineWidth',1.6);
            l2 = errorbar(TaskFreqOctave,cROItaskCorr,CorrTunningFunSEM(:,cROI),'r-o','LineWidth',1.6);
            l3 = errorbar(PassFreqOctave(PassPlotInds),cROIpass(PassPlotInds),PassTunningfunSEM(PassPlotInds,cROI),'k-o','LineWidth',1.6);
            xlabel('Frequency (kHz)');
            ylabel('Mean \DeltaF/F (%)');
            if IsModuIndexExists
                title(sprintf('ROI%d Tunning, BoundModu %.3f',cROI,TaskBoundModuIndex(cROI)));
                set(gca,'FontSize',10);
            else
                title(sprintf('ROI%d Tunning',cROI));
                set(gca,'FontSize',14);
            end
            
            if max(abs(PassFreqOctave)) > 1.5
                set(gca,'xlim',[-2 2],'xtick',TaskFreqOctave,'xticklabel',FreqStrs);
            else
                set(gca,'xlim',[-1.5 1.5],'xtick',TaskFreqOctave,'xticklabel',FreqStrs);
            end
            legend([l1,l2,l3],{'Task Non-miss','Task Corr','Passive'},'FontSize',8,'location','NorthWest','FontSize',12);
            legend('boxoff')
            yscales = get(gca,'ylim');
            xscales = get(gca,'xlim');
            
            BoundPos = (BehavBound - xscales(1))/diff(xscales);
            line([BehavBound BehavBound],yscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
            if BehavBound < 0
                Arrowx = [BoundPos+0.1,BoundPos+0.03];
            else
                Arrowx = [BoundPos+0.1,BoundPos+0.01];
            end
            Arrowy = [0.85 0.85];
            a = annotation('textarrow',Arrowx,Arrowy,'String',{'Behav';'Bound'},'Color','m','FontSize',14);
            %
            saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI));
            saveas(h,sprintf('ROI%d Tunning curve comparison plot',cROI),'png');
            close(h);
        end
    %%
        SessionNum = SessionNum + 1;
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
        %%
    catch ME
        ErrorNumNew = ErrorNumNew + 1;
        ErrorSessNew{ErrorNumNew} = Tasktline;
        ErrorMessNew{ErrorNumNew} = ME;
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
        continue;
    end
end

%%
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
Tasktline = fgetl(Taskfid);
Passtline = fgetl(Passfid);
nSess = 1;

while ischar(Tasktline) && ischar(Passtline)
    if isempty(strfind(Tasktline,'NO_Correction\mode_f_change'))  
        Tasktline = fgetl(Taskfid);
        Passtline = fgetl(Passfid);
        continue;
    end
    %
    NewTaskPath = ['N',Tasktline(2:end)];
    NewPassPath = ['N',Passtline(2:end)];
%     mkdir(NewTaskPath);
%     mkdir(NewPassPath);
%     [StartInds,EndInds] = regexp(Tasktline,'result_save');
%     Status = copyfile(Tasktline(1:EndInds),NewTaskPath(1:EndInds));
    [PStartInds,PEndInds] = regexp(Passtline,'result_save');
    Status2 = copyfile(Passtline(1:PEndInds),NewPassPath(1:PEndInds));
    fprintf('Sess%d File Copy %d.\n',nSess,Status2);
    
    Tasktline = fgetl(Taskfid);
    Passtline = fgetl(Passfid);
    nSess = nSess + 1;
end