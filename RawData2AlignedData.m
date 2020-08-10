function [AlignedFrame, AlignedDatas] = RawData2AlignedData(VariedFrame,RawData)
% align the raw data according to the gived varied frame

if iscell(RawData)
    nROIs = size(RawData{1},1);
    NumTrs = length(RawData);
    TrFrames = cellfun(@(x) size(x,2),RawData);
    IsRawCell = 1;
else
    nROIs = size(RawData,2);
    NumTrs = size(RawData,1);
    TrFrames = size(RawData,3);
    IsRawCell = 0;
end
minOnsetTime = min(VariedFrame); % min frame for alignment
OnsetDiffFrame = VariedFrame - minOnsetTime;
ValidFrameLength = TrFrames(:) - OnsetDiffFrame(:); % valid frame length after alignment
UsedFramelength = min(ValidFrameLength);

AlignedDatas = zeros(NumTrs, nROIs, UsedFramelength);
for cTr = 1 : NumTrs
    if IsRawCell
        cTrAlignedData = RawData{cTr}(:,(OnsetDiffFrame(cTr)+(1:UsedFramelength)));
    else
        cTrAlignedData = squeeze(RawData(cTr,:,...
            (OnsetDiffFrame(cTr)+(1:UsedFramelength))));
    end
    AlignedDatas(cTr,:,:) = cTrAlignedData;
end
AlignedFrame = minOnsetTime;


