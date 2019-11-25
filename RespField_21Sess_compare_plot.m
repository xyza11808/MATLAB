
% 21 sessions saved path

clearvars -except NormSessPathTask NormSessPathPass

nSession = length(NormSessPathTask);
UsedIndsSummary = {};
CompTaskPassFiledCoef = cell(nSession,2);
CompTaskPassFreqs = cell(nSession,2);
TPToneSummary = cell(nSession,2);
for css = 1 : nSession
    cTaskPath = NormSessPathTask{css};
    cPassPath = NormSessPathPass{css};
    cd(cTaskPath);
    try
        %
        clearvars TaskCoefDataStrc PassCoefDataStrc
%
        TaskCoefPath = fullfile(cTaskPath,'SigSelectiveROIInds.mat');
        try
            TaskCoefDataStrc = load(TaskCoefPath);
        catch
            TaskCoefDataStrc = load(fullfile(cTaskPath,'SP_RespField_ana','SigSelectiveROIInds.mat'));
        end
        PassCoefPath = fullfile(cPassPath,'ROIglmCoefSave.mat');
        try
            PassCoefDataStrc = load(PassCoefPath);
        catch
            PassCoefDataStrc = load(fullfile(cPassPath,'SP_RespField_ana','ROIglmCoefSave.mat'));
        end
        PassBFFileData = PassCoefDataStrc.PassBFInds;
        PassBFIndex = find(PassBFFileData);
        nFreqs = numel(PassCoefDataStrc.FreqTypes);
        %
        PassRespROIInds = cellfun(@(x) ~isempty(x),PassCoefDataStrc.ROIAboveThresSummary(:,1));
        PassRespROIIndex = find(PassRespROIInds);
        nTotalROIs = size(PassCoefDataStrc.ROIAboveThresSummary,1);
        BlankPassCoefInds  = zeros(nTotalROIs,nFreqs);
        %
        cPassROINum = length(PassRespROIIndex);
        IsPassInTask = true(cPassROINum,1);
        for cPassr = 1 : cPassROINum
            IsPassInTask(cPassr) = (any(TaskCoefDataStrc.SigROIInds == PassRespROIIndex(cPassr)));

            cROISigCoefIndex = PassCoefDataStrc.ROIAboveThresSummary{PassRespROIIndex(cPassr),1};
            cROISigCoefAll = PassCoefDataStrc.ROIAboveThresSummary{PassRespROIIndex(cPassr),2};
            if max(cROISigCoefIndex) > nFreqs && min(cROISigCoefIndex) <= nFreqs
                % check if StimOff response exists
                TempBlankInds = zeros(nFreqs,2);
                OffInds = cROISigCoefIndex > nFreqs;
                OnCoefIndex = cROISigCoefIndex(~OffInds);
                OnCoefValues = cROISigCoefAll(~OffInds);
                TempBlankInds(OnCoefIndex,1) = OnCoefValues;

                OffCoefIndex = cROISigCoefIndex(OffInds) - nFreqs;
                OffCoefValues = cROISigCoefAll(OffInds);
                TempBlankInds(OffCoefIndex,2) = OffCoefValues;
                RespCoefValues = max(TempBlankInds,[],2);
            elseif any(cROISigCoefIndex <= nFreqs)
                % only Stim on resp exists
                RespCoefValues = zeros(nFreqs,1);
                RespCoefValues(cROISigCoefIndex) = cROISigCoefAll;
            elseif any(cROISigCoefIndex > nFreqs)
                % only stim off resps
                RespCoefValues = zeros(nFreqs,1);
                RespCoefValues(cROISigCoefIndex - nFreqs) = cROISigCoefAll;
            end
            BlankPassCoefInds(PassRespROIIndex(cPassr),:) = RespCoefValues;
            %
        end
        CompTaskPassFiledCoef{css,1} = TaskCoefDataStrc.SigROICoefMtx;
        
        TaskBehavData = load(fullfile(cTaskPath,'RandP_data_plots','boundary_result.mat'));
        TaskBehavTones = double(TaskBehavData.boundary_result.StimType);
        PassUsedFreq = PassCoefDataStrc.FreqTypes;
        nTaskFreqs = length(TaskBehavTones);
        UsedIndsDef = 1 : size(TaskCoefDataStrc.SigROICoefMtx,2);
        TPToneSummary(css,:) = {TaskBehavTones,PassCoefDataStrc.FreqTypes};
        if size(BlankPassCoefInds,2) ~= size(TaskCoefDataStrc.SigROICoefMtx,2)
            TaskToneOctaves = log2(TaskBehavTones/16000);
            PassToneOctaves = log2(PassCoefDataStrc.FreqTypes/16000);
            disp(TaskToneOctaves);
            disp(PassToneOctaves');
            UsedIndsStr = input('Please select the used frequency inds:\n','s');
            if isempty(UsedIndsStr)
                continue;
            else
                UsedInds = str2num(UsedIndsStr);
                BlankPassCoefRaw = BlankPassCoefInds;
                BlankPassCoefInds = BlankPassCoefInds(:,UsedInds);
                PassUsedFreq = PassCoefDataStrc.FreqTypes(UsedInds);
                UsedIndsSummary{css} = UsedInds;
            end
        elseif size(BlankPassCoefInds,2) < size(TaskCoefDataStrc.SigROICoefMtx,2)
            BackTaskCoefs = TaskCoefDataStrc.SigROICoefMtx;
            ExcludeTaskCoefIndex = ceil(numel(nTaskFreqs)/2);
            TaskCoefDataStrc.SigROICoefMtx(:,ExcludeTaskCoefIndex) = [];
            nTaskFreqs = nTaskFreqs - 1;
            TaskBehavTones(ExcludeTaskCoefIndex) = [];
        else
            UsedIndsSummary{css} = UsedIndsDef;
        end
        
         % sort the task Resp data
        [~,maxInds] = max(TaskCoefDataStrc.SigROICoefMtx,[],2);
        [~,SortInds] = sort(maxInds);
        TaskSortCoefs = TaskCoefDataStrc.SigROICoefMtx(SortInds,:);
        if mean(IsPassInTask) ~= 1
            ExtraPassTunROIs = PassRespROIIndex(~IsPassInTask);
            TaskAllCoefs = [TaskSortCoefs;zeros(numel(ExtraPassTunROIs),nTaskFreqs)];
            ROIIndsAll = [TaskCoefDataStrc.SigROIInds(SortInds);ExtraPassTunROIs];

            PassAllCoefs = BlankPassCoefInds(ROIIndsAll,:); 
        else
            TaskAllCoefs = TaskSortCoefs;
            ROIIndsAll = TaskCoefDataStrc.SigROIInds(SortInds);
            PassAllCoefs = BlankPassCoefInds(ROIIndsAll,:);
        end
        % Both Empty ROIcoefs
        NoEmptyROIs = (sum(TaskAllCoefs,2) | sum(PassAllCoefs,2));
        
        CommonROIInds = ROIIndsAll(NoEmptyROIs);
        CommonTaskCoefs = TaskAllCoefs(NoEmptyROIs,:);
        CommonPassCoefs = PassAllCoefs(NoEmptyROIs,:);
        
        
        CompTaskPassFreqs{css,1} = TaskBehavTones;
        CompTaskPassFreqs{css,2} = PassUsedFreq;
        CompTaskPassFiledCoef{css,1} = CommonTaskCoefs;
        CompTaskPassFiledCoef{css,2} = CommonPassCoefs;
        %
    catch ME
        fprintf('Error at session %d.\n',css);
        disp(ME);
    end
end

%%
CompTaskPassFiledCoefBack = CompTaskPassFiledCoef;


%% compare the closs to boundary coef number

nSession = length(NormSessPathTask);

TaskPassCoefSort = cell(nSession,2);
for css = 1 : nSession
    cTaskPath = NormSessPathTask{css};
    TaskBehavData = load(fullfile(cTaskPath,'RandP_data_plots','boundary_result.mat'));
    TaskBoundOct = TaskBehavData.boundary_result.Boundary - 1;
    
    TaskOctTones = log2(CompTaskPassFreqs{css,1}/16000);
%     PassOctTones = CompTaskPassFreqs{css,2};
    cToneNum = numel(TaskOctTones);
    if isempty(CompTaskPassFiledCoef{css,2})
        continue;
    end
    
    if size(CompTaskPassFiledCoef{css,1},2) ~= size(CompTaskPassFiledCoef{css,2},2)
        CompTaskPassFiledCoef{css,1}(:,ceil(numel(TaskOctTones)/2)) = [];
        TaskOctTones(ceil(numel(TaskOctTones)/2)) = [];
        cToneNum = cToneNum - 1;
    end
    Tone2BoundDis = abs(TaskOctTones - TaskBoundOct);
    [~,SortInds] = sort(Tone2BoundDis);
    
    TaskCoefs = CompTaskPassFiledCoef{css,1}(:,SortInds);
    PassCoefs = CompTaskPassFiledCoef{css,2}(:,SortInds);
    
    TaskCoefull = nan(size(TaskCoefs,1),8);
    PassCoefull = nan(size(TaskCoefs,1),8);
    
    TaskCoefull(:,1:cToneNum) = TaskCoefs;
    PassCoefull(:,1:cToneNum) = PassCoefs;
    
    TaskPassCoefSort(css,:) = {TaskCoefull,PassCoefull};
    
end
    
%% 
TaskCoefAlls = cell2mat(TaskPassCoefSort(:,1));
PassCoefAlls = cell2mat(TaskPassCoefSort(:,2));
%
% UsedSess = [1,2,3,4,5,6,7,9,13,14,15,16,17,18,19,20,21];
% TPUsedCoefSort = TaskPassCoefSort(UsedSess,:);
% TaskCoefAlls = cell2mat(TPUsedCoefSort(:,1));
% PassCoefAlls = cell2mat(TPUsedCoefSort(:,2));


TaskCoefNumbers = sum(TaskCoefAlls > 0,'omitnan');
PassCoefNumbers = sum(PassCoefAlls > 0,'omitnan');

DataSumNum = size(TaskCoefAlls,1) - sum(isnan(TaskCoefAlls));

TaskZeroCoefNum = DataSumNum - TaskCoefNumbers;
PassZeroCoefNum = DataSumNum - PassCoefNumbers;

TaskCoefTypeNum = [TaskCoefNumbers;TaskZeroCoefNum];
PassCoefTypeNum = [PassCoefNumbers;PassZeroCoefNum];

%% compare the fraction between task and passive condition

nCols = size(TaskCoefTypeNum,2);
ColFrac_chip = zeros(nCols,1);
ColFracAlls = cell(nCols,1);
for ccol = 1 : nCols
    ChiTables = [TaskCoefTypeNum(:,ccol),PassCoefTypeNum(:,ccol)];
    
    ChiRowSum = sum(ChiTables,2);
    ChiColSum = sum(ChiTables);
    TotalTableNum = sum(ChiRowSum);
    v = (size(ChiTables,1) - 1);

    ChiEXPTable = ChiRowSum * (ChiColSum/TotalTableNum);

    chi2stat = sum(sum((ChiTables - ChiEXPTable).^2 ./ ChiEXPTable));

    ChiSquare_p = 1 - chi2cdf(chi2stat,v);
    ColFrac_chip(ccol) = ChiSquare_p;
    
    ColFrac = ChiTables ./ repmat(sum(ChiTables),2,1);
    ColFracAlls{ccol} = ColFrac;
end
%%
nCols = length(ColFracAlls);
xBases = 0;
xCenters = zeros(nCols,1);
h_f = figure('position',[100 100 900 260]);

for cc = 1 : nCols
    
%     ax = subplot(1,nCols,cc);
    hold on
    bLeg = bar(xBases + [1,2],(ColFracAlls{cc})',0.8,'stacked','EdgeColor','none');
    bLeg(1).FaceColor = [0.1 0.5 0.1];
    bLeg(2).FaceColor = [0.5 0.1 0.1];
    GroupSigIndication(xBases + [1,2],[1 1],ColFrac_chip(cc),h_f);
    text(xBases+[0.4,2.5],ColFracAlls{cc}(1,:),cellstr(num2str((ColFracAlls{cc}(1,:))','%.4f')),...
        'FontSize',8,'HorizontalAlignment','center','Color','b');
    xCenters(cc) = xBases+1.5;
    xBases = xBases + 3;
    
end
set(gca,'xtick',xCenters,'xticklabel',cellstr(num2str((1:nCols)','Freq%d')));
set(gca,'ytick',[0 0.5 1]);
ylabel('Resp Fraction');
set(gca,'FontSize',12);
title('RespField fraction plot');


