clearvars SessAreaIndexStrc ProbNPSess cAUnitInds BaselineResp_First BaselineResp_Last SMBinDataMtx

% load('Chnlocation.mat');

load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end

    load(fullfile(ksfolder,'NPClassHandleSaved.mat'))
% if isempty(ProbNPSess.ChannelAreaStrs)
%     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% end
%%
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
% SMBinDataMtxRaw = SMBinDataMtx(:,:,:);
%%
Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
NumExistAreas = length(ExistAreas_Names);
if NumExistAreas< 1
    return;
end
BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'BaselinePredofBlocktype';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
if isfolder(fullsavePath)
    rmdir(fullsavePath,'s');
end

mkdir(fullsavePath);

[TrNum, ~, ~] = size(SMBinDataMtx);
AfterStimWin = 1/ProbNPSess.USedbin{2};

for cArea = 1 : NumExistAreas
    
    cUsedAreas = ExistAreas_Names{cArea};
    cAUnitInds = SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
    SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);
    
    NumberOfUnits = length(cAUnitInds); % number of units will be used for population decoding
    TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
    AfterStimResp = mean(SMBinDataMtx(:,:,(TriggerAlignBin+1):(TriggerAlignBin+AfterStimWin)),3);
    
    

    
end
%%
save(fullfile(fullsavePath,'PopudecodingDatas.mat'), 'logRegressorProbofBlock', 'SVMDecodingAccuracy', 'SVMDecodingAccu_strs', ...
    'logRegressorProb_strs', 'ExistAreas_Names','logRegressorUnitSampleDec', '-v7.3');

%% ROC test for each unit
[TrNum, unitNum, BinNum] = size(SMBinDataMtxRaw);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
% halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtxRaw(:,:,1:TriggerAlignBin),3);

AUCValuesAll = zeros(unitNum,3);
smoothed_baseline_resp = zeros(size(BaselineResp_First));
for cUnit = 1 : unitNum
    cUnitDatas = BaselineResp_First(:,cUnit);
    [AUC, IsMeanRev] = AUC_fast_utest(cUnitDatas, BlockTypesAll);
    
    [~,~,SigValues] = ROCSiglevelGeneNew([cUnitDatas, BlockTypesAll],500,1,0.001);
    AUCValuesAll(cUnit,:) = [AUC, IsMeanRev, SigValues];
    
    smoothed_baseline_resp(:,cUnit) = smooth(cUnitDatas,7);
end

%% plot all AUC values
[AUCvalues, SortInds] = sort(AUCValuesAll(:,1));
SortedSiglevels = AUCValuesAll(SortInds,3);
IsAUCSigInds = AUCvalues > SortedSiglevels;
AUCIndex = 1 : numel(AUCvalues);
h4f = figure;
hold on
plot(AUCIndex(IsAUCSigInds),AUCvalues(IsAUCSigInds),'ko','linewidth',1.4,'MarkerSize',10);
plot(AUCIndex(~IsAUCSigInds),AUCvalues(~IsAUCSigInds),'o','linewidth',1.4,'MarkerSize',10,'MarkerEdgeColor',[.7 .7 .7]);
title(sprintf('SigAUCfrac = %.4f',mean(IsAUCSigInds)));
xlabel('Units');
ylabel('AUC');
set(gca,'ylim',[0.2 1],'ytick',[0.5 1])
%%

save(fullfile(fullsavePath,'SingleUnitAUC.mat'), 'AUCValuesAll', 'smoothed_baseline_resp', '-v7.3');
AUCSaveName = fullfile(fullsavePath,'Unit AUC distributions');
saveas(h4f,AUCSaveName);
saveas(h4f,AUCSaveName,'png');
close(h4f);

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