
clearvars SessAreaIndexStrc AreainfosAll

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
if ~exist('ProbNPSess','var')
    load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
end
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);


%% find target cluster inds and IDs
% ksfolder = pwd;

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDs = cell(Numfieldnames,4);
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end

USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end

BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'ChoiceANDBT_LDAinfo_ana';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath,'s');
end

% mkdir(sfullsavePath);

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);

AreainfosAll = cell(Numfieldnames,2,3);
AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
for cType = 1 : 2
    TrTypesAll = AllTrInds{cType}; % Action_choice / BlockType
    TrTypes = TrTypesAll(NMTrInds);
    
    nTrs = length(TrTypes);
    for cArea = 1 : Numfieldnames
        
        cUsedAreas = NewAdd_ExistAreaNames{cArea};
        cAUnitInds = NewSessAreaStrc.SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
        
        % % % RespDataMtx = mean(data_aligned(:,:,59:90),3)/100;
        % % % RespDataUsedMtx = RespDataMtx(ActionInds ~= 2,:);
        % RespDataUsedMtx = NewBinnedDatas(NMTrInds,ExistField_ClusIDs{3,2},OutDataStrc.TriggerStartBin+(1:20));
        cAUnits = ExistField_ClusIDs{cArea,2};
        RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,OutDataStrc.TriggerStartBin+(1:15));
        RespDataUsedMtx = mean(RespDataUsedMtx,3);
        MaxROINum = size(RespDataUsedMtx,2);
        
        % [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar] = plsregress(...
        % 	X,y,10);
        MaxPlsDim = min(30,MaxROINum);
        Repeat = 50;
        NumCol_infos = zeros(Repeat,MaxPlsDim,2);
        SVMLossAll = zeros(Repeat,MaxPlsDim,2);
        TrainBaseAll = false(nTrs,1);
        for cR = 1 : Repeat
            %     TrainInds = randsample(nTrs,round(nTrs/2));
            cc = cvpartition(nTrs,'kFold',3);
            
            pls_training_Inds = TrainBaseAll;
            pls_training_Inds(cc.test(1)) = true;
            
            FI_training_Inds = TrainBaseAll;
            FI_training_Inds(cc.test(2)) = true;
            
            Final_test_Inds = TrainBaseAll;
            Final_test_Inds(cc.test(3)) = true;
            
            %     [T,P,U,Q,B,W] = pls(RespDataUsedMtx(pls_training_Inds,:),ActTrs(pls_training_Inds));
            %     % T     score matrix of X
            %     % P     loading matrix of X
            %     % U     score matrix of Y
            %     % Q     loading matrix of Y
            %     % B     matrix of regression coefficient
            %     % W     weight matrix of X
            %     %
            [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar,MSE,stats] = plsregress(...
                RespDataUsedMtx(pls_training_Inds,:),TrTypes(pls_training_Inds),MaxPlsDim);
            
            FI_training_Data = RespDataUsedMtx(FI_training_Inds,:);
            FI_training_x0 = bsxfun(@minus, FI_training_Data, mean(FI_training_Data,1));
            Final_test_Data = RespDataUsedMtx(Final_test_Inds,:);
            Final_test_x0 = bsxfun(@minus, Final_test_Data, mean(Final_test_Data,1));
            
            FI_training_xScore = FI_training_x0 * stats.W;
            FI_training_TrTypes = TrTypes(FI_training_Inds);
            Final_test_xScore = Final_test_x0 * stats.W;
            Final_test_TrTypes = TrTypes(Final_test_Inds);
            
            for cCol = 1 : MaxPlsDim
                
                %         [ddRaw,~,~,TrainWeight] = PopuFICal_fun(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
                %         FI_trainmd = fitcsvm(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
                %         FI_trainloss = 1 - kfoldLoss(crossval(FI_trainmd));
                %
                %         [ddTest,~,~,~] =  PopuFICal_fun(Final_test_xScore(:,1:cCol),Final_test_TrTypes,TrainWeight);
                %         TestDataPredTypes = predict(FI_trainmd, Final_test_xScore(:,1:cCol));
                %         Final_testloss = mean(TestDataPredTypes == Final_test_TrTypes(:));
                %         NumCol_infos(cR,cCol,:) = [ddRaw,ddTest];
                %         SVMLossAll(cR,cCol,:) = [FI_trainloss,Final_testloss];
                
                MergeTypesLabels = [FI_training_TrTypes;Final_test_TrTypes];
                Merge_xScores = [FI_training_xScore(:,1:cCol);Final_test_xScore(:,1:cCol)];
                MergeAllSampleNums = numel(MergeTypesLabels);
                TrainInds = false(MergeAllSampleNums,1);
                TrainInds(1:numel(FI_training_TrTypes)) = true;
                TestInds = ~TrainInds;
                [DisScore,MdPerfs,~,~] = LDAclassifierFun(Merge_xScores, MergeTypesLabels, {TrainInds,TestInds});
                NumCol_infos(cR,cCol,:) = DisScore;
                SVMLossAll(cR,cCol,:) = MdPerfs;
                
                
            end
        end
        SVMLoss_avg = squeeze(mean(SVMLossAll,1));
        FIDiffDatas = diff(SVMLoss_avg(:,2));
        UsedPCnums = find(FIDiffDatas < 0.5,1,'first');
        
        AreainfosAll(cArea,cType,:) = {NumCol_infos, SVMLossAll,UsedPCnums};
        
    end
end
%%
save(fullfile(fullsavePath,'LDAinfo_PLSbasedData.mat'), 'AreainfosAll', 'AllTrInds', ...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', '-v7.3');


% ################################################################################################
% cclr
% AnmSess_sourcepath = 'F:\b107a08_ksoutput';
%
% xpath = genpath(AnmSess_sourcepath);
% nameSplit = (strsplit(xpath,';'))';
%
% if isempty(nameSplit{end})
%     nameSplit(end) = [];
% end
% % DirLength = length(nameSplit);
% % PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
% % PossDataPath = nameSplit(PossibleInds);
% sortingcode_string = 'ks2_5';
% % Find processed folders
% ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,sortingcode_string,'NPClassHandleSaved.mat'),'file') && ...
%    exist(fullfile(x,sortingcode_string,'SessAreaIndexData.mat'),'file') ,nameSplit);
% NPsessionfolders = nameSplit((ProcessedFoldInds>0));
% NumprocessedNPSess = length(NPsessionfolders);
% if NumprocessedNPSess < 1
%     warning('No valid NP session was found in current path.');
% end
%
% %%
%
% for cfff = 1 : NumprocessedNPSess
%     ksfolder = fullfile(NPsessionfolders{cfff},sortingcode_string);
%     baselineSpikePredBlocktypes_4batch;
% end

