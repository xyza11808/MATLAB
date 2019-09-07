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
% OptiFun = @(md) DFRL_call_fun(ActionType,Assumed_TrType,md);
OptiFun = @(md) DFRL_call_fun(ShufSimulate_ActChoice,ShufStimCohn,md);
InitialParas = [1,1,1,1];%[1,-0.1,0.1,0.1];
options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8);
[x,fval,exitflag,output] = fminsearch(OptiFun,InitialParas,options);

%% plot calculated result

MdParas = struct();
MdParas.Action_Choice = ShufSimulate_ActChoice;
MdParas.Tr_Types = ShufStimCohn;
MdParas.Pos_delta_value = x(1); %Pos_delta_value;
MdParas.Neg_delta_value = x(2); %Neg_delta_value;
MdParas.Chose_decay = x(3); %Chose_decay;
MdParas.UnChose_decay = x(4); %UnChose_decay;

[SoftChoiceProbs,TarChoiceProb,Qvalues] = DFRL_model_Cal(MdParas);


