function varargout = DataFluo2Spike(DataAligned,V,P,varargin)
% This function is used for fast oopsi method to estimate spike count, and
% output the estimated spike count for further analysis
IsNegValueCheck = 0;
if nargin > 3
    if ~isempty(varargin{1})
        IsNegValueCheck = varargin{1};
    end
end
IsStdInput = 0;
if nargin > 4
    if ~isempty(varargin{2})
        IsStdInput = 1;
        ROIstd = varargin{2};
    end
end
if iscell(DataAligned)
    nTrials = length(DataAligned);
    nROIs = size(DataAligned{1},1);
    nFrameInds = cellfun(@(x) size(x,2),DataAligned);
    nF = max(nFrameInds);
    SessionTraceData = zeros(nROIs,sum(nFrameInds));
    IsContAcq = 1;
    SpikeData = cell(nTrials,1);
else
    [nTrials,nROIs,nF] = size(DataAligned);
    SessionTraceData = zeros(nROIs,nTrials*nF);
    IsContAcq = 0;
    SpikeData = zeros(nTrials,nROIs,nF);
end

if ~IsStdInput
    ROIstd = zeros(nROIs,1);
    if ~iscell(DataAligned)
        for nROI = 1 : nROIs
            cROIdata = squeeze(DataAligned(:,nROI,:));
            cROITrace = reshape(cROIdata',[],1); 
            cStd = mad(cROITrace,1)*1.4826;
            ROIstd(nROI) = cStd;
            SessionTraceData(nROI,:) = cROITrace;
        end

    else
        for nROI = 1 : nROIs
            cROIdata = cellfun(@(x) x(nROI,:),DataAligned,'UniformOutput',false);
            cROIdata = cROIdata';
            SessionTraceData(nROI,:) = cell2mat(cROIdata);
            cStd = mad(SessionTraceData(nROI,:),1)*1.4826;
            ROIstd(nROI) = cStd;
        end
    end
else
    if ~iscell(DataAligned)
        for nROI = 1 : nROIs
            cROIdata = squeeze(DataAligned(:,nROI,:));
            cROITrace = reshape(cROIdata',[],1); 
            SessionTraceData(nROI,:) = cROITrace;
        end

    else
        for nROI = 1 : nROIs
            cROIdata = cellfun(@(x) x(nROI,:),DataAligned,'UniformOutput',false);
            cROIdata = cROIdata';
            SessionTraceData(nROI,:) = cell2mat(cROIdata);
        end
    end
end
%%
V.T = size(SessionTraceData,2);
P.lam = 10;
TraceSpikeData = zeros(size(SessionTraceData));
TraceSpikeDataNS = zeros(size(SessionTraceData));
ROIcoefData = zeros(nROIs,4);
% ppm = ParforProgMon('ParPool progress', nROIs, 10, 500, 100);
parfor nROI = 1 : nROIs
%%     cROIdata = squeeze(DataAligned(:,nROI,:));
    cROITrace = SessionTraceData(nROI,:);
    [Count,Cent] = hist(cROITrace,100);  % using the maxium mode value as baseline activity
    [~,inds] = max(Count);
    PBase = Cent(inds);
%     cROITrace = reshape(cROIdata',[],1); 
    if IsNegValueCheck
        cROITrace = cROITrace - min(cROITrace); % make all values non-negtive value
    end
%     cStd = mad(cROITrace,1)*1.4826;
%     cStd = ROIstd(nROI);
    if isnan(cStd)
        error('Input data cannot contains nan value.');
    end
    nsTrace = smooth(cROITrace,7,'rloess');
    Resdues = cROITrace(:) - nsTrace(:);
    TraceNoiseStd = std(Resdues);
%     ROIstd(nROI) = cStd;
%     P.sig = cStd;
    [n_best_NoSmooth,p_best_NoSmooth,~,C_NoSmooth]=fast_oopsi(cROITrace,V,P,TraceNoiseStd,PBase);
    Fcal_Nosmooth = p_best_NoSmooth.a * C_NoSmooth + p_best_NoSmooth.b + normrnd(0,p_best_NoSmooth.sig,size(C_NoSmooth));
    [CoefNosmooth,CoefpNS] = corrcoef(Fcal_Nosmooth,cROITrace);
    %%
    [n_best,p_best,~,C]=fast_oopsi(nsTrace,V,P,TraceNoiseStd,PBase);
    Fcal = p_best.a * C + p_best.b + normrnd(0,p_best.sig,size(C));
    [Coef,Coefp] = corrcoef(Fcal,nsTrace);
    %%
    TraceSpikeData(nROI,:) = n_best;
    TraceSpikeDataNS(nROI,:) = n_best_NoSmooth;
    ROIcoefData(nROI,:) = [CoefNosmooth(1,2),Coef(1,2),CoefpNS(1,2),Coefp(1,2)];
    
end
%% convert the spike result
SpikeDataNS = SpikeData;
if ~IsContAcq
    for cROI = 1 : nROIs
        cROItrace = TraceSpikeData(cROI,:);
        cROIFRMtx = reshape(cROItrace',nF,[]);
        cROIFRMtx(:,1:2) = 0;
        cROIFRMtx(:,end-2:end) = 0;
       %     cROIFRMtx = cROIFRMtx/V.dt;
        SpikeData(:,cROI,:) = cROIFRMtx';
        % ###########################################################
        cROItrace = TraceSpikeDataNS(cROI,:);
        cROIFRMtx = reshape(cROItrace',nF,[]);
        cROIFRMtx(:,1:2) = 0;
        cROIFRMtx(:,end-2:end) = 0;
       %     cROIFRMtx = cROIFRMtx/V.dt;
        SpikeDataNS(:,cROI,:) = cROIFRMtx';
    end
else
    TraceSpikeData(:,1:5) = 0;
    k = 1;
    for cTr = 1 : nTrials
        cTrData = TraceSpikeData(:,k:(k+nFrameInds(cTr)-1));
        SpikeData{cTr} = cTrData;

        % #############################################################
        cTrData = TraceSpikeDataNS(:,k:(k+nFrameInds(cTr)-1));
        SpikeDataNS{cTr} = cTrData;
        k = k+nFrameInds(cTr);
    end
end
%%
if nargout == 1
    varargout{1} = SpikeData;
elseif nargout == 2
    varargout{1} = SpikeData;
    varargout{2} = ROIcoefData;
elseif nargout > 2
    varargout{1} = SpikeData;
    varargout{2} = ROIcoefData;
    varargout{3} = SpikeDataNS;
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

