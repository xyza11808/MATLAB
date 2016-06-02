function [circlePixels,UpdateSumMask]=RingShapeMask(FrameSize,CenterXY,CirclePos,RingWidth,ROISummask,ROImask,varargin)
% Create a logical image of a ring with specified
% inner diameter, outer diameter center, and image size.
% First create the image.
if isempty(RingWidth)
    if FrameSize(1)==512
        RingWidth=[2 12];
    elseif FrameSize(1)==256
        RingWidth=[2 8];
    end
end

if isempty(ROISummask)
    ROISummask=false(FrameSize);
end

imageSizeX = FrameSize(1);
imageSizeY = FrameSize(2);
[columnsInImage,rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = CenterXY(1);
centerY = CenterXY(2);
AllDis=sqrt((CirclePos(:,1)-centerX).^2 + (CirclePos(:,2)-centerY).^2);
% MeanInner
innerRadius = mean(AllDis)+RingWidth(1);
outerRadius = RingWidth(2)+mean(AllDis); %8 pixel in default
array2D = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2;
circlePixels = array2D >= innerRadius.^2 & array2D <= outerRadius.^2;
% circlePixels is a 2D "logical" array, as the ring shaped mask
% % Now, display it.
% image(circlePixels) ;
% colormap([0 0 0; 1 1 1]);
% title('Binary Image of a Ring', 'FontSize', 25);

%checking whether ring shape is overlapped with ROI region
UpdateSumMask=ROISummask;  %old mask sum 
UpdateSumMask=UpdateSumMask+ROImask;
OverlapInds=find(UpdateSumMask>1);
UpdateSumMask(OverlapInds)=1; %#ok<*FNDSB> %set overlap inds to 1, double matrix

CurrentRingSumMask=UpdateSumMask+circlePixels; %add new ring shape mask to ROI sum mask
RingROIOPInds=find(CurrentRingSumMask>1);  %find RIng inds overlapped with All ROI mask
circlePixels(RingROIOPInds)=0;  %delete overlap inds in ring shape mask, kepp ROI mask
circlePixels=logical(circlePixels); %convert from double to logical
UpdateSumMask=logical(UpdateSumMask);

