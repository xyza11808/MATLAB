function [DifBlockCom_selfScore,DifBlockCom_otherScore,...
    SimBlockCom_selfScore,SimBlockCom_otherScore,DBScoreP,SBScoreP,...
    BoxPlotData_x,BoxPlotData_GrInds,Grlabels] = ScoreDataExtraction(cA_Data,DataType)
cA_SelfBlockScore = cellfun(@(x) mean(x,'omitnan'),cA_Data(:,1));
cA_OtherBlockScore = cellfun(@(x) mean(x,'omitnan'),cA_Data(:,2),'un',0);

cA_OtherDifBlockScore = cellfun(@(x, y) mean(x(y == 1)),cA_OtherBlockScore,cA_Data(:,3));
cA_OtherSimiBlockScore = cellfun(@(x, y) mean(x(y == 0)),cA_OtherBlockScore,cA_Data(:,3));

DifBlockInds = ~isnan(cA_OtherDifBlockScore);
DifBlockCom_selfScore = cA_SelfBlockScore(DifBlockInds);
DifBlockCom_otherScore = cA_OtherDifBlockScore(DifBlockInds);

SimBlockInds = ~isnan(cA_OtherSimiBlockScore);
SimBlockCom_selfScore = cA_SelfBlockScore(SimBlockInds);
SimBlockCom_otherScore = cA_OtherSimiBlockScore(SimBlockInds);

% DBScoreP = ranksum(DifBlockCom_selfScore,DifBlockCom_otherScore);
% if numel(SimBlockCom_selfScore) >= 5
%     SBScoreP = ranksum(SimBlockCom_selfScore,SimBlockCom_otherScore);
% else
%     SBScoreP = nan;
% end

[~,DBScore_P] = ttest2(DifBlockCom_selfScore,DifBlockCom_otherScore);
DBScorePower = sampsizepwr('t2',[mean(DifBlockCom_selfScore) std(DifBlockCom_selfScore)],...
    mean(DifBlockCom_otherScore),[],numel(DifBlockCom_selfScore));
if isnan(DBScorePower)
    fprintf('Nan values');
end
DBScoreP = [DBScore_P,DBScorePower];
if numel(SimBlockCom_selfScore) >= 5
    [~,SBScore_P] = ttest2(SimBlockCom_selfScore,SimBlockCom_otherScore);
    SBScorePower = sampsizepwr('t2',[mean(SimBlockCom_selfScore) std(SimBlockCom_selfScore)],...
        mean(SimBlockCom_otherScore),[],numel(SimBlockCom_selfScore));
    SBScoreP = [SBScore_P,SBScorePower];
else
    SBScoreP = [nan,nan];
end


BoxPlotData_x = [DifBlockCom_selfScore;DifBlockCom_otherScore;SimBlockCom_selfScore;SimBlockCom_otherScore];
BoxPlotData_GrInds = [ones(size(DifBlockCom_selfScore));ones(size(DifBlockCom_otherScore))+1;...
    ones(size(SimBlockCom_selfScore))+2;ones(size(SimBlockCom_otherScore))+3];
if ~isempty(SimBlockCom_selfScore)
    Grlabels = {sprintf('CVScore_%s',DataType),sprintf('DBscore_%s',DataType),...
        sprintf('CVScore2_%s',DataType),sprintf('SBscore_%s',DataType)};
else
    Grlabels = {sprintf('CVScore_%s',DataType),sprintf('DBscore_%s',DataType)};
end

