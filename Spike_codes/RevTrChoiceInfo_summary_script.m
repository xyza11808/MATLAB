
behavDatafile = fullfile(ksfolder,'NewClassHandle2.mat');
behavDataStrc = load(behavDatafile,'behavResults');
BlockSectionInfo = Bev2blockinfoFun(behavDataStrc.behavResults);
BlockNum = BlockSectionInfo.NumBlocks;
BlockTypes = BlockSectionInfo.BlockTypes;

ChoiceInfoFile = fullfile(ksfolder,'BlockChoiceDecWeight','ChoiceInfoDataSummary.mat');
ChoiceInfoDataStrc = load(ChoiceInfoFile); % 'RevFreqChoiceScores','NewAdd_ExistAreaNames','ExistField_ClusIDs'

LeftChoiceInfoData = cellfun(@(x) x(:,end,1),ChoiceInfoDataStrc.RevFreqChoiceScores(:,1),'un',0);
RightChoiceInfoData = cellfun(@(x) x(:,end,2),ChoiceInfoDataStrc.RevFreqChoiceScores(:,1),'un',0);
% the third and forth is the BT score

TrialSizeAll = cellfun(@(x) squeeze(x(:,end,:)),ChoiceInfoDataStrc.RevFreqChoiceScores(:,2),'un',0);

% Window averaged choice scores
WinedChoiceScores = ChoiceInfoDataStrc.RevFreqChoiceScores(:,3);
LeftWinChoiceScore = cellfun(@(x) squeeze(x(:,1,:)),WinedChoiceScores,'un',0);
RightWinChoiceScore = cellfun(@(x) squeeze(x(:,2,:)),WinedChoiceScores,'un',0);

%%
OnsetBin = 11;

cA = 1;
cA_AreaStr = ChoiceInfoDataStrc.NewAdd_ExistAreaNames{cA};
cA_LeftTempChoice = LeftChoiceInfoData{cA}; % correlate to number of blocks
cA_LeftTempAvgTrace = cellfun(@mean,cA_LeftTempChoice,'un',0);
cA_LeftTempAvgTraceMtx = cat(1,cA_LeftTempAvgTrace{:});
% cA_LeftTempChoiceMtx = cat(3,cA_LeftTempChoice{:});
cA_RightTempChoice = RightChoiceInfoData{cA};
cA_RightTempAvgTrace = cellfun(@mean,cA_LeftTempChoice,'un',0);
cA_RightTempAvgTraceMtx = cat(1,cA_RightTempAvgTrace{:});
% cA_RightTempChoiceMtx = cat(3,cA_RightTempChoice{:});

[LeftWinChoiceScore_Avg,~,LeftWinChoiceScore_Num] = ...
    cellfun(@(x) dataSEMmean(x),LeftWinChoiceScore{cA}); % matrix size is blocknum by window number
[RightWinChoiceScore_Avg,~,RightWinChoiceScore_Num] = ...
    cellfun(@(x) dataSEMmean(x),RightWinChoiceScore{cA});

RevLeftTrNumUsed = LeftWinChoiceScore_Num(:,1); % the rest column is the same
RevRightTrNumUsed = RightWinChoiceScore_Num(:,1);

[~, ChoiceScoreCom_p] = cellfun(@(x,y) ttest2(x,y),...
    LeftWinChoiceScore{cA},RightWinChoiceScore{cA});

LeftRightWinChoiceComp = cat(3,LeftWinChoiceScore_Avg,RightWinChoiceScore_Avg,...
    ChoiceScoreCom_p, LeftWinChoiceScore_Num, RightWinChoiceScore_Num); % blockNum, window, Types





