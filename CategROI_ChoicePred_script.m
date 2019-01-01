clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessPathAll = {};
m = 1;
while ischar(tline)
    
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');
        
        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,2} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end

%%
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat');
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = fullfile(cPassSessPath,'PassFreqUsedInds.mat');
%     if ~exist(PassUsedIndsfile,'file')
% %         return;
%         continue;
%     end
    PassUsedIndsStrc = load(PassUsedIndsfile);
    IsSessUsed(cSess) = 1;
%     if sum(~PassUsedIndsStrc.PassTrInds)
        
        TaskBehavBound = double(min(behavResults.Stim_toneFreq)) * 2;
        if exist(Sess832ROIIndexFile,'file')
            cSess832DataStrc = load(Sess832ROIIndexFile);
            CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
            CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
        else
            CommonROINum = size(data_aligned,2);
            CommonROIIndex = true(CommonROINum,1);
        end
        %
        UsedROIInds = CommonROIIndex;
        TaskCoefFile = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
        TAnsRespROIs = false(CommonROINum,1);
        TAnsRespROIs(unique([TaskCoefFile.LAnsMergedInds;TaskCoefFile.RAnsMergedInds])) = true;
        UsedROIInds(TAnsRespROIs) = false; % excluding all answer ROIs
        UsedROIBase = false(numel(UsedROIInds),1);
        % loading all categorical ROI inds
    %     cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new','NewCurveFitsave.mat');
    %     cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI','BehavBoundResult','IsCategROI');
        cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','PickedCategROIs.mat');
        cTunFitDataUsed = load(cTunFitDataPath);
        NonAnsCategROIInds = UsedROIBase;
        NonAnsCategROIInds(cTunFitDataUsed.CategROIInds) = true;
    %     NonAnsCategROIInds = logical(cTunFitDataUsed.IsCategROI);
        NonAnsCategROIInds(TAnsRespROIs) = false;
        if ~sum(NonAnsCategROIInds)
            warning('No sensory defined category selective ROI exists.\n');
            % continue;
        end
        NonAnsCategROIs = find(NonAnsCategROIInds);
        NonAnsCategUsedROIs = NonAnsCategROIs(logical(UsedROIInds(NonAnsCategROIs)));
        NonCategUsedROIs = UsedROIInds;
        NonCategUsedROIs(NonAnsCategUsedROIs) = false;
        AllNonCategROIIndex = find(NonCategUsedROIs);

    %    
        if ~isdir('NoCatgROI_PopuChoicePred')
            mkdir('NoCatgROI_PopuChoicePred');
        end
        cd('NoCatgROI_PopuChoicePred');
        nRepeats = 50;
        nCategROIs = length(NonAnsCategUsedROIs);
        nNonCategROIs = length(AllNonCategROIIndex);

        NoCategPopu_UsedROIs = UsedROIBase;
        NoCategPopu_UsedROIs(AllNonCategROIIndex) = true;
        ccUsedROIInds = NoCategPopu_UsedROIs;
        isRepeat = 0;
        TrChoice_Pred_script
        TaskNoCategPredAccu = PredAccuMtx;
        clearvars PredAccuMtx

        CategPopuAccuDataAlls = cell(nRepeats,1);
        MergedIndsAll = cell(nRepeats,1);
        isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
            usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
            MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedIndsAll{cRepeat} = MergedInds;

            clearvars PredAccuMtx

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;
            TrChoice_Pred_script
            CategPopuAccuDataAlls{cRepeat} = PredAccuMtx;
        end
        save CategPredAccuSave.mat CategPopuAccuDataAlls TaskNoCategPredAccu MergedIndsAll -v7.3

        % Passive session
        clearvars SelectData SelectSArray
        cd(cPassSessPath);
        load('rfSelectDataSet.mat');

        if ~isdir('./Categ_PassChoice_Pred/')
            mkdir('./Categ_PassChoice_Pred/');
        end
        cd('./Categ_PassChoice_Pred/');
        
        PassUsedTrInds = PassUsedIndsStrc.PassTrInds;
        %
        isRepeat = 0;
        ccUsedROIInds = NoCategPopu_UsedROIs;
        PassChoicePred_script;
        PassNoCategPredAccu = PredAccuMtx;

        PassCategPopuPredAlls = cell(nRepeats,1);
        isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
    %         usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
    %         MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedInds = MergedIndsAll{cRepeat};
            clearvars PredAccuMtx

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;

            PassChoicePred_script
            PassCategPopuPredAlls{cRepeat} = PredAccuMtx;
        end
        save CategPassPredAccuSave.mat PassCategPopuPredAlls PassNoCategPredAccu -v7.3
        %
        PassSelectTrFreqs = SelectSArray(PassUsedTrInds);
        PassFreqTypes = unique(PassSelectTrFreqs);
        nPassFreqs = length(PassFreqTypes);
        PassFreqPredFracMtx = zeros(nPassFreqs,3);
        for cff = 1 : nPassFreqs
            cfInds = PassSelectTrFreqs == PassFreqTypes(cff);
            cfPassCorrMtx = PassNoCategPredAccu(:,cfInds);
            [~,NearTaskPassCorrInds] = min(abs(PassFreqTypes(cff) - TaskFreqs));
            NearTaskPassCorr = TaskFreqCorrs(NearTaskPassCorrInds);

            PassFreqPredFracMtx(cff,:) = [mean(cfPassCorrMtx(:)),NearTaskPassCorr,TaskFreqTrFrac(NearTaskPassCorrInds)];
        end
