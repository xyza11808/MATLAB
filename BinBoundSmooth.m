function NewSmoothedData = BinBoundSmooth(AlignedData,AlignBin,varargin)
% smooth data seperately for brfore AlignBin and after alignBin part
% in case of the value after AlignBin expended before data
if numel(AlignedData) ~= length(AlignedData)
    AlignedData = mean(AlignedData);
end

if nargin > 2
    SmoothOpt = 1;
else
    SmoothOpt = 0;
end

NewSmoothedData = zeros(size(AlignedData));
 if SmoothOpt
     NewSmoothedData(1:AlignBin) = smooth(AlignedData(1:AlignBin),varargin{:});
     NewSmoothedData(AlignBin+1:end) = smooth(AlignedData(AlignBin+1:end),varargin{:});
 else
     NewSmoothedData(1:AlignBin) = smooth(AlignedData(1:AlignBin));
     NewSmoothedData(AlignBin+1:end) = smooth(AlignedData(AlignBin+1:end));
 end
 