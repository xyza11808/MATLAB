function FoldTrainTestIndex = ClassEvenPartitionFun(TrTypes,Folds)
% used for evenly partition for different classes
InputTypes = unique(TrTypes);
NumTypes = length(InputTypes);
TypeTrialNums = zeros(NumTypes,1);
TypeTrialIndexCell = cell(NumTypes,1);
for cTrType = 1 : NumTypes
    cTypeIndex = find(TrTypes == InputTypes(cTrType));
    TypeTrialNums(cTrType) = numel(cTypeIndex);
    
    ccc = cvpartition(TypeTrialNums(cTrType),'kFold',Folds);
    FoldTrainTestAll = cell(2,Folds);
    for cFold = 1 : Folds
        cFoldTrainInds = ccc.training(cFold);
        cFoldTestInds = ~cFoldTrainInds;
        
        TrainIndex = cTypeIndex(cFoldTrainInds);
        TestIndex = cTypeIndex(cFoldTestInds);
        
        FoldTrainTestAll(:,cFold) = {TrainIndex,TestIndex};
    end
    
    TypeTrialIndexCell{cTrType} = FoldTrainTestAll;
end
%%
FoldTrainTestIndex = cell(2,Folds);
for cff = 1 : Folds
    cfAllTypeIndexTrain = cellfun(@(x) x{1,cff},TypeTrialIndexCell,'UniformOutput',false);
    cfAllTypeIndexTest = cellfun(@(x) x{2,cff},TypeTrialIndexCell,'UniformOutput',false);
    
    FoldTrainTestIndex{1,cff} = cell2mat(cfAllTypeIndexTrain);
    FoldTrainTestIndex{2,cff} = cell2mat(cfAllTypeIndexTest);
end

    
