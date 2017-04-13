% scripts for linear regression of calcium response data and try to see
% neuronal response is dominated by which behavior parameter
clear
clc

[fn,fp,fi] = uigetfile('CSessionData.mat','Please select the summrized data for target session');
if ~fi
   return;
else
   load(fullfile(fp,fn));
end

Tr_frequency = double(behavResults.Stim_toneFreq);
Tr_AnmChoice = double(behavResults.Action_choice);
Tr_TrType = double(behavResults.Trial_Type);
Tr_IsModu = double(behavResults.Trial_isOptoProbeTrial + behavResults.Trial_isOptoTraingTrial);

session_bound = 16000;

%%
Tr_Octave = log2(Tr_frequency./session_bound);
Tr_outcome = Tr_AnmChoice(:) == Tr_TrType(:);
NonMissTr = ~(Tr_AnmChoice == 2);
NonMissTr_Data = data_aligned(NonMissTr,:,:);
NonMissTr_Octave = Tr_Octave(NonMissTr);
NonMissTr_Re = Tr_outcome(NonMissTr);
NonMissTr_Choice = Tr_AnmChoice(NonMissTr);
InputParaMeter = {'Octave','Reward','AnmChoice'};
InputBehavData = [NonMissTr_Octave(:),NonMissTr_Re(:),NonMissTr_Choice(:)];
if sum(Tr_IsModu)
    fprintf('Opto trial exists, given current data.\n');
    NonMissTr_IsModu = Tr_IsModu(NonMissTr);
    InputBehavData = [InputBehavData,NonMissTr_IsModu(:)];
    InputParaMeter = {InputParaMeter(:),'OptoModu'};
end
%%
[ROIcoef,ROIp,ROIcoefIssig,fitmdl]  = RespParaRegression(NonMissTr_Data,1.5,start_frame,frame_rate,InputBehavData,InputParaMeter);

%%
[ROIcoef,ROIp,ROIcoefIssig,fitmdl] = RespParaRegression(NonMissTr_Data,[2 3.5],start_frame,frame_rate,InputBehavData,InputParaMeter);
