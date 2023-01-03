% batched through all used sessions
cclr

% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
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

NumSess = length(UniqueSessTypes);

%%
% SessPairedDataSavePath = 'I:\ksOutput_backup\PairedSessionDatas';
SessPairedDataSavePath = 'K:\NPdatas\acrossProbeData\RawDataInfo';
% SessPairedDataSavePath = 'D:\data\NPRawData\PairedSessionDatas\rawDataCCAInfo';

% AllSessFolderDatas = cell(NumSess, 2);
% AllSessCalDatas = cell(NumSess, 3);
for cSess = NumSess: -1 : 1 
    try
        tic
        cSessIndex = UniqueSessTypes(cSess);
        cSessfolders = SessionFolders(SessIndexUsed == cSessIndex);
        SessNumfolders = length(cSessfolders);
        
        cSfoldersData = cell(SessNumfolders,4);
        cSf_AreaNum = zeros(SessNumfolders, 1);
        % load behavior info
        cSfolder = fullfile(strrep(cSessfolders{1},'F:','I:\ksOutput_backup'),sortingcode_string);
        load(fullfile(cSfolder,'NewClassHandle2.mat'),'behavResults');
        behavDataPath = fullfile(cSfolder,'BehavBlockBoundshift.mat');
        behavData_BoundShift = load(behavDataPath,'OverAllBoundShift');
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

        for cSf = 1 : SessNumfolders
    %         cSfolder = cSessfolders{cSf};
            cSfolder = fullfile(strrep(cSessfolders{cSf},'F:','I:\ksOutput_backup'),sortingcode_string);
            cSf_datafile = fullfile(cSfolder,'jeccAnA','CCA_TypeSubCal.mat');
            cSf_dataStrc = load(cSf_datafile);
            NewBinnedDatas = permute(cat(3,cSf_dataStrc.OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
            OnsetBin = cSf_dataStrc.OutDataStrc.TriggerStartBin;
            RawResponseData = NewBinnedDatas(NMTrInds,:,:);
            [nmTrNum, UnitNums, FrameNum] = size(RawResponseData);

            RawResponseData_zs = zeros(size(RawResponseData));
            % BaselineSubData_zs = zeros(size(BaselineSubData));
            for cU = 1 : UnitNums
                cU_Raw = RawResponseData(:,cU,:);
                RawResponseData_zs(:,cU,:) = (cU_Raw - mean(cU_Raw,'all'))/std(cU_Raw(:));

            %     cU_Sub = BaselineSubData(:,cU,:);
            %     BaselineSubData_zs(:,cU,:) = (cU_Sub - mean(cU_Sub,'all'))/std(cU_Sub(:));
            end
            FrameBinTime = cSf_dataStrc.OutDataStrc.USedbin(2);
            BaselineWin = 1:OnsetBin-1;
            AfterRespWin = round((0:0.1:1.9)/FrameBinTime)+OnsetBin;
            ValidWin = 1:(OnsetBin+2/FrameBinTime);
            AllTimeCents = cSf_dataStrc.OutDataStrc.BinCenters;
            cSfoldersData(cSf,:) = {single(RawResponseData_zs),{BaselineWin,AfterRespWin,ValidWin,AllTimeCents},...
                cSf_dataStrc.ExistField_ClusIDs,cSf_dataStrc.NewAdd_ExistAreaNames};
            cSf_AreaNum(cSf) = length(cSfoldersData{cSf,4});
        end

        UsedTimeWin = cSfoldersData{1,2};

        %
        % loop through each session folders to calculate all area pairs
        AllLoopNum = SessNumfolders*(SessNumfolders-1)/2;
        cSessFolderCals = cell(AllLoopNum, 3);
        SessFoldInds = cell(AllLoopNum, 2);
        k = 1;
        for cf1 = 1 : SessNumfolders
            for cf2 = cf1+1 : SessNumfolders
                cf1data = cSfoldersData(cf1,:);
                cf2data = cSfoldersData(cf2,:);

                SessFoldInds{k, 1} = [cf1,cf2];

                AreaInds = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),1);
                %%%
                PairedAreaCorrs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),4);
                PairedAreaAvgs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),2);
                AllPairInfos = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),7);
                ks = 1;
                for cf1Area = 1 : cSf_AreaNum(cf1)
                    for cf2Area = 1 : cSf_AreaNum(cf2)
                        if isempty(cf1data{3}) || isempty(cf2data{3})
                            continue;
                        end
                        AreaInds{ks} = [cf1Area, cf2Area];
                        cf1AreaInds = cf1data{3}{cf1Area,2};
                        cf2AreaInds = cf2data{3}{cf2Area,2};
    %                     
                        cf1AreaNameStr = cf1data{4}{cf1Area};
                        cf2AreaNameStr = cf2data{4}{cf2Area};
    %                   
                        cf1ValidData = cf1data{1}(2:end,cf1AreaInds,UsedTimeWin{3});
                        cf2ValidData = cf2data{1}(2:end,cf2AreaInds,UsedTimeWin{3});

                        % raw data baseline kernal
                        cf1AreaBaseData = cf1data{1}(2:end,cf1AreaInds,UsedTimeWin{1});
                        cf2AreaBaseData = cf2data{1}(2:end,cf2AreaInds,UsedTimeWin{1});

                        [BVar_basecorrData, BVar_baseAvgs, BVarBaseInfos] = crossValCCA_SepData_proj_xnInfo(cf1AreaBaseData,cf1ValidData,...
                            cf2AreaBaseData,cf2ValidData,0.5, {BlockLabelInds(2:end), ChoiceLabelInds(2:end),ChoiceLabelInds(1:end-1)});

                        % raw data after response kernal
                        cf1AreaAfData = cf1data{1}(2:end,cf1AreaInds,UsedTimeWin{2});
                        cf2AreaAfData = cf2data{1}(2:end,cf2AreaInds,UsedTimeWin{2});

                        [BVar_AfcorrData, BVar_AfAvgs, BVarAfInfos] = crossValCCA_SepData_proj_xnInfo(cf1AreaAfData,cf1ValidData,...
                            cf2AreaAfData,cf2ValidData,0.5, {BlockLabelInds(2:end), ChoiceLabelInds(2:end),ChoiceLabelInds(1:end-1)});

                        PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AfcorrData, sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
                            [numel(cf1AreaInds),numel(cf2AreaInds)]};
                        PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AfAvgs};

                        TypeDataCalInfo_Choice_A1 = [BVarBaseInfos(3),BVarAfInfos(3)];
                        TypeDataCalInfo_BT_A1 = [BVarBaseInfos(1),BVarAfInfos(1)];
                        TypeDataCalInfo_Choice_A2 = [BVarBaseInfos(4),BVarAfInfos(4)];
                        TypeDataCalInfo_BT_A2 = [BVarBaseInfos(2),BVarAfInfos(2)];
                        TypeDataCalInfo_preCh_A1 = [BVarBaseInfos(5),BVarAfInfos(5)];
                        TypeDataCalInfo_preCh_A2 = [BVarBaseInfos(6),BVarAfInfos(6)];

                        AllPairInfos(ks,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
                            TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2,...
                            TypeDataCalInfo_preCh_A1,TypeDataCalInfo_preCh_A2,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr)};

    %                     % Block var afterResp kernal
    %                     cf1AreaAFData = cf1data{1}{3}(:,cf1AreaInds,:);
    %                     cf1AreaAFValidData = cf1data{1}{4}(:,cf1AreaInds,:);
    %                     
    %                     cf2AreaAFData = cf2data{1}{3}(:,cf2AreaInds,:);
    %                     cf2AreaAFValidData = cf2data{1}{4}(:,cf2AreaInds,:);
    %                     
    %                     [BVar_AFcorrData, BVar_AFAvgs] = crossValCCA_SepData(cf1AreaAFData,cf1AreaAFValidData,...
    %                         cf2AreaAFData,cf2AreaAFValidData,0.5);
    %                     
    %                     % Trial var baseline kernal
    %                     cf1AreaBase2Data = cf1data{2}{1}(:,cf1AreaInds,:);
    %                     cf1AreaBase2ValidData = cf1data{2}{2}(:,cf1AreaInds,:);
    %                     
    %                     cf2AreaBase2Data = cf2data{2}{1}(:,cf2AreaInds,:);
    %                     cf2AreaBase2ValidData = cf2data{2}{2}(:,cf2AreaInds,:);
    %                     
    %                     [TrVar_base2corrData, TrVar_base2Avgs] = crossValCCA_SepData(cf1AreaBase2Data,cf1AreaBase2ValidData,...
    %                         cf2AreaBase2Data,cf2AreaBase2ValidData,0.5);
    %                     
    %                     % Trial var afterResp kernal
    %                     cf1AreaAF2Data = cf1data{2}{3}(:,cf1AreaInds,:);
    %                     cf1AreaAF2ValidData = cf1data{2}{4}(:,cf1AreaInds,:);
    %                     
    %                     cf2AreaAF2Data = cf2data{2}{3}(:,cf2AreaInds,:);
    %                     cf2AreaAF2ValidData = cf2data{2}{4}(:,cf2AreaInds,:);
    %                     
    %                     [TrVar_AF2corrData, TrVar_AF2Avgs] = crossValCCA_SepData(cf1AreaAF2Data,cf1AreaAF2ValidData,...
    %                         cf2AreaAF2Data,cf2AreaAF2ValidData,0.5);
    %                     
    %                     PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AFcorrData, TrVar_base2corrData, ...
    %                         TrVar_AF2corrData,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
    %                         [numel(cf1AreaInds),numel(cf2AreaInds)]};
    %                     PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AFAvgs,TrVar_base2Avgs,TrVar_AF2Avgs};
                        ks = ks + 1;
                    end
                end
                cSessFolderCals(k,:) = {PairedAreaCorrs, PairedAreaAvgs, AllPairInfos};
                SessFoldInds{k,2} = AreaInds;
                k = k + 1;
            end
        end
        SessCaledInfo = {cSessFolderCals, SessFoldInds, UsedTimeWin};
        SessUsedDatas = {cSfoldersData, cSf_AreaNum}; 
        saveName = fullfile(SessPairedDataSavePath,sprintf('RawDataInfo_tempSave_sess_%d.mat',cSess));
        save(saveName, 'SessCaledInfo','SessUsedDatas', '-v7.3');
        clearvars cSessFolderCals SessCaledInfo SessUsedDatas cSfoldersData
        toc
    %     AllSessFolderDatas{cSess,1} = cat(1,cSessFolderDatas{:,1});
    %     AllSessFolderDatas{cSess,2} = cat(1,cSessFolderDatas{:,2});
        fprintf('Sess %d is processed.\n', cSess);
    catch ME
        p = gcp('nocreate'); % If no pool, do not create new one.
        if ~isempty(p)
            delete(p);
        end
        
        clearvars cSessFolderCals SessCaledInfo SessUsedDatas cSfoldersData
        
        parpool('local',10); 
        fprintf('Sess %d have something wrong.\n', cSess);
    end
    

