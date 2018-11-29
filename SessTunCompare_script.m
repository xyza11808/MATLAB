

SessPaths = {'S:\BatchData\batch58\20181102\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181103\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181104\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
nSess = length(SessPaths);
SessDataAll = cell(nSess,1);
SessROINum = zeros(nSess,1);
for cSess = 1 : nSess
    cSessPath = fullfile(SessPaths{cSess},'Tunning_fun_plot_New1s','TunningDataSave.mat');
    cSessData = load(cSessPath);
    SessDataAll{cSess} = cSessData;
    
    SessROINum(cSess) = size(cSessData.CorrTunningFun,2);
end
%%
UsedROINum = min(SessROINum);

SessUsedDataAll = cell(nSess,2);
SessFreqsAll = cell(nSess,2);
SesszsDataAll = cell(nSess,2);

SessSortInds = cell(nSess,1);
for cSess = 1 : nSess
    SessUsedDataAll{cSess,1} = SessDataAll{cSess}.CorrTunningFun(:,1:UsedROINum);
    SessUsedDataAll{cSess,2} = SessDataAll{cSess}.PassTunningfun(:,1:UsedROINum);
    
    nTones = length(SessDataAll{cSess}.TaskFreqOctave);
    % zscore task and passive data
    MeanDataMtx = repmat(mean(SessUsedDataAll{cSess,1}),nTones,1);
    StdDataMtx = repmat(std(SessUsedDataAll{cSess,1}),nTones,1);
    SesszsDataAll{cSess,1} = (SessUsedDataAll{cSess,1} - MeanDataMtx) ./ StdDataMtx;
    SesszsDataAll{cSess,2} = (SessUsedDataAll{cSess,2} - MeanDataMtx) ./ StdDataMtx;
    
    SessFreqsAll{cSess,1} = 2.^(SessDataAll{cSess}.TaskFreqOctave(:)) * SessDataAll{cSess}.BoundFreq;
    SessFreqsAll{cSess,2} = 2.^(SessDataAll{cSess}.PassFreqOctave(:)) * SessDataAll{cSess}.BoundFreq;
    
    [~,MaxInds] = max(SesszsDataAll{cSess,1});
    [~,SortInds] = sort(MaxInds);
    SessSortInds{cSess} = SortInds;
end

%%
UsedMaxIndsOrder = SessSortInds{4};
hhf = figure('position',[20 60 1670 700]);
for cSess = 1 : nSess
    % upper task plot
    subplot(2,nSess,cSess)
    imagesc((SesszsDataAll{cSess,1}(:,UsedMaxIndsOrder))',[-2 2]);
    set(gca,'xtick',1:length(SessFreqsAll{cSess,1}),'xticklabel',cellstr(num2str(SessFreqsAll{cSess,1}/1000,'%.1f')));
    if cSess == 1
        ylabel('Task');
    end
    
    subplot(2,nSess,cSess+nSess)
    imagesc((SesszsDataAll{cSess,2}(:,UsedMaxIndsOrder))',[-2 2]);
    if cSess == 1
        ylabel('Passive');
    end
    set(gca,'xtick',1:length(SessFreqsAll{cSess,2}),'xticklabel',cellstr(num2str(SessFreqsAll{cSess,2}/1000,'%.1f')));

end

%%
cclr
%%
% load('SessCompDataSave.mat', 'SessPaths')
SessPaths = {'S:\BatchData\batch58\20181101\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181102\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181103\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...%};%,...
    'S:\BatchData\batch58\20181104\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch58\20181106\anm03\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
nSess = length(SessPaths);
SessDataAll = cell(nSess,1);
SessROIIndexAll = cell(nSess,1);
SessROINum = zeros(nSess,1);
for cSess = 1 : nSess
    cSessPath = fullfile(SessPaths{cSess},'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new','TypeSavedData.mat');
    cSessDatas = load(cSessPath,'TaskZSALLTunData','PassZSALLTunData');
    
    cSessUsedROIIndexPath = fullfile(SessPaths{cSess},'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    cSessUsedROIIndex = load(cSessUsedROIIndexPath);
    SessROIIndexAll{cSess} = cSessUsedROIIndex.ROIIndex;
    
    SessDataAll{cSess} = cSessDatas;
    
    SessROINum(cSess) = size(cSessDatas.TaskZSALLTunData,2);
end
  
ComparedROINum = min(SessROINum);
CompROIIndexCell = cell2mat((cellfun(@(x) x(1:ComparedROINum),SessROIIndexAll,'UniformOutput',false))');
UsedROIindex = sum(CompROIIndexCell,2) == nSess;
%%
SessTaskDataAll = cell(nSess,1);
SessPassDataAll = cell(nSess,1);
for cSess = 1 : nSess
    cSessData = SessDataAll{cSess};
    cTaskData = cSessData.TaskZSALLTunData(:,1:ComparedROINum);
    SessTaskDataAll{cSess} = cTaskData(:,UsedROIindex);
    cPassData = cSessData.PassZSALLTunData(:,1:ComparedROINum);
    SessPassDataAll{cSess} = cPassData(:,UsedROIindex);
end
 
%% performing plots

% select the savage path for current analysis
SavePath = uigetdir(pwd,'Please select current dataset savage path');
if ~isdir(SavePath)
    error('Save Path does not exists.\n');
end
cd(SavePath);
zsLims = [0 1.5];

for UsedSortInds = 1 : nSess
% UsedSortInds = 2; % the session index number that will be used for sorting
    [~,MaxZSDataInds] = max(SessTaskDataAll{UsedSortInds});
    [~,SortSeq] = sort(MaxZSDataInds);
    hPlotf = figure('position',[80 120 1750 900]);
    for css = 1 : nSess
        subplot(3,nSess,css);  % task data plots
        imagesc(SessTaskDataAll{css}(:,SortSeq),zsLims);
        xlabel('ROIs');
        if css == 1
            ylabel({'Task';'#Freqs'});
        end
        title(sprintf('Session%d',css));

        subplot(3,nSess,css+nSess);  % Passive data plots
        imagesc(SessPassDataAll{css}(:,SortSeq),zsLims);
        xlabel('ROIs');
        if css == 1
            ylabel({'Pass';'#Freqs'});
        end
    %     title(sprintf('Session%d',css));

        subplot(3,nSess,css+nSess*2); % psychometric curve plots
        psychoPlotPath = fullfile(SessPaths{css},'RandP_data_plots','Behav_fit plot.png');
        psychoPlotid = imread(psychoPlotPath);
        imshow(psychoPlotid);

    end
    annotation('textbox',[0.46 0.79 0.2 0.2],'String',sprintf('Sorted by sess%d',UsedSortInds),'EdgeColor',...
                'none','FitBoxToText','on','FontSize',18,'Color','m');
    saveas(hPlotf,sprintf('CompareSave_sort_by_session%d',UsedSortInds),'png');
    saveas(hPlotf,sprintf('CompareSave_sort_by_session%d',UsedSortInds));
    close(hPlotf);
end
save SessCompDataSave.mat SessDataAll SessROINum UsedROIindex SessPaths -v7.3
%
NewSessPassData = cell(nSess,1);
for css = 1 : nSess
    NewSessPassData{css} = zscore(SessPassDataAll{css});
end

PassZslim = [0 1.5];
hPassf = figure('position',[80 120 1750 950]);
hSPCoef = figure('position',[80 120 1750 600]);
for UsedSortInds = 1 : nSess
    [~,MaxZSDataInds] = max(NewSessPassData{UsedSortInds});
    [~,SortSeq] = sort(MaxZSDataInds);
    figure(hPassf);
    for css = 1 : nSess
%         subplot(nSess,nSess,css);  % task data plots
%         imagesc(SessTaskDataAll{css}(:,SortSeq),zsLims);
%         xlabel('ROIs');
%         if css == 1
%             ylabel({'Task';'#Freqs'});
%         end
%         title(sprintf('Session%d',css));

        subplot(nSess,nSess,css+(UsedSortInds-1)*nSess);  % Passive data plots
        imagesc(NewSessPassData{css}(:,SortSeq),PassZslim);
        xlabel('ROIs');
        if css == 1
            ylabel({sprintf('Pass Sort %d',UsedSortInds);'#Freqs'});
        end
    %     title(sprintf('Session%d',css));


    end

    SourcePath = fullfile(SessPaths{UsedSortInds},'SPPred ROITun Coef Plots.png');
    cfid = imread(SourcePath);
    figure(hSPCoef);
    subplot(2,nSess,UsedSortInds)
    imshow(cfid);
    title(sprintf('Sess %d',UsedSortInds));
    
    ccfid = imread(fullfile(SessPaths{UsedSortInds},'RandP_data_plots','Behav_fit plot.png'));
    subplot(2,nSess,UsedSortInds+nSess)
    imshow(ccfid);
%     title(sprintf('Sess %d',UsedSortInds));
    
%     TargPath = fullfile(SavePath,sprintf('SPPred ROITun Coef Plots Sess%d.png',UsedSortInds));
%     copyfile(SourcePath,TargPath);
end
figure(hPassf);
annotation('textbox',[0.45 0.79 0.2 0.2],'String','Passive session Sorts','EdgeColor',...
            'none','FitBoxToText','on','FontSize',18,'Color','m');
saveas(hPassf,'CompareSave_sort_by_Passive_session','png');
saveas(hPassf,'CompareSave_sort_by_Passive_session');
close(hPassf);
    
saveas(hSPCoef,'SP coef Plot Summary');
saveas(hSPCoef,'SP coef Plot Summary','png');
close(hSPCoef);
 
%% exploring the temporal trace for each session using common ROIs
TempSessTaskDataAll = cell(nSess,2);
TempSessPassDataAll = cell(nSess,2);

for cSess = 1 : nSess
    %%
    cSessTaskPath = fullfile(SessPaths{cSess},'CSessionData.mat');
    cSessTaskDataStrc = load(cSessTaskPath,'data_aligned','start_frame','frame_rate','behavResults');
    NMTrInds = cSessTaskDataStrc.behavResults.Action_choice ~= 2;
    NMdataChoices = double(cSessTaskDataStrc.behavResults.Action_choice(NMTrInds));
    NMDatas = cSessTaskDataStrc.data_aligned(NMTrInds,UsedROIindex,:);
    NMdataTrTypes = double(cSessTaskDataStrc.behavResults.Trial_Type(NMTrInds));
    FreqTypesAll = unique(double(cSessTaskDataStrc.behavResults.Stim_toneFreq(NMTrInds)));
    StartFrame = cSessTaskDataStrc.start_frame;
    TAskFRate = cSessTaskDataStrc.frame_rate;
    
    % Avg all NM trials together
    NMAllTrAvgs = squeeze(mean(NMDatas));
    NMAllTrZsDatas = (nanzscore(NMAllTrAvgs'))';
    NANEndInds = find(isnan(NMAllTrZsDatas(1,:)),1,'first');
    NMAllTrZsDatasUsed = NMAllTrZsDatas(:,1:NANEndInds-1);
    
    % Avg NM trials using correct left and correct right trials
    NMCorrLInds = (NMdataTrTypes(:) == 0 & NMdataTrTypes(:) == NMdataChoices(:));
    NMCorrRInds = (NMdataTrTypes(:) == 1 & NMdataTrTypes(:) == NMdataChoices(:));
    NMCorrLAllTrAvgs = squeeze(mean(NMDatas(NMCorrLInds,:,:)));
    NMCorrLZsDatas = (nanzscore(NMCorrLAllTrAvgs'))';
    NANEndInds_L = find(isnan(NMCorrLZsDatas(1,:)),1,'first');
    NMCorrLZsDatasUsed = NMCorrLZsDatas(:,1:NANEndInds_L-1); 
    
    NMCorrRAllTrAvgs = squeeze(mean(NMDatas(NMCorrRInds,:,:)));
    NMCorrRZsDatas = (nanzscore(NMCorrRAllTrAvgs'))';
    NANEndInds_R = find(isnan(NMCorrRZsDatas(1,:)),1,'first');
    NMCorrRZsDatasUsed = NMCorrRZsDatas(:,1:NANEndInds_R-1); 
    
    % extract passive datas
    [StartInds,EndInds] = regexp(SessPaths{cSess},'test\d{2,3}');
    cPassDataUpperPath = fullfile(sprintf('%srf',SessPaths{cSess}(1:EndInds)),'im_data_reg_cpu','result_save');
    cSessPassDataPath = fullfile(cPassDataUpperPath,'plot_save','NO_Correction','rfSelectDataSet.mat');
    cSessPassDataStrc = load(cSessPassDataPath,'SelectData','SelectSArray','frame_rate');
    
    % Avg all Passive trials
    PassDatas = cSessPassDataStrc.SelectData(:,UsedROIindex,:);
    PassAllTrAvgDatas = squeeze(mean(PassDatas));
    PassAllTrZsDatas = zscore(PassAllTrAvgDatas,0,2);
    
    % Avg according to defined Left and right trials
    PassAllTrFreqs = cSessPassDataStrc.SelectSArray;
    DefaultBound = min(FreqTypesAll) * 2;
    PassLInds = PassAllTrFreqs < DefaultBound;
    PassLDatas = squeeze(mean(PassDatas(PassLInds,:,:)));
    PassLZsData = zscore(PassLDatas,0,2);
    
    
    PassRDatas = squeeze(mean(PassDatas(~PassLInds,:,:)));
    PassRZsData = zscore(PassRDatas,0,2);
    SortDescription = {'Sorted by All Trials';'Sorted by CorrL Trials';'Sorted by CorrR Trials'};
    for cSort = 1 : 3
        switch cSort
            case 1
                [~,MaxInds] = max(NMAllTrZsDatasUsed,[],2);
                [~,TaskAllSortInds] = sort(MaxInds);
            case 2
                [~,MaxInds] = max(NMCorrLZsDatasUsed,[],2);
                [~,TaskAllSortInds] = sort(MaxInds);
            case 3
                [~,MaxInds] = max(NMCorrRZsDatasUsed,[],2);
                [~,TaskAllSortInds] = sort(MaxInds);
            otherwise
                fprintf('No defined sorting method.\n');
        end
                
        hhhhf = figure('position',[30 70 680 1000]);

        % All Trial Avg plots
        subplot(321)
        imagesc(NMAllTrZsDatasUsed(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([StartFrame StartFrame],[0.5,size(NMAllTrZsDatasUsed,1)+0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(NMAllTrZsDatasUsed,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Task All Trials')

        subplot(322)
        imagesc(PassAllTrZsDatas(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([cSessPassDataStrc.frame_rate cSessPassDataStrc.frame_rate],[0.5,size(PassAllTrZsDatas,1)+ 0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(PassAllTrZsDatas,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Pass All Trials')

        subplot(323)
        imagesc(NMCorrLZsDatasUsed(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([StartFrame StartFrame],[0.5,size(NMCorrLZsDatasUsed,1)+0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(NMCorrLZsDatasUsed,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Task Corr Left')

        subplot(324)
        imagesc(PassLZsData(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([cSessPassDataStrc.frame_rate cSessPassDataStrc.frame_rate],[0.5,size(PassLZsData,1)+ 0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(PassLZsData,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Pass Left Trials')

        subplot(325)
        imagesc(NMCorrRZsDatasUsed(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([StartFrame StartFrame],[0.5,size(NMCorrRZsDatasUsed,1)+0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(NMCorrRZsDatasUsed,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Task Corr Left')

        subplot(326)
        imagesc(PassRZsData(TaskAllSortInds,:),[-0.5 2]);
        colormap hot
        line([cSessPassDataStrc.frame_rate cSessPassDataStrc.frame_rate],[0.5,size(PassRZsData,1)+ 0.5],'Color','c','linewidth',2);
        xTicksUsed = 0:TAskFRate:size(PassRZsData,2);
        set(gca,'xtick',xTicksUsed,'xticklabel',xTicksUsed/TAskFRate);
        title('Pass Left Trials')

        annotation('textbox',[0.38,0.685,0.3,0.3],'String',SortDescription{cSort},'FitBoxToText','on','EdgeColor',...
                       'none','FontSize',20,'Color','m');
        saveas(hhhhf,fullfile(SessPaths{cSess},sprintf('TracePlots %s',SortDescription{cSort})));
        saveas(hhhhf,fullfile(SessPaths{cSess},sprintf('TracePlots %s',SortDescription{cSort})),'png');
        close(hhhhf);
    end
    %%
end