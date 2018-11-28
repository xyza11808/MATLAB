

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
load('SessCompDataSave.mat', 'SessPaths')
% SessPaths = {'S:\BatchData\batch58\20181101\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
%     'S:\BatchData\batch58\20181102\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
%     'S:\BatchData\batch58\20181103\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
%     'S:\BatchData\batch58\20181104\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
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
hSPCoef = figure('position',[80 120 1750 340]);
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
    subplot(1,nSess,UsedSortInds)
    imshow(cfid);
    title(sprintf('Sess %d',UsedSortInds));
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
 