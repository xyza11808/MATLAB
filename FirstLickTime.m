function [FLickT,RewardLickT,FLickTSide]=FirstLickTime(LickTimeData,Actionside,TrialResult,OnsetStruct,AnswerTime)
%this function is used for calculate the first lick time after stim onset
%the unique output is the first lick time for all the non-missing trials.
%the output variable FLickT contains the first time lick time, with lick
%time equals 0 if a missing trials occurs
%28th, Sep, 2015

SelectedTrialInds=find(TrialResult ~= 2);
SelectedTrialResult=TrialResult(SelectedTrialInds);
SelectedLickTData=LickTimeData(SelectedTrialInds);
SelectedAction=Actionside(SelectedTrialInds);
SelectedOnsetTime=OnsetStruct.StimOnset(SelectedTrialInds);
SelectedTimeAns=AnswerTime(SelectedTrialInds);
% StimDur=OnsetStruct.StimDuration;
LickSideDes={'LickTimeLeft','LickTimeRight'};
FLickT = zeros(1,length(TrialResult));
FLickTSide = zeros(1,length(TrialResult));
RewardLickT = zeros(1,length(TrialResult));

for n=1:length(SelectedTrialInds)
    LickSideV=SelectedLickTData(n).(LickSideDes{SelectedAction(n)+1});
    TrialStimOff=SelectedOnsetTime(n);%+StimDur, considering licks happened within stimulus duration
%     FLickInds=find(LickSideV>=TrialStimOff,1,'first');
    LeftLickT = SelectedLickTData(n).LickTimeLeft;
    RightLickT = SelectedLickTData(n).LickTimeRight;
    FLickIndLeft = LeftLickT(find(LeftLickT>=TrialStimOff,1,'first'));
    FLickIndRight = RightLickT(find(RightLickT>=TrialStimOff,1,'first'));
    
    cChoice = SelectedAction(n);
    if cChoice
        FLickT(SelectedTrialInds(n)) = FLickIndRight;
        FLickTSide(SelectedTrialInds(n)) = 1;
    else
        FLickT(SelectedTrialInds(n)) = FLickIndLeft;
        FLickTSide(SelectedTrialInds(n)) = 0;
    end
    if isempty([FLickIndLeft,FLickIndRight])
        continue;
    end
%     if isempty(FLickIndLeft)
%         FLickT(SelectedTrialInds(n)) = FLickIndRight;
%         FLickTSide(SelectedTrialInds(n)) = 1;
%     elseif isempty(FLickIndRight)
%         FLickT(SelectedTrialInds(n)) = FLickIndLeft;
%         FLickTSide(SelectedTrialInds(n)) = 0;
%     else
%         [minV,Inds] = min([FLickIndLeft,FLickIndRight]);
%         FLickT(SelectedTrialInds(n)) = minV;
%         FLickTSide(SelectedTrialInds(n)) = Inds - 1;
%     end
        
%     if isempty(LickSideV(FLickInds))
%         FLickT(SelectedTrialInds(n))=TrialStimOff;
%     else
%         FLickT(SelectedTrialInds(n))=LickSideV(FLickInds);
%     end
    
    if SelectedTrialResult(n)==1
        TrialAnsT=SelectedTimeAns(n);
        FLickInds=find(LickSideV>TrialAnsT,1,'first');
        if ~isempty(FLickInds)
            RewardLickT(SelectedTrialInds(n))=LickSideV(FLickInds);
        end
    end
end

