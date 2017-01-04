function [lsizeOUT,ltypeOUT] = nnet_L2(alldata,trainIND,testIND,runName,weightcost,varargin)

seed = 1234;

randn('state', seed );
rand('twister', seed+1 );


%you will NEVER need more than a few hundred epochs unless you are doing
%something very wrong.  Here 'epoch' means parameter update, not 'pass over
%the training set'.
maxepoch = 100;

indata = alldata(:,trainIND);
intest = alldata(:,testIND);

indata = indata(:,randperm(size(indata,2)));
outdata = indata;
intest = intest(:,randperm(size(intest,2)));
outtest = intest;

runDesc = ['seed = ' num2str(seed) 'd is reduced to PC scores with 95 of the variance' ];

%next try using autodamp = 0 for rho computation.  both for version 6 and
%versions with rho and cg-backtrack computed on the training set

if isempty(varargin)
    layersizes = [100 50 20 2 20 50 100];
else
    layersizes = varargin{1};
end
layertypes = {'tanh', 'tanh', 'tanh', 'linear', 'tanh','tanh', 'tanh', 'linear'};


resumeFile = [];

lsizeOUT = [size(alldata,1) layersizes size(alldata,1)];
ltypeOUT = layertypes;
ltypeOUT{find(layersizes == min(layersizes))} = 'linearSTORE';

paramsp = [];
Win = [];
bin = [];
%[Win, bin] = loadPretrainedNet_curves;

numchunks = 4;
numchunks_test = 1;

mattype = 'gn'; %Gauss-Newton.  The other choices probably won't work for whatever you're doing
%mattype = 'hess';
%mattype = 'empfish';

rms = 0;

hybridmode = 1;

%decay = 1.0;
decay = 0.95;

%jacket = 0;
%this enables Jacket mode for the GPU
jacket = 1;

errtype = 'L2'; %report the L2-norm error (in addition to the quantity actually being optimized, i.e. the log-likelihood)


nnet_train_2( runName, runDesc, paramsp, Win, bin, resumeFile, maxepoch, indata, outdata, numchunks, intest, outtest, numchunks_test, layersizes, layertypes, mattype, rms, errtype, hybridmode, weightcost, decay, jacket);
