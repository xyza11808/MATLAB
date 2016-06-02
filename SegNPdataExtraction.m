function LabelSegNPData = SegNPdataExtraction(im,LabelNPmask,varargin)
%this function is used to extract segmental NP datat from Raw image and
%passed to matlab GUI

imsize=size(im);
LabelNum=length(LabelNPmask);
LabelNPData=zeros(LabelNum,imsize(3));

for Label = 1:LabelNum
    LabelMask = LabelNPmask{Label};
%     PixelNum = sum(sum(LabelMask));
    D3IMMask = logical(repmat(LabelMask,1,1,imsize(3)));
    ExtractData = double(im(D3IMMask));
    D3IMData = reshape(ExtractData,[],imsize(3));
    MeanNPData = mean(D3IMData);
    LabelNPData(Label,:) = MeanNPData;
end

LabelSegNPData = LabelNPData;