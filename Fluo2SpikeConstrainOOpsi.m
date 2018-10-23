function varargout = Fluo2SpikeConstrainOOpsi(DataRaw,varargin)
% This function is using constrained fast oopsi method to estimate spike count, and
% output the estimated spike count for further analysis
currentUsedInput = varargin(1:4);
[spkSNR,lamPr,fr,DecayTime] = deal(currentUsedInput{:});
if isempty(spkSNR)
    spkSNR = 0.5;
end
if isempty(lamPr)
    lamPr = 0.99;
end
if isempty(fr)
    fr = 30;
end
if isempty(DecayTime)
    DecayTime = 2;
end

if iscell(DataRaw)
    nTrials = length(DataRaw);
    nROIs = size(DataRaw{1},1);
    nFrameInds = cellfun(@(x) size(x,2),DataRaw);
    nF = max(nFrameInds);
    SessionTraceData = zeros(nROIs,sum(nFrameInds));
    IsContAcq = 1;
    SpikeData = cell(nTrials,1);
else
    [nTrials,nROIs,nF] = size(DataRaw);
    SessionTraceData = zeros(nROIs,nTrials*nF);
    IsContAcq = 0;
    SpikeData = zeros(nTrials,nROIs,nF);
end

if ~iscell(DataRaw)
    for nROI = 1 : nROIs
        cROIdata = squeeze(DataRaw(:,nROI,:));
        cROITrace = reshape(cROIdata',[],1); 
        SessionTraceData(nROI,:) = cROITrace;
    end

else
    for nROI = 1 : nROIs
        cROIdata = cellfun(@(x) x(nROI,:),DataRaw,'UniformOutput',false);
        cROIdata = cROIdata';
        SessionTraceData(nROI,:) = cell2mat(cROIdata);
    end
end
%% estimate spike train using constrained fast oopsi method
TraceSpikeData = zeros(size(SessionTraceData));
TraceEstimatedTrace = zeros(size(SessionTraceData));
ROIFitCoefs = cell(nROIs,1);
parfor cROI = 1 : nROIs
    
    cROISessTrace = SessionTraceData(cROI,:)/100;
    cROISessTraceNM = cROISessTrace - min(cROISessTrace);
    
    lam = choose_lambda(exp(-1/(fr*DecayTime)),GetSn(cROISessTraceNM),lamPr);
    spkmin = spkSNR*GetSn(cROISessTraceNM);
    
    [cc2, spk2, opts_oasis2] = deconvolveCa(cROISessTraceNM,'ar1','optimize_b',true,'method','thresholded',...
                                    'optimize_pars',true,'maxIter',100,'smin',spkmin,'window',200,'lambda',lam);
    TraceSpikeData(cROI,:) = spk2;
    TraceEstimatedTrace(cROI,:) = cc2;
    ROIFitCoefs{cROI} = opts_oasis2;
end

%% set output data formation
% SpikeDataNS = SpikeData;
if ~IsContAcq
    for cROI = 1 : nROIs
        cROItrace = TraceSpikeData(cROI,:);
        cROIFRMtx = reshape(cROItrace',nF,[]);
        cROIFRMtx(:,1:5) = 0;
        cROIFRMtx(:,end-2:end) = 0;
        
        SpikeData(:,cROI,:) = cROIFRMtx';
    end
else
    TraceSpikeData(1,1:5) = 0;
    k = 1;
    for cTr = 1 : nTrials
        cTrData = TraceSpikeData(:,k:(k+nFrameInds(cTr)-1));
        SpikeData{cTr} = cTrData;
        k = k+nFrameInds(cTr);
    end
end

%%
if nargout == 1
    varargout{1} = SpikeData;
elseif nargout == 2
    varargout{1} = SpikeData;
    varargout{2} = TraceEstimatedTrace;
elseif nargout > 2
    varargout{1} = SpikeData;
    varargout{2} = TraceEstimatedTrace;
    varargout{3} = ROIFitCoefs;
end