%     end
    %%
end

%% 
clearvars -except SessPathAll
nSession = size(SessPathAll,1);
SessChoicePredAccu = cell(nSession,4);
SessAvgChoiceAccuAll = cell(nSession,1);
for cSess = 1 : nSession
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_PopuChoicePred','CategPredAccuSave.mat');
    PassChoicePredfile = fullfile(cPassSessPath,'Categ_PassChoice_Pred','CategPassPredAccuSave.mat');
    load(fullfile(cPassSessPath,'rfSelectDataSet.mat'),'SelectSArray');
    
    TaskChoicePredStrc = load(TaskChoicePredfile);
    PassChoicePredStrc = load(PassChoicePredfile);
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = load(fullfile(cPassSessPath,'PassFreqUsedInds.mat'));
    
    TNoCategPredAccu = TaskChoicePredStrc.TaskNoCategPredAccu;
    PNoCategPredAccu = PassChoicePredStrc.PassNoCategPredAccu;
    
    TWithCategPredAccu = TaskChoicePredStrc.CategPopuAccuDataAlls;
    PWithCategPredAccu = PassChoicePredStrc.PassCategPopuPredAlls;
    
    TWithCategPredMtxAll = cat(3,TWithCategPredAccu{:});
    PWithCategPredMtxAll = cat(3,PWithCategPredAccu{:});
    
    TWithCategPredAvgMtx = squeeze(mean(TWithCategPredMtxAll,3));
    PWithCategPredAvgMtx = squeeze(mean(PWithCategPredMtxAll,3));
    
    % shifted to accuracy data
    PassFreqTypes = unique(SelectSArray(PassUsedIndsfile.PassTrInds));
    nPassFreqs = length(PassFreqTypes);
    PassAllCategPredFracMtx = zeros(nPassFreqs,3);
    PassFreqNoCategFracMtx = zeros(nPassFreqs,3);
    for cff = 1 : nPassFreqs
        cfInds = SelectSArray(PassUsedIndsfile.PassTrInds) == PassFreqTypes(cff);
        cfPassCorrMtx = PNoCategPredAccu(:,cfInds);
        [~,NearTaskPassCorrInds] = min(abs(PassFreqTypes(cff) - TaskFreqs));
        NearTaskPassCorr = TaskFreqCorrs(NearTaskPassCorrInds);
        
        PassFreqNoCategFracMtx(cff,:) = [mean(cfPassCorrMtx(:)),NearTaskPassCorr,TaskFreqTrFrac(NearTaskPassCorrInds)];
        
        % repreats data
        cfAllPassCorrMtx = PWithCategPredAvgMtx(:,cfInds);
        PassAllCategPredFracMtx(cff,:) = [mean(cfAllPassCorrMtx(:)),NearTaskPassCorr,TaskFreqTrFrac(NearTaskPassCorrInds)];
        
    end
    SessChoicePredAccu{cSess,1} = PassFreqNoCategFracMtx;
    SessChoicePredAccu{cSess,2} = TNoCategPredAccu;
    SessChoicePredAccu{cSess,3} = PassAllCategPredFracMtx;
    SessChoicePredAccu{cSess,4} = TWithCategPredAvgMtx;
    
    TaskNoCatgAccu = mean(TNoCategPredAccu(:));
    PassNoCatgAccu = mean(PassFreqNoCategFracMtx(:,1) .* PassFreqNoCategFracMtx(:,2));
    TaskWithCategAccu = mean(TWithCategPredAvgMtx(:));
    PassWithCategAccu = mean(PassAllCategPredFracMtx(:,1) .* PassAllCategPredFracMtx(:,2));
    
    SessAvgChoiceAccuAll{cSess,1} = [TaskNoCatgAccu,PassNoCatgAccu,TaskWithCategAccu,...
        PassWithCategAccu,mean(PassFreqNoCategFracMtx(:,1)),mean(PassAllCategPredFracMtx(:,1))];
