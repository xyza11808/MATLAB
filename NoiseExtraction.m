function NoiseStd=NoiseExtraction(Rawdata)

DataSize=size(Rawdata);
NoiseStd=zeros(1,DataSize(2));
for n=1:DataSize(2)
    TempData=squeeze(Rawdata(:,n,:));
    TempData=TempData';
    TempTrace=TempData(:);
    SmoothTempData=smooth(TempTrace,'sgolay',3);
    ExtractNoise=TempTrace-SmoothTempData;
    NoiseStd(n)=std(ExtractNoise);
end