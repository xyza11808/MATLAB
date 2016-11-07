function FlickAnaFun(RawData,FlickT,FlickInds,TrialTypes,TrialOutcomes,FrameRate,varargin)
% this function is a caller functin of function ChoiceSort, using for
% performing some first lick time related analysis

FlickData = RawData(FlickInds,:,:);
FlickTTypes = TrialTypes(FlickInds);
FlickOutcomes = TrialOutcomes(FlickInds);
FlickFrame = round((double(FlickT(FlickInds))/1000)*FrameRate);
AlignFlickF = min(FlickFrame);
AdjustF = FlickFrame - AlignFlickF;
FrameLength = size(FlickData,3) - max(AdjustF) - 1;
[FlickTrials,nROIs,~] = size(FlickData);
NewAlignData = zeros(FlickTrials,nROIs,FrameLength);
for nTr = 1 : FlickTrials
    NewAlignData(nTr,:,:) = FlickData(nTr,:,(AdjustF(nTr)+1):(AdjustF(nTr)+FrameLength));
end

if ~isempty(varargin)
    TimeScale = varargin{1};
    ChoiceSort(NewAlignData,AlignFlickF,FlickTTypes,FlickOutcomes,FrameRate,TimeScale);
else
    ChoiceSort(NewAlignData,AlignFlickF,FlickTTypes,FlickOutcomes,FrameRate);
end

PopuCorrMatrix(FlickData,FlickT,FlickTTypes,FlickOutcomes,[],FrameRate,1);