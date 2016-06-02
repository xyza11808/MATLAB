function [ROIinfoNew , ROIlabel] = OverLapPixelData(ROIinfoStrc,varargin)
%this function will be used to find overlapped ROIs and return its
%integrated mask for each section of overlapped ROIs
%return variable will contains a inds for each overlap of ROIs, the
%integrated ROI mask for that label. and number of ROIs contains in this
%mask
%this function will be furtehr analysis based on ica method

AllROImasks = ROIinfoStrc.ROImask;
AllRingmask = ROIinfoStrc.Ringmask;
AllROIpos = ROIinfoStrc.ROIpos;
nROIs = length(AllROImasks);
ROIcenterC = cellfun(@(xx) round(mean(xx)),AllROIpos,'UniformOutput',false);
ROIcenter = cell2mat(ROIcenterC');

ROIsumMask = zeros(size(AllROImasks{1}));
[rows , cols] = size(ROIsumMask);
if rows == cols
    if rows == 512
        NeiborDis = 57;  % 40 um distance
    elseif rows == 256
        NeiborDis = 29;
    end
else
    pixels = min(rows , cols);
    NeiborDis = ceil(40 * pixels / 362);
end
    
for nr = 1 : nROIs
    ROIsumMask = ROIsumMask + double(AllROImasks{nr});
end
ROIsumMask = double(ROIsumMask > 0); %All ROI mask integrate together

labels = 1;
% labelStrc = struct('Label',[],'ROIindex',[],'IGmask',[]);
ROIsLabel = zeros(nROIs,2);   %the first column indicates whether this ROI has a label, the second column gives correspoonded label value
for nr = 1 : nROIs
    LabelAdd = 1;
%     cnr = nr;
    cROImasklg = AllROImasks{nr};
    cROImask = double(cROImasklg);
    cROIPixels = sum(cROImask(:));  %pixel number of current ROI
    RestSum = RestSumMask(AllROImasks,nr);
    OverlapInds = cROImask + RestSum;
    cROIarea = OverlapInds(cROImasklg);
    overlapRate = (sum(cROIarea) - cROIPixels)/cROIPixels;
    if overlapRate > 0.3
%         labels = labels + 1;
        cROIcenters = ROIcenter(nr,:);
        AllDis = sqrt(sum((ROIcenter - repmat(cROIcenters,nROIs,1)).^2,2));
        NeighborROIindex = AllDis <= NeiborDis & AllDis ~= 0;
        RealROIinds = find(NeighborROIindex);
        NeighborROINum = sum(NeighborROIindex);
        NeighborROI = AllROImasks(NeighborROIindex);
        if NeighborROINum
            for cr = 1 : NeighborROINum
                cNeighborRmask = double(NeighborROI{cr});
                NeighOverlap = cROImask + cNeighborRmask;
                cROIoverlap = NeighOverlap(logical(cROImask));
                OverIndsRatio = (sum(cROIoverlap(:)) - cROIPixels)/cROIPixels;
                if OverIndsRatio > 0.2
                    if ROIsLabel(RealROIinds(cr),1) && ~ROIsLabel(nr,1)
                        ROIsLabel(nr,1) = 1;
                        ROIsLabel(nr,2) = ROIsLabel(RealROIinds(cr),1);
                    elseif ~ROIsLabel(RealROIinds(cr),1) && ROIsLabel(nr,1)
                        ROIsLabel(RealROIinds(cr),1) = 1;
                        ROIsLabel(RealROIinds(cr),1) = ROIsLabel(nr,2);
                    elseif ROIsLabel(RealROIinds(cr),1) && ROIsLabel(nr,1)
                        if ROIsLabel(RealROIinds(cr),2) ~= ROIsLabel(nr,2)
                            warning('Overlap label of ROI%d and ROI%d is different, but they do have enough overlapping.',nr,RealROIinds(cr));
                            CorrectLabel = ROIsLabel(min(nr,RealROIinds(cr)),2);
                            ROIsLabel(RealROIinds(cr),2) = CorrectLabel;
                            ROIsLabel(nr,2) = CorrectLabel;
                        else
                            continue;
                        end
                    else
                        ROIsLabel(nr,1) = 1;
                        ROIsLabel(nr,2) = labels;
                        ROIsLabel(RealROIinds(cr),1) = 1;
                        ROIsLabel(RealROIinds(cr),2) = labels;
                        if LabelAdd
                            labels = labels + 1;
                            LabelAdd = 0;
                        end
                    end
                end
             end
        end
    end
end

LabelNum = unique(ROIsLabel(:,2));
LabelNum(LabelNum == 0) = []; 
LabelNumLg = length(LabelNum);
ROImerged = zeros(nROIs,1);
labelStrc = struct('Label',[],'ROIindex',[],'IGmask',[],'IGpos',{},'IGRingmask',[]);
if LabelNumLg > 1
    fprintf('Overlap ROI exists, merge them together.\n');
    for nOL = 1 : LabelNumLg
        labelStrc(nOL).Label = LabelNum(nOL);
        cLabelROIs = find(ROIsLabel(:,2) == LabelNum(nOL));
        labelStrc(nOL).ROIindex = cLabelROIs;
        cLabelRmask = AllROImasks(cLabelROIs);
        cLabelRingmask = AllRingmask(cLabelROIs);
        cSumMask = double(cLabelRmask{1});
        cSumRingmask = double(cLabelRingmask{1});
        for nn = 2:length(cLabelRmask)
            cSumMask = cSumMask + double(cLabelRmask{nn});
            cSumRingmask = cSumRingmask + double(cLabelRingmask{nn});
        end
        cSumMask = cSumMask > 0;
        cSumRingmask = cSumRingmask > 0;  
        b = bwboundaries(cSumMask);
        labelStrc(nOL).IGpos = b;
        labelStrc(nOL).IGmask = cSumMask;
        labelStrc(nOL).IGRingmask = cSumRingmask;
        ROImerged(cLabelROIs) = 1;
    end
end

ROIinfoStrcBU = ROIinfoStrc;
NoneOverlapStruc = structfun(@(x) ROinfoChange(x,logical(ROImerged)),ROIinfoStrc,'UniformOutput', false);  %remove overlapped ROIs
LeftROIs = length(NoneOverlapStruc.ROImask);
if LabelNumLg > 1
    fprintf('Overlap ROI exists, Remove them and add new ROI mask into ROIinfo.\n');
    for nOL = 1 : LabelNumLg
        NoneOverlapStruc.ROImask(LeftROIs + nOL) = {labelStrc(nOL).IGmask};
        NoneOverlapStruc.ROIpos(LeftROIs + nOL) = labelStrc(nOL).IGpos;
        NoneOverlapStruc.ROItype(LeftROIs + nOL) = {'MergedCell'};
        NoneOverlapStruc.ROI_def_trialNo(LeftROIs + nOL) = 1;
        NoneOverlapStruc.Ringmask(LeftROIs + nOL) = {labelStrc(nOL).IGRingmask};
    end
end
ROIinfoRedefine = NoneOverlapStruc;  %add obverlapped ROIs in integrated form
save MergedOverlapinfo.mat ROIinfoStrcBU ROIinfoRedefine labelStrc ROImerged ROIsLabel 

if nargout > 0
    ROIinfoNew = NoneOverlapStruc;
    ROIlabel = labelStrc;
end


function RestSum = RestSumMask(Allmask,RMroiInds)

RestAllMask = Allmask;
RestAllMask(RMroiInds) = [];
RestSum = double(RestAllMask{1});
for n = 2 : length(RestAllMask)
    RestSum = RestSum + double(RestAllMask{n});
end
RestSum = RestSum > 0;
