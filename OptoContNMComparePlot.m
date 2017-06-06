function OptoContNMComparePlot(AlignData,TrFreq,TrOutcome,TrChoice,AlignF,Frate,TrModu,varargin)
% this function is tried to handle the sessions with optal trials, and plot
% the comparison plot for optical neurometic and control neurometric curve
% only random pure tone session data can be handled for equal fraction of
% data points for each frequency

TrFreq = double(TrFreq);
TrOutcome = double(TrOutcome);
TrChoice = double(TrChoice);
TrModu = double(TrModu);
RespWin = 1.5;
if nargin > 6
    if ~isempty(varargin{1})
       RespWin =  varargin{1};
    end
end

if length(RespWin) == 1
    fRange = sort([AlignF,AlignF+round(RespWin*Frate)]);
elseif length(RespWin) == 2
    fRange = sort([AlignF+round(RespWin(1)*Frate),AlignF+round(RespWin(2)*Frate)]);
else
    error('Error length input time window, please check your input data');
end

if max(TrOutcome) == 2  % if there are miss trials, excluded all those trials
    MisstrInds = TrOutcome ~= 2;
    AlignData = AlignData(MisstrInds,:,:);
    TrFreq = TrFreq(MisstrInds);
    TrOutcome = TrOutcome(MisstrInds);
    TrChoice = TrChoice(MisstrInds);
end


% extract the response window data from aligned data set
RespDataMtx = max(AlignData(:,:,fRange(1):fRange(2)),[],3);
OptoInds = TrModu == 1;
ContInds = ~OptoInds;



function NMBehavRightProb = ChoiceDecodingFun(RespData,TrFreq,TrRchoice)
% this fucntion is just used for internal clasification of choice based on
% SVM method, specifically used for current function
TrSize = size(RespData,1);
nObservation = size(RespData,2);
nSample = 40;
TrainDataSet = zeros(600,nObservation);
for nitr = 1:300
    nBase = (nitr-1)*2+1;
    TrIndsSelect = false(TrSize,1);
    SampleInds = randsample(TrSize,nSample);
    TrIndsSelect(SampleInds) = true;
    SampleTrData = RespData(TrIndsSelect,:);
    SampleChoice = TrRchoice(TrIndsSelect);
    
    LeftChoiceMean = mean(SampleTrData(SampleChoice == 0,:));
    RightChoiceMean = mean(SampleTrData(SampleChoice == 1,:));
    TrainDataSet(nBase,:) = LeftChoiceMean;
    TrainDataSet(nBase + 1,:) = RightChoiceMean;
end
TrainLabel = zeros(600,1);
TrainLabel(1:2:600) = 1;  % training labels

FreqTypes = unique(TrFreq);
nFreqs = length(FreqTypes);
FreqDataAll = zeros(nFreqs,nObservation);
FreqRightFrac = zeros(nFreqs,1);
for nnn = 1 : nFreqs
    cfreq = FreqTypes(nnn);
    cfreqInds = TrFreq == cfreq;
    cFreqData = RespData(cfreqInds,:);
    cFreqMean = mean(cFreqData);
    FreqDataAll(nnn,:) = cFreqMean;
    FreqRightFrac = mean(TrRchoice(cfreqInds));
end

% training the SVM using generated dataset
svmdl = fitcsvm(TrainDataSet,TrainLabel);
ModelLoss = kfoldLoss(crossval(svmdl));
fprintf('The correct rate for currect sessions is %.3f',1-ModelLoss);
[~,FreqPredscore] = predict(svmdl,FreqDataAll);
difscore = FreqPredscore(:,2) - FreqPredscore(:,1);
if max(difscore) > 2*abs(min(difscore))
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(abs(min(difscore))-min(difscore)))+rescaleA; 
    fityAll(fityAll>rescaleB) = rescaleB;
%     NorScaleValue = [min(difscore),abs(min(difscore))];
elseif abs(min(difscore)) > 2 * max(difscore) && max(difscore) > 0
    fityAll=(rescaleB-rescaleA)*((difscore+max(difscore))./(abs(max(difscore)*2)))+rescaleA; 
    fityAll(fityAll<rescaleA) = rescaleA;
%     NorScaleValue = [(-1)*abs(max(difscore)),max(difscore)];
else
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
%     NorScaleValue = [min(difscore),max(difscore)];
end
FreqInOctave = log2(FreqTypes / min(FreqTypes));

NMBehavRightProb.NMProb = fityAll;
NMBehavRightProb.BehavProb = fityAll;
NMBehavRightProb.Oct = FreqInOctave;
NMBehavRightProb.ModelPerf = 1 - ModelLoss;