end

%%
% savefileName = fullfile(SessPairedDataSavePath,'AcrossProbe_CCA_calResults.mat');
% save(savefileName,'AllSessFolderDatas','AllSessCalDatas','-v7.3');

%% get the behavior data for each session
SessPairedDataSavePath = 'E:\NPCCGs\PairedSessionDatas';
% SessPairedDataSavePath = 'K:\NPdatas\acrossProbeData\RawDataInfo';
% SessPairedDataSavePath = 'D:\data\NPRawData\PairedSessionDatas\rawDataCCAInfo';

% AllSessFolderDatas = cell(NumSess, 2);
% AllSessCalDatas = cell(NumSess, 3);
AllSessBehavBoundShifts = cell(NumSess, 1);
for cSess = NumSess: -1 : 1 

        cSessIndex = UniqueSessTypes(cSess);
        cSessfolders = SessionFolders(SessIndexUsed == cSessIndex);
        SessNumfolders = length(cSessfolders);
        
        
        % load behavior info
        cSfolder = fullfile(strrep(cSessfolders{1},'F:','E:\NPCCGs'),sortingcode_string);
        load(fullfile(cSfolder,'NewClassHandle2.mat'),'behavResults');
        behavDataPath = fullfile(cSfolder,'BehavBlockBoundshift.mat');
        behavData_BoundShift = load(behavDataPath,'OverAllBoundShift');
        cSf_AreaNum = zeros(SessNumfolders, 1);
        for cSf = 1 : SessNumfolders
    %         cSfolder = cSessfolders{cSf};
            cSfolder = fullfile(strrep(cSessfolders{cSf},'F:','E:\NPCCGs'),sortingcode_string);
            cSf_datafile = fullfile(cSfolder,'jeccAnA','CCA_TypeSubCal.mat');
            cSf_dataStrc = load(cSf_datafile);
            cSf_AreaNum(cSf) = length(cSf_dataStrc.NewAdd_ExistAreaNames);
        end
        %
        % loop through each session folders to calculate all area pairs
        AllLoopNum = SessNumfolders*(SessNumfolders-1)/2;
        cSessFolderCals = cell(AllLoopNum, 1);
        k = 1;
        for cf1 = 1 : SessNumfolders
            for cf2 = cf1+1 : SessNumfolders
                AreaPairNum = cSf_AreaNum(cf1)*cSf_AreaNum(cf2);
                cSessFolderCals{k} = behavData_BoundShift.OverAllBoundShift*ones(AreaPairNum, 1);
                k = k + 1;
            end
        end
        SesspairedBoundShift = cat(1,cSessFolderCals{:});
        AllSessBehavBoundShifts(cSess) = {SesspairedBoundShift};
        fprintf('Sess %d is processed.\n', cSess);
end

%%
dataSavefile = fullfile(SessPairedDataSavePath,'AllSessBehavBoundShiftsData.mat');
save(dataSavefile,'AllSessBehavBoundShifts','-v7.3');



