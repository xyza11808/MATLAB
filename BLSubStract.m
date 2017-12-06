function [SubSDataMtx,f0Serial,f0,SubFchangeMtx]=BLSubStract(varargin)
%this function is tried to correct baseline shifting by substracting some
%value for each data points according to is neighboring data points
%distribution
%Ref. doi:10.1038/nature10918, harvey's paper

IsContiAcq = 0;
if nargin<1
    return;
elseif nargin==1
    RawData=varargin{1};
    SubPerc=8;
    Win=400;
elseif nargin==2
    RawData=varargin{1};
    SubPerc=varargin{2};
    Win=400;
elseif nargin==3
    [RawData,SubPerc,Win]=deal(varargin{:});
else
    [RawData,SubPerc,Win,TrFrameInds] = deal(varargin{1:4});
    IsContiAcq = 1;
end
if ~IsContiAcq 
    Isreshape=0;
    if ~(size(RawData,1)==1 || size(RawData,2)==1)
        SourceSize=size(RawData);
        RawData=RawData(:);
        Isreshape=1;
    end 
else
    DataVec = zeros(sum(TrFrameInds,1),1);
    DataSize = size(RawData);
    k = 1;
    for cTr = 1 : length(TrFrameInds)
        cTrData = RawData(1:TrFrameInds(cTr),cTr);
        DataVec(k:k+TrFrameInds(cTr)-1) = cTrData;
        k = k + TrFrameInds(cTr);
    end
    RawData = DataVec;
end
if length(RawData)<Win*10
    error('Data length is significantly less than window size, quit analysis');
end
%%
span=floor(Win/2);
SubSData=zeros(length(RawData),1);
f0Serial=zeros(length(RawData),1);
SubThresValueAll=zeros(length(RawData),1);
parfor n=1:length(RawData)
    DisScale=[n-span+1,n+span];
    if DisScale(1)<1
        DisScale(1)=1;
    end
    if DisScale(2)>length(RawData)
        DisScale(2)=length(RawData);
    end
    SubThresValue=prctile(RawData(DisScale(1):DisScale(2)),SubPerc);
    f0Serial(n)=SubThresValue;
    SubSData(n)=RawData(n)-SubThresValue;
    SubThresValueAll(n)=SubThresValue;
end
SubSData=SubSData+median(SubThresValueAll);
SubFchange=(RawData-f0Serial)./f0Serial*100;
f0=median(SubThresValueAll);
%%
if ~IsContiAcq
    if Isreshape
        SubSDataMtx=reshape(SubSData,SourceSize(1),SourceSize(2));
        SubFchangeMtx=reshape(SubFchange,SourceSize(1),SourceSize(2));
    end
else
    %
    SubSDataMtx = zeros(DataSize);
    SubFchangeMtx = zeros(DataSize);
    for cTr = length(TrFrameInds):-1:1
        SubSDataMtx(1:TrFrameInds(cTr),cTr) = SubSData((k-TrFrameInds(cTr)):k-1);
        SubFchangeMtx(1:TrFrameInds(cTr),cTr) = SubFchange((k-TrFrameInds(cTr)):k-1);
        k = k - TrFrameInds(cTr);
    end
    if k ~= 1
        error('The k value is not equal to 1, maybe something wrong');
    end
end