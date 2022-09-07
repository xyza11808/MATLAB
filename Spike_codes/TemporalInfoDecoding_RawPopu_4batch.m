
clearvars SessAreaIndexStrc ProbNPSess AreainfosAll

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 4],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

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
%
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
% if isfolder(fullsavePath)
%     rmdir(fullsavePath,'s');
% end
% 
% mkdir(fullsavePath);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);

AreainfosAll = cell(Numfieldnames,2,2);
AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
for cType = 1 : 2
    TrTypesAll = AllTrInds{cType}; % Action_choice / BlockType
    TrTypes = TrTypesAll(NMTrInds);
    nTrs = length(TrTypes);
    for cArea = 1 : Numfieldnames
        
        cUsedAreas = NewAdd_ExistAreaNames{cArea};
        cAUnitInds = NewSessAreaStrc.SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
        
        cAUnits = ExistField_ClusIDs{cArea,2};
        MaxROINum = length(cAUnits);
        MaxPlsDim = min(30,MaxROINum);
        Repeat = 100;
        
        FrameBin_infos = zeros(Repeat,2,NumFrameBins);
        FrameBin_Accuracy = zeros(Repeat,2,NumFrameBins);
        for cframe = 1 : NumFrameBins
%             RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,OutDataStrc.TriggerStartBin+(1:15));
%             RespDataUsedMtx = mean(RespDataUsedMtx,3);
            RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,cframe);
            

            % [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar] = plsregress(...
            % 	X,y,10);
            
            NumCol_infos = zeros(Repeat,2);
            SVMLossAll = zeros(Repeat,2);
            TrainBaseAll = false(nTrs,1);
            for cR = 1 : Repeat
                %     TrainInds = randsample(nTrs,round(nTrs/2));
                cc = cvpartition(nTrs,'kFold',2);

                FI_training_Inds = TrainBaseAll;
                FI_training_Inds(cc.test(1)) = true;

                Final_test_Inds = TrainBaseAll;
                Final_test_Inds(cc.test(2)) = true;

                [DisScore,MdPerfs,~,~] = LDAclassifierFun(RespDataUsedMtx, TrTypes, {FI_training_Inds,Final_test_Inds});
                NumCol_infos(cR,:) = DisScore;
                SVMLossAll(cR,:) = MdPerfs;
            end
            FrameBin_infos(:,:,cframe) = NumCol_infos;
            FrameBin_Accuracy(:,:,cframe) = SVMLossAll;
        end
        AreainfosAll(cArea,cType,:) = {FrameBin_infos, FrameBin_Accuracy};
    end
end
%%
save(fullfile(fullsavePath,'LDAinfo_rawPopuData.mat'), 'AreainfosAll', 'AllTrInds', ...
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