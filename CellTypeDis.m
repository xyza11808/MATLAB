function CellTypeDis(RawData,AlignPoint,FrameRate,thres,varargin)
%this function will be tried to classify cell types according to their
%temporal file
%two conditions will be considered here, one is real value and next one is
%point slope
%three responsive cell types will be considered, two single responsive
%types and one both responsive types. the rest will be taken as
%non-responsive cell

if nargin>4
    StimScaleT=varargin{1};
    NonSenScaleT=varargin{2};
end
if isempty(StimScaleT)
    StimScaleT=[0,1];
end
if isempty(NonSenScaleT)
    NonSenScaleT=[1,3.5];
end

if nargin>6
    Slope=varargin{3};
else
    Slope=[];
end
%if no slope data gives, initial slope value calculation
if isempty(Slope)

    if gpuDeviceCount
        RawData=gpuArray(RawData);
        DataSize=size(RawData);
        yslope=gpuArray(zeros(DataSize));
        DataSize=gpuArray(DataSize);
    else
        DataSize=size(RawData);
        yslope=zeros(DataSize);
    end
    for n=1:DataSize(1)
        for m=1:DataSize(2)         
            x=squeeze(RawData(n,m,:));
            x=smooth(x);
%             yslope=zeros(length(x),1);
%             xticks=1:length(x);
            span=5; %data points used to calculate center points slope
            for k=ceil(span/2):length(x)-floor(span/2)
                Xlist=(1:span)';
                Ylist=x((k-floor(span/2)):(k+floor(span/2)));
                ffit=fit(Xlist,Ylist,'poly1');
                yslope(n,m,k)=ffit.p1;
            end
        end
    end
end

if isempty(thres)
    thres=zeros(1,size(RawData,2));
    for nROIs=1:size(RawData,2)
        SROIData=squeeze(RawData(:,nROIs,:));
        thres(nROIs)=mad(SROIData(:))*1.4826;
    end
end

%%
%cell type distinguish
%