% this scripts is used for summaried data from csessionData into the format
% that will be used for Wenbin Yang's analysis
% loading data from 'CSessionData.mat', and then processed into the format
% as Wenbin needed
clear
clc
[fn,fp,fi] = uigetfile('CSessionData.mat','Please select your session save data');
if fi
    xx = load(fullfile(fp,fn));
    cd(fp);
    Rawdata = xx.smooth_data;
    TrOutcome = xx.trial_outcome;
    TrChoiceAll = xx.behavResults.Action_choice;
    TaskAlignF = xx.start_frame;
    TaskFrate = xx.frame_rate;
    TaskFreqs = xx.behavResults.Stim_toneFreq;
else
    return;
end

%%
MisssTrsInds = TrChoiceAll == 2;
NonMissRawData = Rawdata(~MisssTrsInds,:,:);
NonMissTrOutcome = TrOutcome(~MisssTrsInds);
NonMissTrChoice = TrChoiceAll(~MisssTrsInds);
NonMissFreqs = TaskFreqs(~MisssTrsInds);

TimeScale = [0 1.5];
FrameScale = round(TimeScale*TaskFrate)+TaskAlignF;
RespData = NonMissRawData(:,:,(FrameScale(1)+1):FrameScale(2));

SumDataSet = squeeze(max(RespData,[],3));
TrChoice = double(NonMissTrChoice);
TrStimFreq = double(NonMissFreqs);
FreqTypes = unique(TrStimFreq);
disp(FreqTypes);
%%
% load passive dataset
[Passfn,Passfp,Passfi] = uigetfile('rfSelectDataSet.mat','Please select your passive saving data');
if ~Passfi
    return;
else
    yy = load(fullfile(Passfp,Passfn));
    PassData = yy.SelectData;
    PassTrFreqs = yy.SelectSArray;
end
nROIs = size(PassData,2);
SmoothTrace = zeros(size(PassData));

for ntrs = 1 :size(PassData,1)
    cTrData = squeeze(PassData(ntrs,:,:));
    parfor nROI = 1 : nROIs
        cTrace = cTrData(nROI,:);
        SmoothTrace(ntrs,nROI,:) = smooth(cTrace,5);
    end
end

PassRespData = squeeze(max(SmoothTrace(:,:,(FrameScale(1)+1):FrameScale(2)),[],3));
PassiveDataUsing = PassRespData;
PassiveFreq = PassTrFreqs;

%%
save cDatasave.mat SumDataSet TrChoice TrStimFreq PassiveDataUsing PassiveFreq -v7.3

%%
[Coeff,scores,~,~,exp,mu] = pca(SumDataSet);
LeftChoices = TrChoice == 0;
RightChoice = ~LeftChoices;

%%
FreqTypes = unique(TrStimFreq);
nFreqtypes = length(FreqTypes);
for nf = 1 : nFreqtypes
    cfreq = FreqTypes(nf);
    cfreqInds = TrStimFreq == cfreq;
    figure;
    hist(scores(cfreqInds,1),20);
end