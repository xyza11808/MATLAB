% "Cortical information flow during flexible sensorimotor decisions"
% ksfolder = pwd;
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
clearvars ProbNPSess AllNullThres_Mtx NSMUnitOmegaSqrData CalWinUnitOmegaSqrs NullOmegaSqrDatas

load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% transfromed into trial-by-units-by-bin matrix
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); 
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
%%
Numfieldnames = length(ExistAreaNames);
ExistField_ClusIDs = [];
AreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
end
%%
if isempty(ExistField_ClusIDs)
    fprintf('No target region units within current session.\n');
    return;
end
CalUnitInds = ExistField_ClusIDs(:,2);
NumCaledUnits = length(CalUnitInds);

SPTimeBinSize = ProbNPSess.USedbin;
StimOnsetBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};

SMBinDataMtxUsed = SMBinDataMtx(:,CalUnitInds,:);
BlockSectionInfo = Bev2blockinfoFun(behavResults);  
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));

%%

ActionChoices = double(behavResults.Action_choice(:));
TrNMInds = ActionChoices ~= 2;

TrFreqs = double(behavResults.Stim_toneFreq(:));
TrBlockTypes = double(behavResults.BlockType(:));
TrAnsTimes = double(behavResults.Time_answer(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrAnsAfterStimOnsetTime = TrAnsTimes - TrStimOnsets;
% adding other behavior model fitting results latter

NMTrChoices = ActionChoices(TrNMInds);
NMTrFreqs =TrFreqs(TrNMInds);
NMTrBlockTypes = TrBlockTypes(TrNMInds);
NMAnsTimeAFOnset = TrAnsAfterStimOnsetTime(TrNMInds);

RevFreqTrInds = double(ismember(NMTrFreqs, RevFreqs));


%% processing binned datas
DataBinTimeWin = 0.05; %seconds
winGoesStep = 0.01; %seconds, moving steps, partially overlapped windows 
calDataBinSize = DataBinTimeWin/ProbNPSess.USedbin(2);
calDataStepBin = winGoesStep/ProbNPSess.USedbin(2);
OverAllUsedTime = 5; % seconds, used time length for each trial, this time including prestim periods
TotalCalcuNumber = (OverAllUsedTime/ProbNPSess.USedbin(2))/calDataStepBin - (calDataBinSize - calDataStepBin);
CaledStartBin = ceil(calDataBinSize/2);
CaledStimOnsetBin = StimOnsetBin - CaledStartBin + 1;
SmoothWin = hann(calDataBinSize*2+1);
SmoothWin = SmoothWin/sum(SmoothWin);

CalWinUnitOmegaSqrs = cell(TotalCalcuNumber, NumCaledUnits, 3);

for cCalWin = 1 : TotalCalcuNumber
    cCal_startInds = (cCalWin -1)*calDataStepBin + 1;
    cCal_endInds = cCal_startInds + calDataBinSize - 1;
    UsedDataWin = cCal_startInds:cCal_endInds;
    UnitRespData = mean(SMBinDataMtxUsed(TrNMInds,:,UsedDataWin),3);
    
    UnitOmegaSqr_times = cell(NumCaledUnits, 3);
    parfor cU = 1 : NumCaledUnits
        cU_data = UnitRespData(:,cU);
        Datas = zeros(3,1);
%         [p,tbl,stats] = anovan(cU_data,{NMTrChoices,NMTrFreqs,NMTrBlockTypes},...
%             'varnames',{'Choice','stimuli','BlockType'},'display','on');
        % factor 1, controls for blocktypes
        Type1Inds = NMTrBlockTypes == 0;
        Type2Inds = NMTrBlockTypes == 1;
        Datas_1_1 = OmegaSqrStats(cU_data(Type1Inds), NMTrChoices(Type1Inds));
        Datas_1_2 = OmegaSqrStats(cU_data(Type2Inds), NMTrChoices(Type2Inds));
        Datas_1 = [Datas_1_1,Datas_1_2];
        
        % factor 2, controls for block types
        Datas_2_1 = OmegaSqrStats(cU_data(Type1Inds), NMTrFreqs(Type1Inds));
        Datas_2_2 = OmegaSqrStats(cU_data(Type2Inds), NMTrFreqs(Type2Inds));
        Datas_2 = [Datas_2_1,Datas_2_2];
        
        % factor 3, controls for choices and Rev-NonRev freqs
        Datas_3 = zeros(2,2);
        for cChoice = 1 : 2
            for cIsRev = 1 : 2
                cInds = NMTrChoices == (cChoice - 1) & RevFreqTrInds == (cIsRev - 1);
                Datas_3(cChoice, cIsRev) = OmegaSqrStats(cU_data(cInds), NMTrBlockTypes(cInds));
            end
        end
        
        UnitOmegaSqr_times(cU,:) = {Datas_1, Datas_2, Datas_3};
%         RandShufInds = rand(nRepeats,numel(cU_data));
%         ShufOutValues = zeros(nRepeats,3);
%         parfor cR = 1 : nRepeats
%             [~,randSortInds] = sort(RandShufInds(cR,:));
%             ShufcUData = cU_data(randSortInds);
%             shufOmegaSqr1 = OmegaSqrStats(ShufcUData, NMTrChoices);
%             shufOmegaSqr2 = OmegaSqrStats(ShufcUData, NMTrFreqs);
%             shufOmegaSqr3 = OmegaSqrStats(ShufcUData, NMTrBlockTypes);
%             ShufOutValues(cR,:) = [shufOmegaSqr1,shufOmegaSqr2,shufOmegaSqr3];
%         end
%         NullOmegaSqrDatas{cCalWin, cU} = ShufOutValues;
    end
    CalWinUnitOmegaSqrs(cCalWin,:,:) = UnitOmegaSqr_times;
end

%% generate null distribution values
t1 = tic;
% generate each types group infos
% first factor, choices
Factor_choiceTypes = unique(NMTrChoices);
NumF1Types = numel(Factor_choiceTypes);
TypeIndsANDnum_F1 = cell(NumF1Types,2);
for cF1 = 1 : NumF1Types
    F1TypesInds = NMTrChoices == Factor_choiceTypes(cF1);
    TypeIndsANDnum_F1(cF1,:) = {F1TypesInds,sum(F1TypesInds)};
end

% second, frequencies
Factor_freqTypes = unique(NMTrFreqs);
NumF2Types = numel(Factor_freqTypes);
TypeIndsANDnum_F2 = cell(NumF2Types,2);
for cF1 = 1 : NumF2Types
    F2TypesInds = NMTrFreqs == Factor_freqTypes(cF1);
    TypeIndsANDnum_F2(cF1,:) = {F2TypesInds,sum(F2TypesInds)};
end

% third, blocktypes
Factor_BTTypes = unique(NMTrBlockTypes);
NumF3Types = numel(Factor_BTTypes);
TypeIndsANDnum_F3 = cell(NumF3Types,2);
for cF1 = 1 : NumF3Types
    F3TypesInds = NMTrBlockTypes == Factor_BTTypes(cF1);
    TypeIndsANDnum_F3(cF1,:) = {F3TypesInds,sum(F3TypesInds)};
end


nRepeats = 1000;
NullOmegaSqrDatas = cell(TotalCalcuNumber,1);

ShufOmegaSqrsDatas = zeros(TotalCalcuNumber, NumCaledUnits, 3);
for cCalWin = 1 : TotalCalcuNumber
    cCal_startInds = (cCalWin -1)*calDataStepBin + 1;
    cCal_endInds = cCal_startInds + calDataBinSize - 1;
    UsedDataWin = cCal_startInds:cCal_endInds;
    UnitRespData = mean(SMBinDataMtxUsed(TrNMInds,:,UsedDataWin),3);

    ForNullIndsData = rand([size(UnitRespData),nRepeats]);
    cShufUnitOmegaSqr = zeros(nRepeats,NumCaledUnits, 3);
    cUtotalmean = mean(UnitRespData);
    cUtotalSS = var(UnitRespData)*(sum(TrNMInds)-1);
    parfor cR = 1 : nRepeats
        cRandIndsData = ForNullIndsData(:,:,cR);
        for cU = 1 : NumCaledUnits
            cU_data = UnitRespData(:,cU);
            [~,ShufInds] = sort(cRandIndsData(:,cU));
            ShufcUData = cU_data(ShufInds);

            MeanANDSStotal = [cUtotalmean(cU),cUtotalSS(cU)];
            cDatas = zeros(3,1);
    %         [p,tbl,stats] = anovan(cU_data,{NMTrChoices,NMTrFreqs,NMTrBlockTypes},...
    %             'varnames',{'Choice','stimuli','BlockType'},'display','on');
            cDatas(1) = OmegaSqrStats_typeInds(ShufcUData, Factor_choiceTypes,...
                TypeIndsANDnum_F1,MeanANDSStotal);
            cDatas(2) = OmegaSqrStats_typeInds(ShufcUData, Factor_freqTypes,...
                TypeIndsANDnum_F2,MeanANDSStotal);
            cDatas(3) = OmegaSqrStats_typeInds(ShufcUData, Factor_BTTypes,...
                TypeIndsANDnum_F3,MeanANDSStotal);
            cShufUnitOmegaSqr(cR,cU,:) = cDatas;
        end
    end
    NullOmegaSqrDatas{cCalWin} = cShufUnitOmegaSqr;
end

tt1 = toc(t1);
%% smooth the real value using hanning window, half width is the same as calculation bin
% SMUnitOmegaSqrData = zeros(size(CalWinUnitOmegaSqrs));
% for cFactor = 1 : 3
%     cfData = CalWinUnitOmegaSqrs(:,:,cFactor);
%     cfData_sm = conv2(SmoothWin,1,cfData,'same');
%     SMUnitOmegaSqrData(:,:,cFactor) = cfData_sm;
% end

UnitOmegaSqr_AvgMtx = cellfun(@(x) mean(x(:),'omitnan'),CalWinUnitOmegaSqrs);
NSMUnitOmegaSqrData = zeros(size(UnitOmegaSqr_AvgMtx));
for cFactor = 1 : 3
    cfData = UnitOmegaSqr_AvgMtx(:,:,cFactor);
    cfData_sm = conv2(SmoothWin,1,cfData,'same');
    NSMUnitOmegaSqrData(:,:,cFactor) = cfData_sm;
end

%%
AllNullThres_Cell = cellfun(@(x) squeeze(prctile(x,99,1)),NullOmegaSqrDatas,'un',0);
AllNullThres_Mtx = permute(cat(3,AllNullThres_Cell{:}),[3,1,2]);

%%
if ~isfolder(fullfile(ksfolder,'AnovanAnA'))
    mkdir(fullfile(ksfolder,'AnovanAnA'))
end
savename = fullfile(ksfolder,'AnovanAnA','OmegaSqrDatas.mat');
save(savename,'AllNullThres_Mtx', 'NSMUnitOmegaSqrData', 'CalWinUnitOmegaSqrs', 'NullOmegaSqrDatas','-v7.3');
%%
% close;
% % nan values meaning there is not enough valid data within calculation
% % window
% 
% TotalCalcuNumber = size(NSMUnitOmegaSqrData,1);
% CaledStimOnsetBin = 149; % stimonset bin is 151, and the calculation window is 50ms (5 bins)
% winGoesStep = 0.01; % seconds
% TotalUnitNumbers = ((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep;
% cUnit = 118;
% % cFactor = 3;
% titleStrs = {'Choices','Freqs','Blocktypes'};
% huf = figure('position',[100 100 1080 380]);
% for caInds = 1 : 3
%     ax = subplot(1,3,caInds);
%     hold on
% %     plot(TotalUnitNumbers,squeeze(SMUnitOmegaSqrData(:,cUnit,caInds)),'r','linewidth',1.5);
%     plot(TotalUnitNumbers,squeeze(AllNullThres_Mtx(:,cUnit,caInds)),'Color',[.7 .7 .7],'linewidth',1.2);
%     plot(TotalUnitNumbers,squeeze(NSMUnitOmegaSqrData(:,cUnit,caInds)),'Color','r','linewidth',1.2);
%     yscales = get(gca,'ylim');
%     line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
%     set(ax,'ylim',yscales);
%     title(titleStrs{caInds});
% end

