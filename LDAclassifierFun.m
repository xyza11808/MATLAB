function [DisScore,LDA_Accuracy,PredClassLabels,beta] = ...
    LDAclassifierFun(X, y, varargin)
% function used for LDA classifier analysis, return the decoding accuracy
% and discrimination scores


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
    TrainIndex = randsample(NumofTotalDatas,round(NumofTotalDatas*0.7));
    TrainInds = false(NumofTotalDatas,1);
    TrainInds(TrainIndex) = true;
    TestInds = ~TrainInds;
end
% DataMtx = rand(100,25);
% TrainLabels = double(rand(100,1) > 0.5);
% TestData = rand(24,25);

[Alluniqlabel,~,Alltruelabels] = unique(y);
DataMtx = X(TrainInds,:);
TrainLabels = Alltruelabels(TrainInds);
TestData = X(TestInds,:);
TestLabels = Alltruelabels(TestInds);
%%
% ref from : https://www.youtube.com/watch?v=moqPyJQHR_s

NumberLabels = length(Alluniqlabel);
if NumberLabels > 2
    warning('Currently cannot handled with class more than 2 (%d)',NumberLabels);
    return;
end

C1DataInds = TrainLabels == 1;
C2DataInds = TrainLabels == 2;

C1_SampleNum = sum(C1DataInds);
C2_SampleNum = sum(C2DataInds);

C1_rawData = DataMtx(C1DataInds,:);
C2_rawData = DataMtx(C2DataInds,:);

C1_Avg = mean(C1_rawData);
C2_Avg = mean(C2_rawData);

C1_cov = cov(C1_rawData);
C2_cov = cov(C2_rawData);

MtxStableTerm = 1e-6; % served to stabilize matrix inversion
pooled_cov = (C1_SampleNum*C1_cov + C2_SampleNum*C2_cov)/(C1_SampleNum + C2_SampleNum);
pooled_cov = pooled_cov + eye(size(pooled_cov))*MtxStableTerm; 
% pooled_cov = (C1_cov + C2_cov)/2;

beta = (pooled_cov)\((C1_Avg - C2_Avg))'; % hyperplane normal to beta is the classification hyperplane

% similar to number of standard distance, a value of 3 indicates the mean
% differ by 3 standard deviations. the larger value, the smaller overlaps
% D_sqr = beta' * ((C1_Avg - C2_Avg))'; % effectiveness of the discrimination, or the Mahalanobis distance between groups
D_sqr = (beta' * ((C1_Avg - C2_Avg))')^2/(beta' * (C1_cov+C2_cov)/2 * beta)'; % another method from: https://www.nature.com/articles/s41586-022-04724-y#Sec8
% fprintf('The discrimination distance is %.3f.\n',D_sqr);

TrainScores = (DataMtx - (C1_Avg + C2_Avg)/2)*beta;  % training data score, sign indicates class label
ClassBoundScore = log(C1_SampleNum/C2_SampleNum);

Trainc1_scoreInds = TrainScores > ClassBoundScore;
TrainClassLabels = nan(numel(TrainLabels),1);
TrainClassLabels(Trainc1_scoreInds) = 1;
TrainClassLabels(~Trainc1_scoreInds) = 2;
TrainPerfAccu = mean(TrainLabels == TrainClassLabels)*100;
%% predict new data points
NumTestPoints = size(TestData,1);
NewPredScore = (TestData - (C1_Avg + C2_Avg)/2)*beta;  % output score, sign indicates class label

if iscell(Alluniqlabel(1))
    PredClassLabels = cell(NumTestPoints, 1);
else
    PredClassLabels = nan(NumTestPoints, 1);
end
Abovec1_scoreInds = NewPredScore > ClassBoundScore;
PredClassLabels(Abovec1_scoreInds) = Alluniqlabel(1);
PredClassLabels(~Abovec1_scoreInds) = Alluniqlabel(2);

% [Tuniqlabel,~,Ttruelabels] = unique(TestLabels);
C1_data_test = TestData(TestLabels == 1,:);
C2_data_test = TestData(TestLabels == 2,:);

C1_Avg_test = mean(C1_data_test);
C2_Avg_test = mean(C2_data_test);

C1_cov_test = cov(C1_data_test);
C2_cov_test = cov(C2_data_test);

Cov_test_Avg = (C1_cov_test + C2_cov_test)/2;

% test data discrimination ability
d_opt_sqr = (((C1_Avg_test - C2_Avg_test)/2) * beta).^2/(beta' * Cov_test_Avg * beta);

% fprintf('TestData discrimination distance is %.3f.\n',d_opt_sqr);

if iscell(Alluniqlabel(1))
    PredPerfs = cellfun(@(x,y) strcmpi(x,y),PredClassLabels,Alluniqlabel(TestLabels));
else
    PredPerfs = PredClassLabels == Alluniqlabel(TestLabels);
end
% fprintf('The prediction accuracy is %.2f%%.\n',mean(PredPerfs)*100);
PredAccuracy = mean(PredPerfs)*100;
DisScore = [D_sqr, d_opt_sqr];

LDA_Accuracy = [TrainPerfAccu, PredAccuracy];



