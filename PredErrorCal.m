function [MeanErro,stimErro,classErro] = PredErrorCal(dataResult)
% this function is handled for cellfun, calculate the mean error and error
% rate for each freq type
RealStim = dataResult(:,2);
PredStim = dataResult(:,1);

TotalError = double(~(RealStim == PredStim));
StimTypes = unique(RealStim);
StimType = RealStim > StimTypes(round(length(StimTypes)/2));
PredType = PredStim > StimTypes(round(length(StimTypes)/2));
TypeError = double(~(StimType == PredType));
cTypeError = zeros(1,length(StimTypes));
cStimError = zeros(1,length(StimTypes));
for nn = 1 : length(StimTypes)
    cFreq = StimTypes(nn);
    cFreqInds = RealStim == cFreq;
    cStimError(nn) = mean(TotalError(cFreqInds));
    cTypeError(nn) = mean(TypeError(cFreqInds));
end
MeanErro = [mean(TotalError),mean(TypeError)];
stimErro = cStimError;
classErro = cTypeError;