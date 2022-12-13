function varargout = ...
    LDAclassifierFun_3d(X, y, varargin)
% default outputs: [DisScore,LDA_Accuracy,TrainANDtestScores,beta]
% if output number is larger than 4, the fifth output is ShufScores

% function used for LDA classifier analysis, return the decoding accuracy
% and discrimination scores
% the labels must be 1 or 2, arbitory binary labels could be convert to
% these values using unique function

% load fisheriris
% inds = ~strcmp(species,'setosa');
% X = meas(inds,3:4);
% y = species(inds);

%%
IsPartitionIndsGiven = 0;
if nargin > 2 % check whether partition inds is given
    if ~isempty(varargin{1})
        IsPartitionIndsGiven = 1;
        TrainInds = varargin{1}{1};
        TestInds = varargin{1}{2};
    end
end
if ~IsPartitionIndsGiven
    NumofTotalDatas = length(y);
    % uniform labels into numbers
    TrainIndex = randsample(NumofTotalDatas,round(NumofTotalDatas*0.8));
    TrainInds = false(NumofTotalDatas,1);
    TrainInds(TrainIndex) = true;
    TestInds = ~TrainInds;
end


% DataMtx = rand(100,25);
% TrainLabels = double(rand(100,1) > 0.5);
% TestData = rand(24,25);

% [Alluniqlabel,~,Alltruelabels] = unique(y);
Alltruelabels = y(:);
DataMtx = X(TrainInds,:,:);
TrainLabels = Alltruelabels(TrainInds);
TestData = X(TestInds,:,:);
TestLabels = Alltruelabels(TestInds);
%%
% ref from : https://www.youtube.com/watch?v=moqPyJQHR_s

% NumberLabels = length(Alluniqlabel);
% if NumberLabels > 2
%     warning('Currently cannot handled with class more than 2 (%d)',NumberLabels);
%     return;
% end

C1DataInds = TrainLabels == 1;
C2DataInds = TrainLabels == 2;

C1_SampleNum = sum(C1DataInds);
C2_SampleNum = sum(C2DataInds);

DataMtxPermute = permute(DataMtx,[2,3,1]);
C1_rawData = DataMtxPermute(:,:,C1DataInds);
C2_rawData = DataMtxPermute(:,:,C2DataInds);
C1_Avg = sum(C1_rawData,3)/size(C1_rawData,3);
C2_Avg = sum(C2_rawData,3)/size(C2_rawData,3);
% C1_Avg_noPer = sum(DataMtx)/size(C1_rawData,1);
% C2_Avg_noPer = sum(DataMtx)/size(C1_rawData,1);
C1_rawData_noPermute = DataMtx(C1DataInds,:,:);
C2_rawData_noPermute = DataMtx(C2DataInds,:,:);
[NumTrainTrials,NumUnits,NumTimeBins] = size(DataMtx);
C1_cov = zeros(NumUnits,NumUnits,NumTimeBins);
C2_cov = zeros(NumUnits,NumUnits,NumTimeBins);
for cTimeBin = 1 : NumTimeBins
    C1_cov(:,:,cTimeBin) = cov_cus(C1_rawData_noPermute(:,:,cTimeBin),[C1_SampleNum,NumUnits]);
    C2_cov(:,:,cTimeBin) = cov_cus(C2_rawData_noPermute(:,:,cTimeBin),[C2_SampleNum,NumUnits]);
end
% C1_rawData = DataMtx(C1DataInds,:,:);
% C2_rawData = DataMtx(C2DataInds,:,:);

% C1_Avg = sum(C1_rawData)/size(C1_rawData,1);
% C2_Avg = sum(C2_rawData)/size(C2_rawData,1);
% 
% C1_cov = cov(C1_rawData);
% C2_cov = cov(C2_rawData);
%%
MtxStableTerm = 1e-8; %1e-6; % served to stabilize matrix inversion
pooled_cov = (C1_SampleNum*C1_cov + C2_SampleNum*C2_cov)/(C1_SampleNum + C2_SampleNum);
beta = zeros(NumUnits,NumTimeBins);
% D_sqr = zeros(1,NumTimeBins);
for cTimeBin = 1 : NumTimeBins
    pooled_cov(:,:,cTimeBin) = pooled_cov(:,:,cTimeBin) + eye(NumUnits)*MtxStableTerm; 
    beta(:,cTimeBin) = (pooled_cov(:,:,cTimeBin))\((C1_Avg(:,cTimeBin) - C2_Avg(:,cTimeBin))); % hyperplane normal to beta is the classification hyperplane
