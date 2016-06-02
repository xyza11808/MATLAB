% variable format
% in structure form, contains following fields:
S=struct();

%%
%two photon data analysis part
S.SessionNamePre=''; %prefixed name for this session
S.DataAqInfo=struct(); %data acqusition settings
S.nFrames=[];   %frame number for each file
S.FrameTime=[];  %time cost for each file's acqusition
S.nROIs=[];  %ROI number for this session
S.RawData=[]; %raw data for selected ROIs, a three dimensional matrix, which is TrialNum by ROINum by FrameNum
S.ROImask={};  %cell vector contains mask info for each ROI
S.ROIpos={};  %cell vector contains boarder info for each ROI
S.ROIDefineTrial=[]; %Trial number that used to define every ROI

%%
%behavior data part
S.TimeOnset=[]; %stim onset time for each Trials
S.TimeAnswer=[]; %
S.TimeReward=[];
S.TrialType=[]; %Trial type for each Trials
S.TrialFreq=[]; %freq value for each Trials
S.ActionChoice=[];
S.IsProbTrial=[]; %indicates whether current is a prob trial
S.IsOptoTrial=[];  %indicates whether current is a prob trial
S.LickTime=struct(); %contains lick time data for each Trial,in strure form, contains for fields
    S.LickTime.LickNumLeft=[]; 
    S.LickTime.LickTimeLeft={};
    S.LickTime.LickNumRight=[];
    S.LickTime.LickTimeRight={};
S.ExtraInfo=struct(); %structure form data to store other info in case someone needs this extra info
S.RespDalay=[]; %Resp delay after stim onset
S.ExtraSettings=struct(); %used to save extra setting info
