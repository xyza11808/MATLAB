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

AllSessFolderDatas = cell(NumSess, 3);
% AllSessCalDatas = cell(NumSess, 3);
for cSess = NumSess: -1 : 8
    tic
    try
        AllSessFolderDatas = cell(1,3);
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
        cSessFolderDatas = cell(AllLoopNum, 3);
        SessFoldInds = cell(AllLoopNum, 2);
        
        k = 1;
        for cf1 = 1 : SessNumfolders
            for cf2 = cf1+1 : SessNumfolders
                cf1data = cSfoldersData(cf1,:);
                cf2data = cSfoldersData(cf2,:);
                SessFoldInds{k, 1} = [cf1,cf2];

                AreaInds = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),1);
                %%%
                PairedAreaCorrs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),6);
                PairedAreaAvgs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),4);
                AllPairInfos = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),5);
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

                        % Block var baseline kernal
                        cf1AreaBaseData = cf1data{1}{1}(NMTrInds,cf1AreaInds,:);
                        cf1AreaBaseValidData = cf1data{1}{2}(NMTrInds,cf1AreaInds,:);

                        cf2AreaBaseData = cf2data{1}{1}(NMTrInds,cf2AreaInds,:);
                        cf2AreaBaseValidData = cf2data{1}{2}(NMTrInds,cf2AreaInds,:);

                        % BVarBaseInfos: BT_A1, BT_A2, choice_A1, choice_A2
                        [BVar_basecorrData, BVar_baseAvgs, BVarBaseInfos] = crossValCCA_SepData_projInfo(cf1AreaBaseData,cf1AreaBaseValidData,...
                            cf2AreaBaseData,cf2AreaBaseValidData,0.5, {BlockLabelInds, ChoiceLabelInds}); % crossValCCA_SepData_projInfo crossValCCA_SepData

                        % Block var afterResp kernal
                        cf1AreaAFData = cf1data{1}{3}(NMTrInds,cf1AreaInds,:);
                        cf1AreaAFValidData = cf1data{1}{4}(NMTrInds,cf1AreaInds,:);

                        cf2AreaAFData = cf2data{1}{3}(NMTrInds,cf2AreaInds,:);
                        cf2AreaAFValidData = cf2data{1}{4}(NMTrInds,cf2AreaInds,:);

                        [BVar_AFcorrData, BVar_AFAvgs, BVarAfInfos] = crossValCCA_SepData_projInfo(cf1AreaAFData,cf1AreaAFValidData,...
                            cf2AreaAFData,cf2AreaAFValidData,0.5, {BlockLabelInds, ChoiceLabelInds});

                        % Trial var baseline kernal
                        cf1AreaBase2Data = cf1data{2}{1}(NMTrInds,cf1AreaInds,:);
                        cf1AreaBase2ValidData = cf1data{2}{2}(NMTrInds,cf1AreaInds,:);

                        cf2AreaBase2Data = cf2data{2}{1}(NMTrInds,cf2AreaInds,:);
                        cf2AreaBase2ValidData = cf2data{2}{2}(NMTrInds,cf2AreaInds,:);

                        [TrVar_base2corrData, TrVar_base2Avgs, TrVar_baseInfos] = crossValCCA_SepData_projInfo(cf1AreaBase2Data,cf1AreaBase2ValidData,...
                            cf2AreaBase2Data,cf2AreaBase2ValidData,0.5, {BlockLabelInds, ChoiceLabelInds});

                        % Trial var afterResp kernal
                        cf1AreaAF2Data = cf1data{2}{3}(NMTrInds,cf1AreaInds,:);
                        cf1AreaAF2ValidData = cf1data{2}{4}(NMTrInds,cf1AreaInds,:);

                        cf2AreaAF2Data = cf2data{2}{3}(NMTrInds,cf2AreaInds,:);
                        cf2AreaAF2ValidData = cf2data{2}{4}(NMTrInds,cf2AreaInds,:);

                        [TrVar_AF2corrData, TrVar_AF2Avgs, TrVar_AfInfos] = crossValCCA_SepData_projInfo(cf1AreaAF2Data,cf1AreaAF2ValidData,...
                            cf2AreaAF2Data,cf2AreaAF2ValidData,0.5, {BlockLabelInds, ChoiceLabelInds});

                        PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AFcorrData, TrVar_base2corrData, ...
                            TrVar_AF2corrData,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
                            [numel(cf1AreaInds),numel(cf2AreaInds)]};
                        PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AFAvgs,TrVar_base2Avgs,TrVar_AF2Avgs};

                        TypeDataCalInfo_Choice_A1 = [BVarBaseInfos(3),TrVar_baseInfos(3),BVarAfInfos(3),TrVar_AfInfos(3)];
                        TypeDataCalInfo_BT_A1 = [BVarBaseInfos(1),TrVar_baseInfos(1),BVarAfInfos(1),TrVar_AfInfos(1)];
                        TypeDataCalInfo_Choice_A2 = [BVarBaseInfos(4),TrVar_baseInfos(4),BVarAfInfos(4),TrVar_AfInfos(4)];
                        TypeDataCalInfo_BT_A2 = [BVarBaseInfos(2),TrVar_baseInfos(2),BVarAfInfos(2),TrVar_AfInfos(2)];
                        AllPairInfos(ks,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
                            TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr)};
    %                     TypeDataClaInfos = {mean(RepeatInfos_BT_A1,4),mean(RepeatInfos_BT_A2, 4),mean(RepeatInfos_choice_A1,4),...
    %                         mean(RepeatInfos_choice_A2, 4)};
                        ks = ks + 1;
                    end
                end
                cSessFolderDatas(k,:) = {PairedAreaCorrs, PairedAreaAvgs, AllPairInfos};
                SessFoldInds{k,2} = cat(1, AreaInds{:});
                k = k + 1;
            end
        end
    %     AllSessCalDatas(cSess,:) = {cSfoldersData, cSf_AreaNum, SessFoldInds};
        AllSessFolderDatas{1} = cat(1,cSessFolderDatas{:,1});
        AllSessFolderDatas{2} = cat(1,cSessFolderDatas{:,2});
        AllSessFolderDatas{3} = cat(1,cSessFolderDatas{:,3});
        
        savefileName = fullfile(SessPairedDataSavePath,sprintf('AcrossProbe_CCAProjData_Sub%d.mat',cSess));
        save(savefileName,'AllSessFolderDatas','-v7.3');
        clearvars AllSessFolderDatas PairedAreaCorrs PairedAreaAvgs AllPairInfos
        
        fprintf('Sess %d is processed.\n', cSess);
    catch ME
        
        clearvars AllSessFolderDatas PairedAreaCorrs PairedAreaAvgs AllPairInfos
        fprintf('Sess %d have something wrong.\n', cSess);
    end
    toc
end

%%
savefileName = fullfile(SessPairedDataSavePath,'AcrossProbe_CCAProjData.mat');
save(savefileName,'AllSessFolderDatas','AllSessCalDatas','-v7.3');



