
% clearvars SessAreaIndexStrc ProbNPSess AreainfosAll InfoCodingStrc ChoiceInfos BTInfos
clearvars  InfoCodingStrc AreainfosAll ChoiceInfos BTInfos 
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

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

CommonUnitNums = 15;
BaseData = mean(NewBinnedDatas(NMTrInds,:,1:(OutDataStrc.TriggerStartBin-1)),3);

ActTrs = ActionInds(NMTrInds);
NumofFrames = size(NewBinnedDatas,3);
AreainfosAll = cell(Numfieldnames,2,2);
AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
TypewiseCal = cell(2,3);
for cType = 1 : 2
    TrTypesAll = AllTrInds{cType}; % Action_choice / BlockType
    TrTypes = TrTypesAll(NMTrInds);
    nTrs = length(TrTypes);
    FramewiseScores = zeros(NumofFrames,Numfieldnames+1,2,2);
    FramewisePerfs = zeros(NumofFrames,Numfieldnames+1,2,2);
    Framewisebeta = cell(NumofFrames,Numfieldnames+1,2);
    %calculate frame by frame redundance
    for cframe = 1 : NumofFrames
        cfSMInds = [max(1,cframe-1), min(NumofFrames,cframe+1)];
        cfRawRespData = mean(NewBinnedDatas(NMTrInds,:,cfSMInds(1):cfSMInds(2)),3);
        cfBaseSubData = cfRawRespData - BaseData;
        
        % The last area index indicating all units is considered
        AreaDisScores = zeros(Numfieldnames+1,2,2); % two data types and training-vs-tesing datas
        ArealinearPerf = zeros(Numfieldnames+1,2,2); % two data types and training-vs-tesing datas
        AreaBoundBeta = cell(Numfieldnames+1,2);
        for cArea = 1 : Numfieldnames

            cUsedAreas = NewAdd_ExistAreaNames{cArea};
            cAUnits = ExistField_ClusIDs{cArea,2};
            cAROINum = length(cAUnits);
            
            cc = cvpartition(nTrs,'kFold',2);
            TrainBaseAll = false(nTrs,1);
            FI_training_Inds = TrainBaseAll;
            FI_training_Inds(cc.test(1)) = true;

            Final_test_Inds = TrainBaseAll;
            Final_test_Inds(cc.test(2)) = true;

            [RawDisScore,RawMdPerfs,~,Rawbeta] = LDAclassifierFun(cfRawRespData(:,cAUnits), ...
                TrTypes, {FI_training_Inds,Final_test_Inds});
            
            [BSDisScore,BSMdPerfs,~,BSbeta] = LDAclassifierFun(cfBaseSubData(:,cAUnits), ...
                TrTypes, {FI_training_Inds,Final_test_Inds});
            AreaDisScores(cArea,:,:) = [RawDisScore;BSDisScore];
            ArealinearPerf(cArea,:,:) = [RawMdPerfs;BSMdPerfs];
            AreaBoundBeta(cArea,:) = {Rawbeta,BSbeta};
        end
        
        [RawDisScoreAU,RawMdPerfsAU,~,RawbetaAU] = LDAclassifierFun(cfRawRespData(:,:), ...
            TrTypes, {FI_training_Inds,Final_test_Inds});

        [BSDisScoreAU,BSMdPerfsAU,~,BSbetaAU] = LDAclassifierFun(cfBaseSubData(:,:), ...
            TrTypes, {FI_training_Inds,Final_test_Inds});
        AreaDisScores(end,:,:) = [RawDisScoreAU;BSDisScoreAU];
        ArealinearPerf(end,:,:) = [RawMdPerfsAU;BSMdPerfsAU];
        AreaBoundBeta(end,:) = {RawbetaAU,BSbetaAU};
        
        FramewiseScores(cframe,:,:,:) = AreaDisScores;
        FramewisePerfs(cframe,:,:,:) = ArealinearPerf;
        Framewisebeta(cframe,:,:) = AreaBoundBeta;
    end
    
    TypewiseCal(cType,:) = {FramewiseScores,FramewisePerfs,Framewisebeta};
end

% RawRespTestScore = TypewiseCal{1}(:,:,1,2);
% 
% figure;plot(RawRespTestScore(:,1:4))
% hold on;plot(RawRespTestScore(:,5),'k')
% Index = RawRespTestScore(:,5)./sum(RawRespTestScore(:,1:4),2);
% figure;plot(Index)
%%
save(fullfile(fullsavePath,'LDAinfo_redunt.mat'), 'TypewiseCal', 'AllTrInds', ...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', 'OutDataStrc','-v7.3');

