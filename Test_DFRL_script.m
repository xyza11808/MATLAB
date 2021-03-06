% used Parameters
ChoiceType = [0,1]; % left or right
NumChoiceTypes = numel(ChoiceType);
TrNum = 100;
QValues = zeros(NumChoiceTypes,TrNum);
Pos_delta_value = 3;
Neg_delta_value = 0;
Chose_decay = 0.6;
UnChose_decay = 0.5;

Assumed_TrType = double(rand(TrNum,1) > 0.5);
ActionType = zeros(TrNum,1);

CorrIndex = randsample(TrNum,round(TrNum*0.7));
ChoseIndex = logical(ActionType);
ChoseIndex(CorrIndex) = true;
ActionType(ChoseIndex) = Assumed_TrType(ChoseIndex);
ActionType(~ChoseIndex) = double(rand(sum(~ChoseIndex),1) > 0.5);
OverCorrRate = mean(ActionType == Assumed_TrType);
TrOutcome = double(ActionType == Assumed_TrType);
Tr_Used_Decay = [Neg_delta_value,Pos_delta_value];

for cTr = 2 : TrNum
    cTrType = Assumed_TrType(cTr);
    cActIndex = double(ChoiceType == ActionType(cTr)); 
    cTrOutcome = TrOutcome(cTr);
    for cN_choice = 1 : NumChoiceTypes
        if cActIndex(cN_choice) % update same action side Q values
            QValues(cN_choice,cTr) = Chose_decay * QValues(cN_choice,cTr-1) + Tr_Used_Decay(cTrOutcome + 1);
        else % update different action side Q values
            QValues(cN_choice,cTr) = UnChose_decay * QValues(cN_choice,cTr-1);
        end
    end
end

%%
 [behavResults,behavSettings] = behav_cell2struct(SessionResults,SessionSettings);
 ActionType = double(behavResults.Action_choice(:));
 Assumed_TrType = double(behavResults.Stim_toneFreq(:));
 Assumed_Tr_Octs = log2(Assumed_TrType / min(Assumed_TrType)) - 1;
 

NonMissInds = ActionType ~= 2;
NmAction_choice = ActionType(NonMissInds);
NmTrType = Assumed_Tr_Octs(NonMissInds);
NmInds_lowBlock = double(inds_Low(NonMissInds));
NmInds_lowBlock(~NmInds_lowBlock) = -1;
NmInds_lowBlock = NmInds_lowBlock' * -1; 

%%
IntialContext = 1;
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
% test model
% OptiFun = @(md) RLConfid_call_fun(NmAction_choice, NmTrType, NmInds_lowBlock, md);
% InitialParas = [1,1,0.5,0.5,1,1,1,0.4]; %[1,-0.1,0.1,0.1];
% LB = [0 -inf 0 0 1 1 1 0.4];
% UB = [inf 0 1 1 1 1 1 2]; 
% [x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB, options);

% DFRL model
OptiFun = @(md) DFRL_call_fun(NmAction_choice, NmTrType,md);
InitialParas = [1, 1, 0.5, 0.5]; %[1,-0.1,0.1,0.1];
LB = [0 -10 0 0];
UB = [10 0 1 1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search

%% Different RL models 
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
OptiFun = @(md) RL_MdAll_call_fun(NmAction_choice, NmTrType, 'DFRL', md);
InitialParas = [1, 1, 0.5, 0.5]; %[1,-0.1,0.1,0.1];
LB = [0 -10 0 0];
UB = [10 0 1 1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search


%% plot calculated result

MdParas = struct();
MdParas.Action_Choice = NmAction_choice;
MdParas.Tr_Types = NmTrType;
MdParas.Pos_delta_value = x(1); %Pos_delta_value;
MdParas.Neg_delta_value = x(2); %Neg_delta_value;
MdParas.Chose_decay = x(3); %Chose_decay;
MdParas.UnChose_decay = x(4); %UnChose_decay;

% MdParas.SwitchProb_decay = x(5); %switch prob decay;
% MdParas.SwitchProb_delta = x(6); %switch prob delta;
% MdParas.SwitchProb_Thres = x(7); %switch prob threshold;
% MdParas.Step_Delta = x(8);
% MdParas.Context_indices = NmInds_lowBlock; % initial block context indication

[SoftChoiceProbs,TarChoiceProb,Qvalues] = DFRL_model_Cal(MdParas);

% [SoftChoiceProbs,TarChoiceProb,HiddenValues] = RL_Confidence_model_Cal(MdParas);
%% calculate AIC
ActionChoiceMtx = ([1 - NmAction_choice(2:end), NmAction_choice(2:end)])';
% Calculate AIC from the second estimation
SoftMaxOutputs = SoftChoiceProbs(:,2:end);
PosInds = ActionChoiceMtx == 1;
NegInds = ActionChoiceMtx == 0;

Likelihood_sum = (sum(log(SoftMaxOutputs(PosInds))) + sum(log(1 - SoftMaxOutputs(NegInds))));
AIC = 2*length(x) - 2*Likelihood_sum;

%%
Choice = SoftChoiceProbs(1,:) > SoftChoiceProbs(2,:);
mean(1-Choice(:) == NmAction_choice(:))
hf = figure;
hold on 
yyaxis left
plot(smooth(NmAction_choice,5),'k')
plot(smooth(1-Choice,5),'r')

yyaxis right
plot(NmInds_lowBlock,'c')
%%
figure;
subplot(311)
plot(HiddenValues{3})
title('Context')
subplot(312)
plot(HiddenValues{2})
title('Switch prob')
subplot(313)
plot((HiddenValues{1})')
title('Qvalues')