end
%%
% error rate correction
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
hNewf = FourColDataPlots(CoefMtx(:,1:4),{'NoCatgT','NoCatgP','CategT','CategP'},{'r','k','m','k'});
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(CoefMtx(:,1),CoefMtx(:,2));
GroupSigIndication([1,2],max(CoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(CoefMtx(:,3),CoefMtx(:,4));
GroupSigIndication([3,4],max(CoefMtx(:,3:4)),p_34,hNewf);

%%
% without error rate correction
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
UsedCoefMtx = CoefMtx(:,[1,5,3,6]);
hNewf = FourColDataPlots(UsedCoefMtx(:,1:4),{'NoCatgT','NoCatgP','CategT','CategP'},{'r','k','m','k'});
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,2));
GroupSigIndication([1,2],max(UsedCoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(UsedCoefMtx(:,3),UsedCoefMtx(:,4));
GroupSigIndication([3,4],max(UsedCoefMtx(:,3:4)),p_34,hNewf);

%%
nSession = size(SessPathAll,1);

for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
%     TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_PopuChoicePred','CategPredAccuSave.mat');
%     PassChoicePredfile = fullfile(cPassSessPath,'Categ_PassChoice_Pred','CategPassPredAccuSave.mat');
    PassFreqsStrc = load(fullfile(cPassSessPath,'rfSelectDataSet.mat'),'SelectSArray');
    
    PassFreqTypes = unique(PassFreqsStrc.SelectSArray);
    
%     TaskChoicePredStrc = load(TaskChoicePredfile);
%     PassChoicePredStrc = load(PassChoicePredfile);
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    disp(TaskFreqs);
%     disp('\n');
    disp(PassFreqTypes');
%     disp('\n');
    PassUsedIndsTr = input('Please select pass used inds:\n','s');
    PassPassUsedInds = str2num(PassUsedIndsTr);
    if numel(PassPassUsedInds) == 1 && PassPassUsedInds > 0
        PassIndsAll = find(true(numel(PassFreqTypes),1));
        PassTrInds = true(numel(PassFreqsStrc.SelectSArray),1);
    elseif numel(PassPassUsedInds) > 1
        PassIndsAll = PassPassUsedInds;
        nUsedInds = numel(PassIndsAll);
        PassTrInds = false(numel(PassFreqsStrc.SelectSArray),1);
        for cInds = 1 : nUsedInds
            cIndsTrInds = PassFreqsStrc.SelectSArray == PassFreqTypes(PassIndsAll(cInds));
            PassTrInds(cIndsTrInds) = true;
        end
    elseif isempty(PassPassUsedInds)
        PassIndsAll = [];
        PassTrInds = [];
    else
        warning('Unkown input types.\n');
        PassIndsAll = [];
        PassTrInds = [];
    end
    
    cd(cPassSessPath);
    if ~isempty(PassTrInds)
        save PassFreqUsedInds.mat PassIndsAll PassTrInds -v7.3
    end
    %
end

%% single cell AUC calculation 
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
for cSess = 1 : 2 %nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    clearvars behavResults smooth_data
    load('CSessionData.mat');
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = fullfile(cPassSessPath,'PassFreqUsedInds.mat');
    TrialTypes = behavResults.Trial_Type(:);
    PassUsedIndsStrc = load(PassUsedIndsfile);
    IsSessUsed(cSess) = 1;
        
        TaskBehavBound = double(min(behavResults.Stim_toneFreq)) * 2;
        if exist(Sess832ROIIndexFile,'file')
            cSess832DataStrc = load(Sess832ROIIndexFile);
            CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
            CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
        else
            CommonROINum = size(data_aligned,2);
            CommonROIIndex = true(CommonROINum,1);
        end
        %
        UsedROIInds = logical(CommonROIIndex);
        if ~isdir('./UsedROI_AUC/')
            mkdir('./UsedROI_AUC/');
        end
        cd('./UsedROI_AUC/');
        ROC_check(smooth_data(:,UsedROIInds,:),TrialTypes,start_frame,frame_rate,1,'Stim_time_Align');
        
        % Passive session
        clearvars SelectData SelectSArray
        cd(cPassSessPath);
        load('rfSelectDataSet.mat');
        
        PassUsedTrInds = logical(PassUsedIndsStrc.PassTrInds);
        %
        if ~isdir('./UsedROI_AUC/')
            mkdir('./UsedROI_AUC/');
        end
        cd('./UsedROI_AUC/');
        ROC_check(SelectData(PassUsedTrInds,UsedROIInds,:),SelectSArray(PassUsedTrInds)>TaskBehavBound,...
            frame_rate,frame_rate,1,'Stim_time_Align_select');
        save UsedTaskROIInds.mat UsedROIInds -v7.3
        
end
