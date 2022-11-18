function [RepeatInfo_check,RepeatAccu_check,AllRepeatBetas_check,BlockChoiceVec,BlockInds,BlockShufDecs,BlockChoiceANDData] = ...
    BlockWiseChoiceDecVec(UsedTrNMDatas_maxBin, TrialBlockIndex, ...
    TrialChoices, NumBlocks, RepeatNum)
% function used to perform blockwise decoding of the given data set
if ~exist('RepeatNum','var')
    RepeatNum = 50;
end
shufRepeatNum = 500;

RepeatInfo_check = zeros(NumBlocks,RepeatNum,2);
RepeatAccu_check = zeros(NumBlocks,RepeatNum,2);
AllRepeatBetas_check = cell(NumBlocks,RepeatNum);
BlockShufDecs = cell(NumBlocks,3);
BlockChoiceANDData = cell(NumBlocks,2);
for cB = 1:NumBlocks
    cB_TrInds = TrialBlockIndex == cB;
    cBNMTrNums = sum(cB_TrInds);
    cBData = UsedTrNMDatas_maxBin(cB_TrInds,:);
    cBChoices = TrialChoices(cB_TrInds);
    for cR = 1 : RepeatNum

        cR_TrainIndex = randsample(cBNMTrNums,round(cBNMTrNums*0.8));
        cR_TrainBaseInds = false(cBNMTrNums,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        [InfoScore,LDAAccu,~,beta] = LDAclassifierFun(cBData,...
            cBChoices,{cR_TrainBaseInds,cR_TestInds});
        AllRepeatBetas_check(cB,cR) = {beta};
        RepeatInfo_check(cB,cR,:) = InfoScore;
        RepeatAccu_check(cB,cR,:) = LDAAccu;
        
    end
    BlockChoiceANDData(cB,:) = {cBData, cBChoices};
%     sampleNum = round(cBNMTrNums*0.8);
    RandValues = rand(shufRepeatNum,cBNMTrNums);
    cShufInfoAll = zeros(shufRepeatNum,2);
    cShufPerfAll = zeros(shufRepeatNum,2);
    cShufBetaAll = cell(1,shufRepeatNum);
    for cR = 1 : shufRepeatNum
        cR_TrainIndex = randsample(cBNMTrNums,round(cBNMTrNums*0.8));
        cR_TrainBaseInds = false(cBNMTrNums,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        [~,sortInds] = sort(RandValues(cR,:));
        [InfoScore,LDAAccu,~,beta] = LDAclassifierFun(cBData,...
            cBChoices(sortInds),{cR_TrainBaseInds,cR_TestInds});
        cShufInfoAll(cR,:) = InfoScore;
        cShufPerfAll(cR,:) = LDAAccu;
        cShufBetaAll{cR} = beta;
    end
    
    ShufInfoScoreThres = prctile(cShufInfoAll,95);
    ShufPerfScoreThres = prctile(cShufPerfAll,95);
    ShufBetaMtx = cat(2,cShufBetaAll{:});
    ShufBetaCI = prctile(ShufBetaMtx,[2.5 97.5],2);
    BlockShufDecs(cB,:) = {ShufInfoScoreThres,ShufPerfScoreThres,ShufBetaCI};
end
%
BlockCombineNum = NumBlocks*(NumBlocks-1)/2;
BlockChoiceVec = zeros(RepeatNum,BlockCombineNum);
BlockInds = zeros(2,BlockCombineNum);
k = 1;
for cB1 = 1 : NumBlocks
    for cB2 = cB1+1 : NumBlocks
        
        for cR = 1 : RepeatNum
            BlockChoiceVec(cR,k) = VecAnglesFun(AllRepeatBetas_check{cB1,cR},AllRepeatBetas_check{cB2,cR});
        end
        BlockInds(:,k) = [cB1,cB2];
        k = k + 1;
    end
end







