

cclr
%
SessPathAll = {...
    'H:\F_b60_matBackup\20190610\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'H:\F_b60_matBackup\20190611\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'H:\F_b60_matBackup\20190613\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
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

SessDatas = cell(NumSesss,5);
for cSess = 1 : NumSesss
    %
    cSessPath = SessPathAll{cSess};
    ROIUsedInds_path = fullfile(cSessPath,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    SessROIsRawData_path = fullfile(cSessPath,'CSessionData.mat');
    
    ROIUsedInds_strc = load(ROIUsedInds_path,'ROIIndex');
    SessROIsRawData_strc = load(SessROIsRawData_path);
    
    ROI1Datas = squeeze(SessROIsRawData_strc.data_aligned(:,1,:));
    MinNANframes = find(isnan(mean(ROI1Datas)),1,'first');
    SessParas.StartFrame = SessROIsRawData_strc.start_frame;
    SessParas.FrameRate = SessROIsRawData_strc.frame_rate;
    switch TypeIndex
        case 1
            % use all trials
            TaskDatas = SessROIsRawData_strc.data_aligned ;
        case 2
            % use onlt non-miss trial
            UsedInds_sess = SessROIsRawData_strc.trial_outcome ~= 2;
            TaskDatas = SessROIsRawData_strc.data_aligned(UsedInds_sess,:,:);
        case 3
            % use onlt non-miss trial
            UsedInds_sess = SessROIsRawData_strc.trial_outcome == 1;
            TaskDatas = SessROIsRawData_strc.data_aligned(UsedInds_sess,:,:);
        otherwise
            fprintf('Unkonwn trial index type.\n');
    end
    TotalTrials = size(TaskDatas,1);
    HalfTrial_Indexes = randsample(TotalTrials,round(TotalTrials/2));
    EmptyInds = false(TotalTrials,1);
    EmptyInds(HalfTrial_Indexes) = true;
    FirstHalfAlignDatas = squeeze(mean(TaskDatas(EmptyInds,:,1:(MinNANframes-1))));
    SndHalfAlignDatas = squeeze(mean(TaskDatas(~EmptyInds,:,1:(MinNANframes-1))));
    
    SessDatas{cSess,1} = FirstHalfAlignDatas;
    SessDatas{cSess,2} = SndHalfAlignDatas;
    SessDatas{cSess,3} = ROIUsedInds_strc.ROIIndex;
    
    cPassSessPath = SessPassPathAlls{cSess};
    PassSessData_path = fullfile(cPassSessPath,'rfSelectDataSet.mat');
    PassSessData_Strc = load(PassSessData_path);
    
    PassSessFrames = size(PassSessData_Strc.SelectData,3);
    PassUsedFrame = min(MinNANframes-1,PassSessFrames);
    SessDatas{cSess,5} = squeeze(mean(PassSessData_Strc.SelectData(:,:,1:PassUsedFrame)));
%     SessParas.PassStartFRate = PassSessData_Strc.frame_rate;
    SessDatas{cSess,4} = SessParas;
   %
end

%%
MinROINums = min(cellfun(@numel,SessDatas(:,3)));
CommmonUsedROIIndexCell = cellfun(@(x) x(1:MinROINums) > 0,SessDatas(:,3),'UniformOutput',false);
CommmonUsedROI_Mtx = cell2mat(CommmonUsedROIIndexCell');
CommmonUsedROIIndex = mean(CommmonUsedROI_Mtx,2) == 1;
CommonROIData_Cell_FH = cellfun(@(x) x(CommmonUsedROIIndex,:),SessDatas(:,1),'UniformOutput',false);
CommonROIData_Cell_SH = cellfun(@(x) x(CommmonUsedROIIndex,:),SessDatas(:,2),'UniformOutput',false);
CommonROIPass_Cell_All = cellfun(@(x) x(CommmonUsedROIIndex,:),SessDatas(:,5),'UniformOutput',false);
%
[CommonROIData_ZSed_FH,zs_mu,zs_sig] = cellfun(@(x) ForceMultiOutput_zs(x,0,2),CommonROIData_Cell_FH,'UniformOutput',false);
CommonROIData_ZSed_SH = cellfun(@(x,y,z) InputMuSig_Norm(x,y,z),CommonROIData_Cell_SH,...
    zs_mu,zs_sig,'UniformOutput',false);
CommonROIPass_ZSed_All = cellfun(@(x,y,z) InputMuSig_Norm(x,y,z),CommonROIPass_Cell_All,...
    zs_mu,zs_sig,'UniformOutput',false);

%% plot the results
% raw image plots
TotalROINums = sum(CommmonUsedROIIndex);
% set color scale lim
Color_lims = [-0.5 2];

huf = figure('position',[80 250 1700 840]);
for cSess = 1 : NumSesss
    subplot(3,NumSesss,cSess);
    
    cFH_data = CommonROIData_ZSed_FH{cSess};
    cSessparas =  SessDatas{cSess,4};
    cFH_frames = size(cFH_data,2);
    xTimeTick = (1:cFH_frames)/cSessparas.FrameRate;
    StartTime = cSessparas.StartFrame/cSessparas.FrameRate;
    yROITicks = 1:TotalROINums;
    
    imagesc(xTimeTick,yROITicks,cFH_data,Color_lims);
    line([StartTime StartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    if cSess == 1
        ylabel('# ROIs');
    end
    title(AnmInfoCell{cSess}.SessionDate);
    
    subplot(3,NumSesss,cSess+NumSesss);
    
    cSH_data = CommonROIData_ZSed_SH{cSess};
    cSessparas =  SessDatas{cSess,4};
    cSH_frames = size(cSH_data,2);
    xTimeTick = (1:cSH_frames)/cSessparas.FrameRate;
    StartTime = cSessparas.StartFrame/cSessparas.FrameRate;
    yROITicks = 1:TotalROINums;
    
    imagesc(xTimeTick,yROITicks,cSH_data,Color_lims);
    line([StartTime StartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    xlabel('Time (s)');
    
    subplot(3,NumSesss,cSess+NumSesss*2);
    
    cPass_data = CommonROIPass_ZSed_All{cSess};
    cSessparas =  SessDatas{cSess,4};
    cPass_frames = size(cPass_data,2);
    xTimeTick = (1:cPass_frames)/cSessparas.FrameRate;
    StartTime = cSessparas.StartFrame/cSessparas.FrameRate;
    yROITicks = 1:TotalROINums;
    
    imagesc(xTimeTick,yROITicks,cPass_data,Color_lims);
    line([StartTime StartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    xlabel('Time (s)');
    
    
end
%
%% plot the results
% Color plots with sorted ROI sequence
TotalROINums = sum(CommmonUsedROIIndex);

% Choose used session sort inds
SortUsedInds = NumSesss;
SortUsedData = CommonROIData_ZSed_FH{SortUsedInds};
[~,maxInds] = max(SortUsedData,[],2);
[~,MaxSortInds] = sort(maxInds);

% set color scale lim
Color_lims = [-0.5 1.5];

huf = figure('position',[80 150 1700 960]);
for cSess = 1 : NumSesss
    subplot(4,NumSesss,cSess);
    
    cFH_data = CommonROIData_ZSed_FH{cSess};
    
    cSessparas =  SessDatas{cSess,4};
    cFH_frames = size(cFH_data,2);
    TaskxTimeTick = (1:cFH_frames)/cSessparas.FrameRate;
    TaskStartTime = cSessparas.StartFrame/cSessparas.FrameRate;
    yROITicks = 1:TotalROINums;
    
    imagesc(TaskxTimeTick,yROITicks,cFH_data(MaxSortInds,:),Color_lims);
    line([TaskStartTime TaskStartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    if cSess == 1
        ylabel('# ROIs');
    end
    title(AnmInfoCell{cSess}.SessionDate);
    set(gca,'xlim',[0 max(TaskxTimeTick)],'ylim',[0.5 TotalROINums+0.5],...
        'xtick',0:max(TaskxTimeTick));
    
    subplot(4,NumSesss,cSess+NumSesss);
    
    cSH_data = CommonROIData_ZSed_SH{cSess};
    cSessparas =  SessDatas{cSess,4};
    cSH_frames = size(cSH_data,2);
    xTimeTick = (1:cSH_frames)/cSessparas.FrameRate;
    TaskStartTime = cSessparas.StartFrame/cSessparas.FrameRate;
    yROITicks = 1:TotalROINums;
    
    imagesc(xTimeTick,yROITicks,cSH_data(MaxSortInds,:),Color_lims);
    line([TaskStartTime TaskStartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    xlabel('Time (s)');
    set(gca,'xlim',[0 max(xTimeTick)],'ylim',[0.5 TotalROINums+0.5],...
        'xtick',0:max(xTimeTick));
    if cSess == 1
        ylabel('# ROIs');
    end
    title('Non-overlap half');
    
    % passive response
    subplot(4,NumSesss,cSess+NumSesss*2);
    cPass_data = CommonROIPass_ZSed_All{cSess};
    cSessparas =  SessDatas{cSess,4};
    cPass_frames = size(cPass_data,2);
    PassxTimeTick = (1:cPass_frames)/cSessparas.FrameRate;
    StartTime = 1;
    yROITicks = 1:TotalROINums;
    
    imagesc(PassxTimeTick,yROITicks,cPass_data(MaxSortInds,:),Color_lims);
    line([StartTime StartTime],[0.5 TotalROINums+0.5],'Color','m','linewidth',2);
    xlabel('Time (s)');
    set(gca,'xlim',[0 max(PassxTimeTick)],'ylim',[0.5 TotalROINums+0.5],...
        'xtick',0:max(PassxTimeTick));
    if cSess == 1
        ylabel('# ROIs Passive');
    end
    
    % plot the averaged trace
    TaskxTicks = TaskxTimeTick - TaskStartTime;
    PassxTicks = PassxTimeTick - 1;
    PassBaseline_Inds = PassxTicks <= 0;
    
    TaskAvgResponse = mean(cFH_data);
    TaskAvgResp_SH = mean(cSH_data);
    PassAvgResp = mean(cPass_data);
    PassBaselineValues = mean(PassAvgResp(PassBaseline_Inds));
    TaskBaseline = mean(TaskAvgResponse(TaskxTicks <= 0));
    TaskBaseline_SH = mean(TaskAvgResp_SH(TaskxTicks <= 0));
    
    subplot(4,NumSesss,cSess+NumSesss*3);
    hold on
    plot(TaskxTicks,TaskAvgResponse-TaskBaseline,'r','linewidth',1.8);
    plot(TaskxTicks,TaskAvgResp_SH-TaskBaseline_SH,'b','linewidth',1.8);
    plot(PassxTicks,PassAvgResp-PassBaselineValues,'k','linewidth',1.8);
    yscales = get(gca,'ylim');
    line([0 0],yscales,'Color',[.7 .7 .7],'linewidth',1.5);
    xlabel('Time (s)');
    ylabel('Norm response');
    
end
%%
saveas(huf,'B60a01_01 Colorplot CorrTrials sort by last session save')
saveas(huf,'B60a01_01 Colorplot CorrTrials sort by last session save','png')

%% response field analysis
% load field datas

Coef_Clims = [0 0.5];
huf = figure('position',[80 100 1700 940]);
for cSess = 1 : NumSesss
    %
    cSessPath = SessPathAll{cSess};
    ROIUsedInds_path = fullfile(cSessPath,'SP_RespField_ana','SigSelectiveROIInds.mat');
    ROIUsedInds_strc = load(ROIUsedInds_path);
    SessFreqs_strc = load(fullfile(cSessPath,'RandP_data_plots','boundary_result.mat'));
    %
    ROIPassInds_path = fullfile(SessPassPathAlls{cSess},'SP_RespField_ana','PassCoefMtxSave_New.mat');
    ROIPassInds_FreqTypes_path = fullfile(SessPassPathAlls{cSess},'SP_RespField_ana','ROIglmCoefSave_New.mat');
    ROIPassInds_FreqTypes_strc = load(ROIPassInds_FreqTypes_path,'FreqTypes');
    ROIPassInds_strc = load(ROIPassInds_path);
    %
    % merge frequency responsive ROIs coef matrix
    TaskROIIndex = ROIUsedInds_strc.SigROIInds;
    PassROIIndex = ROIPassInds_strc.PassRespROIInds;
    MaxROIIndexes = max(max(max(TaskROIIndex),max(PassROIIndex)),numel(CommmonUsedROIIndex));
    [TBaselineDatas,PBaselineDatas] = deal(false(MaxROIIndexes,1));
    TaskFreqNums = numel(SessFreqs_strc.boundary_result.StimType);
    PassFreqNums = numel(ROIPassInds_FreqTypes_strc.FreqTypes);
    TaskCoefMtx = zeros(MaxROIIndexes,TaskFreqNums);
    PassCoefMtx = zeros(MaxROIIndexes,PassFreqNums);
    
    TBaselineDatas(TaskROIIndex) = true;
    PBaselineDatas(PassROIIndex) = true;
%     MergedROIs = TBaselineDatas | PassROIIndex;
    TaskCoefMtx(TaskROIIndex,:) = ROIUsedInds_strc.SigROICoefMtx;
    PassCoefMtx(PassROIIndex,:) = ROIPassInds_strc.PassRespCoefMtx;
    
    TaskMergeCoefMtx = TaskCoefMtx(CommmonUsedROIIndex,:); % task common frequency response matrix
    PassMergeCoefMtx = PassCoefMtx(CommmonUsedROIIndex,:); % Pass common frequency response matrix
    
    % extract answer response ROIs from task data
    if ~isempty(ROIUsedInds_strc.LAnsMergedInds)
        LAnsCommonROIs = ROIUsedInds_strc.LAnsMergedInds(ROIUsedInds_strc.LAnsMergedInds < numel(CommmonUsedROIIndex));
%         AnsMaxROIIndex = max(MaxROIIndexes,max(ROIUsedInds_strc.LAnsMergedInds));
        LAnsCommonROIs_logiInds = CommmonUsedROIIndex(LAnsCommonROIs);
        LAnsCommonROIsCoefAlls = PassCoefMtx(LAnsCommonROIs,:);
        LAnsCommonROIs_Coefmtx = LAnsCommonROIsCoefAlls(LAnsCommonROIs_logiInds,:);
        LAnsNum = size(LAnsCommonROIs_Coefmtx,1);
    else
        LAnsCommonROIs_Coefmtx = [];
        LAnsNum = 0;
    end
    if ~isempty(ROIUsedInds_strc.RAnsMergedInds)
        RAnsCommonROIs = ROIUsedInds_strc.RAnsMergedInds(ROIUsedInds_strc.RAnsMergedInds < numel(CommmonUsedROIIndex));
%         AnsMaxROIIndex = max(MaxROIIndexes,max(ROIUsedInds_strc.RAnsMergedInds));
        RAnsCommonROIs_logiInds = CommmonUsedROIIndex(RAnsCommonROIs);
        RAnsCommonROIsCoefAlls = PassCoefMtx(RAnsCommonROIs,:);
        RAnsCommonROIs_Coefmtx = RAnsCommonROIsCoefAlls(RAnsCommonROIs_logiInds,:);
        RAnsNum = size(RAnsCommonROIs_Coefmtx,1);
    else
        RAnsCommonROIs_Coefmtx = [];
        RAnsNum = 0;
    end
    % plot the results
    subplot(4,NumSesss,cSess)
    TaskFreqStrs = cellstr(num2str(SessFreqs_strc.boundary_result.StimType(:)/1000,'%.1f'));
    imagesc(TaskMergeCoefMtx,Coef_Clims);
    set(gca,'xtick',1:size(TaskMergeCoefMtx,2),'xticklabel',TaskFreqStrs);
    title('Task freqResp Coef');
    
    subplot(4,NumSesss,cSess+NumSesss)
    PassFreqStrs = cellstr(num2str(ROIPassInds_FreqTypes_strc.FreqTypes(:)/1000,'%.1f'));
    imagesc(PassMergeCoefMtx,Coef_Clims);
    set(gca,'xtick',1:size(PassMergeCoefMtx,2),'xticklabel',PassFreqStrs);
    title('Pass freqResp Coef');
    
    % answer response passive coefs
    subplot(4,NumSesss,cSess+NumSesss*2)
    if LAnsNum && RAnsNum % both answer type exists
        MergedAns_PassCoefs = [LAnsCommonROIs_Coefmtx;RAnsCommonROIs_Coefmtx];
        yTickss = [1,LAnsNum+1];
        imagesc(MergedAns_PassCoefs,Coef_Clims);
        line([0.5 PassFreqNums+0.5],[0.5 0.5]+LAnsNum,'Color','m','linewidth',1.8);
        set(gca,'xtick',1:PassFreqNums,'xticklabel',PassFreqStrs,...
            'xlim',[0.5 PassFreqNums+0.5],'ylim',[0.5 LAnsNum+RAnsNum+0.5]);
        set(gca,'ytick',yTickss,'yticklabel',{'left';'Right'});
        title('L & R AnsROI passResp');
    elseif LAnsNum
        % only left answer response exists
        imagesc(LAnsCommonROIs_Coefmtx,Coef_Clims);
        set(gca,'xtick',1:PassFreqNums,'xticklabel',PassFreqStrs,...
            'xlim',[0.5 PassFreqNums+0.5],'ylim',[0.5 LAnsNum+0.5],...
            'ytick',1,'yticklabel','Left');
        title('Left AnsROIs PassCoefs');
    elseif RAnsNum
        % only right answer ROI exists
        imagesc(RAnsCommonROIs_Coefmtx,Coef_Clims);
        set(gca,'xtick',1:PassFreqNums,'xticklabel',PassFreqStrs,...
            'xlim',[0.5 PassFreqNums+0.5],'ylim',[0.5 RAnsNum+0.5],...
            'ytick',1,'yticklabel','Left');
        title('Right AnsROIs PassCoefs');
    else
        title('No Ansresp ROIs');
    end
    
    % plot the frequency peak distribution line
    subplot(4,NumSesss,cSess+NumSesss*3);
    TaskSigRespCurve = sum(TaskMergeCoefMtx > 0);
    PassSigRespCurve = sum(PassMergeCoefMtx > 0);
    TaskBaseFreqs = min(SessFreqs_strc.boundary_result.StimType);
    TaskFreqOcts = log2(SessFreqs_strc.boundary_result.StimType(:)/TaskBaseFreqs);
    PassFreqOcts = log2(ROIPassInds_FreqTypes_strc.FreqTypes(:)/TaskBaseFreqs);
    
    hold on
    plot(TaskFreqOcts,TaskSigRespCurve,'r-o','linewidth',1.7);
    plot(PassFreqOcts,PassSigRespCurve,'k-d','linewidth',1.4);
    set(gca,'xtick',TaskFreqOcts([1,end]),'xticklabel',...
        TaskFreqStrs([1,end]),'xlim',[TaskFreqOcts(1)-0.1 TaskFreqOcts(end)+0.1]);
    yscales = get(gca,'ylim');
    line(SessFreqs_strc.boundary_result.Boundary*[1 1],yscales,'Color',[0.8 0.6 0.2],...
        'linewidth',1.4,'linestyle','--');
    xlabel('Freq (kHz)');
    ylabel('Counts');
    title('Freq resp coef distribution');
    %
end

%%
saveas(huf,'B60a05_02 coef field colorplot save')
saveas(huf,'B60a05_02 coef field colorplot save','png')
