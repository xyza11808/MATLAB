SwitchDiff = [0,diff(inds_Low)];
SwitchBoundaries = find(abs(SwitchDiff));

OctTypes = unique(NmTrial_octs);
NumOctTypes = numel(OctTypes);
OctIndsANDdata = cell(NumOctTypes, 3);
OctColors = cool(NumOctTypes);
hhls = [];
figure;
hold on
for cOct = 2 : NumOctTypes-1
    cOctInds = find(NmTrial_octs == OctTypes(cOct));
    cOctInds_choice = NmAction_choice(cOctInds);
    OctIndsANDdata(cOct,:) = {cOctInds, cOctInds_choice, smooth(cOctInds_choice,3)};
    hl = plot(cOctInds, OctIndsANDdata{cOct,2},'Color',OctColors(cOct,:));
    hhls = [hhls, hl];
end
NumBounds = numel(SwitchBoundaries);
SwitchBoundxMtx = [SwitchBoundaries; SwitchBoundaries; nan(1, NumBounds)];
SwitchBoundyMtx = [zeros(1,NumBounds); ones(1,NumBounds); nan(1, NumBounds)];
plot(SwitchBoundxMtx(:), SwitchBoundyMtx(:), 'Color','k');


%%
cOct = 6;
figure;
hold on
plot(OctIndsANDdata{cOct,1}, OctIndsANDdata{cOct,2},'Color',OctColors(cOct,:));
plot(SwitchBoundxMtx(:), SwitchBoundyMtx(:), 'Color','k');


%%
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
NMLowInds = inds_Low(NonMissInds);
%%
NmOutcomes = double(NmTrType == NmAction_choice);
NmOutcomes(NmOutcomes == 0) = -1; % set as neg-values for error trials

MDParas = struct();
MDParas.BS_thres = 0.5; % the threshold to switch internal boundary estimation
MDParas.BS_evid_Thres = 0.6; % in octave, used for constain the stimulus evidence used for boundary switch
MDParas.BS_LearRate = 0.9; % learn rate for boundary value update
MDParas.OctShiftStep = 0.5; % in octave, the scale range is [0.33, 0.66], according to real behavior design
MDParas.Q_learRate = 0.9; % learn rate for boundary value update


FunLosses = ParaSearchFun(NmAction_choice, NmOutcomes, NmTrial_octs, NMLowInds, MDParas);


%%

options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-8,'MaxIter',5000);
OptiFun = @(md) ParaSearchFun(NmAction_choice, NmOutcomes, NmTrial_octs, NMLowInds, md);
InitialParas = [0.5 0.6 0.9 0.5 0.9]; %[1,-0.1,0.1,0.1];
LB = [-1 0.6 0 0.33 0];
UB = [1 0.6  1 0.66 1]; 
% [x,fval,exitflag,output] = fminsearch(OptiFun, InitialParas, options); %unbounded parameter search
[x,fval,exitflag,output] = fminsearchbnd(OptiFun, InitialParas, LB, UB,options); %unbounded parameter search


%%
MDParas = struct();
MDParas.BS_thres = x(1);% 0.5; % the threshold to switch internal boundary estimation
MDParas.BS_evid_Thres = x(2);% 0.6; % in octave, used for ocnstain the stimulus evidence used for boundary switch
MDParas.BS_LearRate = x(3);%0.9; % learn rate for boundary value update
MDParas.OctShiftStep = x(4);%0.5; % in octave, the scale range is [0.33, 0.66], according to real behavior design
MDParas.Q_learRate = x(5);%;

[Q_values, Bsvalues] = BoundQmodel(NmAction_choice, NmOutcomes, NmTrial_octs, MDParas);
