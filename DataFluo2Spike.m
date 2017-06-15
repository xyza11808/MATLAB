function nSpikes = DataFluo2Spike(DataAligned,V,P,varargin)
% This function is used for fast oopsi method to estimate spike count, and
% output the estimated spike count for further analysis

[nTrials,nROIs,nF] = size(DataAligned);
nSpikes = zeros(nTrials,nROIs,nF);
ROIstd = zeros(nROIs,1);
V.T = nF;
P.lam = 20;
for nROI = 1 : nROIs
    cROIdata = squeeze(DataAligned(:,nROI,:));
    cStd = mad(reshape(cROIdata',[],1),1)*1.4826;
    if isnan(cStd)
        error('Input data cannot contains nan value.');
    end
    ROIstd(nROI) = cStd;
    P.sig = cStd;
    parfor nTr = 1 : nTrials
        nTrace = cROIdata(nTr,:);
        nsTrace = smooth(nTrace,11,'rloess');
%         nsTrace(1:4) = mean(nsTrace(1:4));
%         nsTrace = zscore(nsTrace);
        [n_best,~,~,~]=fast_oopsi(nsTrace,V,P);
        n_best(1:4) = 0;
        n_best(n_best < 0.05) = 0;
        n_bestReal = n_best/V.dt;
        nSpikes(nTr,nROI,:) = n_bestReal;
    end
end
