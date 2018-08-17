
AnmChoice = double(behavResults.Action_choice(:));
AnmFreqs = double(behavResults.Stim_toneFreq(:));
NMChoiceInds = AnmChoice ~= 2;
NMChoice = AnmChoice(NMChoiceInds);
NMFreqs = AnmFreqs(NMChoiceInds);

FreqType = unique(AnmFreqs);
nFreqs = length(FreqType);

BNDatas = zeros(5,nFreqs);
MeanData = zeros(2,nFreqs);

for cfreq = 1 : nFreqs
    cfreqInds = NMFreqs == FreqType(cfreq);
    cfreqChoice = NMChoice(cfreqInds);
    
    MeanData(:,cfreq) = [mean(cfreqChoice),std(cfreqChoice)/sqrt(numel(cfreqChoice))];
    [phat,pci] = binofit(sum(cfreqChoice),numel(cfreqChoice),0.01);
    BNDatas(:,cfreq) = [phat,pci,sum(cfreqChoice),numel(cfreqChoice)];
end

%%
figure;hold on
errorbar(1:8,MeanData(1,:),MeanData(2,:),'k')
errorbar(1:8,BNDatas(1,:),BNDatas(1,:) - BNDatas(2,:),BNDatas(3,:)-BNDatas(1,:),'r')