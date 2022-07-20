
load fisheriris
inds = ~strcmp(species,'setosa');
X = meas(inds,3:4);
y = species(inds);

%%
NumofTotalDatas = length(y);
TrainIndex = randsample(NumofTotalDatas,round(NumofTotalDatas*0.7));
TrainInds = false(NumofTotalDatas,1);
TrainInds(TrainIndex) = true;
TestInds = ~TrainInds;

% DataMtx = rand(100,25);
% TrainLabels = double(rand(100,1) > 0.5);
% TestData = rand(24,25);
DataMtx = X(TrainInds,:);
TrainLabels = y(TrainInds);
TestData = X(TestInds,:);
TestLabels = y(TestInds);
%%
% ref from : https://www.youtube.com/watch?v=moqPyJQHR_s

[uniqlabel,~,truelabels] = unique(TrainLabels);
NumberLabels = length(uniqlabel);
if NumberLabels > 2
    warning('Currently cannot handled with class more than 2 (%d)',NumberLabels);
    return;
end

C1DataInds = truelabels == 1;
C2DataInds = truelabels == 2;

C1_SampleNum = sum(C1DataInds);
C2_SampleNum = sum(C2DataInds);

C1_rawData = DataMtx(C1DataInds,:);
C2_rawData = DataMtx(C2DataInds,:);

C1_Avg = mean(C1_rawData);
C2_Avg = mean(C2_rawData);

C1_cov = cov(C1_rawData);
C2_cov = cov(C2_rawData);

pooled_cov = (C1_SampleNum*C1_cov + C2_SampleNum*C2_cov)/(C1_SampleNum + C2_SampleNum);
% pooled_cov = (C1_cov + C2_cov)/2;

beta = inv(pooled_cov)*((C1_Avg - C2_Avg))';

% similar to number of standard distance, a value of 3 indicates the mean
% differ by 3 standard deviations. the larger value, the smaller overlaps
D_sqr = beta' * ((C1_Avg - C2_Avg))'; % effectiveness of the discrimination, or the Mahalanobis distance between groups

fprintf('The discrimination distance is %.3f.\n',D_sqr);

%% predict new data points
NumTestPoints = size(TestData,1);
NewPredScore = (TestData - (C1_Avg + C2_Avg)/2)*beta;  % output score
ClassBoundScore = log(C1_SampleNum/C1_SampleNum);
if iscell(TrainLabels(1))
    ClassLabels = cell(NumTestPoints, 1);
else
    ClassLabels = nan(NumTestPoints, 1);
end
Abovec1_scoreInds = NewPredScore > ClassBoundScore;
ClassLabels(Abovec1_scoreInds) = uniqlabel(1);
ClassLabels(~Abovec1_scoreInds) = uniqlabel(2);


if iscell(TrainLabels(1))
    PredPerfs = cellfun(@(x,y) strcmpi(x,y),ClassLabels,TestLabels);
else
    PredPerfs = ClassLabels == TestLabels;
end
fprintf('The prediction accuracy is %.2f%%.\n',mean(PredPerfs)*100);







