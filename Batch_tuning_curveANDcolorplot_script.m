% batched ROI morph plot
clearvars -except NormSessPathPass NormSessPathTask 
%%
nSessPath = length(NormSessPathTask);
CusMap = blue2red_2(32,0.8);
ErrorSessNum = [];
ErrorMes = {};
k_sess = 0;
%%
for cSess = 1 : nSessPath
    %
    if exist(fullfile(NormSessPathTask{cSess},'Tunning_fun_plot_New1s','TunningSTDDataSave.mat'),'file')
        continue;
    end
    try
    %
    Passtline = NormSessPathPass{cSess};
    Tasktline = NormSessPathTask{cSess};
     
    %
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
        
        BehavUsedBaseFreqs = double(min(BehavDataStrc.boundary_result.StimType));
        BoundFreq = BehavUsedBaseFreqs * 2;
        if isempty(BehavBound)
            BehavBound = BehavDataStrc.boundary_result.FitModelAll{1}{2}.ffit.u;
        end
        
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

%         NonMissTunningFun = zeros(FreqNum,nROIs);
%         NonMissTunningFunSEM = zeros(FreqNum,nROIs);
%         CorrTunningFun = zeros(FreqNum,nROIs);
%         CorrTunningFunSEM = zeros(FreqNum,nROIs);
        %
        Framescales = [(TaskDataStrc.start_frame+1+DataRespWinF(1)),(TaskDataStrc.start_frame+DataRespWinF(2))];
        
%         for nTFreq = 1 : FreqNum
%             cfreq = FreqTypes(nTFreq);
%             % non-miss data
%             cfreqInds = NonMissFreqs == cfreq;
%             cFreqDataNM = NonMissData(cfreqInds,:,:);

%             DataStrcNM = MeanMaxSEMCal(NonMissData,NonMissFreqs,Framescales);
            DataStrcNM = MeanMaxSEMCal(NonMissData,NonMissFreqs,Framescales);
            NonMissTunningFun = DataStrcNM.MeanValue;
            NonMissTunningFunSEM = DataStrcNM.SEMValue;
            NonMissTunningFunSTD = DataStrcNM.STDData;
            NonMissTunningCellData = DataStrcNM.MaxIndsDataAll;
            
            NMTypeNumber = DataStrcNM.TypeNumber;
            NMTypeFreqs = log2(DataStrcNM.CurrentTypes/BoundFreq);
            %correct data
%             cfreqInds = CorrTrFreqs == cfreq;
%             cFreqDataCorr = CorrTrData(cfreqInds,:,:);

%             DataStrcCorr = MeanMaxSEMCal(CorrTrData,CorrTrFreqs,Framescales);
            DataStrcCorr = MeanMaxSEMCal(CorrTrData,CorrTrFreqs,Framescales);
            CorrTunningFun = DataStrcCorr.MeanValue;
            CorrTunningFunSEM = DataStrcCorr.SEMValue;
            CorrTunningFunSTD = DataStrcCorr.STDData;
            CorrTunningCellData = DataStrcCorr.MaxIndsDataAll;
            CorrTypeNum = DataStrcCorr.TypeNumber;
            CorrTypeFreqs = log2(DataStrcCorr.CurrentTypes/BoundFreq);
%         end
        if size(NonMissTunningFun,1) ~= size(CorrTunningFun,1)
            
        end
        % passive data extaction
        PassiveData = PassDataStrc.f_percent_change;
        nPassROI = size(PassiveData,2);
        if nPassROI > nROIs
            PassiveData = PassiveData(:,1:nROIs,:);
            nPassROI = nROIs;
        end
%         PassRespWinT = 1;
%         PassRespWinF = round(PassRespWinT*PassDataStrc.frame_rate);
        PassFrameScale = [(PassDataStrc.frame_rate+1+DataRespWinF(1)),(PassDataStrc.frame_rate+DataRespWinF(2))];
        if length(unique(PassDataStrc.sound_array(:,2))) > 1
            UsedDBinds = PassDataStrc.sound_array(:,2) == 70 | PassDataStrc.sound_array(:,2) == 75;
%             PassRespData = MeanMaxSEMCal(PassiveData(UsedDBinds,:,:),PassDataStrc.sound_array(UsedDBinds,1),PassFrameScale);
            PassRespData = MeanMaxSEMCal(PassiveData(UsedDBinds,:,:),PassDataStrc.sound_array(UsedDBinds,1),PassFrameScale);
            PassFreqTypes = unique(PassDataStrc.sound_array(UsedDBinds,1));
            nPassFreq = length(PassFreqTypes);
        else
%             PassRespData = MeanMaxSEMCal(PassiveData,PassDataStrc.sound_array(:,1),PassFrameScale);
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
            PassTunningfunSTD = PassRespData.STDData;
            PassTunCellData = PassRespData.MaxIndsDataAll;
%         end
        %
        
        TaskFreqOctave = log2(FreqTypes/BoundFreq);
        FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
        PassFreqOctave = log2(PassFreqTypes/BoundFreq);
        BehavBound = BehavBound - 1; % convert into positive-negtive value
        if ~isdir('./Tunning_fun_plot_New1s/')
            mkdir('./Tunning_fun_plot_New1s/');
        end
        cd('./Tunning_fun_plot_New1s/');

        save TunningSTDDataSave.mat NonMissTunningFun CorrTunningFun PassTunningfun TaskFreqOctave ...
            PassFreqOctave BoundFreq NonMissTunningFunSEM CorrTunningFunSEM PassTunningfunSEM ...
            PassTunCellData CorrTunningCellData NonMissTunningCellData NMTypeNumber CorrTypeNum PassTunningfunSTD ...
            CorrTunningFunSTD NonMissTunningFunSTD -v7.3
        IsModuIndexExists = 0;
        if exist('NearBoundAmpDiffSig.mat','file')
            load('NearBoundAmpDiffSig.mat','TaskBoundModuIndex');
            IsModuIndexExists = 1;
        end
        for cROI = 1 : nROIs
            %
            PassPlotInds = abs(PassFreqOctave) < 1.03;
            h = figure('position',[220 300 550 420],'visible','off');
            hold on;
            cROItaskNM = NonMissTunningFun(:,cROI);
            cROItaskCorr = CorrTunningFun(:,cROI);
            cROIpass = PassTunningfun(:,cROI);
            l1 = errorbar(NMTypeFreqs,cROItaskNM,NonMissTunningFunSEM(:,cROI),'c-o','LineWidth',1.6);
            l2 = errorbar(CorrTypeFreqs,cROItaskCorr,CorrTunningFunSEM(:,cROI),'r-o','LineWidth',1.6);
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
    %
        tline = Tasktline;
        BehavBound = BoundFreq;
        ColorPlot_for_batch_script;
    catch ME
        k_sess = k_sess + 1;
        ErrorSessNum = [ErrorSessNum,cSess];
        ErrorMes{k_sess} = ME;
    end
    %
end