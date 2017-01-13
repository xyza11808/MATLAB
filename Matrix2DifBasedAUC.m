function [ROIDisAUC, ROIDisAUCMean] = Matrix2DifBasedAUC(MatrixAUC)

[nROI,nStim,~] = size(MatrixAUC);
ROIDisAUC = cell(nROI,nStim-1);
ROIDisAUCMean = zeros(nROI,nStim-1);
for nxnx = 1 : nROI
    cMatrix = squeeze(MatrixAUC(nxnx,:,:));
    for nmnm = 1 : (nStim-1)
        DisAUC = diag(cMatrix,nmnm);
        ROIDisAUC(nxnx,nmnm) = {DisAUC};
        ROIDisAUCMean(nxnx,nmnm) = mean(DisAUC);
    end
end