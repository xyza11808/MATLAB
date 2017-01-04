function [lsizeOUT,ltypeOUT] = nnet_classify_cvalidate(alldata,alllabels,runName,testBlock)
seed = 1234;

randn('state', seed );
rand('twister', seed+1 );


%you will NEVER need more than a few hundred epochs unless you are doing
%something very wrong.  Here 'epoch' means parameter update, not 'pass over
%the training set'.
maxepoch = 40;


%CURVES
%%%%%%%%%%%%%%%%%
%this dataset (by Ruslan Salakhutdinov) is available here: http://www.cs.toronto.edu/~jmartens/digs3pts_1.mat

% tmp = load('digs3pts_1.mat');
% indata = tmp.bdata';
% %outdata = tmp.bdata;
% intest = tmp.bdatatest';
% %outtest = tmp.bdatatest;
% clear tmp
% 
% perm = randperm(size(indata,2));
% indata = indata( :, perm );

%it's an auto-encoder so output is input
% outdata = indata;
% outtest = intest;
%runName = 'HFb10_04122013';
trainBlock = (1:size(alldata,2));
trainBlock = trainBlock(~ismember(trainBlock,testBlock));
intest = alldata(:,testBlock);
outtest = alllabels(:,testBlock);
indata = alldata(:,trainBlock);
outdata = alllabels(:,trainBlock);


runDesc = ['seed = ' num2str(seed) 'd is reduced to PC scores with 95 of the variance' ];

%next try using autodamp = 0 for rho computation.  both for version 6 and
%versions with rho and cg-backtrack computed on the training set


layersizes = [100];
layertypes = {'logistic', 'logistic'};

% layersizes = [150 75 40 20 2 20 40 75 150];
% layertypes = {'logistic', 'logistic', 'logistic', 'logistic', 'linear', 'logistic', 'logistic', 'logistic', 'logistic', 'linear'};


resumeFile = [];

lsizeOUT = [size(alldata,1) layersizes size(alllabels,1)];
ltypeOUT = layertypes;
%ltypeOUT{find(layersizes == min(layersizes))} = 'linearSTORE';

paramsp = [];
Win = [];
bin = [];
%[Win, bin] = loadPretrainedNet_curves;

numchunks = 5;
goodChunks = mod(length(trainBlock),numchunks);

while goodChunks ~= 0
numchunks = numchunks - 1;
goodChunks = mod(length(trainBlock),numchunks),
end



numchunks_test = 1;

mattype = 'gn'; %Gauss-Newton.  The other choices probably won't work for whatever you're doing
%mattype = 'hess';
%mattype = 'empfish';

rms = 0;

hybridmode = 1;

%decay = 1.0;
decay = 0.95;

jacket = 0;
%this enables Jacket mode for the GPU
%jacket = 1;

errtype = 'L2'; %report the L2-norm error (in addition to the quantity actually being optimized, i.e. the log-likelihood)

%standard L_2 weight-decay:
weightcost = 2e-5;
%weightcost = 0
%weightcost = 2e-6;

nnet_train_2( runName, runDesc, paramsp, Win, bin, resumeFile, maxepoch, indata, outdata, numchunks, intest, outtest, numchunks_test, layersizes, layertypes, mattype, rms, errtype, hybridmode, weightcost, decay, jacket);
