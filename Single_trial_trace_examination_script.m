
load('EstimateSPsaveNewMth.mat', 'nnspike', 'frame_rate', 'behavResults');

%%
[lick_time_struct,~]=beha_lickTime_data(behavResults,10); % exclude licks 10 seconds after

OnsetStruct = struct('StimOnset',double(behavResults.Time_stimOnset(:)),'StimDuration',300);
trial_outcome = double(behavResults.Action_choice(:) == behavResults.Trial_Type(:));
trial_outcome(behavResults.Action_choice(:) == 2) = 2;

[FLickT,~,FlickSide]=FirstLickTime(lick_time_struct,double(behavResults.Action_choice(:)),trial_outcome,OnsetStruct,double(behavResults.Time_answer(:)));



%%

cTr = 6;

cROI = 11;

close;

cTrTrace = DataRaw{cTr}(cROI,:);
cTrChoice = double(behavResults.Action_choice(cTr));
cTrFreq = double(behavResults.Stim_toneFreq(cTr));
cTrStimOn = double(behavResults.Setted_TimeOnset(cTr));
cTrOnFrame = round((cTrStimOn/1000)*frame_rate);
NFSignal = filtfilt(cDes,cTrTrace);


hf = figure;
hold on
plot(cTrTrace,'k','linewidth',1.8)
plot(NFSignal,'r','linewidth',1.8);
title(sprintf('Freq %d, Choice %d',cTrFreq,cTrChoice));
ylims = get(gca,'ylim');
line([cTrOnFrame cTrOnFrame],ylims,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');
if FLickT(cTr)
    FLickframe = round(FLickT(cTr)/1000*frame_rate);
    if FlickSide(cTr) % right side
        cColor = 'r';
    else
        cColor = 'b';
    end
    line([FLickframe FLickframe],ylims,'Color',cColor,'linewidth',1.8,'linestyle','--');
end

%%
% figure
cDes = designfilt('lowpassfir','PassbandFrequency',5,'StopbandFrequency',10,...
    'StopbandAttenuation', 60,'SampleRate',frame_rate,'DesignMethod','kaiserwin');  %'ZeroPhase',true,
fvtool(cDes)

%%
NFSignal = filtfilt(cDes,cTrTrace);
figure;
hold on
plot(cTrTrace,'k');
plot(NFSignal,'r');

%%
figure;
periodogram(NFSignal,[],[],frame_rate)

