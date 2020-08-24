function [TraceSpikeData, TraceEstimatedTrace, ROIFitCoefs] = ...
    MtxTrace2SP(SessionTraceData,Paras)
[spkSNR,lamPr,fr,DecayTime] = deal(Paras{:});
nROIs = size(SessionTraceData,1);
TraceSpikeData = zeros(size(SessionTraceData));
TraceEstimatedTrace = zeros(size(SessionTraceData));
ROIFitCoefs = cell(nROIs,1);
if max(SessionTraceData(:)) > 50
    SessionTraceData = SessionTraceData/100;
end
parfor cROI = 1 : nROIs
    %%
    cROISessTrace = SessionTraceData(cROI,:);
    cROISessTraceNM = cROISessTrace - min(cROISessTrace);
    
%     lam = choose_lambda(exp(-1/(fr*DecayTime)),GetSn(cROISessTraceNM,[],[],fr),lamPr);
    lam = choose_lambda(exp(-1/(fr*DecayTime)),GetSn(cROISessTraceNM,[],[],fr),lamPr);
    spkmin = spkSNR*GetSn(cROISessTraceNM,[],[],fr);
    
    [Count,Cent] = hist(cROISessTraceNM,100);
    [~,MaxInds] = max(Count);
    fBase = Cent(MaxInds);
    %%
    if (prctile(cROISessTraceNM,99) - fBase) < 1.5  % filtering the trace when signal is low
        if fr < 35
            cDes = designfilt('lowpassfir','PassbandFrequency',1,'StopbandFrequency',5,...
                'StopbandAttenuation', 60,'SampleRate',fr,'DesignMethod','kaiserwin');  %'ZeroPhase',true,
%             cDesNew = designfilt('bandpassfir','PassbandFrequency1',0.5,'StopbandFrequency1',0.3,...
%                 'PassbandFrequency2',5,'StopbandFrequency2',6,'SampleRate',fr,'StopbandAttenuation1',60,...
%                 'StopbandAttenuation2',60,'DesignMethod','kaiserwin');
        else
            cDes = designfilt('lowpassfir','PassbandFrequency',5,'StopbandFrequency',10,...
                'StopbandAttenuation', 50,'SampleRate',fr,'DesignMethod','kaiserwin');
        end
        NFSignal = filtfilt(cDes,cROISessTraceNM);
    else
        NFSignal = cROISessTraceNM;
    end 
%%     if any(isnan(NFSignal))
%         NFSignal = cROISessTraceNM;
%         warning('cTrace filtering skipped due to nan value output.\n');
%     end
%     if any(isnan(NFSignal))
%         fprintf('DEbug point.\n');
%     end
    [cc2, spk2, opts_oasis2] = deconvolveCa(NFSignal,'ar2','optimize_b',true,'method','foopsi',...
                                    'optimize_pars',true,'maxIter',100,'smin',spkmin,'window',fr*5,'lambda',lam);
    %%
    TraceSpikeData(cROI,:) = spk2;
    TraceEstimatedTrace(cROI,:) = cc2;
    ROIFitCoefs{cROI} = opts_oasis2;
end
