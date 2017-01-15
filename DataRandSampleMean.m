function SampleMean = DataRandSampleMean(DataStrc)
DataPopu = DataStrc.TestLoss;
DataNum = numel(DataPopu);
SampleSize = DataNum/2;
nSampleIter = 10;
SampleMean = zeros(nSampleIter,1);
for nmnm = 1 : nSampleIter
    sampleInds = randsample(DataNum,SampleSize);
    SampleMean(nmnm) = mean(DataPopu(sampleInds));
end