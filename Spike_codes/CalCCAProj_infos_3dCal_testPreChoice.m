
clearvars behavResults TypeRespCalResults TypeAreaPairInfo BlockVarDatas TrialVarDatas PairAreaInds AllPairInfos
savefilename = fullfile(ksfolder,'jeccAnA','ProjDataInfo_PrechoiceInfo.mat');

if exist(savefilename,'file')
    return;
end

load(fullfile(ksfolder,'NewClassHandle2.mat'), 'behavResults');
load(fullfile(ksfolder,'jeccAnA','CCACalDatas.mat'));
load(fullfile(ksfolder,'jeccAnA','CCA_TypeSubCal.mat'), 'TypeRespCalResults','TypeAreaPairInfo');


%%

BlockSectionInfo = Bev2blockinfoFun(behavResults);

% performing trialtype average subtraction for each frequency types
AllTrFreqs = double(behavResults.Stim_toneFreq(:));
AllTrBlocks = double(behavResults.BlockType(:));
AllTrChoices = double(behavResults.Action_choice(:));
NMTrInds = AllTrChoices(1:sum(BlockSectionInfo.BlockLens)) ~= 2;
NMTrFreqs = AllTrFreqs(NMTrInds);
NMBlockTypes = AllTrBlocks(NMTrInds);
NMBlockBoundVec = [1;abs(diff(NMBlockTypes))];
NMBlockBoundIndex = cumsum(NMBlockBoundVec);
NMActionChoice = AllTrChoices(NMTrInds);

[BlockTypes, ~, BlockLabelInds] = unique(NMBlockTypes);
[ChoiceTypes, ~, ChoiceLabelInds] = unique(NMActionChoice);

%%
NumAreas = length(NewAdd_ExistAreaNames);
PairAreaInds = zeros(NumAreas*(NumAreas - 1)/2,2);
k = 1;
for cA1 = 1 : NumAreas
    for cA2 = cA1+1 : NumAreas
        PairAreaInds(k,:) = [cA1, cA2];
        k = k + 1;
    end
end

