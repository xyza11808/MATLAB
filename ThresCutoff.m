function CutOffData=ThresCutoff(RawData,Thres,varargin)
%this function is used to cut off raw signal, and set values below
%threshold to 0


if isempty(Thres)
    RawDataShift=permute(RawData,[2,1,3]);
    RawDataReshape=reshape(RawDataShift,DataSize(2),DataSize(1)*DataSize(3)); %first dimension if ROI number
    ROIstd=mad(RawDataReshape,1)*1.4826; %estimated std value
    Thres=ROIstd;
elseif numel(Thres)==1
    %if thres is a single input, means select thres data from saved data
    %files
    [filename,filepath,fileindex]=uigetfile('ROIStd.mat','Select ROI threshold data save file');
    if ~fileindex
        return;
    end
    x=load(fullfile(filepath,filename));
    Thres=x.ROIThres;
end

if isempty(varargin)
    CutThres=Thres;
else
    CutThres=varargin{1}*Thres;  %factor to adjust threshold value
end

datasize=size(RawData);
CutOffData=zeros(datasize);
for n=1:datasize(2)
    SingleData=squeeze(RawData(:,n,:));
    SingleData(SingleData<=CutThres(n))=0;
    CutOffData(:,n,:)=SingleData;  %balues below thres set to zero
end
