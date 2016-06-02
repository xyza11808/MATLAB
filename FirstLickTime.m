function [FLickT,RewardLickT]=FirstLickTime(LickTimeData,Actionside,TrialResult,OnsetStruct,AnswerTime)
%this function is used for calculate the first lick time after stim onset
%the unique output is the first lick time for all the non-missing trials.
%the output variable FLickT contains the first time lick time, with lick
%time equals 0 if a missing trials occurs
%28th,Sep, 2015

SelectedTrialInds=find(TrialResult~=2);
SelectedTrialResult=TrialResult(SelectedTrialInds);
SelectedLickTData=LickTimeData(SelectedTrialInds);
SelectedAction=Actionside(SelectedTrialInds);
SelectedOnsetTime=OnsetStruct.StimOnset(SelectedTrialInds);
SelectedTimeAns=AnswerTime(SelectedTrialInds);
% StimDur=OnsetStruct.StimDuration;
LickSideDes={'LickTimeLeft','LickTimeRight'};
FLickT=zeros(1,length(TrialResult));
RewardLickT=zeros(1,length(TrialResult));

for n=1:length(SelectedTrialInds)
    LickSideV=SelectedLickTData(n).(LickSideDes{SelectedAction(n)+1});
    TrialStimOff=SelectedOnsetTime(n);%+StimDur
    FLickInds=find(LickSideV>=TrialStimOff,1,'first');
    if isempty(FLickInds)
        continue;
    end
    if isempty(LickSideV(FLickInds))
        FLickT(SelectedTrialInds(n))=TrialStimOff;
    else
        FLickT(SelectedTrialInds(n))=LickSideV(FLickInds);
    end
    
    if SelectedTrialResult(n)==1
        TrialAnsT=SelectedTimeAns(n);
        FLickInds=find(LickSideV>TrialAnsT,1,'first');
        if ~isempty(FLickInds)
            RewardLickT(SelectedTrialInds(n))=LickSideV(FLickInds);
        end
    end
end

