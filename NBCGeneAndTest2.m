function p_cGivenf = NBCGeneAndTest2(TrainingSet,TrainingC,TestingSet,TestFreq,varargin)
% TrainingC is a two columns matrix, first column corresponded to left-right trial
% types, second column corresponded to trial stimulus

% DensityFun = 'normal';
% if nargin > 3
%     if isempty(varargin{1})
%         DensityFun = varargin{1};
%     end
% end
TrialChoice = TrainingC(:,2);
TrialStim = TrainingC(:,1);
NumFreq = unique(TrialStim); % frequency types number
numChoice = unique(TrialChoice); %animal choice type, basically just left or right
nROIs = size(TrainingSet,2);
%%
% pre-processing
% population response prob
% PopuRespPara = ([mean(TrainingSet);std(TrainingSet)])'; % nROI by 2 matrix, first column is summarized mean, second column is summarized std
PopuCovMatrix = cov(TrainingSet); % nROI-by-nROI covariance matrix

% Choice type probability
ChoiceInds = cell(length(numChoice),1);
CHoiceProb = zeros(1,length(numChoice));
ChoiceProbPara = cell(length(numChoice),1);
ChoiceMu = zeros(length(numChoice),nROIs);
% ChoiceSigma = zeros(nROIs,length(numChoice));
for nn = 1 : length(numChoice)
    ChoiceInds{nn} = TrialChoice == numChoice(nn);
    CHoiceProb(nn) = sum(ChoiceInds{nn})/length(TrialChoice);
    ChoiceData = TrainingSet(ChoiceInds{nn},:);
    ChoiceRespMean = mean(ChoiceData);
    ChoiceRespstd = std(ChoiceData);
    ChoiceProbPara{nn} = [ChoiceRespMean;ChoiceRespstd];
    ChoiceMu(nn,:) = ChoiceRespMean;
%     ChoiceSigma(:,nn) = ChoiceRespstd;
end
% MatrixForPopuMean = repmat(ChoiceMu,nROIs,1);
% MatrixForPopuStd = repmat(ChoiceSigma,nROIs,1);
% p_MatrixClass = repmat(CHoiceProb,nROIs,1);
%%
% frequency type probability
FreqInds = cell(length(NumFreq),1);
FreqProb = zeros(length(NumFreq),1);
% DataDisParameter = cell(length(NumFreq),1);  % assuming a gaussian distribution for cell response
FreqClassMean = zeros(length(NumFreq),nROIs);
% AllROIstd = zeros(nROIs,length(NumFreq));
for nm = 1 : length(NumFreq)
    FreqInds{nm} = TrialStim == NumFreq(nm);
    FreqProb(nm) = sum(FreqInds{nm})/length(TrialStim);
    AllROIResp = TrainingSet(FreqInds{nm},:); % two dimensional matrix, with only mean and std meaningful for distribution analysis
    AllROIMean = mean(AllROIResp);
%     AllROIstd = std(AllROIResp);
%     DataDisParameter{nm} = [AllROIMean;AllROIstd]; %parameters for gaussian distribution, each column corresponded to a ROI
    FreqClassMean(nm,:) = AllROIMean;
end

%%
% calculate the population probability using multivariate gaussian
% distribution
% calculate p(c|x) = p(x|c) * p(c)/p(x)
% p(x) = sum(p(x,ci)) = p(x|c1)*p(c1) + p(x|c2)*p(c2) + ...
% p(x|f) and p(x|c) will all be considered as multivariate gaussian
% distribution
nTTr = size(TestingSet,1);
% TestingSet = TestingSet'; % nROI by nTrials
ProbSummaryTypeClass = zeros(nTTr,length(numChoice));
ProbSummaryFreqClass = zeros(nTTr,1);
p_cGivenf = zeros(nTTr,length(numChoice));
% p_cGivenfNor = zeros(nTTr,length(numChoice),length(NumFreq));
% p_cGivenfSumNor = zeros(nTTr,length(numChoice),length(NumFreq));
p_cGivenx_all = zeros(nTTr,length(numChoice));
for nttr = 1 : nTTr
    % for each test trial, calculate following values
    cTestTrial = TestingSet(nttr,:);
    cTestFreq = TestFreq(nttr);
    
    % calculate p(x)
    for nnh = 1 : length(numChoice)
        p_xGivenC = mvncdf(cTestTrial,ChoiceMu(nnh,:),PopuCovMatrix);
        ProbSummaryTypeClass(nttr,nnh) = p_xGivenC * CHoiceProb(nnh);  % p_xGivenC * p_c
    end
    p_cGivenx_all(nttr,:) = ProbSummaryTypeClass(nttr,:)/sum(ProbSummaryTypeClass(nttr,:));
    
    % each test trial will only have one frequency distributions
    % correct the code after correct this
    
    % calculate p(x|f)
    cFreqInds = NumFreq == cTestFreq;
%     for nfreqs = 1 : length(NumFreq)
        p_xGivenf = mvncdf(cTestTrial,FreqClassMean(cFreqInds,:),PopuCovMatrix);
        ProbSummaryFreqClass(nttr) = p_xGivenf;
%     end
    
    % calculate p(c|f)
    for njk = 1 : length(numChoice)
        cClassProb = p_cGivenx_all(nttr,njk);
        p_cGivenf(nttr,njk) = cClassProb .* ProbSummaryFreqClass(nttr);
%         p_cGivenfNor(nttr,njk,:) = p_cGivenf(nttr,njk,:)/max(p_cGivenf(nttr,njk,:));
%         p_cGivenfSumNor(nttr,njk,:) = p_cGivenf(nttr,njk,:)/sum(p_cGivenf(nttr,njk,:));
    end
    
end
% ###########################
% the final result should be the sum of p_cGivenf at the first dimension?
% ###########################

% %%
% %calculate the posterior probability for test data set
% % calculate p(c|x) = p(x|c) * p(c)/p(x)
% nTTr = size(TestingSet,1);
% TestingSet = TestingSet'; % nROI by nTrials
% pSummary = zeros(nTTr,length(numChoice),length(NumFreq));
% for nh = 1 : length(numChoice)
%     cChoiceDis = (ChoiceProbPara{nh})'; % two columns matrix
%     for nt = 1 : nTTr
%         p_xGivenc = normcdf(TestingSet(:,nt),cChoiceDis(:,1),cChoiceDis(:,2)); %supposed to be a nROI by 1 vector of probability
%         p_c = CHoiceProb(nh);
%         p_x = sum(normcdf(repmat(TestingSet(:,nt),1,length(numChoice)),ChoiceMu,ChoiceSigma).*p_MatrixClass,2);
%         p_cGivenx = p_xGivenc * p_c./ p_x;
%         % calculate the posterior prob p(x|f)
%         for nf = 1 : length(NumFreq)
%             cFreqDisPara = (DataDisParameter{nf})';
%             p_xGivenf = normcdf(TestingSet(:,nt),cFreqDisPara(:,1),cFreqDisPara(:,2));
%             p_cGivenf = sum(p_cGivenx .* p_xGivenf);
%             pSummary(nt,nh,nf) = p_cGivenf;
%         end
%     end
% end