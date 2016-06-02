%% Specify Prior Probabilites When Training Naive Bayes Classifiers
% Construct a naive Bayes classifier for Fisher's iris data set. Also, specify
% prior probabilities during training.
%%
% Load Fisher's iris data set.

% Copyright 2015 The MathWorks, Inc.

load fisheriris
X = meas;
Y = species;
classNames = {'setosa','versicolor','virginica'}; % Class order 
%%
% |X| is a numeric matrix that contains four petal measurements for 150
% irises.  |Y| is a cell array of strings that contains the corresponding
% iris species.
%%
% By default, the prior class probability distribution is the relative
% frequency distribution of the classes in the data set, which in this case
% is 33% for each species.  However, suppose you know that in the
% population 50% of the irises are setosa, 20% are versicolor, and 30% are
% virginica.  You can incorporate this information by specifying this
% distribution as a prior probability during training.
%%
% Train a naive Bayes classifier.  Specify the class order and
% prior class probability distribution.
prior = [0.5 0.2 0.3];
Mdl = fitcnb(X,Y,'ClassNames',classNames,'Prior',prior)
%%
% |Mdl| is a trained |ClassificationNaiveBayes| classifier, and some of its
% properties appear in the Command Window.  The software treats the
% predictors as independent given a class, and, by default, fits them using
% normal distributions.
%%
% The naive Bayes algorithm does not use the prior class probabilities
% during training.  Therefore, you can specify prior class probabilities
% after training using dot notation.  For example, suppose that you want to
% see the difference in performance between a model that uses the 
% default prior class probabilities and a model that uses |prior|.
%%
% Create a new naive Bayes model based on |Mdl|, and specify that the
% prior class probability distribution is an empirical class distribution.
defaultPriorMdl = Mdl;
FreqDist = cell2table(tabulate(Y));
defaultPriorMdl.Prior = FreqDist{:,3};
%%
% The software normalizes the prior class probabilities to sum to |1|.
%%
% Estimate the cross-validation error for both models using 10-fold cross
% validation.
rng(1); % For reproducibility
defaultCVMdl = crossval(defaultPriorMdl);
defaultLoss = kfoldLoss(defaultCVMdl)
CVMdl = crossval(Mdl);
Loss = kfoldLoss(CVMdl)
%%
% |Mdl| performs better than |defaultPriorMdl|.


