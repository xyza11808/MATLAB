function ROICoefDisCorr(SmoothData,ROIcenters,varargin)
%this function is only used for calculating all ROIs corrcoef correlation
%with ROI distance, Maybe more function will add in the future
% XIN Yu

PairedROIcoef=ROI_Coeff_Calcu(SmoothData);
ROICentersDis=pdist(ROIcenters);

if length(PairedROIcoef) ~= length(ROICentersDis)
    warning('Error input, quit ROICoefDisCorr function...\n');
    return;
end

if ~isdir('./AllROI_distance_coef/')
    mkdir('./AllROI_distance_coef/');
end
cd('./AllROI_distance_coef/');

[CoefValue,CoefP]=corrcoef(PairedROIcoef,ROICentersDis);
[SortROIDis,I]=sort(ROICentersDis);
ROIDisCoef=CoefValue(1,2);
ROICoefP=CoefP(1,2);
c = linspace(1,10,length(PairedROIcoef));
hPlot=figure;
scatter(SortROIDis,PairedROIcoef(I),40,c);
colormap cool;
title(sprintf('CorrCoef value = %.3f and Pvalue = %.2e',ROIDisCoef,ROICoefP));
xlabel('Paired Distance');
ylabel('Paired ROI coef');
saveas(hPlot,'ROI_distance_coef_corrlation.png');
saveas(hPlot,'ROI_distance_coef_corrlation.fig');
close(hPlot);
save ROIPairedData.mat PairedROIcoef ROICentersDis -v7.3

cd ..;
