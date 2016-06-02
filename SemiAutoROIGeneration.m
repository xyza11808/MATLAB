function varargout=SemiAutoROIGeneration(im,varargin)
%this function will be used to generate an ROI mask from given image, and
%then return ROI mask and boundary position
%user have to define the center of given ROI mask and then program will
%generate a ROI contains this center point

FrameSize=size(im);
imageSizeX = FrameSize(1);
imageSizeY = FrameSize(2);
if ~isempty(varargin)
    FrameLength=varargin{1};  %the real length of given image (um)
else
    FrameLength=[];
end
if ~isempty(FrameLength)
    PixelUnits=FrameLength/imageSizeX;
    PixelRange=ceil(15/PixelUnits);  % select 15um away from center pixel pixels
else
    PixelRange=20;  %default value. select pixels within 20 pixel from center pixel
end

if nargin>2
    LevelCorrRatio=varargin{2};
end
if ~exist('LevelCorrRatio','var') || isempty(LevelCorrRatio)
    LevelCorrRatio=1;  %when this value is bigger than 1, than ROI mask will be smaller; if it is less than 1 but more than 0, than the ROI mask will be bigger
end

if nargin >3
    isSignalMultify=varargin{3};  %when this value is true, program will mulyify signal by power 2
end
if ~exist('isSignalMultify','var') || isempty(isSignalMultify)
    isSignalMultify=1;  %using raw image for processing region of interest
end

if nargin > 4
    InputHandle=varargin{4};
    CurrentROI=varargin{5};
else
    InputHandle=[];
end
%
if isSignalMultify
    SelectionSize=PixelRange*2+1;
    ConerIndsMask=zeros(SelectionSize,SelectionSize);
    ConerWidth=PixelRange/4;
    ConerIndsMask(1:ConerWidth,1:ConerWidth)=1;
    ConerIndsMask(1:ConerWidth,SelectionSize-ConerWidth+1:end)=1;
    ConerIndsMask(SelectionSize-ConerWidth+1:end,1:ConerWidth)=1;
    ConerIndsMask(SelectionSize-ConerWidth+1:end,SelectionSize-ConerWidth+1:end)=1;
    ConerIndsMask=logical(ConerIndsMask);

    CenterInds=false(SelectionSize,SelectionSize);
    CenterInds(PixelRange-ConerWidth+1:PixelRange+ConerWidth,PixelRange-ConerWidth+1:PixelRange+ConerWidth)=true;
end
%
% SelectSizeX=PixelRange*2+1;
% SelectSizeY=PixelRange*2+1;
% [columnsInImage,rowsInImage] = meshgrid(1:SelectSizeX, 1:SelectSizeY);
% AllDis=sqrt((rowsInImage-PixelRange-1).^2 + (columnsInImage-PixelRange-1).^2);
% circlePixels=AllDis<=PixelRange;
if isempty(InputHandle) || ~ishandle(InputHandle)
    h_all=figure;
    imagesc(im,[0 500]);
    colormap gray
    CurrentROI=0;
else
    figure(InputHandle);
    h_all=InputHandle;
end
fprintf('Please select the center of ROI position.\nClick enter to end ROI center selection.\n');
[Ypos,Xpos]=ginput;
if isempty(Xpos)
    warning('No position had been selected, quit function.\n');
    return;
end
Xpos=floor(Xpos);
Ypos=floor(Ypos);
SelectPoints=length(Xpos);
ROImask=cell(SelectPoints,1);
ROIpos=cell(SelectPoints,1);
ROIringmask=cell(SelectPoints,1);
h_hist_center=figure;
h_hist_corner=figure;
f=figure;

for ROInumber=1:SelectPoints
    CROImask=zeros(FrameSize);
%     CRingmask=zeros(FrameSize);
    CurrentCenter=[Xpos(ROInumber),Ypos(ROInumber)];
    xRange=(CurrentCenter(1)-PixelRange):(CurrentCenter(1)+PixelRange);
    xOuterInds=(xRange < 1) | (xRange > imageSizeX);
    xRange(xOuterInds)=[];
    CenterInds(xOuterInds,:)=[];
    ConerIndsMask(xOuterInds,:)=[];
    yRange=(CurrentCenter(2)-PixelRange):(CurrentCenter(2)+PixelRange);
    yOuterInds=(yRange < 1) | (yRange > imageSizeY);
    CenterInds(xOuterInds,:)=[];
    ConerIndsMask(xOuterInds,:)=[];
    yRange(yOuterInds)=[];
    CSelectScale=im(xRange,yRange);
    figure(h_hist_center);
    hist(double(CSelectScale(CenterInds)));
    figure(h_hist_corner);
    hist(double(CSelectScale(ConerIndsMask)));
    
%     CSelectScale=CSelectScale(1:length(xRange),)
%     if isSignalMultify
%         if mean(CSelectScale(CenterInds)) < 1.5*mean(CSelectScale(ConerIndsMask))
%             CSelectScale=power(CSelectScale,2);
%         end
%     end
%     CurrentCenter=[PixelRange+1,PixelRange+1];
%     f=figure;
%     imagesc(CSelectScale);
%     colormap gray
    BaseForNor=sort(CSelectScale(:),'descend');
    NorSelectIM=CSelectScale/mean(BaseForNor(1:50));  %normalize select image to [0 1]
%     NorSelectIM=CSelectScale;  %skip normalization step
    level=graythresh(NorSelectIM); %level used to define binary image
    BW=im2bw(NorSelectIM,(level*LevelCorrRatio));  %generate binary image 
    figure(f);
    imagesc(BW)
%     BW(~circlePixels)=false;
    [B,L,N,~]=bwboundaries(BW); %generate boundary position, return a cell variabele
    if N>1
        labelCount=zeros(N,1);
        for m=1:N
            labelCount(m)=sum(sum(L==m));
        end
        [~,RealROIlbel]=max(labelCount);
%         RealROIlbel=I;
        RealMask=L==double(RealROIlbel);
        RealPos=B(RealROIlbel);
    else
        RealMask=L;
        RealPos=B;
    end
    Bpos=RealPos{1};
%     figure(f);
    line(Bpos(:,2),Bpos(:,1),'color','r');
    RealBpos=zeros(size(Bpos));
    RealBpos(:,1)=Bpos(:,1)+(CurrentCenter(1)-PixelRange)-1;
    RealBpos(:,2)=Bpos(:,2)+(CurrentCenter(2)-PixelRange)-1;
    CROImask(xRange,yRange)=RealMask;
    ROImask(ROInumber)={logical(CROImask)};
    ROIpos(ROInumber)={RealBpos};
    CenterXY=mean(RealBpos);
    [RingMask,~]=RingShapeMask(FrameSize,CenterXY,RealBpos,[],false(FrameSize),CROImask);
    ROIringmask{ROInumber}=RingMask;
%     figure(h_all);
%     line(RealBpos(:,2),RealBpos(:,1),'color','r');
%     text(CurrentCenter(2),CurrentCenter(1),sprintf('%d',ROInumber+CurrentROI),'FontSize',12,'color','c');
end

if nargout==1
    varargout{1}={{ROImask},{ROIpos},{ROIringmask}};
elseif nargout==3
    varargout{1}=ROImask;
    varargout{2}=ROIpos;
    varargout{3}=ROIringmask;
end
