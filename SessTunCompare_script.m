

SessPaths = {'P:\BatchData\batch55\20180823\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch55\20180905\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch55\20180906\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch55\20180908\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
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