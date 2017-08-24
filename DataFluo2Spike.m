function nSpikes = DataFluo2Spike(DataAligned,V,P,varargin)
% This function is used for fast oopsi method to estimate spike count, and
% output the estimated spike count for further analysis

[nTrials,nROIs,nF] = size(DataAligned);
nSpikes = zeros(nTrials,nROIs,nF);
ROIstd = zeros(nROIs,1);
for nROI = 1 : nROIs
    cROIdata = squeeze(DataAligned(:,nROI,:));
    cROITrace = reshape(cROIdata',[],1); 
    cStd = mad(cROITrace,1)*1.4826;
    ROIstd(nROI) = cStd;
end
V.T = length(cROITrace);
P.lam = 20;
ppm = ParforProgMon('ParPool progress', nROIs, 10, 500, 100);
parfor nROI = 1 : nROIs
    cROIdata = squeeze(DataAligned(:,nROI,:));
    cROITrace = reshape(cROIdata',[],1); 
    cStd = mad(cROITrace,1)*1.4826;
    if isnan(cStd)
        error('Input data cannot contains nan value.');
    end
%     ROIstd(nROI) = cStd;
%     P.sig = cStd;
    
    nsTrace = smooth(cROITrace,7,'rloess');
    [n_best,~,~,~]=fast_oopsi(nsTrace,V,P,ROIstd(nROI));
    cROIFRMtx = (reshape(n_best,size(cROIdata,2),[]))';
    cROIFRMtx(:,1:2) = 0;
    cROIFRMtx = cROIFRMtx/V.dt;
    nSpikes(:,nROI,:) = cROIFRMtx;
    ppm.increment();
end


% for nROI = 1 : nROIs
%     cROIdata = squeeze(DataAligned(:,nROI,:));
%     
%     cStd = mad(reshape(cROIdata',[],1),1)*1.4826;
%     if isnan(cStd)
%         error('Input data cannot contains nan value.');
%     end
%     ROIstd(nROI) = cStd;
%     P.sig = cStd;
%     parfor nTr = 1 : nTrials
%         nTrace = cROIdata(nTr,:);
%         nsTrace = smooth(nTrace,11,'rloess');
% %         nsTrace(1:4) = mean(nsTrace(1:4));
% %         nsTrace = zscore(nsTrace);
%         [n_best,~,~,~]=fast_oopsi(nsTrace,V,P);
%         n_best(1:4) = 0;
%         n_best(n_best < 0.05) = 0;
%         n_bestReal = n_best/V.dt;
%         nSpikes(nTr,nROI,:) = n_bestReal;
%     end
% end
