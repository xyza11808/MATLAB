
[XTrain,YTrain] = japaneseVowelsTrainData;
YTypes = unique(YTrain);
% YTypeData = 
%%
cclr
InputTtestData = [0,0,1,1,1,0,0,1;0,1,1,1,0,1,1,1];
OutPutData = [1,0,1,1,0,0,0,0];
InputSize = 2;
HiddenSize = 9;
OutPutSize = 1;
TrainingSteps = length(OutPutData);

TestLSTMModel = C_LSTM(InputSize,HiddenSize,OutPutSize,TrainingSteps);
TimeStepMD = cell(TrainingSteps,1);
for cStep = 1 : TrainingSteps
    TimeStepMD{cStep} = TestLSTMModel;
end
%% random data for swquence prediction
cclr
x = 0:200;
y = sin(x*pi/5);
figure;plot(x,y)
z = sin(x*pi/15);
hold on
plot(x,z)
a = sin(x*pi/40)*0.5;
plot(x,a)

InputsAll = [y;z;a];
OutPutsAll = [y+a;z+a]; % is output data range out from [0 1], then rescale it
OutPutsAll = (OutPutsAll - min(OutPutsAll(:)))./(max(OutPutsAll(:)) - min(OutPutsAll(:)));
PredStep = 100;

InputTtestData = OutPutsAll(:,1:PredStep);
OutPutData = OutPutsAll(:,2:(PredStep+1));

InputSize = size(InputTtestData,1);
HiddenSize = 9;
OutPutSize = size(OutPutData,1);
TrainingSteps = PredStep;

TestLSTMModel = C_LSTM(InputSize,HiddenSize,OutPutSize,TrainingSteps);
TimeStepMD = cell(TrainingSteps,1);
for cStep = 1 : TrainingSteps
    TimeStepMD{cStep} = TestLSTMModel;
end

%
%% random data for swquence prediction, using matlab dataset
cclr
data = chickenpox_dataset;
data = [data{:}];
[scale01_data,MinMaxD] = Rescale0_1(data);
if size(scale01_data,1) ~= 1
    scale01_data = scale01_data';
end
%
PredStep = 100;

InputTtestData = scale01_data(:,1:PredStep);
OutPutData = scale01_data(:,2:(PredStep+1));

InputSize = size(InputTtestData,1);
HiddenSize = 21;
OutPutSize = size(OutPutData,1);
TrainingSteps = PredStep;

TestLSTMModel = C_LSTM(InputSize,HiddenSize,OutPutSize,TrainingSteps);
TimeStepMD = cell(TrainingSteps,1);
for cStep = 1 : TrainingSteps
    TimeStepMD{cStep} = TestLSTMModel;
end
figure;
plot(OutPutData)
%%
IterMax = 10e6;
LearnRate = 0.2; %
hf = figure;
clearvars Adam Nadam MomentSGD
OptiMethod = 'MomentSGD';
IsAdam = 0;
IsSGD = 1;
LossAll = [];
%%
for cIter = 1 : IterMax
%
%     cIter = 6;
    
    cStepLosss = cell(TrainingSteps,1);
    for cStep = 1 : TrainingSteps
        if cStep == 1
            h_prev_data = zeros(HiddenSize,1);
            c_prev_data = zeros(HiddenSize,1);
        else
            h_prev_data = TimeStepMD{cStep-1}.H_T;
            c_prev_data = TimeStepMD{cStep-1}.C_t;
        end

        cLSTMMds = TimeStepMD{cStep}.Forward_cal(InputTtestData(:,cStep),OutPutData(:,cStep),h_prev_data,c_prev_data);
        TimeStepMD{cStep} = cLSTMMds;
        cStepLosss{cStep} = cLSTMMds.LossData;
    end
    %
    AllTimeLoss = mean(cell2mat(cStepLosss));
    for cStep = TrainingSteps : -1 : 1
        if cStep == TrainingSteps
            dhNext = zeros(HiddenSize,1);
            dcNext = zeros(HiddenSize,1);
            dd_next = {dhNext,dcNext};
            IsFirstStep = 1;
        else
            dd_next = States;
            IsFirstStep = 0;
        end
        [TimeStepMD{cStep},Grads,States] = TimeStepMD{cStep}.Backprop_cal(dd_next);
        if IsFirstStep
            GradSum = Grads;
        else
            GradTempSum = cellfun(@(x,y) x+y, GradSum, Grads,'UniformOutput',0);
            GradSum = GradTempSum;
        end
    end
