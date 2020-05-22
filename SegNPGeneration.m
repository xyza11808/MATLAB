function [LabelNPmask,ROIlabel]=SegNPGeneration(FrameSize,ROIpos,ROImask,OverAllMasks,varargin)
%this function used to generate empty mask for segmental NP data
%generation, and will be called by matlab GUI

%FrameSize will be used for define number of segmentaions
% a two number vector that defines row length and column length
% this variable should be ths same as ROImask size

% ROInum=length(ROIpos);
ROIcenterCELL=cellfun(@mean,ROIpos,'UniformOutput',false);
ROIcenter=floor(cell2mat(ROIcenterCELL'));
if length(ROIcenter) == numel(ROIcenter)
    ROIcenter = (reshape(ROIcenter,2,[]))';
end
ROImaskSize=size(ROImask{1});

if ~isequal(ROImaskSize,FrameSize)
    error('ROI mask size is different from input image size, quit analysis.');
end

if ~isempty(varargin) && ~isempty(varargin{1})
    SegMentalNum = varargin{1};
else
    if FrameSize(1) == 256
        SegMentalNum = 9;
    elseif FrameSize(1) == 512
        SegMentalNum = 16;
    else
        fprintf('The input frame size row is %d, please input the Segments number for analysis.\n',FrameSize(1));
        Istr=input('','s');
        SegMentalNum=str2num(Istr);
    end
end

RowSegNum=sqrt(SegMentalNum);
SegBoundInds=floor(linspace(0,FrameSize(1),(RowSegNum+1)));
SegSize=floor(FrameSize(1)/RowSegNum);
TempROIlabel=floor(ROIcenter/SegSize);  %the first column is x label, and second column is y label
ROIlabel=sum(TempROIlabel*[RowSegNum;1],2)+1; %label for each ROIs. label distribution is COLUMN WISED increase
%%
LabelNPmask=cell(1,SegMentalNum);
SegMaskSums = zeros(size(OverAllMasks));
for LabelNum=1:SegMentalNum
%     SameLabelROIinds = ROIlabel == LabelNum;
%     LabelROImask = ROImask(SameLabelROIinds);
%     LabelROInumber = sum(SameLabelROIinds);
%     SUMlabelMask = zeros(FrameSize);
    SegNPmask = zeros(FrameSize);
%     for m=1:LabelROInumber
%         TempMask = LabelROImask{m};
%         SUMlabelMask = SUMlabelMask + TempMask;
%     end
%     SUMlabelMask = double(SUMlabelMask > 0);
    [x,y]=ind2sub([RowSegNum RowSegNum],LabelNum);
    SegNPmask(SegBoundInds(x)+1:SegBoundInds(x+1),SegBoundInds(y)+1:SegBoundInds(y+1))=...
        ~OverAllMasks(SegBoundInds(x)+1:SegBoundInds(x+1),SegBoundInds(y)+1:SegBoundInds(y+1));
%         ~SUMlabelMask(SegBoundInds(x):SegBoundInds(x+1),SegBoundInds(y):SegBoundInds(y+1));
    LabelNPmask{LabelNum}=SegNPmask;
    SegMaskSums = SegMaskSums + SegNPmask * 2;
end
%%
 disp('Function end');
