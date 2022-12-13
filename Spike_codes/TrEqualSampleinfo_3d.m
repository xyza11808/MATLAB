function [RepeatAvgScores, RepeatAvgPerfs] = TrEqualSampleinfo_3d(Datas, labelNumInds, ratio)
% same function as TrEqualSampleinfo, but to handling 3d input datas

% the trial type labels will firstly equal sampled, and then using the
% ratio to generate train and test dataset
% ####################################################################
% have to make sure the labels are 1 and 2 while calling this function, so
% that we dont need to use unique function to increase time cost

labelNumInds = labelNumInds(:);
if ~exist('ratio','var') || isempty(ratio)
    ratio = 0.6; % training data ratio
end
    
% [labelTypes, ~, labelNumInds] = unique(labels);
% if length(labelTypes) ~= 2
%     error('The input labels should only have two types.');
% end
labelTypeCount = accumarray(labelNumInds,1);
MinTypeCounts = min(labelTypeCount);
TotalTrNums = numel(labelNumInds);

TrainSampleTrNums = round(MinTypeCounts*ratio);
Label1Inds = find(labelNumInds == 1);
Label2Inds = find(labelNumInds == 2);

Label1TotalNum = numel(Label1Inds);
Label2TotalNum = numel(Label2Inds);

Label1TrainSampleRatio = TrainSampleTrNums/Label1TotalNum;
Label2TrainSampleRatio = TrainSampleTrNums/Label2TotalNum;

NumRepeats = 50; % repeated sampling 
label1RandData = rand(NumRepeats, Label1TotalNum);
label2RandData = rand(NumRepeats, Label2TotalNum);
label1RandRatioThres = prctile(label1RandData,Label1TrainSampleRatio*100,2);
label2RandRatioThres = prctile(label2RandData,Label2TrainSampleRatio*100,2);
%%
ShufwithinRepeats = 10;
BinSize = size(Datas,3);
TotalrandData = rand(TotalTrNums, ShufwithinRepeats, NumRepeats);
[~, randDataSortInds] = sort(TotalrandData);
AllTrTrainInds = false(numel(labelNumInds),1);
AllRepeatScores = zeros(BinSize, 2, NumRepeats);
AllRepeatPerfs = zeros(BinSize, 2,NumRepeats);
AllShufPerfs = cell(NumRepeats,1);
for cR = 1 : NumRepeats
    cRTrainInds = AllTrTrainInds;
    cRLabel1_usedTrIndex = Label1Inds(label1RandData(cR,:) <= label1RandRatioThres(cR));
    cRLabel2_usedTrIndex = Label2Inds(label2RandData(cR,:) <= label2RandRatioThres(cR));
    AllTrainLabelIndex = [cRLabel1_usedTrIndex(:);cRLabel2_usedTrIndex(:)];
    cRTrainInds(AllTrainLabelIndex) = true;
    
    [DisScores,MdPerfs,~,beta] = LDAclassifierFun_3d(Datas, ...
            labelNumInds, {cRTrainInds,~cRTrainInds});
    AllRepeatScores(:,:,cR) = DisScores;
    AllRepeatPerfs(:,:,cR) = MdPerfs;
    
%     randSampleInds = rand(ShufwithinRepeats,TotalTrNums);
    ShufScoreANDperf = zeros(ShufwithinRepeats,BinSize,2);
    for cShuf = 1 : ShufwithinRepeats
%         [~,sortInds] = sort(randSampleInds(cShuf,:));
        sortInds = randDataSortInds(:,cShuf,cR);
        ShufLabels = labelNumInds(sortInds);
        [Score,Perf,~] = LDAclassifierFun_Score_3d(Datas(~cRTrainInds,:,:),...
            ShufLabels(~cRTrainInds),beta);
        ShufScoreANDperf(cShuf,:,:) = [Score,Perf];
    end
    AllShufPerfs{cR} = ShufScoreANDperf;
end
ShufPerfsAll = cat(1,AllShufPerfs{:});
ShufThres = squeeze(prctile(ShufPerfsAll,99));
% RepeatAvgScores = [mean(AllRepeatScores);std(AllRepeatScores)/sqrt(NumRepeats)];
% RepeatAvgPerfs = [mean(AllRepeatPerfs);std(AllRepeatPerfs)/sqrt(NumRepeats)];

RepeatAvgScores = [mean(AllRepeatScores,3),ShufThres(:,1)];
RepeatAvgPerfs = [mean(AllRepeatPerfs,3),ShufThres(:,2)];



