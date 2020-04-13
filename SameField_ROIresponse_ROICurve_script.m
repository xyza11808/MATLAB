cclr
%
SessPathAll = {...
    'S:\BatchData\batch58\20181031\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181101\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181102\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181104\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181106\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};

NumSesss = length(SessPathAll);
AnmInfoCell = cellfun(@(x) SessInfoExtraction(x),SessPathAll,'UniformOutput',false);

SessPassPathAlls = cell(NumSesss,1);
for cSess = 1 : NumSesss
    [StartInds,EndInds] = regexp(SessPathAll{cSess},'test\d{2,3}');
    
    if EndInds-StartInds > 5
        EndInds = EndInds - 1; % in case of a repeated session sub imaging serial number
    end
    
    cPassDataUpperPath = fullfile(sprintf('%srf',SessPathAll{cSess}(1:EndInds)),'im_data_reg_cpu','result_save');

    PassPathline = fullfile(cPassDataUpperPath,'plot_save','NO_Correction');
    SessPassPathAlls{cSess} = PassPathline;
end

%%
UsedTrTypeCell = {'All','Nonmiss','Corr'};
TypeIndex = 3;

SessDatas = cell(NumSesss,8);
SessBehavDatas = cell(NumSesss,1);
SessABSAUCDatas = cell(NumSesss,2);
for cSess = 1 : NumSesss
    %
    cSessPath = SessPathAll{cSess};
    ROIUsedInds_path = fullfile(cSessPath,'Tunning_fun_plot_New1s','SelectROIIndex.mat'); 
    TunData_path = fullfile(cSessPath,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat');
    TaskBehav_path = fullfile(cSessPath,'RandP_data_plots','boundary_result.mat');
%     SessROIsRawData_path = fullfile(cSessPath,'CSessionData.mat');
    
    ROIUsedInds_strc = load(ROIUsedInds_path,'ROIIndex');
%     SessROIsRawData_strc = load(SessROIsRawData_path);
    SessTunData_strc = load(TunData_path);
    TaskBehav_strc = load(TaskBehav_path);
    
    SessDatas{cSess,1} = {SessTunData_strc.CorrTunningFun,SessTunData_strc.CorrTunningFunSEM};
    SessDatas{cSess,2} = {SessTunData_strc.PassTunningfun,SessTunData_strc.PassTunningfunSEM};
    SessDatas{cSess,3} = {SessTunData_strc.TaskFreqOctave,SessTunData_strc.PassFreqOctave};
    SessDatas{cSess,4} = SessTunData_strc.BoundFreq;
    SessDatas{cSess,5} = ROIUsedInds_strc.ROIIndex;
    SessDatas{cSess,6} = TaskBehav_strc.boundary_result.Boundary - 1;
    
    % load response field datas
    Task_RespField_dataPath = fullfile(cSessPath,'SP_RespField_ana','SigSelectiveROIInds.mat');
    Task_RespField_data_strc = load(Task_RespField_dataPath);
    Pass_RespField_dataPath = fullfile(SessPassPathAlls{cSess},'SP_RespField_ana','PassCoefMtxSave_New.mat');
    Pass_RespField_data_strc = load(Pass_RespField_dataPath);
    
    SessDatas{cSess,7} = {Task_RespField_data_strc.SigROIInds,Task_RespField_data_strc.SigROICoefMtx,...
        Task_RespField_data_strc.LAnsMergedInds,Task_RespField_data_strc.RAnsMergedInds};
    SessDatas{cSess,8} = {Pass_RespField_data_strc.PassRespROIInds,Pass_RespField_data_strc.PassRespCoefMtx};
    
    SessBehavDatas{cSess} = TaskBehav_strc.boundary_result;
    
    % load single neuron AUC datas
    TaskAUCData_path = fullfile(cSessPath,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat');
    TaskAUCData_Strc = load(TaskAUCData_path);
    IsAUC_revert = TaskAUCData_Strc.ROCRevert > 0;
    Task_ROIAUC_ABS = TaskAUCData_Strc.ROCarea;
    Task_ROIAUC_ABS(IsAUC_revert) = 1 - Task_ROIAUC_ABS(IsAUC_revert);
    SessABSAUCDatas{cSess,1} = Task_ROIAUC_ABS;
    SessABSAUCDatas{cSess,2} = TaskAUCData_Strc.ROCShufflearea;
    
end

%
MinROINums = min(cellfun(@numel,SessDatas(:,5)));
CommmonUsedROIIndexCell = cellfun(@(x) x(1:MinROINums) > 0,SessDatas(:,5),'UniformOutput',false);
CommmonUsedROI_Mtx = cell2mat(CommmonUsedROIIndexCell');
CommmonUsedROIIndex = mean(CommmonUsedROI_Mtx,2) == 1;

%% plot the results
plottedROIindex = find(CommmonUsedROIIndex);
xtickstrs = {'8.0';'16.0';'32.0'};

cPlotROI_Inds = 40;
cROI_realIndex = plottedROIindex(cPlotROI_Inds);
close;
hccf = figure('position',[2400 250 1200 690]);
for cSess = 1 : NumSesss
    
    cSess_cROI_Task_Data = SessDatas{cSess,1}{1}(:,cROI_realIndex);
    cSess_cROI_Task_SEM = SessDatas{cSess,1}{2}(:,cROI_realIndex);
    
    PassDataUsedInds = true(size(SessDatas{cSess,2}{1},1),1);
    if size(SessDatas{cSess,2}{1},1) > numel(SessDatas{cSess,3}{2})
        Pass_ExcludeIndex = ceil(size(SessDatas{cSess,2}{1},1)/2);
        PassDataUsedInds(Pass_ExcludeIndex) = false;
    end
    cSess_cROI_Pass_Data = SessDatas{cSess,2}{1}(PassDataUsedInds,cROI_realIndex);
    cSess_cROI_Pass_SEM = SessDatas{cSess,2}{2}(PassDataUsedInds,cROI_realIndex);
    cSess_Task_Octave = SessDatas{cSess,3}{1};
    cSess_Pass_Octave = SessDatas{cSess,3}{2};
    
    cSess_task_field_datas = SessDatas{cSess,7};
    cSess_pass_field_datas = SessDatas{cSess,8};
    
    subplot(2,3,cSess);
    hold on
    errorbar(cSess_Task_Octave,cSess_cROI_Task_Data,cSess_cROI_Task_SEM,'r-o','linewidth',1.5);
    errorbar(cSess_Pass_Octave,cSess_cROI_Pass_Data,cSess_cROI_Pass_SEM,'k-o','linewidth',1.5);
    yscales = get(gca,'ylim');
    line(SessDatas{cSess,6}*[1 1],yscales,'Color',[.5 .5 .5],'linewidth',1.4,'linestyle','--');
    
    if ~isempty(cSess_task_field_datas{1})
        % freq response ROI exists
        if sum(cSess_task_field_datas{1} == cROI_realIndex) % if the ROI within responsive ROIs
            FieldMtx_inds = cSess_task_field_datas{1} == cROI_realIndex;
            cROI_respFields = cSess_task_field_datas{2}(FieldMtx_inds,:);
            RespFreqIndex = (cROI_respFields > 0);
            text(cSess_Task_Octave(RespFreqIndex),ones(sum(RespFreqIndex),1)*yscales(2)*0.99,...
                '#','Color','m','FontSize',16,'HorizontalAlignment','center','linewidth',2);
        end
    end
    if ~isempty(cSess_pass_field_datas{1})
        % passive freq response ROIs
            if sum(cSess_pass_field_datas{1} == cROI_realIndex) % if ROI within responsive ROIs
                FieldMtx_inds = cSess_pass_field_datas{1} == cROI_realIndex;
                cPass_respFields = cSess_pass_field_datas{2}(FieldMtx_inds,:);
                PassRespInds = (cPass_respFields > 0);
                text(cSess_Pass_Octave(PassRespInds),ones(sum(PassRespInds),1)*yscales(2)*0.95,...
                    '$','Color',[0.1 0.6 0.1],'FontSize',14,'HorizontalAlignment','center','linewidth',2);
            end
    end
    if ~isempty(cSess_task_field_datas{3})
        % left answer response ROI exists
        if sum(cSess_task_field_datas{3} == cROI_realIndex) % if Current ROI was left answer response
            text(-0.5,yscales(1)+5,'Left','Color','b','FontSize',10,'HorizontalAlignment','center');
        end
    end
    if ~isempty(cSess_task_field_datas{4})
        % left answer response ROI exists
        if sum(cSess_task_field_datas{4} == cROI_realIndex) % if Current ROI was left answer response
            text(0.5,yscales(1)+5,'Right','Color','r','FontSize',10,'HorizontalAlignment','center');
        end
    end
    
    set(gca,'xlim',[min(cSess_Pass_Octave)-0.05 max(cSess_Pass_Octave)+0.05],'xtick',-1:1,...
        'xticklabel',xtickstrs,'ylim',yscales);
    title([AnmInfoCell{cSess}.SessionDate,'  ',num2str(cROI_realIndex,'ROI%d')]);
    
end

%% Average All ROIs' tuning curve data together
plottedROIindex = find(CommmonUsedROIIndex);
xtickstrs = {'8.0';'16.0';'32.0'};

% cPlotROI_Inds = 46;
% cROI_realIndex = plottedROIindex(cPlotROI_Inds);
% close;
hccf = figure('position',[200 250 1400 690]);
for cSess = 1 : NumSesss
    
    cSess_cROI_Task_Data = SessDatas{cSess,1}{1}(:,plottedROIindex);
%     cSess_cROI_Task_SEM = SessDatas{cSess,1}{2}(:,cROI_realIndex);
    cSess_cROI_Pass_Data = SessDatas{cSess,2}{1}(:,plottedROIindex);
%     cSess_cROI_Pass_SEM = SessDatas{cSess,2}{2}(:,cROI_realIndex);
    cSess_Task_Octave = SessDatas{cSess,3}{1};
    cSess_Pass_Octave = SessDatas{cSess,3}{2};
    
    cSess_ROI_Task_zsData = zscore(cSess_cROI_Task_Data);
    cSess_ROI_Pass_zsData = zscore(cSess_cROI_Pass_Data);
    
    Sess_Task_zsData_Avg = mean(cSess_ROI_Task_zsData,2);
    Sess_Task_zsData_Sem = std(cSess_ROI_Task_zsData,[],2)/sqrt(size(cSess_ROI_Task_zsData,2));
    if size(cSess_ROI_Pass_zsData,1) > numel(cSess_Pass_Octave)
        cSess_ROI_Pass_zsData(ceil(size(cSess_ROI_Pass_zsData,1)/2),:) = [];
    end
    Sess_Pass_zsData_Avg = mean(cSess_ROI_Pass_zsData,2);
    Sess_Pass_zsData_Sem = std(cSess_ROI_Pass_zsData,[],2)/sqrt(size(cSess_ROI_Pass_zsData,2));
    if NumSesss > 6
       subplot(2,4,cSess);
    else
        subplot(2,3,cSess);
    end
    
    yyaxis right
    cBehavDataStrc = SessBehavDatas{cSess};
    RightwardProbs = cBehavDataStrc.StimCorr;
    LeftStimInds = cBehavDataStrc.RevertStimRProb;
%     RightwardProbs = BehaOctave_perf;
    RightwardProbs(LeftStimInds) = 1 - RightwardProbs(LeftStimInds);
    RightStimOctaves = log2(cBehavDataStrc.StimType / min(cBehavDataStrc.StimType)) - 1;
    
    hold on
    plot(RightStimOctaves,RightwardProbs,'bo','markerSize',10,'linewidth',1.5);
    plot(cBehavDataStrc.FitValue.curve(:,1)-1,cBehavDataStrc.FitValue.curve(:,2),...
        'c','linewidth',1.5);
    set(gca,'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
    ylabel('Right Prob.');
    set(gca,'yColor','c');
    
    yyaxis left
    hold on
    errorbar(cSess_Task_Octave,Sess_Task_zsData_Avg,Sess_Task_zsData_Sem,'r-o','linewidth',1.5);
    errorbar(cSess_Pass_Octave,Sess_Pass_zsData_Avg,Sess_Pass_zsData_Sem,'k-o','linewidth',1.5);
    plot(cSess_Task_Octave,Sess_Task_zsData_Avg-Sess_Pass_zsData_Avg,'m--o','linewidth',1.5);
    yscales = get(gca,'ylim');
    line(SessDatas{cSess,6}*[1 1],yscales,'Color',[.5 .5 .5],'linewidth',1.4,'linestyle','--');
    
    set(gca,'xlim',[min(cSess_Pass_Octave)-0.05 max(cSess_Pass_Octave)+0.05],'xtick',-1:1,...
        'xticklabel',xtickstrs,'ylim',yscales);
    title(['A600101\_',AnmInfoCell{cSess}.SessionDate]);
end
%% plot the response field change at two condition
plottedROIindex = find(CommmonUsedROIIndex);
xtickstrs = {'8.0';'16.0';'32.0'};

% cPlotROI_Inds = 46;
% cROI_realIndex = plottedROIindex(cPlotROI_Inds);
% close;
hccf = figure('position',[2400 250 1400 690]);
for cSess = 1 : NumSesss
    cSess_task_field_datas = SessDatas{cSess,7};
    cSess_pass_field_datas = SessDatas{cSess,8};
    
    TaskSigROIInds = cSess_task_field_datas{1};
    TaskSig_CoefMtx = cSess_task_field_datas{2};
    PassSigROIInds = cSess_pass_field_datas{1};
    PassSig_CoefMtx = cSess_pass_field_datas{2};
    cSess_Task_Octave = SessDatas{cSess,3}{1};
    if size(PassSig_CoefMtx,2) > numel(cSess_Task_Octave)
        PassSig_CoefMtx(:,ceil(size(PassSig_CoefMtx,2)/2)) = [];
    end
    
    %
    MaxROIIndes = max(max(TaskSigROIInds),max(PassSigROIInds));
    FreqsNums = size(TaskSig_CoefMtx,2);
    TaskCoefMtxAlls = zeros(MaxROIIndes,FreqsNums);
    PassCoefMtxAlls = zeros(MaxROIIndes,FreqsNums);

    TaskCoefMtxAlls(TaskSigROIInds,:) = TaskSig_CoefMtx;
    PassCoefMtxAlls(PassSigROIInds,:) = PassSig_CoefMtx;
    EitherROICoef_Inds = sum(TaskCoefMtxAlls,2) > 0 | sum(PassCoefMtxAlls,2) > 0;

    Task_MergeCoefMtx = TaskCoefMtxAlls(EitherROICoef_Inds,:) > 0;
    Pass_MergeCoefMtx = PassCoefMtxAlls(EitherROICoef_Inds,:) > 0;
    %
    BothRespInds = sum(Task_MergeCoefMtx & Pass_MergeCoefMtx);
    TaskPass_DiffMtx = Task_MergeCoefMtx - Pass_MergeCoefMtx;
    BothFieldInds = sum(BothRespInds);
    TaskEnhanceInds = sum(TaskPass_DiffMtx > 0);
    TaskInhibitInds = sum(TaskPass_DiffMtx < 0);
    TaskFieldNums = sum(Task_MergeCoefMtx(:));
    
    cBehavDataStrc = SessBehavDatas{cSess};
    
    if NumSesss > 6
       subplot(2,4,cSess);
    else
        subplot(2,3,cSess);
    end
    
    RightwardProbs = cBehavDataStrc.StimCorr;
    LeftStimInds = cBehavDataStrc.RevertStimRProb;
%     RightwardProbs = BehaOctave_perf;
    RightwardProbs(LeftStimInds) = 1 - RightwardProbs(LeftStimInds);
    RightStimOctaves = log2(cBehavDataStrc.StimType / min(cBehavDataStrc.StimType)) - 1;
    
    yyaxis left
    hold on
    plot(RightStimOctaves,RightwardProbs,'bo','markerSize',10,'linewidth',1.5);
    plot(cBehavDataStrc.FitValue.curve(:,1)-1,cBehavDataStrc.FitValue.curve(:,2),...
        'c','linewidth',1.5);
    set(gca,'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
    ylabel('Right Prob.');
    
    yyaxis right
    hold on
    hl1 = plot(cSess_Task_Octave,BothRespInds/TaskFieldNums,'Color',[.5 .5 .5],'linewidth',1.5);
    hl2 = plot(cSess_Task_Octave,TaskEnhanceInds/TaskFieldNums,'Color','r','linewidth',1.5,'linestyle','-');
    hl3 = plot(cSess_Task_Octave,TaskInhibitInds/TaskFieldNums,'Color','b','linewidth',1.5,'linestyle','-');
    yscales = get(gca,'ylim');
    line(SessDatas{cSess,6}*[1 1],[-0.05 1],'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
    set(gca,'ylim',[-0.05 max(0.5,yscales(2))]);
    legend([hl1,hl2,hl3],{'Both','Enhan','Inhibt'},'location','northwest','box','off','FontSize',8)
    title([AnmInfoCell{cSess}.SessionDate,'  ','60\_0203']);
    ylabel('Frac.')
    
end

%%
saveas(gcf,'Field change curve plot b60a0203 with09session');
saveas(gcf,'Field change curve plot b60a0203 with09session','png');

%% plot the response field coef data for each condition
%% plot the response field change at two condition
plottedROIindex = find(CommmonUsedROIIndex);
xtickstrs = {'8.0';'16.0';'32.0'};

% cPlotROI_Inds = 46;
% cROI_realIndex = plottedROIindex(cPlotROI_Inds);
% close;
hccf = figure('position',[200 250 1400 690]);
for cSess = 1 : NumSesss
    cSess_task_field_datas = SessDatas{cSess,7};
    cSess_pass_field_datas = SessDatas{cSess,8};
    
    TaskSigROIInds = cSess_task_field_datas{1};
    TaskSig_CoefMtx = cSess_task_field_datas{2};
    PassSigROIInds = cSess_pass_field_datas{1};
    PassSig_CoefMtx = cSess_pass_field_datas{2};
    cSess_Task_Octave = SessDatas{cSess,3}{1};
    if size(PassSig_CoefMtx,2) > numel(cSess_Task_Octave)
        PassSig_CoefMtx(:,ceil(size(PassSig_CoefMtx,2)/2)) = [];
    end
    
    %
    MaxROIIndes = max(max(TaskSigROIInds),max(PassSigROIInds));
    FreqsNums = size(TaskSig_CoefMtx,2);
    TaskCoefMtxAlls = zeros(MaxROIIndes,FreqsNums);
    PassCoefMtxAlls = zeros(MaxROIIndes,FreqsNums);

    TaskCoefMtxAlls(TaskSigROIInds,:) = TaskSig_CoefMtx;
    PassCoefMtxAlls(PassSigROIInds,:) = PassSig_CoefMtx;
    EitherROICoef_Inds = sum(TaskCoefMtxAlls,2) > 0 | sum(PassCoefMtxAlls,2) > 0;
    %
    Task_MergeCoefMtx = TaskCoefMtxAlls(EitherROICoef_Inds,:);
    Pass_MergeCoefMtx = PassCoefMtxAlls(EitherROICoef_Inds,:);
    
    Task_MergeCoef_maxValue = max(Task_MergeCoefMtx,[],2);
    Task_MergeCoef_maxValue(Task_MergeCoef_maxValue == 0) = 1;
    Task_CoefNormed_mtx = Task_MergeCoefMtx ./ repmat(Task_MergeCoef_maxValue,1,...
        numel(cSess_Task_Octave));
    
    Pass_MergeCoef_maxValue = max(Pass_MergeCoefMtx,[],2);
    Pass_MergeCoef_maxValue(Pass_MergeCoef_maxValue == 0) = 1;
    Pass_CoefNormed_mtx = Pass_MergeCoefMtx ./ repmat(Pass_MergeCoef_maxValue,1,...
        numel(cSess_Task_Octave));
    
    Task_NormedCoef_Avg = mean(Task_CoefNormed_mtx);
    Task_NormedCoef_SEM = std(Task_CoefNormed_mtx)/sqrt(size(Task_CoefNormed_mtx,1));
    
    Pass_NormedCoef_Avg = mean(Pass_CoefNormed_mtx);
    Pass_NormedCoef_SEM = std(Pass_CoefNormed_mtx)/sqrt(size(Pass_CoefNormed_mtx,1));
    %
    cBehavDataStrc = SessBehavDatas{cSess};
    
    if NumSesss > 6
       subplot(2,4,cSess);
    else
        subplot(2,3,cSess);
    end
    
    RightwardProbs = cBehavDataStrc.StimCorr;
    LeftStimInds = cBehavDataStrc.RevertStimRProb;
%     RightwardProbs = BehaOctave_perf;
    RightwardProbs(LeftStimInds) = 1 - RightwardProbs(LeftStimInds);
    RightStimOctaves = log2(cBehavDataStrc.StimType / min(cBehavDataStrc.StimType)) - 1;
    
    yyaxis left
    hold on
    plot(RightStimOctaves,RightwardProbs,'bo','markerSize',10,'linewidth',1.5);
    plot(cBehavDataStrc.FitValue.curve(:,1)-1,cBehavDataStrc.FitValue.curve(:,2),...
        'c','linewidth',1.5);
    set(gca,'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
    ylabel('Right Prob.');
    
    yyaxis right
    hold on
    hl1 = errorbar(cSess_Task_Octave,Task_NormedCoef_Avg,Task_NormedCoef_SEM,...
        'Color','r','linewidth',1.5,'linestyle','-');
    hl2 = errorbar(cSess_Task_Octave,Pass_NormedCoef_Avg,Pass_NormedCoef_SEM,...
        'Color','k','linewidth',1.5,'linestyle','-');
    yscales = get(gca,'ylim');
    line(SessDatas{cSess,6}*[1 1],[-0.05 1],'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
    set(gca,'ylim',yscales,'xtick',-1:1,'xticklabel',xtickstrs);
%     legend([hl1,hl2],{'Task','Pass'},'location','northwest','box','off','FontSize',8)
    title([AnmInfoCell{cSess}.SessionDate,'  ','60\_0503']);
    ylabel('Frac.')
    xlabel('Freq (kHz)');
    
end

%%
saveas(gcf,'Field coef average plot b60a0503 with09session');
saveas(gcf,'Field coef average plot b60a0503 with09session','png');

%% plot AUC change datas
% plot the results
StartLine = -1;
% hccf = figure('position',[200 250 1200 690]);
CommonROIData_cell = cell(NumSesss,2);
Session_TaskPerf = cell(NumSesss,2);
for cSess = 1 : NumSesss
    cSessAUCs = SessABSAUCDatas{cSess,1};
    CommonROIData_cell{cSess,1} = cSessAUCs(CommmonUsedROIIndex);
    ROISigThres = SessABSAUCDatas{cSess,2}(CommmonUsedROIIndex);
    
    CommonROIData_cell{cSess,2} = CommonROIData_cell{cSess,1}(CommonROIData_cell{cSess,1} > ROISigThres);
    if numel(SessDatas{cSess,3}{1}) > 8 && StartLine < 0
        StartLine = cSess - 0.5;
    end
    
    TaskBehavStrc = SessBehavDatas{cSess};
    FreqperfAlls = TaskBehavStrc.StimCorr(2:end-1);
    if mod(numel(FreqperfAlls),2)
        FreqPerfNearBound = FreqperfAlls([3,5]);
        FreqperfAlls(4) = [];
    else
        FreqPerfNearBound = FreqperfAlls([3,4]);
    end
    Session_TaskPerf(cSess,:) = {FreqperfAlls,FreqPerfNearBound};
end
%
CommonROIDataAvg = cellfun(@mean,CommonROIData_cell);
CommonROIDataSem = cellfun(@(x) std(x)/sqrt(numel(x)),CommonROIData_cell);
MeanAllAUCVal = CommonROIDataAvg(:,1);
MeanAllAUCSEMVal = CommonROIDataSem(:,1);
MeanSigAUCVal = CommonROIDataAvg(:,2);
MeanSigAUCSEMVal = CommonROIDataSem(:,2);

hAUCf = figure('position',[2000 100 620 340]);
ax1 = axes;
yyaxis left
hold on
hl1 = errorbar(1:NumSesss,MeanAllAUCVal,MeanAllAUCSEMVal,'k-o','linewidth',2,'MarkerSize',12);
hl2 = errorbar(1:NumSesss,MeanSigAUCVal,MeanSigAUCSEMVal,'b-o','linewidth',2,'MarkerSize',12);

if StartLine > 0
    % plot boundary frequency added session
    yscales = get(gca,'ylim');
    line([StartLine StartLine],yscales,'Color',[0.1 0.5 0.1],'Linewidth',2,'linestyle','--');
    set(gca,'ylim',yscales);
end

set(gca,'xlim',[0.5 NumSesss+0.5],'xtick',1:NumSesss)
% legend([hl1 hl2],{'AllAUC','SigAUC'},'Location','Southwest','box','off');
xlabel('# Session');
ylabel('AUC');

SessBehav_Avg = cellfun(@mean,Session_TaskPerf);
yyaxis right
hl3 = plot(1:NumSesss,SessBehav_Avg(:,1),'Color',[0.7 0.1 0.7],'linewidth',1.4,'linestyle','--');
hl4 = plot(1:NumSesss,SessBehav_Avg(:,2),'Color','c','linewidth',1.4,'linestyle','--');
ylabel('Middle Freq. Perf.');
lls = legend([hl1 hl2 hl3 hl4],{'AllAUC','SigAUC','MidCorr','NearTwo'},'Location',...
    'Southwestoutside','box','off','FontSize',10);
legPos = get(lls,'position');
AxisPos = get(ax1,'position');
set(lls,'position',[legPos(1)/2 legPos(2) legPos(3) legPos(4)*1.5]);
set(ax1,'position',[AxisPos(1)*0.8 AxisPos(2) AxisPos(3) AxisPos(4)]);

%%
AnmStrs = '0503';
title(sprintf('b60\\_%s',AnmStrs));
saveas(hAUCf,sprintf('Anm b60%s Single Neuron AUC save',AnmStrs));
saveas(hAUCf,sprintf('Anm b60%s Single Neuron AUC save',AnmStrs),'png');
save(sprintf('AUCAndPerf_b60a%s_data.mat',AnmStrs),'CommonROIDataAvg','SessBehav_Avg','-v7.3');

%%
AllROIs_AUCs = (cell2mat(CommonROIData_cell(:,1)))';

%% load all animal's AUC and task performance together
DataFolders = 'H:\F_b60_matBackup\SessAUC_AvgPlots';
DataStrs = dir(fullfile(DataFolders,'AUCAndPerf*.mat'));
NumFiles = length(DataStrs);
AllColors = jet(NumFiles);

hAnmf = figure('position',[400 250 1100 800]);
ax1 = subplot(221); % All ROI AUC and middle performance 1,1
hold on
ax2 = subplot(222); % All ROI AUC and tough two performance 1,2
hold on
ax3 = subplot(223); % Sig ROI AUC and middle performance 2,1
hold on
ax4 = subplot(224);% Sig ROI AUC and tough two performance 2,2
hold on
AxAlls = {ax1,ax2,ax3,ax4};
AllAnmSessDatas = cell(NumFiles,2);
for cAnm = 1 : NumFiles
    cAnmFolders = fullfile(DataFolders,DataStrs(cAnm).name);
    cAnmDataStrc = load(cAnmFolders);
    AllAnmSessDatas{cAnm,1} = cAnmDataStrc.CommonROIDataAvg;
    AllAnmSessDatas{cAnm,2} = cAnmDataStrc.SessBehav_Avg;
    
    cColors = AllColors(cAnm,:);
    
    plot(ax1,AllAnmSessDatas{cAnm,1}(:,1),AllAnmSessDatas{cAnm,2}(:,1),'o',...
        'MarkerSize',10,'linewidth',2,'Color',AllColors(cAnm,:));
    plot(ax2,AllAnmSessDatas{cAnm,1}(:,1),AllAnmSessDatas{cAnm,2}(:,2),'o',...
        'MarkerSize',10,'linewidth',2,'Color',AllColors(cAnm,:));
    plot(ax3,AllAnmSessDatas{cAnm,1}(:,2),AllAnmSessDatas{cAnm,2}(:,1),'o',...
        'MarkerSize',10,'linewidth',2,'Color',AllColors(cAnm,:));
    plot(ax4,AllAnmSessDatas{cAnm,1}(:,2),AllAnmSessDatas{cAnm,2}(:,2),'o',...
        'MarkerSize',10,'linewidth',2,'Color',AllColors(cAnm,:));
end
TitleStrs = {'AllAUC\_MidPerf','AllAUC\_TwoPerf','SigAUC\_MidPerf','SigAUC\_TwoPerf'};
for cAx = 1 : 4
    xlabel(AxAlls{cAx},'AUC');
    ylabel(AxAlls{cAx},'Correct rate');
    title(AxAlls{cAx},TitleStrs{cAx});
end
%%
AllAUCDatas = cell2mat(AllAnmSessDatas(:,1));
AllPerfDatas = cell2mat(AllAnmSessDatas(:,2));

CoefANDp = zeros(4,2);
[ccCoef,cc_p] = corrcoef(AllAUCDatas(:,1),AllPerfDatas(:,1));
CoefANDp(1,:) = [ccCoef(1,2),cc_p(1,2)];
[ccCoef,cc_p] = corrcoef(AllAUCDatas(:,1),AllPerfDatas(:,2));
CoefANDp(2,:) = [ccCoef(1,2),cc_p(1,2)];
[ccCoef,cc_p] = corrcoef(AllAUCDatas(:,2),AllPerfDatas(:,1));
CoefANDp(3,:) = [ccCoef(1,2),cc_p(1,2)];
[ccCoef,cc_p] = corrcoef(AllAUCDatas(:,2),AllPerfDatas(:,2));
CoefANDp(4,:) = [ccCoef(1,2),cc_p(1,2)];

for cAx = 1 : 4
    xscales = get(AxAlls{cAx},'xlim');
    yscales = get(AxAlls{cAx},'ylim');
    Text_x = xscales * [0.2;0.8];
    Text_y = yscales * [0.9;0.1];
    text(AxAlls{cAx},Text_x,Text_y,sprintf('Coef %.3f, p %.4f',...
        CoefANDp(cAx,1),CoefANDp(cAx,2)),'HorizontalAlignment','center',...
        'Color','r');
end

%%
saveas(gcf,'NeuTuning curve average b60a0502 save');
saveas(gcf,'NeuTuning curve average b60a0502 save','png');
%%
SessFIDatas = cell(NumSesss,3);
PassSessFIDatas = cell(NumSesss,2);
SessBehavDatas = cell(NumSesss,1);
for cSess = 1 : NumSesss
    %
    cSessPath = SessPathAll{cSess};
    [ROIFIDatas,xValues] = NeuFisherInfoCalFun(cSessPath,[]);
    SessFIDatas{cSess,1} = ROIFIDatas;
    SessFIDatas{cSess,3} = xValues;
    ROIUsedInds_path = fullfile(cSessPath,'Tunning_fun_plot_New1s','SelectROIIndex.mat'); 
    ROIUsedInds_strc = load(ROIUsedInds_path,'ROIIndex');
    SessFIDatas{cSess,2} = ROIUsedInds_strc.ROIIndex;
    
    TaskBehav_path = fullfile(cSessPath,'RandP_data_plots','boundary_result.mat');
    TaskBehav_strc = load(TaskBehav_path);
    SessBehavDatas{cSess} = TaskBehav_strc.boundary_result;
    
    cPassSess = SessPassPathAlls{cSess};
    PassSessDataPath = fullfile(cPassSess,'rfSelectDataSet.mat');
    PassSessData_strc = load(PassSessDataPath);
    PassDataForCal.data_aligned = PassSessData_strc.SelectData;
    PassDataForCal.frame_rate = PassSessData_strc.frame_rate;
    PassDataForCal.start_frame = PassSessData_strc.frame_rate;
    PassDataForCal.behavResults = PassSessData_strc.SelectSArray;
    [PassFIData,PassxValues] = NeuFisherInfoCalFun(PassDataForCal,[]);
    PassSessFIDatas{cSess,1} = PassFIData;
    PassSessFIDatas{cSess,2} = PassxValues;
end
% ##########################
MinROINums = min(cellfun(@numel,SessFIDatas(:,2)));
CommmonUsedROIIndexCell = cellfun(@(x) x(1:MinROINums) > 0,SessFIDatas(:,2),'UniformOutput',false);
CommmonUsedROI_Mtx = cell2mat(CommmonUsedROIIndexCell');
CommmonUsedROIIndex = mean(CommmonUsedROI_Mtx,2) == 1;

xtickstrs = {'8.0';'16.0';'32.0'};

hccf = figure('position',[2400 250 1400 690]);
for cSess = 1 : NumSesss
    
    cBehavDataStrc = SessBehavDatas{cSess};
    
    if NumSesss > 6
       subplot(2,4,cSess);
    else
        subplot(2,3,cSess);
    end
    
    RightwardProbs = cBehavDataStrc.StimCorr;
    LeftStimInds = cBehavDataStrc.RevertStimRProb;
%     RightwardProbs = BehaOctave_perf;
    RightwardProbs(LeftStimInds) = 1 - RightwardProbs(LeftStimInds);
    RightStimOctaves = log2(cBehavDataStrc.StimType / min(cBehavDataStrc.StimType)) - 1;
    BehavBound = cBehavDataStrc.Boundary - 1;
    
    yyaxis left
    hold on
    plot(RightStimOctaves,RightwardProbs,'bo','markerSize',10,'linewidth',1.5);
    plot(cBehavDataStrc.FitValue.curve(:,1)-1,cBehavDataStrc.FitValue.curve(:,2),...
        'c','linewidth',1.5);
    yscales = get(gca,'ylim');
    line([BehavBound BehavBound],yscales,'linewidth',1.4,...
        'Color',[0.2 0.6 0.2],'linestyle','--');
    set(gca,'ylim',yscales);
    set(gca,'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
    ylabel('Right Prob.');
    
    % processing task information
    cFisherInfoData = SessFIDatas{cSess,1}(:,CommmonUsedROIIndex);
    xPlotValues = SessFIDatas{cSess,3}-1;
    cFI_Avgs = mean(cFisherInfoData,2);
    
    FIBoots = bootstrp(1000,@mean,cFisherInfoData');
    FI_95CI_datas = prctile(FIBoots,[2.5 97.5]);
    Patch_x = [xPlotValues(:);flipud(xPlotValues(:))];
    Patch_y = [FI_95CI_datas(1,:),fliplr(FI_95CI_datas(2,:))];
    
    % processing passive session
    Pass_cSessFInfoData = PassSessFIDatas{cSess,1}(:,CommmonUsedROIIndex);
    PassxValue = PassSessFIDatas{cSess,2}-1;
    Pass_cFI_Avg = mean(Pass_cSessFInfoData,2);
    Pass_FIBoots = bootstrp(1000,@mean,Pass_cSessFInfoData');
    Pass_FI_95CI = prctile(Pass_FIBoots,[2.5 97.5]);
    Pass_P_x = [PassxValue(:);flipud(PassxValue(:))];
    Pass_P_y = [Pass_FI_95CI(1,:),fliplr(Pass_FI_95CI(2,:))];
    
    yyaxis right
    hold on
    patch(Pass_P_x,Pass_P_y,1,'FaceColor',[.7 .7 .7],'edgecolor','none',...
        'facealpha',0.6);
    patch(Patch_x,Patch_y,1,'FaceColor',[.8 .2 .8],'edgecolor','none',...
        'facealpha',0.7);
    hhl1 = plot(PassxValue,Pass_cFI_Avg,'k-','linewidth',1.6);
    hhl2 = plot(xPlotValues,cFI_Avgs,'r-','linewidth',1.6);
    title([AnmInfoCell{cSess}.SessionDate,'  ','60\_0101']);
    ylabel('Fisher info.');
    yscales_R = get(gca,'ylim');
    legend([hhl1 hhl2],{'Pass','Task'},'location','northwest','box','off');
    set(gca,'xlim',[min(xPlotValues)-0.05 max(xPlotValues)+0.05]);
    set(gca,'xtick',-1:1,'xticklabel',xtickstrs);
    xlabel('Freq (kHz)');
end

%%
saveas(gcf,'PopuNeuron fisher information b60a0503 save');
saveas(gcf,'PopuNeuron fisher information b60a0503 save','png');

%% 
% SessFIDatas = cell(NumSesss,3);
% PassSessFIDatas = cell(NumSesss,2);
% SessBehavDatas = cell(NumSesss,1);
NumSess = size(SessFIDatas,1);
Session_IFPerf_summary = cell(NumSess,5);
OctIndexWidth = 0.15;  % the half size of tone step size
for cSess = 1 : NumSess
    cSessBehav_strc = SessBehavDatas{cSess};
    cSess_Corr_rate = cSessBehav_strc.StimCorr;
    AllTaskFreqs = double(cSessBehav_strc.StimType);
    cSessOctaves = log2(AllTaskFreqs(:) / min(AllTaskFreqs)) - 1;
    if mod(numel(cSessOctaves),2)
        UsedTwoOctaves = cSessOctaves([4,6]);
        UsedTwoOct_perf = cSess_Corr_rate([4,6]);
    else
        UsedTwoOctaves = cSessOctaves([4,5]);
        UsedTwoOct_perf = cSess_Corr_rate([4,5]);
    end
    UsedTwoOct_ScaleInds = [UsedTwoOctaves,UsedTwoOctaves] + ...
        [-OctIndexWidth/2,OctIndexWidth/2;-OctIndexWidth/2,OctIndexWidth/2];
    
    % calculate task infomation
    TaskOctInds = SessFIDatas{cSess,3} - 1;
    LeftOctScaleInds = TaskOctInds > UsedTwoOct_ScaleInds(1,1) & ...
        TaskOctInds < UsedTwoOct_ScaleInds(1,2);
    LeftOctScaleIF_Avg = mean(SessFIDatas{cSess,1}(LeftOctScaleInds));
    RightOctScaleInds = TaskOctInds > UsedTwoOct_ScaleInds(2,1) & ...
        TaskOctInds < UsedTwoOct_ScaleInds(2,2);
    RightOctScaleIF_Avg = mean(SessFIDatas{cSess,1}(RightOctScaleInds));
    
    % calculate passive condition
    PassOctInds = PassSessFIDatas{cSess,2} - 1;
    P_LeftOctScaleInds = PassOctInds > UsedTwoOct_ScaleInds(1,1) & ...
        PassOctInds < UsedTwoOct_ScaleInds(1,2);
    P_LeftOctScaleIF_Avg = mean(PassSessFIDatas{cSess,1}(P_LeftOctScaleInds));
    P_RightOctScaleInds = PassOctInds > UsedTwoOct_ScaleInds(2,1) & ...
        PassOctInds < UsedTwoOct_ScaleInds(2,2);
    P_RightOctScaleIF_Avg = mean(PassSessFIDatas{cSess,1}(P_RightOctScaleInds));
    
    Session_IFPerf_summary(cSess,:) = {UsedTwoOct_perf,LeftOctScaleIF_Avg,RightOctScaleIF_Avg,...
        P_LeftOctScaleIF_Avg,P_RightOctScaleIF_Avg};
end
%%
save('Anm0101_FIAndPerf_data,mat','Session_IFPerf_summary','SessFIDatas',...
    'PassSessFIDatas','SessBehavDatas','-v7.3');

