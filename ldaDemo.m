% trainSamples = [3  1; 
%            5  2;
%            1 -3;
%           -1 -5;
%            2 -3;
%            5 -5;];
%        
% trainClasses = {'1', '1', '2', '2', '3', '3'}; %try drawing samples and discriminant line!
% % [G,GN] = grp2idx(trainClasses);  % convert classes into index and corresponded unique classes in a cell vector
% %%
% testSamples = [14 15;
%               -8 -6];
%           
% testClasses = {'1', '2'};
%%
TrainInds = false(length(AllFreqvector),1);
TrainIndex = randsample(length(AllFreqvector),round(length(AllFreqvector)*0.8));
TrainInds(TrainIndex) = true;
TestInds = ~TrainInds;
trainSamples = DataAll(TrainInds,:);
trainClasses = AllFreqvector(TrainInds);
testSamples = DataAll(TestInds,:);
testClasses = AllFreqvector(TestInds);

%%
%************************* MultiClass LDA ***************************************

mLDA = LDA(trainSamples, trainClasses);
mLDA.Compute();
%%
%dimension of a samples is < (mLDA.NumberOfClasses-1) so following line cannot be executed:
%transformedSamples = mLDA.Transform(meas, mLDA.NumberOfClasses - 1);

transformedTrainSamples = mLDA.Transform(trainSamples, 2);
transformedTestSamples = mLDA.Transform(testSamples, 2);

h = figure('position',[230 230 1450 700]);
subplot(1,2,1)
gscatter(transformedTrainSamples(:,1),transformedTrainSamples(:,2),trainClasses);
title('Training data set');

subplot(1,2,2)
gscatter(transformedTestSamples(:,1),transformedTestSamples(:,2),testClasses);
title('Testing data set');

saveas(h,'LDA projection scatter plot');
saveas(h,'LDA projection scatter plot','png');
%************************* MultiClass LDA ***************************************
%%
calculatedClases = knnclassify(transformedTestSamples, transformedTrainSamples, trainClasses);
simmilarity = [];
if iscell(testClasses)
    for i = 1 : 1 : length(testClasses)
        similarity(i) = ( testClasses{i} == calculatedClases{i} );
    end
else
    for i = 1 : 1 : length(testClasses)
        similarity(i) = ( testClasses(i) == calculatedClases(i) );
    end
end

accuracy = sum(similarity) / length(testClasses);
fprintf('Testing: Accuracy is: %f %%\n', accuracy*100);