%     D_sqr(cTimeBin) = beta(:,cTimeBin)' * (C1_Avg(:,cTimeBin) - C2_Avg(:,cTimeBin));
% pooled_cov = (C1_cov + C2_cov)/2;
end
%%
% similar to number of standard distance, a value of 3 indicates the mean
% differ by 3 standard deviations. the larger value, the smaller overlaps
D_sqr = diag(beta' * ((C1_Avg - C2_Avg))); % effectiveness of the discrimination, or the Mahalanobis distance between groups
% D_sqr = (beta' * ((C1_Avg - C2_Avg))')^2/(beta' * (C1_cov+C2_cov)/2 * beta)'; % another method from: https://www.nature.com/articles/s41586-022-04724-y#Sec8
% fprintf('The discrimination distance is %.3f.\n',D_sqr);
%%
NumTestPoints = size(TestData,1);
TrainScores = zeros(NumTrainTrials, NumTimeBins);
testPredScore = zeros(NumTestPoints, NumTimeBins);
for cBin = 1 : NumTimeBins
    TrainScores(:,cBin) = (DataMtx(:,:,cBin) - (C1_Avg(:,cBin)+C2_Avg(:,cBin))'/2)*beta(:,cBin);
    testPredScore(:,cBin) = (TestData(:,:,cBin) - (C1_Avg(:,cBin)+C2_Avg(:,cBin))'/2)*beta(:,cBin);
end
% TrainScores = (DataMtx - repmat((C1_Avg_noPer + C2_Avg_noPer)/2,NumAllTrials,1,1))*beta;  % training data score, sign indicates class label
% ClassBoundScore = log(C1_SampleNum/C2_SampleNum);
ClassBoundScore = 0; % the real prior is 0, although in reality there could be different
%%
Trainc1_scoreInds = TrainScores > ClassBoundScore;
NumTrainLabels = NumTrainTrials; %numel(TrainLabels);
TrainClassLabels = nan(size(TrainScores));
TrainClassLabels(Trainc1_scoreInds) = 1;
TrainClassLabels(~Trainc1_scoreInds) = 2;
TrainPerfAccu = sum(repmat(TrainLabels,1,NumTimeBins) == TrainClassLabels)/NumTrainLabels*100;
%% predict new data points
% NumTestPoints = size(TestData,1);
% NewPredScore = (TestData - (C1_Avg + C2_Avg)/2)*beta;  % output score, sign indicates class label

% if iscell(Alluniqlabel(1))
%     PredClassLabels = cell(NumTestPoints, 1);
% else
    PredClassLabels = nan(size(testPredScore));
% end
Abovec1_scoreInds = testPredScore > ClassBoundScore;
PredClassLabels(Abovec1_scoreInds) = 1;
PredClassLabels(~Abovec1_scoreInds) = 2;

% [Tuniqlabel,~,Ttruelabels] = unique(TestLabels);
C1_data_test = TestData(TestLabels == 1,:,:);
C2_data_test = TestData(TestLabels == 2,:,:);

C1_testNum = sum(TestLabels == 1);
C2_testNum = sum(TestLabels == 2);

C1_Avg_test = squeeze(sum(C1_data_test)/size(C1_data_test,1));
C2_Avg_test = squeeze(sum(C2_data_test)/size(C2_data_test,1));
if NumUnits == 1
    C1_Avg_test = C1_Avg_test';
    C2_Avg_test = C2_Avg_test';
end
C1_cov_test = zeros(NumUnits,NumUnits,NumTimeBins);
C2_cov_test = zeros(NumUnits,NumUnits,NumTimeBins);
for cTimeBin = 1 : NumTimeBins
    C1_cov_test(:,:,cTimeBin) = cov_cus(C1_data_test(:,:,cTimeBin),[C1_testNum NumUnits]);
    C2_cov_test(:,:,cTimeBin) = cov_cus(C2_data_test(:,:,cTimeBin),[C2_testNum NumUnits]);
end
% C1_cov_test = cov(C1_data_test);
% C2_cov_test = cov(C2_data_test);

Cov_test_Avg = (C1_cov_test + C2_cov_test)/2;

% test data discrimination ability
d_opt_sqr = zeros(NumTimeBins,1);
for cBin = 1 : NumTimeBins
    d_opt_sqr(cBin) = ((C1_Avg_test(:,cBin) - C2_Avg_test(:,cBin))' * beta(:,cBin)).^2/(beta(:,cBin)' * Cov_test_Avg(:,:,cBin) * beta(:,cBin));
end
% d_opt_sqr = (C1_Avg_test - C2_Avg_test) * beta;

% fprintf('TestData discrimination distance is %.3f.\n',d_opt_sqr);

% if iscell(Alluniqlabel(1))
%     PredPerfs = cellfun(@(x,y) strcmpi(x,y),PredClassLabels,Alluniqlabel(TestLabels));
% else
%     PredPerfs = PredClassLabels == Alluniqlabel(TestLabels);
% end
% fprintf('The prediction accuracy is %.2f%%.\n',mean(PredPerfs)*100);
PredPerfs = PredClassLabels == repmat(TestLabels,1,NumTimeBins);
PredAccuracy = sum(PredPerfs)/numel(TestLabels)*100;
DisScore = [D_sqr, d_opt_sqr];

LDA_Accuracy = [TrainPerfAccu', PredAccuracy'];

TrainANDtestScores = {TrainScores,testPredScore,ClassBoundScore,PredClassLabels};

if nargout == 4
    varargout = {DisScore,LDA_Accuracy,TrainANDtestScores,beta};
end