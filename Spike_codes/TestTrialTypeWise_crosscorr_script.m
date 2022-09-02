
clearvars CalResults OutDataStrc ExistField_ClusIDs
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);

%%
BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
AllTrFreqs = double(behavResults.Stim_toneFreq(:));
RevFreqInds = ismember(AllTrFreqs,RevFreqs);
NonRevFreqInds = ~RevFreqInds;

BehavActionChoice = double(behavResults.Action_choice(:));
RevFreqInds(BehavActionChoice==2) = false;
NonRevFreqInds(BehavActionChoice==2) = false;

TrialIsCorrect = double(behavResults.Action_choice(:)) == double(behavResults.Trial_Type(:));
TrialIsError = TrialIsCorrect & double(behavResults.Action_choice(:)) ~= 2;
%%
% try
%     NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
% catch ME % some added sessions do not have file named "SessAreaIndexDataNew.mat"
    NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
% end
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


%%

RevTrDatas = NewBinnedDatas(RevFreqInds,:,:);
RevTrDatasIsCorrect = TrialIsCorrect(RevFreqInds); % corresponded correct trial index

NonRevTrDatas = NewBinnedDatas(NonRevFreqInds,:,:);
NonRevTrDatasIsCorrect = TrialIsCorrect(NonRevFreqInds); % corresponded correct trial index

fprintf('RevTrial Correct rate is %.2f, NonRevTrial Correct rate is %.2f.\n',mean(RevTrDatasIsCorrect),mean(NonRevTrDatasIsCorrect));
%%

NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
CalResults = cell(NumCalculations,11);

k = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        % correct trials
        Area1_datas = RevTrDatas(RevTrDatasIsCorrect,ExistField_ClusIDs{cAr,2},:);
        Area2_datas = RevTrDatas(RevTrDatasIsCorrect,ExistField_ClusIDs{cAr2,2},:);
        [jPECC_val, jPECC_p] = jPECC(Area1_datas,Area2_datas,...
                5,[],5);
        % error trials
        Area1_datas2 = RevTrDatas(~RevTrDatasIsCorrect,ExistField_ClusIDs{cAr,2},:);
        Area2_datas2 = RevTrDatas(~RevTrDatasIsCorrect,ExistField_ClusIDs{cAr2,2},:);
        [jPECC_val2, jPECC_p2] = jPECC(Area1_datas2,Area2_datas2,...
                5,[],5);
        
        % NonRevTr Correct trials
        Area1_datas3 = NonRevTrDatas(NonRevTrDatasIsCorrect,ExistField_ClusIDs{cAr,2},:);
        Area2_datas3 = NonRevTrDatas(NonRevTrDatasIsCorrect,ExistField_ClusIDs{cAr2,2},:);
        [jPECC_val3, jPECC_p3] = jPECC(Area1_datas3,Area2_datas3,...
                5,[],5);
        
        % NonRevTr Error trials
        if sum(~NonRevTrDatasIsCorrect) > 15
            Area1_datas4 = NonRevTrDatas(~NonRevTrDatasIsCorrect,ExistField_ClusIDs{cAr,2},:);
            Area2_datas4 = NonRevTrDatas(~NonRevTrDatasIsCorrect,ExistField_ClusIDs{cAr2,2},:);
            [jPECC_val4, jPECC_p4] = jPECC(Area1_datas4+1e-6,Area2_datas4+1e-6,...
                    5,[],5);
        else
            jPECC_val4 = [];
            jPECC_p4 = [];
        end
            
        CalResults(k,:) = {jPECC_val, jPECC_p, jPECC_val2, jPECC_p2, ...
            jPECC_val3, jPECC_p3, jPECC_val4, jPECC_p4, ...
            NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2},...
            [numel(ExistField_ClusIDs{cAr,1}),numel(ExistField_ClusIDs{cAr2,1})]};
        k = k + 1;
    end
end

%%
Savepath = fullfile(ksfolder,'jeccAnA');
if ~isfolder(Savepath)
    mkdir(Savepath);
end
dataSavePath = fullfile(Savepath,'JeccDataTrialWise.mat');

save(dataSavePath,'CalResults','OutDataStrc',...
    'ExistField_ClusIDs','NewAdd_ExistAreaNames','-v7.3')

%%
% Times = ((1:size(RevTrDatas,3))-OutDataStrc.TriggerStartBin+0.5)*0.1;
% 
% PlotInds = 4;
% 
% figure('position',[100 100 1240 680]);
% subplot(231)
% imagesc(Times,Times,CalResults{PlotInds,1},[0 0.6])
% title(sprintf('%s -> %s, Correct',CalResults{PlotInds,9},CalResults{PlotInds,10}));
% 
% subplot(232)
% imagesc(Times,Times,CalResults{PlotInds,3},[0 0.6])
% title(sprintf('%s -> %s, Error',CalResults{PlotInds,9},CalResults{PlotInds,10}));
% 
% subplot(233)
% imagesc(Times,Times,CalResults{PlotInds,1} - CalResults{PlotInds,3},[-0.3 0.3])
% title('Correct-Error');
% 
% subplot(234)
% imagesc(Times,Times,CalResults{PlotInds,5},[0 0.6])
% title(sprintf('%s -> %s, NonRev Correct',CalResults{PlotInds,9},CalResults{PlotInds,10}));
% 
% subplot(235)
% imagesc(Times,Times,CalResults{PlotInds,7},[0 0.6])
% title(sprintf('%s -> %s, NonRev Error',CalResults{PlotInds,9},CalResults{PlotInds,10}));
% try
%     subplot(236)
%     imagesc(Times,Times,CalResults{PlotInds,5} - CalResults{PlotInds,7},[-0.3 0.3])
%     title('NonRev Correct-Error');
% end



