
clearvars ProbNPSess UnitRespDatas SMBinDataMtx StimResp1 ChoiceResp
CoefsaveName = fullfile(cSessFolder,'UnitRespTypeCoefNew.mat');
load(CoefsaveName,'UnitUsedCoefs', 'AboveThresUnit', 'UsedUnitMDRs_WithShuf');
if isempty(AboveThresUnit)
    UnitRespDatas = []; 
    BlockSectionInfo = [];
    dataSaveFile = fullfile(PlotSaveName,'UnitRespFR.mat');
    save(dataSaveFile,'UnitRespDatas','BlockSectionInfo','-v7.3');
    return;
end
load(fullfile(cSessFolder,'NPClassHandleSaved.mat'));
%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
ExcludedInds = (behavResults.Action_choice(:) == 2);
SMBinDataMtxRaw = SMBinDataMtx;
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
% SMBinDataMtx = SMBinDataMtx(~ExcludedInds,:,:);

[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

OnsetTime = double(behavResults.Time_stimOnset(:));
% OnsetTime = OnsetTime(:);
ReTimes = double(behavResults.Time_reward(:));
% ReTimes = ReTimes(:);
ChoiceTimes = double(behavResults.Time_answer(:));
% ChoiceTimes = ChoiceTimes(:);
Trial_freqs = double(behavResults.Stim_toneFreq(:));
% Trial_freqs = Trial_freqs(:);
Trial_Choices = double(behavResults.Action_choice(:));
% Trial_Choices = Trial_Choices(:);
TrialBlockTypes = double(behavResults.BlockType(:));
% TrialBlockTypes = TrialBlockTypes(:);

BlockSectionInfo = Bev2blockinfoFun(behavResults);

StimFreqTypes = unique(Trial_freqs);
NumFreqTypes = length(StimFreqTypes);

ChoiceTypes = unique(Trial_Choices);
NumChoiceTypes = length(ChoiceTypes);

%%
% time shift of real response unit data
% [TrNum, unitNum, BinNum] = size(SMBinDataMtx);
% TShiftSMBinDataMtx = zeros(TrNum, unitNum, BinNum);
% TShiftSize = round(BinNum/3);
% parfor cTr = 1 : TrNum
%     for cU = 1 : unitNum
%         cTrace = squeeze(SMBinDataMtx(cTr, cU, :));
%         ShiftSize = randsample(TShiftSize,1);
%         if rand(1) > 0.5
%             Direction = 1;
%         else
%             Direction = -1;
%         end
%         TShiftSMBinDataMtx(cTr, cU, :) = circshift(cTrace, ShiftSize*Direction);
%     end
% end

%%

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
Stimwinbin = round([0,500]/1000/ProbNPSess.USedbin(2));
AnsRe_winbin = round([0,1000]/1000/ProbNPSess.USedbin(2));
if strcmpi(ProbNPSess.TrigAlignType{ProbNPSess.CurrentSessInds},'trigger') % events aligend to trigger time 
    
elseif strcmpi(ProbNPSess.TrigAlignType{ProbNPSess.CurrentSessInds},'stim') 
    AlignedChoiceTime = ChoiceTimes - OnsetTime;
    AlignedChoiceBin = round(max(AlignedChoiceTime,0)/1000/ProbNPSess.USedbin(2) + TriggerAlignBin);
    AlignedRewardTime = ReTimes - OnsetTime;
    AlignedReBin = round(max(AlignedRewardTime,0)/1000/ProbNPSess.USedbin(2) + TriggerAlignBin);
    BaselineResp = mean(SMBinDataMtx(:,:,1:TriggerAlignBin-1),3);
    StimResp1 = mean(SMBinDataMtx(:,:,(TriggerAlignBin+Stimwinbin(1,1)+1):(TriggerAlignBin+Stimwinbin(1,2))),3) - BaselineResp;%;

    ChoiceResp = zeros(TrNum, unitNum);
    ReResp = zeros(TrNum, unitNum);
%     ShufChoiceResp = zeros(TrNum, unitNum);
%     ShufReResp = zeros(TrNum, unitNum);
    
    for cTr = 1 : TrNum
        ChoiceResp(cTr,:) = squeeze(mean(SMBinDataMtx(cTr,:,(TriggerAlignBin+AlignedChoiceBin(cTr)+AnsRe_winbin(1)+1):...
            (TriggerAlignBin+AlignedChoiceBin(cTr)+AnsRe_winbin(2))),3));
        ReResp(cTr,:) = squeeze(mean(SMBinDataMtx(cTr,:,(TriggerAlignBin+AlignedReBin(cTr)+AnsRe_winbin(1)+1):...
            (TriggerAlignBin+AlignedReBin(cTr)+AnsRe_winbin(2))),3));
    end
    NoRewardInds = AlignedReBin == TriggerAlignBin;
    ReResp(NoRewardInds,:) = ChoiceResp(NoRewardInds,:); % using choice response data as non-reward response data
    ChoiceResp = ChoiceResp - BaselineResp;
    ReResp = ReResp - BaselineResp;
    
end

%%


PlotSaveName = fullfile(cSessFolder,'RespUnitFRplot');
if ~isfolder(PlotSaveName)
    mkdir(PlotSaveName);
end
%%
% save(saveName,'UnitUsedCoefs', 'AboveThresUnit', 'UnitFitmds_All', 'overAllTerms_mtx','UsedUnitMDRs_WithShuf','-v7.3');
if ~isempty(AboveThresUnit) % no response unit exists
    NumRespUnit = length(AboveThresUnit);
    NumSessBlock = BlockSectionInfo.NumBlocks;
    UnitRespDatas = cell(NumRespUnit, NumSessBlock, 4);
    for cU = 1 : NumRespUnit
        cU_index = AboveThresUnit(cU);
        cU_stimRespData = StimResp1(:,cU_index);
        cU_ChoiceRespData = ChoiceResp(:,cU_index);
        
        % plot the response tuning curve
        huf = figure('position',[100 100 680 350]);
        hold on
        BlockLineColor = [0.1 0.6 0.3;1 0.7 0.3];
        for cB = 1 : NumSessBlock
           cB_Type = BlockSectionInfo.BlockTypes(cB);
           cB_TrScale =  BlockSectionInfo.BlockTrScales(cB,:);
           cU_cB_Stimfreqs = Trial_freqs(cB_TrScale(1):cB_TrScale(2));
           cU_cB_TrChoice = Trial_Choices(cB_TrScale(1):cB_TrScale(2));
           cU_cB_StimRespData = cU_stimRespData(cB_TrScale(1):cB_TrScale(2));
           cU_cB_AnsRespData = cU_ChoiceRespData(cB_TrScale(1):cB_TrScale(2));
           ccNMChoiceInds = cU_cB_TrChoice ~= 2;
           
           cU_cB_StimfreqsNM = cU_cB_Stimfreqs(ccNMChoiceInds);
           cU_cB_TrChoiceNM = cU_cB_TrChoice(ccNMChoiceInds);
           cU_cB_StimRespDataNM = cU_cB_StimRespData(ccNMChoiceInds);
           cU_cB_AnsRespDataNM = cU_cB_AnsRespData(ccNMChoiceInds);
           
           Freqwise_respData = zeros(NumFreqTypes,3);
           for cTrFreq = 1 : NumFreqTypes
              cf_Inds =  cU_cB_StimfreqsNM == StimFreqTypes(cTrFreq);
              cf_RespDatas = cU_cB_StimRespDataNM(cf_Inds);
              
              Freqwise_respData(cTrFreq,:) = [mean(cf_RespDatas), std(cf_RespDatas)/sqrt(numel(cf_RespDatas)),...
                  numel(cf_RespDatas)];
           end
           
           Choicewise_respData = zeros(NumChoiceTypes,3);
           for cC = 1 : NumChoiceTypes
              cC_Inds =  cU_cB_TrChoiceNM == ChoiceTypes(cC);
              cC_RespDatas = cU_cB_AnsRespDataNM(cC_Inds);
              Choicewise_respData(cC,:) = [mean(cC_RespDatas), ...
                  std(cC_RespDatas)/sqrt(numel(cC_RespDatas)),numel(cC_RespDatas)];
           end
           
           cLColor = BlockLineColor(cB_Type+1,:);
           errorbar(1:NumFreqTypes, Freqwise_respData(:,1),Freqwise_respData(:,2),...
               '-o','linewidth',1.4,'Color',cLColor);
           errorbar(NumFreqTypes+(1:NumChoiceTypes),...
               Choicewise_respData(:,1),Choicewise_respData(:,2),...
               '-o','linewidth',1.4,'Color',cLColor);
           
           text(1:NumFreqTypes, Freqwise_respData(:,1),cellstr(num2str(Freqwise_respData(:,3))),...
               'Color','m','HorizontalAlignment','left');
%            text(NumFreqTypes+(1:NumChoiceTypes), Choicewise_respData(:,1),cellstr(num2str(Choicewise_respData(:,3))),...
%                'Color','m','HorizontalAlignment','left');
           UnitRespDatas(cU,cB,:) = {StimFreqTypes,Freqwise_respData,ChoiceTypes,Choicewise_respData};
           
        end
        yscales = get(gca,'ylim');
        cUAllCoefs = abs(UnitUsedCoefs{cU,1});
        SigCoefInds = cUAllCoefs(1:NumFreqTypes+NumChoiceTypes) > 0;
        NumSigCoefs = sum(SigCoefInds);
        text(find(SigCoefInds),yscales(2)*ones(NumSigCoefs,1),'*','HorizontalAlignment','center');
        
        set(gca,'xtick',1:(NumFreqTypes+NumChoiceTypes),'xticklabel',[cellstr(num2str(StimFreqTypes/1000,'F%.2f'));...
               cellstr(num2str(ChoiceTypes,'C%d'))]);
        ylabel('Firing rate');
        set(gca,'ylim',[yscales(1),yscales(2)+3]);
        MDRs = UsedUnitMDRs_WithShuf{cU,1};
        title(sprintf('Unit %d, LMmodel Rs = %.3f',ProbNPSess.UsedClus_IDs(cU),MDRs));
        
        
        
        UnitSaveName = fullfile(PlotSaveName,sprintf('Unit%d response curve plot',cU_index));
        saveas(huf,UnitSaveName);
        saveas(huf,UnitSaveName,'png');
        close(huf);
    end
    
else
    
   UnitRespDatas = []; 
end

%%
dataSaveFile = fullfile(PlotSaveName,'UnitRespFR.mat');
save(dataSaveFile,'UnitRespDatas','BlockSectionInfo','-v7.3');


% % batched running code
% cclr
% 
% AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% % AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumUsedSess = length(SessionFolders);
% 
% 
% %%
% 
% 
% for cSess = 1 : NumUsedSess
%     
% %     cSessFolder = fullfile(SessionFolders{cSess}(2:end-1),'ks2_5');
%     cSessFolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'));
%     
%     EventResp_avg_codes;
% 
%     saveName = fullfile(cSessFolder,'ks2_5','UnitRespTypeCoef.mat');
%     save(saveName,'UnitUsedCoefs', 'AboveThresUnit', 'UnitFitmds_All', 'overAllTerms_mtx', 'DevThreshold','-v7.3');
%     
% end



%%
% cUnit = 31;
% if cUnit > unitNum
%     return;
% end
% 
% AllParas_mtx = zeros(TrNum*3,NumFreqTypes+2+1+2);
% AllParas_mtx(1:TrNum,1:NumFreqTypes) = FreqParas_mtx;
% AllParas_mtx((1+TrNum):(TrNum*2),(1+NumFreqTypes):(2+NumFreqTypes)) = ChoiceParas_mtx;
% AllParas_mtx((1+TrNum*2):(TrNum*3),(3+NumFreqTypes)) = ReParas_mtx;
% BlockType_mtx = [1-TrialBlockTypes,TrialBlockTypes];
% AllParas_mtx(1:end,(4+NumFreqTypes):(5+NumFreqTypes)) = [BlockType_mtx;BlockType_mtx;BlockType_mtx];
% 
% % NumRepeats = 100;
% % UnitFitmds_All = cell(unitNum,2);
% % parfor cUnit = 1 : unitNum
%     warning off
%     cUnitRespVec = [StimResp1(:,cUnit);ChoiceResp(:,cUnit);ReResp(:,cUnit)];
%     cUnitRespVec = zscore(cUnitRespVec);
% %     IsNegResp = mean(cUnitRespVec) < 0;
% %     cUnitRespVec = cUnitRespVec/mean(cUnitRespVec);
%     
% %     cUnitRepeatDevExplain = zeros(NumRepeats,1);
% %     cUnitRepeatMD = cell(NumRepeats,1);
% %     for cRepeat = 1 : NumRepeats
%         SampleInds = randsample(numel(cUnitRespVec),round(numel(cUnitRespVec)*0.7));
%         trainInds = false(numel(cUnitRespVec),1);
%         trainInds(SampleInds) = true;
% 
%         TestInds = ~trainInds;
% 
%         md2 = fitglm(AllParas_mtx(trainInds,:),cUnitRespVec(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
%             true(NumFreqTypes+5,1));
% 
%         %
%         TestDataVec = cUnitRespVec(~trainInds,:);
%         TestDataPred = predict(md2,AllParas_mtx(~trainInds,:));
% 
%         NullDEvience = sum((TestDataVec - mean(TestDataVec)).^2);
%         predDev = sum((TestDataVec - TestDataPred).^2);
%         Explain = (NullDEvience - predDev)/NullDEvience;
%         
% %         cUnitRepeatDevExplain(cRepeat) = Explain;
% %         cUnitRepeatMD{cRepeat} = md2.Coefficients;
%         
%         disp(md2)
% 
%         fprintf('Current cluster %d: \n   devience explain = %.6f.\n',ProbNPSess.UsedClus_IDs(cUnit),Explain);
% % end
% warning on
% 




%%
% warning off
% % nRepeat = 100;
% NullDevExplain = zeros(NullRepeat,1);
% for cRe = 1 : NullRepeat
% %     AllshufRespVec = Vshuffle(cUnitRespVec);
% %     TrainParas_Mtx = AllParas_mtx(trainInds,:);
% %     SelectInds = 1:size(TrainParas_Mtx,1);
% %     md2sf = fitglm(TrainParas_Mtx(Vshuffle(SelectInds),:),AllshufRespVec(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
% %     true(size(TrainParas_Mtx,2),1));
% % 
% %     TestDataVecShuf = cUnitRespVec(~trainInds,:);
% %     TestDataPred = predict(md2sf,AllParas_mtx(~trainInds,:));
%     cUnitRespVecShuf = [NullDataSet{cRe,1}(:,cUnit);NullDataSet{cRe,2}(:,cUnit);NullDataSet{cRe,3}(:,cUnit)];
%     cUnitRespVecShuf = cUnitRespVecShuf/mean(cUnitRespVecShuf); % incase of zeros mean
%     
%     SampleInds = randsample(numel(cUnitRespVecShuf),round(numel(cUnitRespVecShuf)*0.7));
%     trainInds = false(numel(cUnitRespVecShuf),1);
%     trainInds(SampleInds) = true;
% 
%     TestInds = ~trainInds;
%     
%     md2sf = fitglm(AllParas_mtx(trainInds,:),cUnitRespVecShuf(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
%         true(size(AllParas_mtx,2),1));
%     
%     TestDataVecShuf = cUnitRespVecShuf(~trainInds,:);
%     NullDEvienceShuf = sum((TestDataVecShuf - mean(TestDataVecShuf)).^2);
%     TestDataPred_shuf = predict(md2sf,AllParas_mtx(~trainInds,:));
%     
%     predDevShuf = sum((TestDataVecShuf - TestDataPred_shuf).^2);
%     NullDevExplain(cRe) = (NullDEvienceShuf - predDevShuf)/NullDEvienceShuf;
% end
% disp(prctile(NullDevExplain,95));
% warning on


% % % ###############################################################################################
% % % ###############################################################################################

% cclr
% 
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% % AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumUsedSess = length(SessionFolders);
% 
% 
% %%
% 
% 
% for cSess = 1 : NumUsedSess
%     
% %     cSessFolder = fullfile(SessionFolders{cSess},'ks2_5');
%     cSessFolder = fullfile(strrep(SessionFolders{cSess},'F:','P:'),'ks2_5');
%     fprintf('Processing session %d ...\n',cSess);
%     EventRespUnit_FRplot;
% 
% %     saveName = fullfile(cSessFolder,'ks2_5','UnitRespTypeCoef.mat');
% %     save(saveName,'UnitUsedCoefs', 'AboveThresUnit', 'UnitFitmds_All', 'overAllTerms_mtx', 'DevThreshold','-v7.3');
%     
% end
