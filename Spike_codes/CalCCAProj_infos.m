
clearvars behavResults TypeRespCalResults TypeAreaPairInfo BlockVarDatas TrialVarDatas

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
CalDataTypeStrs = {'Base_BVar','Af_BVar','Base_TrVar','Af_TrVar'};

for cPairInds = 1:1 %NumPairs
    cPairUsedAreaInds = PairAreaInds(cPairInds,:);
    cPair_Area1_unitInds = ExistField_ClusIDs{cPairUsedAreaInds(1),2};
    cPair_Area2_unitInds = ExistField_ClusIDs{cPairUsedAreaInds(2),2};
    cPairRepeatCals = TypeRespCalResults(cPairInds,:); % Base_BVar,Af_BVar,Base_TrVar,Af_TrVar
    
    TypeDataCalInfo_Choice = cell(1, 4);
    TypeDataCalInfo_BT = cell(1, 4);
    % valid dataset already contains raw data part
    for cDataType = 1 : 4
        cData_cals = cPairRepeatCals{cDataType};
        % only non-miss trial is used for calculation
        %     cTypeRawData_A1 = fourTypeRawDatas{cDataType}(cPair_Area1_unitInds,NMTrInds,:);
        %     cTypeRawData_A2 = fourTypeRawDatas{cDataType}(cPair_Area2_unitInds,NMTrInds,:);
        cTypeValidData_A1 = fourTypeValidDatas{cDataType}(cPair_Area1_unitInds,NMTrInds,:);
        cTypeValidData_A2 = fourTypeValidDatas{cDataType}(cPair_Area2_unitInds,NMTrInds,:);
        NumTimeBin = size(cTypeValidData_A1, 3);
        NumMaxComponents = min(size(cTypeValidData_A1, 1), size(cTypeValidData_A2, 1));
        
        nRepeats = size(cData_cals, 1);
        RepeatInfos_choice = zeros(NumMaxComponents, NumTimeBin,3,nRepeats);
        RepeatInfos_Ch = zeros(NumMaxComponents, NumTimeBin,3,nRepeats);
        for cRepeat = 1 :  nRepeats
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
            ValidProjDataInfo_A1 = zeros(NumMaxComponents, NumTimeBin, 3, 2, 2);
            ValidProjDataInfo_A2 = zeros(NumMaxComponents, NumTimeBin, 3, 2, 2);
            for cComp = 1 : NumMaxComponents
                for cTimeBin = 1 : NumTimeBin
                    
                    % calculate for valid datas
                    cProjDatas_cA1 = cA1_proj_Valid(:, cComp,cTimeBin);
                    [RepeatAvgScores_BT, RepeatAvgPerfs_BT] = TrEqualSampleinfo(cProjDatas_cA1, BlockLabelInds, 0.6);
                    [RepeatAvgScores_Ch, RepeatAvgPerfs_Ch] = TrEqualSampleinfo(cProjDatas_cA1, ChoiceLabelInds, 0.6);
                    ValidProjDataInfo_A1(cComp, cTimeBin, :, 1, 1) = RepeatAvgScores_BT;
                    ValidProjDataInfo_A1(cComp, cTimeBin, :, 2, 1) = RepeatAvgPerfs_BT;
                    ValidProjDataInfo_A1(cComp, cTimeBin, :, 1, 2) = RepeatAvgScores_Ch;
                    ValidProjDataInfo_A1(cComp, cTimeBin, :, 2, 2) = RepeatAvgPerfs_Ch;
                    
                    cProjDatas_cA2 = cA2_proj_Valid(:, cComp,cTimeBin);
                    [A2RepeatAvgScores_BT, A2RepeatAvgPerfs_BT] = TrEqualSampleinfo(cProjDatas_cA2, BlockLabelInds, 0.6);
                    [A2RepeatAvgScores_Ch, A2RepeatAvgPerfs_Ch] = TrEqualSampleinfo(cProjDatas_cA2, ChoiceLabelInds, 0.6);
                    ValidProjDataInfo_A2(cComp, cTimeBin, :, 1, 1) = A2RepeatAvgScores_BT;
                    ValidProjDataInfo_A2(cComp, cTimeBin, :, 2, 1) = A2RepeatAvgPerfs_BT;
                    ValidProjDataInfo_A2(cComp, cTimeBin, :, 1, 2) = A2RepeatAvgScores_Ch;
                    ValidProjDataInfo_A2(cComp, cTimeBin, :, 2, 2) = A2RepeatAvgPerfs_Ch;
                    
                end
            end
            A1_usedInfoData_BT = ValidProjDataInfo_A1(:,:,:,1,1); % only choice score is seprated
            A1_usedInfoData_Ch = ValidProjDataInfo_A1(:,:,:,1,2);
            
            RepeatInfos_choice(:,:,:,cRepeat) = A1_usedInfoData_BT;
            RepeatInfos_Ch(:,:,:,cRepeat) = A1_usedInfoData_Ch;
        end
        
        TypeDataCalInfo_BT{cDataType} = mean(RepeatInfos_choice, 4); % train test and threshold
        TypeDataCalInfo_Choice{cDataType} = mean(RepeatInfos_Ch, 4);
        
    end
    
    % cPairTypeInfos = [TypeDataCalInfo_BT,TypeDataCalInfo_Choice];
    
    AllPairInfos(cPairInds,:) = {TypeDataCalInfo_BT,TypeDataCalInfo_Choice};
end
%%
savefilename = fullfile(ksfolder,'jeccAnA','ProjDataInfo.mat');
save(savefilename,'AllPairInfos','PairAreaInds','ExistField_ClusIDs','-v7.3');

