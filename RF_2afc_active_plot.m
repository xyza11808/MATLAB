function [sumNewMask,PlotMap] = RF_2afc_active_plot(ROImask,RFInds,BehvInds,varargin)
%the input ROImask should be a cell format data that gives ROI position for
%each neuron. if there is any overlapping between two ROIs, then the latter
%ROIs position will exclude the overlapping position
% RFInds: indicates whether ROI is active during RF test, in a vector
% form
% BehvInds: indicates whether ROI is active during 2AFC test, in a vector
% form

if ~islogical(RFInds)
    RFInds = logical(RFInds);
end
if ~islogical(BehvInds)
    BehvInds = logical(BehvInds);
end

ROInum = length(ROImask);
ROIsummask = double(ROImask{1});
newROImask = zeros(ROInum,size(ROIsummask,1),size(ROIsummask,2));
newROImask(1,:,:) = ROIsummask;

for nROI = 2 : ROInum
    cROImask = double(ROImask{nROI});
    OverLapInds = find((cROImask+ROIsummask) > 1 );
    if ~isempty(OverLapInds)
        cROImask(OverLapInds) = 0;
    end
    ROIsummask = ROIsummask + cROImask;
    newROImask(nROI,:,:) = cROImask;
end
newROImask(~(RFInds+BehvInds),:,:) = newROImask(~(RFInds+BehvInds),:,:)*0;
newROI2afcmask = newROImask;
newROIrfmask = newROImask;
newROIrfmask(RFInds,:,:) = newROIrfmask(RFInds,:,:)*2; %set to number 2 for RF active neurons

OverLapInds = (RFInds+BehvInds) > 1;
newROImask(OverLapInds,:,:) = newROI2afcmask(OverLapInds,:,:) + newROIrfmask(OverLapInds,:,:);
RFInds(OverLapInds) = false;  %exclude overlap inds 
BehvInds(OverLapInds) = false;  %exclude overlap inds 
newROImask(RFInds,:,:) = newROIrfmask(RFInds,:,:);
newROImask(BehvInds,:,:) = newROI2afcmask(BehvInds,:,:);


% sumNewMask = squeeze(newROImask(1,:,:));
% for n = 2 : ROInum
%     cROImask = squeeze(newROImask(n,:,:));
%     sumNewMask = sumNewMask + cROImask;
% end

sumNewMask = squeeze(sum(newROImask));
PlotMap = [0,0,0;0,1,0;1,0,0;1,1,0];
