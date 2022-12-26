% % batched through all used sessions
% cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);

SessIndexCell = readcell(AllSessFolderPathfile,'Range','D:D',...
        'Sheet',1);
SessIndexAll = SessIndexCell(2:end);
SessIndexUsed = cat(1,SessIndexAll{UsedFolderInds});

UniqueSessTypes = unique(SessIndexUsed);
%%
load('K:\NPdatas\acrossProbeData\AcrossProbe_CCA_calResults.mat');

%
NumSess = size(AllSessCalDatas, 1);

%%
% SessPairedDataSavePath = 'I:\ksOutput_backup\PairedSessionDatas';
SessPairedDataSavePath = 'K:\NPdatas\acrossProbeData';
CalDataTypeStrs = {'Base_BVar','Base_TrVar','Af_BVar','Af_TrVar'};

% AllSessFolderDatas = cell(NumSess, 3);
% AllSessCalDatas = cell(NumSess, 3);
for cSess = NumSess: -1 : 8
    tic
    try
        cSessIndex = UniqueSessTypes(cSess);
        cSessfolders = SessionFolders(SessIndexUsed == cSessIndex);
    %     SessNumfolders = length(cSessfolders);
    %     cSfoldersData = cell(SessNumfolders,4);
    %     cSf_AreaNum = zeros(SessNumfolders, 1);
    %     for cSf = 1 : SessNumfolders
    % %         cSfolder = cSessfolders{cSf};
            cSfolder = fullfile(strrep(cSessfolders{1},'F:','I:\ksOutput_backup'),sortingcode_string);
%             cSfolder = fullfile(strrep(cSessfolders{1},'F:','E:\NPCCGs'),sortingcode_string);

    %         cSf_datafile = fullfile(cSfolder,'jeccAnA','CCACalDatas.mat');
    %         cSf_dataStrc = load(cSf_datafile);
    %         cSfoldersData(cSf,:) = {cSf_dataStrc.BlockVarDatas,cSf_dataStrc.TrialVarDatas,...
    %             cSf_dataStrc.ExistField_ClusIDs,cSf_dataStrc.NewAdd_ExistAreaNames};
    %         cSf_AreaNum(cSf) = length(cSfoldersData{cSf,4});
    %     end
        load(fullfile(cSfolder,'NewClassHandle2.mat'),'behavResults');
        %
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
        %
        cSfoldersData = AllSessCalDatas{cSess,1};
        cSf_AreaNum = AllSessCalDatas{cSess,2};
        cSessFolderDatas = AllSessFolderDatas{cSess,1};
        %%
        SessNumfolders = size(cSfoldersData, 1);
    %     for cSNumProbes = 1 : size(cSfoldersData, 1)
    %         cSFoldData1 = cSfoldersData{cSNumProbes, 1};
    %         cSFoldData2 = cSfoldersData{cSNumProbes, 2};
    %         cSFoldData1_cell = cellfun(@single, cSFoldData1, 'un', 0);
    %         cSFoldData2_cell = cellfun(@single, cSFoldData2, 'un', 0);
    %         cSfoldersData{cSNumProbes, 1} = cSFoldData1_cell;
    %         cSfoldersData{cSNumProbes, 2} = cSFoldData2_cell;
    %     end
    %     AllSessCalDatas{cSess,1} = cSfoldersData; %#ok<SAGROW>
        %
        % loop through each session folders to calculate all area pairs
        AllLoopNum = SessNumfolders*(SessNumfolders-1)/2;
        cInfoDatas = cell(AllLoopNum, 1);
        SessFoldInds = cell(AllLoopNum, 2);
        SampleIndexBase = 1;
        k = 1;
        for cf1 = 1 : SessNumfolders
            for cf2 = cf1+1 : SessNumfolders
                cf1data = cSfoldersData(cf1,:);
                cf2data = cSfoldersData(cf2,:);
                SessFoldInds{k, 1} = [cf1,cf2];

                AreaInds = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),1);
                %%%.
                AreaCombNums = cSf_AreaNum(cf1)*cSf_AreaNum(cf2);
                PairedAreaCorrs = cSessFolderDatas(SampleIndexBase:(SampleIndexBase+AreaCombNums-1),:);
                SampleIndexBase = SampleIndexBase + AreaCombNums;
                AllPair_preChInfos = cell(AreaCombNums,3);
