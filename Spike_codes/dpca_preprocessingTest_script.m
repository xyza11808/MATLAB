% dpca usage example can be found in: dpca_demo


% TrialNum_dpc = 
BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockTypesAll = double(behavResults.BlockType(:));

TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));

NMissInds = TrialAnmChoice ~= 2;

NMTrialFreqs = TrialFreqsAll(NMissInds);
NMTrialChoice = TrialAnmChoice(NMissInds);
NMTrialBTs = BlockTypesAll(NMissInds);

FreqTypes = unique(NMTrialFreqs);
NumFreqs = numel(FreqTypes);
ChoiceTypes = unique(NMTrialChoice);
NumChoices = numel(ChoiceTypes);
BlockType_types = unique(NMTrialBTs);
NumBTs = numel(BlockType_types);

UsedUnitInds = SessAreaIndexStrc.VL.MatchedUnitInds;
NumUnits = length(UsedUnitInds);

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

UsedUnitPSTHdata = SMBinDataMtx(:,UsedUnitInds,:); % NTrials by nUnits by nTimes
[TotalTrNums, UnitNums, TimeBins] = size(UsedUnitPSTHdata);

TrNums_dpca = zeros(1,NumFreqs,NumChoices,NumBTs); % will be repmat by the number of units
for cf = 1 : NumFreqs
    for cc = 1 : NumChoices
        for cBT = 1 : NumBTs
           TrNums_dpca(1,cf,cc,cBT) = sum(NMTrialFreqs == FreqTypes(cf) & ...
               NMTrialChoice == ChoiceTypes(cc) & ...
               NMTrialBTs == NMTrialBTs(cBT));
        end
    end
end

MaxTrInds = max(TrNums_dpca(:));
if min(MaxTrInds(:)) == 0
    warning('some types have no corresponded trials');
end
TrNums_dpca =  repmat(TrNums_dpca,UnitNums,1,1,1);
frs = zeros(UnitNums,NumFreqs,NumChoices,NumBTs,TimeBins,MaxTrInds);
for cf = 1 : NumFreqs
    for cc = 1 : NumChoices
        for cBT = 1 : NumBTs
           TrtypeInds = (NMTrialFreqs == FreqTypes(cf) & ...
               NMTrialChoice == ChoiceTypes(cc) & ...
               NMTrialBTs == NMTrialBTs(cBT));
           if sum(TrtypeInds)
               cTypeData = UsedUnitPSTHdata(TrtypeInds,:,:);
               NumcTypes = size(cTypeData, 1);
               filledTypeData = cat(1, cTypeData, zeros(MaxTrInds-NumcTypes,...
                   UnitNums, TimeBins));
               
               frs(:,cf,cc,cBT,:,:) = permute(filledTypeData,[2,3,1]);
           end
           
        end
    end
end

frAvgs = mean(frs, length(size(frs)),'omitnan');

%%
%    1 - stimulus 
%    2 - decision
%    3 - block types
%    4 - time

combinedParams = {{1, [1,4]}, {2, [2,4]}, {3,[3,4]},{4},{[1 3], [1 3 4]}...
    , {[2 3], [2 3 4]}}; %, {[1 2], [1 2 4]},{[1 2 3],[1 2 3 4]}
margNames = {'Stimulus', 'Decision', 'BlockType', 'Condition-independent', 'S/B Interaction',...
     'B/D Interaction'}; % 'S/D Interaction', 'S/B/D Interaction'
lineColors = linspecer(length(combinedParams));

times = (1:TimeBins) * ProbNPSess.USedbin(2);
timeEvent = ProbNPSess.USedbin(2)*ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};

%%
[W,V,whichMarg] = dpca(frs, 20, ...
    'combinedParams', combinedParams);

%%

explVar = dpca_explainedVariance(frs, W, V, ...
    'combinedParams', combinedParams);

%%
dpca_plot(frs, W, V, @dpca_plot_default, ...
    'explainedVar', explVar, ...
    'marginalizationNames', margNames, ...
    'marginalizationColours', lineColors, ...
    'whichMarg', whichMarg,                 ...
    'time', times,                        ...
    'timeEvents', timeEvent,               ...
    'timeMarginalization', 3, ...
    'legendSubplot', 16);




















