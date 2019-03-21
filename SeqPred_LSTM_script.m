
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

%%
IterMax = 1000;
hf = figure;
for cIter = 1 : IterMax
%
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
        else
            dd_next = States;
        end
        [cLSTMMds,Grads,States] = TimeStepMD{cStep}.Backprop_cal(dd_next);

        cLSTMMds = cLSTMMds.UpdateParas('SGD',Grads,0.2);
    %     NewStepMD{cStep} = cLSTMMds;
        TimeStepMD{cStep} = cLSTMMds;
    end 
    %
    StepOutputAll = cellfun(@(x) x.SM_Output,TimeStepMD,'UniformOutput',false);
    StepOutData = cell2mat(StepOutputAll');
    figure(hf);
    plot(StepOutData')
    pause(0.1);
    if ~mod(cIter,20)
        fprintf('cIterError = %.5f.\n',AllTimeLoss);
    end
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