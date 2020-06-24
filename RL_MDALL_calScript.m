% preprocessing

 [behavResults,behavSettings] = behav_cell2struct(SessionResults,SessionSettings);
 ActionType = double(behavResults.Action_choice(:));
%  Assumed_TrType = double(behavResults.Stim_toneFreq(:));
% Assumed_Tr_Octs = log2(Assumed_TrType / min(Assumed_TrType)) - 1;
Assumed_TrType = double(behavResults.Trial_Type(:));
Assumed_TrFreqs = double(behavResults.Stim_toneFreq(:));
Assumed_Tr_Octs = log2(Assumed_TrFreqs / min(Assumed_TrFreqs)) - 1;

NonMissInds = ActionType ~= 2;
NmAction_choice = ActionType(NonMissInds);

% NmTrType = Assumed_Tr_Octs(NonMissInds);
NmTrType = Assumed_TrType(NonMissInds);
% NmInds_lowBlock = double(inds_Low(NonMissInds));
% NmInds_lowBlock(~NmInds_lowBlock) = -1;
% NmInds_lowBlock = NmInds_lowBlock' * -1; 
NmOutcomes = double(NmTrType == NmAction_choice);
NmTrial_octs = Assumed_Tr_Octs(NonMissInds);
% NmOutcomes(NmOutcomes == 0) = -1; % set as neg-values for error trials
%%
% DFRL model calculation
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
OptiFun = @(md) RL_MdAll_call_fun(NmAction_choice, NmTrType, 'DFRL', md);
InitialParas = [1, 1, 0.5, 0.5]; %[1,-0.1,0.1,0.1];
LB = [0 -10 0 0];
UB = [10 0 1 1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search
%%
MdParas = struct();
MdParas.Action_Choice = NmAction_choice;
MdParas.Trial_Types = NmTrType;
MdParas.Pos_delta_value = x(1); %Pos_delta_value;
MdParas.Neg_delta_value = x(2); %Neg_delta_value;
MdParas.Chose_decay = x(3); %Chose_decay;
MdParas.UnChose_decay = x(4); %UnChose_decay;

[SoftChoiceProbs,TarChoiceProb,Qvalues] = RL_model_CalAll('DFRL', MdParas);

%% calculate AIC
ActionChoiceMtx = ([1 - NmAction_choice(2:end), NmAction_choice(2:end)])';
% Calculate AIC from the second estimation
SoftMaxOutputs = SoftChoiceProbs(:,2:end);
PosInds = ActionChoiceMtx == 1;
NegInds = ActionChoiceMtx == 0;

Likelihood_sum = (sum(log(SoftMaxOutputs(PosInds))) + sum(log(1 - SoftMaxOutputs(NegInds))));
AIC = 2*length(x) - 2*Likelihood_sum;
disp(AIC)

%%
Choice = SoftChoiceProbs(1,:) > SoftChoiceProbs(2,:);
mean(1-Choice(:) == NmAction_choice(:))

hf = figure;
hold on 
yyaxis left
plot(smooth(NmAction_choice,5),'k')
plot(smooth(1-Choice,5),'r')

% yyaxis right
% plot(NmInds_lowBlock,'c')
%%
% figure;
% subplot(311)
% plot(HiddenValues{3})
% title('Context')
% subplot(312)
% plot(HiddenValues{2})
% title('Switch prob')
% subplot(313)
% plot((HiddenValues{1})')
% title('Qvalues')

%% QL model calculation
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
OptiFun = @(md) RL_MdAll_call_fun(NmAction_choice, NmTrType, 'QL', md);
InitialParas = [0.8]; %[1,-0.1,0.1,0.1];
LB = [0];
UB = [1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search
% QL model calculation
MdParas = struct();
MdParas.Action_Choice = NmAction_choice;
MdParas.Trial_Types = NmTrType;
MdParas.LearningRate = x(1); % learning rate 
[SoftChoiceProbs,TarChoiceProb,Qvalues] = RL_model_CalAll('QL', MdParas);

%% DFQL model calculation
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
OptiFun = @(md) RL_MdAll_call_fun(NmAction_choice, NmTrType, 'DFQL', md);
InitialParas = [0.9 0.9 0.5]; %[1,-0.1,0.1,0.1];
LB = [0 0 0];
UB = [1 1 1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search

MdParas = struct();
MdParas.Action_Choice = NmAction_choice;
MdParas.Trial_Types = NmTrType;
MdParas.LearningRate = x(1);
MdParas.Chose_decay = x(2);
MdParas.UnChose_decay = x(3);
[SoftChoiceProbs,TarChoiceProb,Qvalues] = RL_model_CalAll('DFQL', MdParas);


