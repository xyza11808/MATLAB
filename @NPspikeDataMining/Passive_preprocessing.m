
StimFileName = 'passive tones20210316.txt';
StimArray = textscan(fopen(StimFileName),'%f %f %f %f');
FreqsArray = StimArray{1};
DBArray = StimArray{2};
StimDurArray = StimArray{3};
BaselineDur = 1000;  % ms
StimOnset = BaselineDur*ones(numel(FreqsArray),1);
StimOffset = StimOnset + StimDurArray;
AlignEvents = [StimOnset,StimOffset]; % aligned to trigger time
TrRepeats = [FreqsArray,DBArray];

RepeatStr = {'Freqs','DB'};


%%