%     UsedGrads = cellfun(@(x) x/TrainingSteps,GradSum,'uniformOutput',false);
    UsedGrads = GradSum;
    switch OptiMethod
        case 'Adam'
            if ~exist('Adam','var')
                Adam = [];
            end
            [TimeStepMD{1},Adam] = TimeStepMD{1}.UpdateParas('Adam',UsedGrads,Adam);
            IsAdam = 1;
        case 'SGD'
            TimeStepMD{1} = TimeStepMD{1}.UpdateParas('SGD',UsedGrads,LearnRate);
            IsSGD = 1;
        case 'MomentSGD'
            if ~exist('SGD_Moment','var')
                SGDMoment = [];
            end
            [TimeStepMD{1},SGDMoment] = TimeStepMD{1}.UpdateParas('SGD_Moment',UsedGrads,SGDMoment);
            
        case 'Nadam'
            if ~exist('Nadam','var')
                NAdam = [];
            end
            [TimeStepMD{1},NAdam] = TimeStepMD{1}.UpdateParas('Nadam',UsedGrads,NAdam);
            IsAdam = 1;
        otherwise
            fprintf('Undefined optimization method.\n');
            return;
    end
    for cStep = 2 : TrainingSteps
        TimeStepMD{cStep} = CommonWeightsUpdates(TimeStepMD{1},TimeStepMD{cStep});
    end
    Adam.IsUpdateBeta = 0;
    %
    StepOutputAll = cellfun(@(x) x.SM_Output,TimeStepMD,'UniformOutput',false);
    StepOutData = cell2mat(StepOutputAll');
    figure(hf);
    plot(StepOutData')
    set(gca,'ylim',[0 1]);
    pause(0.1);
    if mod(cIter,10) == 1
        fprintf('cIterError = %.5f.\n',AllTimeLoss);
%         if IsAdam
%             Adam.IsUpdateBeta = 1;
%         end
    end
    if IsAdam
        if mod(cIter,20) == 1
            switch OptiMethod
            case 'Adam'
                Adam.IsUpdateBeta = 1;
            case 'Nadam'
                Nadam.IsUpdateBeta = 1;
            end
        end
%         if mod(cIter,1000) == 1
%             Adam.LearnAlpha = Adam.LearnAlpha * 0.8;
%             if Adam.LearnAlpha < 0.1
%                 Adam.LearnAlpha = 0.1;
%             end
%         end
    end
    
    if IsSGD
        LearnRate = LearnRate * 0.9;
        if LearnRate < 0.01
            LearnRate = 0.2;
        end
    end
    LossAll(cIter) = AllTimeLoss;
    %
end

%%
StepOutputAll = cellfun(@(x) x.SM_Output,TimeStepMD,'UniformOutput',false);

%%
NewInputData = OutPutsAll(:,1:PredStep*2);
NewOutputData = OutPutsAll(:,(1:PredStep*2)+1);
cStepLosss = cell(TrainingSteps,1);
    for cStep = 1 : TrainingSteps
        if cStep == 1
            h_prev_data = zeros(HiddenSize,1);
            c_prev_data = zeros(HiddenSize,1);
        else
            h_prev_data = TimeStepMD{cStep-1}.H_T;
            c_prev_data = TimeStepMD{cStep-1}.C_t;
        end

        cLSTMMds = TimeStepMD{cStep}.Forward_cal(NewInputData(:,cStep),NewOutputData(:,cStep),h_prev_data,c_prev_data);
        TimeStepMD{cStep} = cLSTMMds;
        cStepLosss{cStep} = cLSTMMds.LossData;
    end
    %%
 StepOutputAll = cellfun(@(x) x.SM_Output,TimeStepMD,'UniformOutput',false);
    StepOutData = cell2mat(StepOutputAll');
    figure;
    plot(StepOutData')