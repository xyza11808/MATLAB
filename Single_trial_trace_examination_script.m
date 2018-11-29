

cTr = 147;

cROI = 45;

close;

cTrTrace = DataRaw{cTr}(cROI,:);
cTrChoice = double(behavResults.Action_choice(cTr));
cTrFreq = double(behavResults.Stim_toneFreq(cTr));
cTrStimOn = double(behavResults.Setted_TimeOnset(cTr));
cTrOnFrame = round((cTrStimOn/1000)*frame_rate);

hf = figure;
plot(cTrTrace,'k')
title(sprintf('Freq %d, Choice %d',cTrFreq,cTrChoice));
ylims = get(gca,'ylim');
line([cTrOnFrame cTrOnFrame],ylims,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');