%                 PairedAreaCorrs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),6);
%                 PairedAreaAvgs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),4);
%                 AllPairInfos = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),5);
                ks = 1;
                for cf1Area = 1 : cSf_AreaNum(cf1)
                    for cf2Area = 1 : cSf_AreaNum(cf2)
                        if isempty(cf1data{3}) || isempty(cf2data{3})
                            continue;
                        end
                        AreaInds{ks} = [cf1Area, cf2Area];
                        cf1AreaInds = cf1data{3}{cf1Area,2};
                        cf2AreaInds = cf2data{3}{cf2Area,2};

                        cf1AreaNameStr = cf1data{4}{cf1Area};
                        cf2AreaNameStr = cf2data{4}{cf2Area};
                        
                        
                        BVar_basecorrs = PairedAreaCorrs{ks,1};
                        BVar_Afcorrs = PairedAreaCorrs{ks,2};
                        TrVar_basecorrs = PairedAreaCorrs{ks,3};
                        TrVar_Afcorrs = PairedAreaCorrs{ks,4};
                        
                        % Block var baseline kernal
                        cf1BaseBVarValidData = permute(cf1data{1}{2}(NMTrInds,cf1AreaInds,:),[2, 1, 3]); % units by trials by framebin
                        cf2BaseBVarValidData = permute(cf2data{1}{2}(NMTrInds,cf2AreaInds,:),[2, 1, 3]);
                        
                        % Block var afterResp kernal
                        cf1AFBVarValidData = permute(cf1data{1}{4}(NMTrInds,cf1AreaInds,:),[2, 1, 3]);
                        cf2AFBVarValidData = permute(cf2data{1}{4}(NMTrInds,cf2AreaInds,:),[2, 1, 3]);
                        
                        % Trial var baseline kernal
                        cf1BaseTrVarValidData = permute(cf1data{2}{2}(NMTrInds,cf1AreaInds,:),[2, 1, 3]);
                        cf2BaseTrVarValidData = permute(cf2data{2}{2}(NMTrInds,cf2AreaInds,:),[2, 1, 3]);
                        
                        % Trial var afterResp kernal
                        cf1AFTrVarValidData = permute(cf1data{2}{4}(NMTrInds,cf1AreaInds,:),[2, 1, 3]);
                        cf2AFTrVarValidData = permute(cf2data{2}{4}(NMTrInds,cf2AreaInds,:),[2, 1, 3]);
                        
                        NumMaxComponents = min(size(cf1AFTrVarValidData, 1), size(cf2AFTrVarValidData, 1));
                        NumMaxComponents = min(NumMaxComponents,10); 
                        
                        NumTimeBin = size(cf1BaseBVarValidData, 3);
                        BaseBVarValidData_A1 = zeros(size(cf1BaseBVarValidData));
                        BaseBVarValidData_A2 = zeros(size(cf2BaseBVarValidData));
                        BaseTrVarValidData_A1 = zeros(size(cf1BaseTrVarValidData));
                        BaseTrVarValidData_A2 = zeros(size(cf2BaseTrVarValidData));
                        for cBin = 1 : NumTimeBin
                            cA1Data = (cf1BaseBVarValidData(:,:,cBin))';
                            BaseBVarValidData_A1(:,:,cBin) = (cA1Data - mean(cA1Data))';
                            cA2Data = (cf2BaseBVarValidData(:,:,cBin))';
                            BaseBVarValidData_A2(:,:,cBin) = (cA2Data - mean(cA2Data))';
                            
                            cA1Data = (cf1BaseTrVarValidData(:,:,cBin))';
                            BaseTrVarValidData_A1(:,:,cBin) = (cA1Data - mean(cA1Data))';
                            cA2Data = (cf2BaseTrVarValidData(:,:,cBin))';
                            BaseTrVarValidData_A2(:,:,cBin) = (cA2Data - mean(cA2Data))';
                        end
                        % after response time bins
                        NumTimeBin2 = size(cf1AFBVarValidData, 3);
                        AfBVarValidData_A1 = zeros(size(cf1AFBVarValidData));
                        AfBVarValidData_A2 = zeros(size(cf2AFBVarValidData));
                        AfTrVarValidData_A1 = zeros(size(cf1AFTrVarValidData));
                        AfTrVarValidData_A2 = zeros(size(cf2AFTrVarValidData));
                        for cBin = 1 : NumTimeBin2
                            cA1Data = (cf1AFBVarValidData(:,:,cBin))';
                            AfBVarValidData_A1(:,:,cBin) = (cA1Data - mean(cA1Data))';
                            cA2Data = (cf2AFBVarValidData(:,:,cBin))';
                            AfBVarValidData_A2(:,:,cBin) = (cA2Data - mean(cA2Data))';
                            
                            cA1Data = (cf1AFTrVarValidData(:,:,cBin))';
                            AfTrVarValidData_A1(:,:,cBin) = (cA1Data - mean(cA1Data))';
                            cA2Data = (cf2AFTrVarValidData(:,:,cBin))';
                            AfTrVarValidData_A2(:,:,cBin) = (cA2Data - mean(cA2Data))';
                        end
                        
                        AllValidDatasCell = {BaseBVarValidData_A1,BaseTrVarValidData_A1,AfBVarValidData_A1,AfTrVarValidData_A1;...
                            BaseBVarValidData_A2,BaseTrVarValidData_A2,AfBVarValidData_A2,AfTrVarValidData_A2}; 
                        AllDataCorrLoads_A1 = [BVar_basecorrs(:,1), TrVar_basecorrs(:,1), BVar_Afcorrs(:,1), TrVar_Afcorrs(:,1)];
                        AllDataCorrLoads_A2 = [BVar_basecorrs(:,2), TrVar_basecorrs(:,2), BVar_Afcorrs(:,2), TrVar_Afcorrs(:,2)];
                        NumRepeats = size(BVar_basecorrs, 1);
                        TypeProjData_infos_base = zeros(NumMaxComponents, NumTimeBin, 3, 2, NumRepeats, 2, 'single'); % the last two is A1 and A2
                        TypeProjData_infos_Af = zeros(NumMaxComponents, NumTimeBin2, 3, 2, NumRepeats, 2, 'single'); % the last two is A1 and A2
                        for cType = 1 : 4
                            cTypeValidDatas_A1 = AllValidDatasCell{1, cType};
                            cTypeValidDatas_A2 = AllValidDatasCell{2, cType};
                            cType_A1_loads = AllDataCorrLoads_A1{cType};
                            cType_A2_loads = AllDataCorrLoads_A2{cType};
                            
                            for cR = 1 : NumRepeats
                                cA1_proj_Valid = permute(pagemtimes(cType_A1_loads', cTypeValidDatas_A1),[2,1,3]); %
                                cA2_proj_Valid = permute(pagemtimes(cType_A2_loads', cTypeValidDatas_A2),[2,1,3]); %
                                
                                for cComp = 1 : NumMaxComponents
                                    cProjDatas_cA1 = cA1_proj_Valid(:, cComp,:);
                                    [RepeatAvgScores_Ch, ~] = TrEqualSampleinfo_3d(cProjDatas_cA1(2:end,:,:), ...
                                        ChoiceLabelInds(1:end-1), 0.6);
%                                     
                                    cProjDatas_cA2 = cA2_proj_Valid(:, cComp,:);
                                    [A2RepeatAvgScores_Ch, ~] = TrEqualSampleinfo_3d(cProjDatas_cA2(2:end,:,:), ...
                                        ChoiceLabelInds(1:end-1), 0.6);
%                                     RepeatAvgScores_Ch = rand(size(cProjDatas_cA1, 3),3);
%                                     A2RepeatAvgScores_Ch = rand(size(cProjDatas_cA2, 3),3);
                                    if cType < 3
                                        TypeProjData_infos_base(cComp,:,:,cType,cR,1) = RepeatAvgScores_Ch;
                                        TypeProjData_infos_base(cComp,:,:,cType,cR,2) = A2RepeatAvgScores_Ch;
                                    else
                                        TypeProjData_infos_Af(cComp,:,:,cType-2,cR,1) = RepeatAvgScores_Ch;
                                        TypeProjData_infos_Af(cComp,:,:,cType-2,cR,2) = A2RepeatAvgScores_Ch;
                                    end
                                end
                            end
                        end
                        A1_base_preChInfoData = mean(TypeProjData_infos_base(:,:,:,:,:,1), 5);
                        A2_base_preChInfoData = mean(TypeProjData_infos_base(:,:,:,:,:,2), 5);
                        
                        A1_Af_preChInfoData = mean(TypeProjData_infos_Af(:,:,:,:,:,1), 5);
                        A2_Af_preChInfoData = mean(TypeProjData_infos_Af(:,:,:,:,:,2), 5);
                        
                        A1_InfoDatasAll = {A1_base_preChInfoData(:,:,:,1),A1_base_preChInfoData(:,:,:,2),...
                            A1_Af_preChInfoData(:,:,:,1),A1_Af_preChInfoData(:,:,:,2)};
                        A2_InfoDatasAll = {A2_base_preChInfoData(:,:,:,1),A2_base_preChInfoData(:,:,:,2),...
                            A2_Af_preChInfoData(:,:,:,1),A2_Af_preChInfoData(:,:,:,2)};
                        
                        AllPair_preChInfos(ks,:) = {A1_InfoDatasAll, A2_InfoDatasAll, sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr)};
                        % BVarBaseInfos: BT_A1, BT_A2, choice_A1, choice_A2
%                         
%                         PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AFcorrData, TrVar_base2corrData, ...
%                             TrVar_AF2corrData,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
%                             [numel(cf1AreaInds),numel(cf2AreaInds)]};
%                         PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AFAvgs,TrVar_base2Avgs,TrVar_AF2Avgs};
% 
%                         TypeDataCalInfo_Choice_A1 = [BVarBaseInfos(3),TrVar_baseInfos(3),BVarAfInfos(3),TrVar_AfInfos(3)];
%                         TypeDataCalInfo_BT_A1 = [BVarBaseInfos(1),TrVar_baseInfos(1),BVarAfInfos(1),TrVar_AfInfos(1)];
%                         TypeDataCalInfo_Choice_A2 = [BVarBaseInfos(4),TrVar_baseInfos(4),BVarAfInfos(4),TrVar_AfInfos(4)];
%                         TypeDataCalInfo_BT_A2 = [BVarBaseInfos(2),TrVar_baseInfos(2),BVarAfInfos(2),TrVar_AfInfos(2)];
%                         AllPairInfos(ks,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
%                             TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr)};
%     %                     TypeDataClaInfos = {mean(RepeatInfos_BT_A1,4),mean(RepeatInfos_BT_A2, 4),mean(RepeatInfos_choice_A1,4),...
%     %                         mean(RepeatInfos_choice_A2, 4)};
                        ks = ks + 1;
                    end
                end
                cInfoDatas(k) = {AllPair_preChInfos};
                
                SessFoldInds{k,2} = cat(1, AreaInds{:});
                k = k + 1;
            end
        end
    %     AllSessCalDatas(cSess,:) = {cSfoldersData, cSf_AreaNum, SessFoldInds};
        AllSessInfoDatas = cat(1,cInfoDatas{:,1});
%         AllSessFolderDatas{2} = cat(1,cSessFolderDatas{:,2});
%         AllSessFolderDatas{3} = cat(1,cSessFolderDatas{:,3});
        
        savefileName = fullfile(SessPairedDataSavePath,sprintf('AP_CCAProjData_PreChInfo_Sub%d.mat',cSess));
        save(savefileName,'AllSessInfoDatas','SessFoldInds','-v7.3');
        clearvars AllSessInfoDatas cInfoDatas SessFoldInds
        
        fprintf('Sess %d is processed.\n', cSess);
    catch ME
        
        clearvars AllSessInfoDatas cInfoDatas SessFoldInds
        fprintf('Sess %d have something wrong.\n', cSess);
    end
    toc
end

%%
savefileName = fullfile(SessPairedDataSavePath,'AcrossProbe_CCAProjData.mat');
save(savefileName,'AllSessFolderDatas','AllSessCalDatas','-v7.3');