%%
% % TypeRespCalResults(ks,:) = {BaseRepeatCorrSum, AfRepeatCorrSum, Base2RepeatCorrSum, Af2RepeatCorrSum};
BlockVarDatasPermu = cellfun(@(x) permute(x,[2, 1, 3]),BlockVarDatas,'un',0);
TrialVarDatasPermu = cellfun(@(x) permute(x,[2, 1, 3]),TrialVarDatas,'un',0);
% BlockVarDatasPermu = BlockVarDatas;
% TrialVarDatasPermu = TrialVarDatas;
% fourTypeRawDatas = {BlockVarDatasPermu{1},TrialVarDatasPermu{1},BlockVarDatasPermu{3},TrialVarDatasPermu{3}};
fourTypeValidDatas = {BlockVarDatasPermu{2},TrialVarDatasPermu{2},BlockVarDatasPermu{4},TrialVarDatasPermu{4}};
NumPairs = size(TypeRespCalResults,1);
AllPairInfos = cell(NumPairs, 2);
%%
CalDataTypeStrs = {'Base_BVar','Base_TrVar','Af_BVar','Af_TrVar'};
tic
for cPairInds = 1:NumPairs
    cPairUsedAreaInds = PairAreaInds(cPairInds,:);
    cPair_Area1_unitInds = ExistField_ClusIDs{cPairUsedAreaInds(1),2};
    cPair_Area2_unitInds = ExistField_ClusIDs{cPairUsedAreaInds(2),2};
    cPairRepeatCals = TypeRespCalResults(cPairInds,:); % Base_BVar,Af_BVar,Base_TrVar,Af_TrVar
    
    TypeDataCalInfo_preChoice_A1 = cell(1, 4);
    TypeDataCalInfo_preChoice_A2 = cell(1, 4);
    
    % valid dataset already contains raw data part
    for cDataType = 1 : 4
        cData_cals = cPairRepeatCals{cDataType};
        % only non-miss trial is used for calculation
        %     cTypeRawData_A1 = fourTypeRawDatas{cDataType}(cPair_Area1_unitInds,NMTrInds,:);
        %     cTypeRawData_A2 = fourTypeRawDatas{cDataType}(cPair_Area2_unitInds,NMTrInds,:);
        cTypeValidData_A1_raw = fourTypeValidDatas{cDataType}(cPair_Area1_unitInds,NMTrInds,:);
        cTypeValidData_A2_raw = fourTypeValidDatas{cDataType}(cPair_Area2_unitInds,NMTrInds,:);
        
        NumTimeBin = size(cTypeValidData_A1_raw, 3);
        cTypeValidData_A1 = zeros(size(cTypeValidData_A1_raw));
        cTypeValidData_A2 = zeros(size(cTypeValidData_A2_raw));
        for cBin = 1 : NumTimeBin
            cA1Data = (cTypeValidData_A1_raw(:,:,cBin))';
            cTypeValidData_A1(:,:,cBin) = (cA1Data - mean(cA1Data))';
            cA2Data = (cTypeValidData_A2_raw(:,:,cBin))';
            cTypeValidData_A2(:,:,cBin) = (cA2Data - mean(cA2Data))';
        end
        
        NumMaxComponents = min(size(cTypeValidData_A1, 1), size(cTypeValidData_A2, 1));
        NumMaxComponents = min(NumMaxComponents,10); % maximumly top ten component is calculated
        nRepeats = size(cData_cals, 1);
        RepeatInfos_Prechoice_A1 = zeros(NumMaxComponents, NumTimeBin,3,nRepeats);
        RepeatInfos_Prechoice_A2 = zeros(NumMaxComponents, NumTimeBin,3,nRepeats);

        parfor cRepeat = 1 :  nRepeats
            %         cRepeat = 1;
            cRCorrCoefs = cData_cals(cRepeat,:);
            %     {A1_base, A2_base, R_base, SampleR, cat(2,FrameCorrs{:}), cat(2,ShufCorrs{:})};
            cA1_projCoef = cRCorrCoefs{1};
            cA2_projCoef = cRCorrCoefs{2};
            
            %         % calculate the raw data projection datas
            % %         cA1_proj_Raw = cTypeRawData_A1 * cA1_projCoef; % nTrials by TimeBin by nComponents
            % %         cA2_proj_Raw = cTypeRawData_A2 * cA2_projCoef; % nTrials by TimeBin by nComponents
            %         cA1_proj_Raw = pagemtimes(cA1_projCoef', cTypeRawData_A1); % nComponents by TimeBin by nTrials
            %         cA2_proj_Raw = pagemtimes(cA2_projCoef', cTypeRawData_A2); % nComponents by TimeBin by nTrials
            
            
            %         cA1_proj_Valid = cTypeValidData_A1 * cA1_projCoef; %
            %         cA2_proj_Valid = cTypeValidData_A2 * cA2_projCoef; %
            cA1_proj_Valid = permute(pagemtimes(cA1_projCoef', cTypeValidData_A1),[2,1,3]); %
            cA2_proj_Valid = permute(pagemtimes(cA2_projCoef', cTypeValidData_A2),[2,1,3]); %
            
            
            % the info for each component will be calculated seperatedly
            %         [~, NumMaxComponents, NumTimeBin] = size(cA1_proj_Valid);
            %         RawProjDataInfo_A1 = zeros(NumMaxComponents, NumTimeBin, 2, 2, 2); % the last four dimensions are [Train test threshold], [Score, Perf],[BT choice]
            %         RawProjDataInfo_A2 = zeros(NumMaxComponents, NumTimeBin, 2, 2, 2);
            ValidProjDataInfo_A1 = zeros(NumMaxComponents, NumTimeBin, 3, 2, 'single');
            ValidProjDataInfo_A2 = zeros(NumMaxComponents, NumTimeBin, 3, 2, 'single');
            for cComp = 1 : NumMaxComponents
%                 for cTimeBin = 1 : NumTimeBin
                    
                    % calculate for valid datas
                    cProjDatas_cA1 = cA1_proj_Valid(:, cComp,:);
                    [RepeatAvgScores_BT, RepeatAvgPerfs_BT] = TrEqualSampleinfo_3d(cProjDatas_cA1(2:end,:,:), ChoiceLabelInds(1:end-1), 0.6);
%                     [RepeatAvgScores_Ch, RepeatAvgPerfs_Ch] = TrEqualSampleinfo_3d(cProjDatas_cA1, ChoiceLabelInds, 0.6);
                    ValidProjDataInfo_A1(cComp, :, :, 1) = RepeatAvgScores_BT;
                    ValidProjDataInfo_A1(cComp, :, :, 2) = RepeatAvgPerfs_BT;
%                     ValidProjDataInfo_A1(cComp, :, :, 1, 2) = RepeatAvgScores_Ch;
%                     ValidProjDataInfo_A1(cComp, :, :, 2, 2) = RepeatAvgPerfs_Ch;
                    
                    cProjDatas_cA2 = cA2_proj_Valid(:, cComp,:);
                    [A2RepeatAvgScores_BT, A2RepeatAvgPerfs_BT] = TrEqualSampleinfo_3d(cProjDatas_cA2(2:end,:,:), ChoiceLabelInds(1:end-1), 0.6);
%                     [A2RepeatAvgScores_Ch, A2RepeatAvgPerfs_Ch] = TrEqualSampleinfo_3d(cProjDatas_cA2, ChoiceLabelInds, 0.6);
                    ValidProjDataInfo_A2(cComp, :, :, 1) = A2RepeatAvgScores_BT;
                    ValidProjDataInfo_A2(cComp, :, :, 2) = A2RepeatAvgPerfs_BT;
%                     ValidProjDataInfo_A2(cComp, :, :, 1, 2) = A2RepeatAvgScores_Ch;
%                     ValidProjDataInfo_A2(cComp, :, :, 2, 2) = A2RepeatAvgPerfs_Ch;
                    
%                 end
            end
            A1_usedInfoData_preCh = ValidProjDataInfo_A1(:,:,:,1);
            A2_usedInfoData_preCh = ValidProjDataInfo_A2(:,:,:,1);
            
            RepeatInfos_Prechoice_A1(:,:,:,cRepeat) = A1_usedInfoData_preCh;
            RepeatInfos_Prechoice_A2(:,:,:,cRepeat) = A2_usedInfoData_preCh;
        end
        TypeDataCalInfo_preChoice_A1{cDataType} = mean(RepeatInfos_Prechoice_A1, 4);
        TypeDataCalInfo_preChoice_A2{cDataType} = mean(RepeatInfos_Prechoice_A2, 4);
    end
    
    % cPairTypeInfos = [TypeDataCalInfo_BT,TypeDataCalInfo_Choice];
    
    AllPairInfos(cPairInds,:) = {TypeDataCalInfo_preChoice_A1,TypeDataCalInfo_preChoice_A2}; % A1_info_BT,A2_info_BT,A1_info_choice,A2_info_choice
    
    clearvars TypeDataCalInfo_preChoice_A1 TypeDataCalInfo_preChoice_A2 
end
toc

%%
% savefilename = fullfile(ksfolder,'jeccAnA','ProjDataInfo.mat');
save(savefilename,'AllPairInfos','PairAreaInds','ExistField_ClusIDs','-v7.3');

