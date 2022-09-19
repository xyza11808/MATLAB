

RevTrFreqs_test = NMTrFreqsAll(NMRevFreqInds);
NonRevTrfreqs_train = NMTrFreqsAll(NonRevFreqInds);

TrainANDtestScore = [SampleScores{1};SampleScores{2}];
TrainANDtestFreqs = [NonRevTrfreqs_train;RevTrFreqs_test];
TrainANDtestBTs = [NMBlockTypes(NonRevFreqInds);NMBlockTypes(NMRevFreqInds)];

FreqTypes = unique(NMTrFreqsAll);
FreqType2Octs = log2(FreqTypes/FreqTypes(1));
FreqTypeNum = length(FreqTypes);
FreqTypeScores = zeros(FreqTypeNum,3,2);
for cF = 1 : FreqTypeNum
    cf_inds = TrainANDtestFreqs == FreqTypes(cF) & TrainANDtestBTs == 0;
    cf_Scores = TrainANDtestScore(cf_inds);
    FreqTypeScores(cF,:,1) = [mean(cf_Scores),std(cf_Scores)/sqrt(numel(cf_Scores)),numel(cf_Scores)];
    
    cf_inds2 = TrainANDtestFreqs == FreqTypes(cF) & TrainANDtestBTs == 1;
    cf_Scores2 = TrainANDtestScore(cf_inds2);
    FreqTypeScores(cF,:,2) = [mean(cf_Scores2),std(cf_Scores2)/sqrt(numel(cf_Scores2)),numel(cf_Scores2)];
    
end

figure;
errorbar(FreqType2Octs,-FreqTypeScores(:,1,1),FreqTypeScores(:,2,1),'g-o','linewidth',1.2)
hold on;
errorbar(FreqType2Octs,-FreqTypeScores(:,1,2),FreqTypeScores(:,2,2),'y-o','linewidth',1.2)
%
RawRespScores = [NRevTrChoiceScores;RevTrChoiceScores];
FreqTypeNum = length(FreqTypes);
FreqTypeScoresRaw = zeros(FreqTypeNum,3,2);
for cF = 1 : FreqTypeNum
    cf_inds = TrainANDtestFreqs == FreqTypes(cF) & TrainANDtestBTs == 0;
    cf_Scores = RawRespScores(cf_inds);
    FreqTypeScoresRaw(cF,:,1) = [mean(cf_Scores),std(cf_Scores)/sqrt(numel(cf_Scores)),numel(cf_Scores)];
    
    cf_inds2 = TrainANDtestFreqs == FreqTypes(cF) & TrainANDtestBTs == 1;
    cf_Scores2 = RawRespScores(cf_inds2);
    FreqTypeScoresRaw(cF,:,2) = [mean(cf_Scores2),std(cf_Scores2)/sqrt(numel(cf_Scores2)),numel(cf_Scores2)];
    
end

errorbar(FreqType2Octs,-FreqTypeScoresRaw(:,1,1),FreqTypeScoresRaw(:,2,1),'b-o','linewidth',1.2)

errorbar(FreqType2Octs,-FreqTypeScoresRaw(:,1,2),FreqTypeScoresRaw(:,2,2),'m-o','linewidth',1.2)

%% baseline project to choice plot, frequency wise
FreqTypeScores_BT2C = zeros(FreqTypeNum,3,2);
for cF = 1 : FreqTypeNum
    cf_inds = NMTrFreqsAll == FreqTypes(cF) & NMBlockTypes == 0;
    cf_Scores = TrBaseScores(cf_inds);
    FreqTypeScores_BT2C(cF,:,1) = [mean(cf_Scores),std(cf_Scores)/sqrt(numel(cf_Scores)),numel(cf_Scores)];
    
    cf_inds2 = NMTrFreqsAll == FreqTypes(cF) & NMBlockTypes == 1;
    cf_Scores2 = TrBaseScores(cf_inds2);
    FreqTypeScores_BT2C(cF,:,2) = [mean(cf_Scores2),std(cf_Scores2)/sqrt(numel(cf_Scores2)),numel(cf_Scores2)];
    
end

figure;
hold on
errorbar(FreqType2Octs,-FreqTypeScores_BT2C(:,1,1),FreqTypeScores_BT2C(:,2,1),'g-o','linewidth',1.2)

errorbar(FreqType2Octs,-FreqTypeScores_BT2C(:,1,2),FreqTypeScores_BT2C(:,2,2),'y-o','linewidth',1.2)