% ############################################################################

% % batched through all used sessions
% cclr
%
% % AllSessFolderPathfile = 'K\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% sortingcode_string = 'ks2_5';
%
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumprocessedNPSess = length(SessionFolders);
%
%
% %%
% for cfff = 1 : NumprocessedNPSess
%
%     ksfolder = fullfile(SessionFolders{cfff},sortingcode_string);
%     cSessFolder = ksfolder;
% %     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','I:\ksOutput_backup'),sortingcode_string);
%     fprintf('Processing session %d...\n', cfff);
% % % %     OldFolderName = fullfile(cSessFolder,'BaselinePredofBlocktype');
% % % %     if isfolder(OldFolderName)
% % % % %         stats = rmdir(OldFolderName,'s');
% % % %
% % % %         stats = movefile(OldFolderName,fullfile(cSessFolder,'Old_BaselinePredofBT'),'f');
% % % %         if ~stats
% % % %             error('Unable to delete folder in Session %d.',cfff);
% % % %         end
% % % %     end
%     OldFolderName = fullfile(cSessFolder,'UnitRespTypeCoef.mat');
%     if exist(OldFolderName,'file')
%         delete(OldFolderName);
%
% %         stats = movefile(OldFolderName,fullfile(cSessFolder,'Old_BaselinePredofBT'),'f');
% %         if ~stats
% %             error('Unable to delete folder in Session %d.',cfff);
% %         end
%     end
%
% %     baselineSpikePredBlocktypes_SVMProb;
% %     BlockType_Choice_decodingScript;
% %     baselineSpikePredBlocktypes_4batch;
% %     BT_Choice_decodingScript_trialtypeWise;
%     EventResp_avg_codes_tempErrorProcess;
% end