% different from BP_test_scripts.m, using minibatch method for large data
% set

clear
clc
[X,T] = simpleclass_dataset;
xData = X;
yData = T;
%%
xData = [1,0,0,0;0,1,0,0;0,0,0,1;0,0,0,1;1,1,0,0;0,0,1,1];
xData = xData';
yData = [1,0,0;0,1,0;0,0,1;0,1,0;1,0,0;0,1,0];
yData = yData';
xData = xData(:,1:3);
yData = yData(:,1:3);
% %%
% xData = ([1,1,0,0])';
% yData = ([1,0])';
%%
clear
clc
cd('P:\THBI\DataSet');
TestIm = loadMNISTImages('t10k-images.idx3-ubyte');
TestLabel = loadMNISTLabels('t10k-labels.idx1-ubyte');
TrainIM = loadMNISTImages('train-images.idx3-ubyte');
TrainLabel = loadMNISTLabels('train-labels.idx1-ubyte'); 
xData = TrainIM;
yLabelData = TrainLabel';

yData = double(repmat((0:9)',1,size(yLabelData,2)) == repmat(yLabelData,10,1));

xData = xData(:,1:5000);
yData = yData(:,1:5000);

%%
clearvars -except xData yData
HidNodesNum = [21];
nHiddenLayer = length(HidNodesNum); % hidden layers
nLearnRate = 0.7;
InputData = xData; % rows as number of observation, columns as number of samples

Inputvariables = sum(InputData,2);
RawInputData = InputData;
EmptyInputData = Inputvariables < 1e-16;
InputData = InputData(~EmptyInputData,:);
% InputData = rand(10,1);
% InputData = (TrainData(1,:))';
nInputNodes = size(InputData,1); % input nodes
% OutputData = TrainOutPutData(:,1);
% OutputData = [1,0];
OutputData = yData;
nOutputNodes = size(OutputData,1);
nSamples = size(InputData,2);  % samples to be trained
nHidNodesNum = [HidNodesNum,nOutputNodes];
nNetNodes = [nInputNodes,HidNodesNum,nOutputNodes];

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation

%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
LearnRate = [];
%
nSamples = size(InputData,2); 
nTotalSample = nSamples;
MiniBatchNums = nSamples;
IsMiniBatch = 0;
if nSamples > 500 && IsMiniBatch
    MiniRatio = 0.005;
%     MiniBatchNums = round(nSamples*MiniRatio);
    MiniBatchNums = 100;
    IsMiniBatch = 1;
    nSamples = MiniBatchNums;
end

%%
% initial weights for each hidden layer nodes
InputLayerW = rand(nInputNodes,nHidNodesNum(1));
HiddenLayerNodeW = cell(nHiddenLayer+1,1);
LayerActValue = cell(nHiddenLayer+1,1);
LayerOutValue = cell(nHiddenLayer+1,1);
DeltaJNodesData = cell(nHiddenLayer+1,1);
HiddenLBias = cell(nHiddenLayer+1,1);
WeightsMtxSize = cell(nHiddenLayer+1,1);
BiasMtxSize = cell(nHiddenLayer+1,1);
TotalElementNum = 0;
for nHl = 1 : nHiddenLayer+1
    if nHl == nHiddenLayer+1
        HiddenLayerNodeW{nHl} = 0.04*(rand(nOutputNodes,nHidNodesNum(nHl-1))-0.5); % should be the size of nNodes(l+1) by nNodes(l)
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    elseif nHl == 1
        HiddenLayerNodeW{nHl} = 0.04*(rand(nHidNodesNum(nHl),nInputNodes)-0.5);
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    else
        HiddenLayerNodeW{nHl} = 0.04*(rand(nHidNodesNum(nHl),nHidNodesNum(nHl-1))-0.5);
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    end
    WeightsMtxSize{nHl} = size(HiddenLayerNodeW{nHl});
    BiasMtxSize{nHl} = size(HiddenLBias{nHl});
    TotalElementNum = TotalElementNum + numel(HiddenLayerNodeW{nHl}) + numel(HiddenLBias{nHl});
    
    LayerActValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the activation function for each layer
    LayerOutValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the output value for each layer
    
    DeltaJNodesData{nHl} = zeros(nHidNodesNum(nHl),nSamples); 
end
LayerSizeStrc.Weights_size = WeightsMtxSize;
LayerSizeStrc.Bias_size = BiasMtxSize;
LayerParaValuesStrc.Weights_Mtx = HiddenLayerNodeW;
LayerParaValuesStrc.Bias_Mtx = HiddenLBias;
% HiddenLBias = rand(length(nHidNodesNum),1);
% OutputNetInData = zeros(nOutputNodes,nSamples);
% OutputNetOutData = zeros(nOutputNodes,nSamples);
SampleWChange = cell(nHiddenLayer+1,1);
SampleBiasChange = cell(nHiddenLayer+1,1);
[AllVecs,ParaInds] = FeedfowardWB2Vec(LayerSizeStrc,LayerParaValuesStrc,TotalElementNum);
% % NewWBDataStrc = FeedfowardVec2WB(LayerSizeStrc,AllVecs,ParaInds);

%%
% parameters for adam optimization
scgParam.sigma = 5*1e-5;
scgParam.sigma_k = [];
scgParam.s_k = [];
scgParam.lamda = 1e-6;
scgParam.lamda_hat = 0;
scgParam.p = [];
scgParam.p_square = [];
scgParam.r = [];
scgParam.k = 1; 
scgParam.success = true; 
scgParam.delta_k = [];
scgParam.Mu = [];
scgParam.Alpha_k = [];
scgParam.UpDELTA_k = [];
scgParam.Beta_k = [];

%% set up network parameters
NetParaSum = struct();
NetParaSum.InputData = [];
NetParaSum.TargetData = [];
NetParaSum.HiddenLayerNum = HidNodesNum;
NetParaSum.LayerConnWeights = HiddenLayerNodeW;
NetParaSum.LayerConnBias = HiddenLBias;
NetParaSum.LayerSizeStrc = LayerSizeStrc;
NetParaSum.AllParaVec = AllVecs;
NetParaSum.ParaVecInds = ParaInds;
NetParaSum.TotalParaNum = TotalElementNum;
NetParaSum.LayerActV = LayerActValue;
NetParaSum.LayerOutV = LayerOutValue;
NetParaSum.OutFun = 'LeakyReLU';
NetParaSum.DeltaJNodesDatas = DeltaJNodesData;
NetParaSum.FullLayerNodeNums = [size(InputData,1),NetParaSum.HiddenLayerNum,...
    size(OutputData,1)];
NetParaSum.gradParaVec = zeros(numel(AllVecs),1);
NetParaSum.NetPerf = 1;

%% SampleLayerInOutData = cell(nInputNodes,1); % s
IterTime = tic;
IsShuffle = 1;
cBatchStartInds = 1;
Scalar_lamda_k = [];
UpdeltaK = [];
while scgParam.success
    %
    if IsMiniBatch
        if (cBatchStartInds+MiniBatchNums) > nTotalSample
            Start2EndIndsNum = nTotalSample - cBatchStartInds;
            ExtraStartInds = MiniBatchNums - Start2EndIndsNum;
            
            MiniInds = [1:ExtraStartInds,cBatchStartInds+1:nTotalSample];
            cBatchStartInds = ExtraStartInds + 1;
            
            % Performing shuffle is given option
            if IsShuffle
                TotalInds = 1 : nTotalSample;
                ShufTotalInds = Vshuffle(TotalInds);
                InputData = InputData(:,ShufTotalInds);
                OutputData = OutputData(:,ShufTotalInds);
            end
%         elseif (cBatchStartInds+MiniBatchNums) == nTotalSample
%             MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
%             cBatchStartInds 
        else
            MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
        end
        MiniInputData = InputData(:,MiniInds);
        MiniOutPutData = OutputData(:,MiniInds);
        cMiniSample = MiniBatchNums;
%         if nIters == 1
%             SampleWChange = cellfun(@(x) repmat(x,1,1,cMiniSample),HiddenLayerNodeW,'UniformOutput',false);
%             SampleBiasChange = cellfun(@(x) repmat(x,1,cMiniSample),HiddenLBias,'UniformOutput',false);
%         end
    else
        MiniInputData = InputData;
        MiniOutPutData = OutputData;
        cMiniSample = nTotalSample;
%         if nIters == 1
%             SampleWChange = cellfun(@(x) repmat(x,1,1,cMiniSample),HiddenLayerNodeW,'UniformOutput',false);
%             SampleBiasChange = cellfun(@(x) repmat(x,1,cMiniSample),HiddenLBias,'UniformOutput',false);
%         end
    end
    %
%     NetParaSum.InputData = MiniInputData;
%     NetParaSum.TargetData = MiniOutPutData;
%     
%     [IterError,NetParaSum] = NetWorkCalAndGrad(NetParaSum);
    BackscgPara = scgParam;
    if scgParam.k == 1
        NetParaSum.InputData = MiniInputData;
        NetParaSum.TargetData = MiniOutPutData;
        [IterError,NetParaSum] = NetWorkCalAndGrad(NetParaSum);
        
        scgParam.p = -NetParaSum.gradParaVec;
        scgParam.r = -NetParaSum.gradParaVec;
    end
    IterErrorAll(nIters) = IterError;
    if ~mod(nIters,10)
        fprintf(sprintf('cIterError = %.3f, Iter number %d.\n',IterError,nIters));
    end
%     scgParam.p = -NetParaSum.gradParaVec;
    scgParam.p_square = scgParam.p' * scgParam.p;
    scgParam.sigma_k = scgParam.sigma / sqrt(scgParam.p_square);
%     scgParam.r = -NetParaSum.gradParaVec;
    %
    % calculate s_k
    TempNetData = NetParaSum;
    Temp_WB = TempNetData.AllParaVec + scgParam.sigma_k * scgParam.p;
    TempNetData.AllParaVec = Temp_WB;
    [~,TempNetData] = NetWorkCalAndGrad(TempNetData);
    scgParam.s_k = (TempNetData.gradParaVec - NetParaSum.gradParaVec) / scgParam.sigma_k;
    
    scgParam.delta_k = scgParam.p' * scgParam.s_k;
    %
    % scale delta
    scgParam.delta_k = scgParam.delta_k + (scgParam.lamda - scgParam.lamda_hat)*scgParam.p_square;
%     scgParam.s_k = scgParam.s_k + (scgParam.lamda - scgParam.delta_k)* scgParam.p; % from thr python version scg
    
    % if delta <= 0 then make the hessian matrix positive definite
    if scgParam.delta_k <= 0
%         scgParam.s_k = scgParam.s_k + (scgParam.lamda - 2*scgParam.delta_k/scgParam.p_square)*scgParam.p; % from thr python version scg
        scgParam.lamda_hat = 2*(scgParam.lamda - scgParam.delta_k / scgParam.p_square);
        scgParam.delta_k = -scgParam.delta_k + scgParam.lamda*scgParam.p_square;
%         scgParam.delta_k = -scgParam.delta_k;% from thr python version scg
        scgParam.lamda = scgParam.lamda_hat;
    end
    
    Old_r = scgParam.r; % for beta calculation
    % calculate step size
    scgParam.Mu = scgParam.p' * scgParam.r;
    scgParam.Alpha_k = scgParam.Mu/scgParam.delta_k;
    
    % calculate the comparison parameter
    NewTempNetData = NetParaSum;
    NewTempNetData.AllParaVec = NewTempNetData.AllParaVec + scgParam.Alpha_k * scgParam.p;
    [IterError,NewTempNetData] = NetWorkCalAndGrad(NewTempNetData);
    scgParam.UpDELTA_k = 2*scgParam.delta_k*(NetParaSum.NetPerf - NewTempNetData.NetPerf)/(scgParam.Mu^2);
    %
    if scgParam.UpDELTA_k >= 0
%         NetParaSum.AllParaVec = NetParaSum.AllParaVec + scgParam.Alpha_k * scgParam.p;
%         [IterError,NetParaSum] = NetWorkCalAndGrad(NetParaSum);
        NetParaSum = NewTempNetData;
        scgParam.r = -NetParaSum.gradParaVec;
        scgParam.lamda_hat = 0;
        scgParam.success = true; 
    
        if rem(scgParam.k,NetParaSum.TotalParaNum) == 1
            scgParam.p = scgParam.r;
        else
            scgParam.Beta_k = (scgParam.r' * scgParam.r - scgParam.r'*Old_r)/scgParam.Mu;
            scgParam.p = scgParam.r + scgParam.Beta_k*scgParam.p;
        end

        if scgParam.UpDELTA_k >= 0.75
            % reduce the scale parameter
            scgParam.lamda = 0.25*scgParam.lamda;
%             scgParam.lamda = 0.5*scgParam.lamda;  % from thr python version scg
        end
    else
        scgParam.lamda_hat = scgParam.lamda;
        scgParam.success = false;
        fprintf('Delta Out iter end.\n ');
    end
    if scgParam.UpDELTA_k < 0.25
        % increase the scale parameter
        scgParam.lamda = scgParam.lamda + (scgParam.delta_k * (1 - scgParam.UpDELTA_k)/scgParam.p_square);
%         scgParam.lamda = scgParam.lamda * 4; % from thr python version scg
    end
    Scalar_lamda_k(nIters) = scgParam.lamda;
    
    if sqrt(scgParam.r'*scgParam.r) >1e-6
        scgParam.k = scgParam.k + 1;
    else
        scgParam.success = false;
        fprintf('Zeros descent iter end.\n ');
    end
    UpdeltaK(nIters) = scgParam.UpDELTA_k;
%     LayerParaValuesStrc.Weights_Mtx = NetParaSum.LayerConnWeights;
%     LayerParaValuesStrc.Bias_Mtx = NetParaSum.LayerConnBias;
%     [NewAllVecs,~] = FeedfowardWB2Vec(LayerSizeStrc,LayerParaValuesStrc,NetParaSum.TotalParaNum);
%     NetParaSum.AllParaVec = NewAllVecs;
    %
    
    nIters = nIters + 1;
%     nLearnRate = nLearnRate * 0.9;
%     if nLearnRate < 0.001
%         nLearnRate = 0.6;
%     end
%     LearnRate(nIters) = nLearnRate;
    if IsMiniBatch
        cBatchStartInds = cBatchStartInds + MiniBatchNums;
    end
end

%%
TrainTime = toc(IterTime);
RealIter = nIters - 1;
fprintf('BP stops after %d iterations, with ErrorRate = %.2e, time used is %d seconds.\n',RealIter,IterError,TrainTime);
figure;
plot(IterErrorAll,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('Eror');

%%
RealIter = nIters - 1;
figure;
plot(1:RealIter,Scalar_lamda_k,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('scalar parameter');

%%
RealIter = nIters - 1;
figure;
plot(1:RealIter,UpdeltaK,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('comparison parameter');

