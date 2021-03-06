% load('./SP_RespField_ana/SPDataBehavCoefSaveOff_191228.mat');
load(fullfile(cSessPath,'SP_RespField_ana','SPDataBehavCoefSaveOff_191228.mat'));

cSessOnRespInds = logical(ROIRespType(:,1));
cSessOffRespInds = logical(ROIRespType(:,4));
OnTunData = ROIRespTypeCoef(cSessOnRespInds,1);
OffTunData = ROIRespTypeCoef(cSessOffRespInds,4);

OnOffDataCellAll = ROIRespTypeCoef(:,[1,4]);
nROIs = size(OnOffDataCellAll,1);
OnOffMergeData = cell(nROIs,1);
for cR = 1 : nROIs
    cRDatas = [OnOffDataCellAll{cR,1};OnOffDataCellAll{cR,2}];
    if ~isempty(cRDatas)
        [~,SortInds] = sort(cRDatas(:,2),'descend');
        cRDatas = cRDatas(SortInds,:);
    end
    OnOffMergeData{cR} = cRDatas;
end
nFreqs = (length(ROIAboveThresInds{1,1}) - 6)/2;
%%
OnOrOffROIinds = cSessOnRespInds | cSessOffRespInds;
OnSigDataCell = ROIRespTypeCoef(OnOrOffROIinds,1);
OffSigDataCell = ROIRespTypeCoef(OnOrOffROIinds,4);
cSigROIs = sum(OnOrOffROIinds);
cROIBaseCoef = zeros(1,nFreqs);
SigROICoefMtx = zeros(cSigROIs,nFreqs);
for cR = 1 : cSigROIs
    
    cROIOnCoef = cROIBaseCoef;
    if ~isempty(OnSigDataCell{cR})
        cROIOnCoef(OnSigDataCell{cR}(:,1)) = OnSigDataCell{cR}(:,2);
    end
    
    cROIOffCoef = cROIBaseCoef;
    if ~isempty(OffSigDataCell{cR})
        cROIOffCoef(OffSigDataCell{cR}(:,1)) = OffSigDataCell{cR}(:,2);
    end
    MergedCoef = max([cROIOffCoef;cROIOnCoef]);
    
    SigROICoefMtx(cR,:) = MergedCoef;
end
SigROIInds = find(OnOrOffROIinds);

LAnsROIInds = find(ROIRespType(:,2));
RAnsROIInds = find(ROIRespType(:,3));
if ~isempty(LAnsROIInds)
    for cr = 1 : length(LAnsROIInds)
        cLAnsRInds = LAnsROIInds(cr);
        LAnsCoef = ROIRespTypeCoef{cLAnsRInds,2}(1,2);
        if any(SigROIInds(:) == cLAnsRInds)
            crStimCoefInds = SigROIInds(:) == cLAnsRInds;
            crStimCoef = SigROICoefMtx(crStimCoefInds,:);
            ExCludeInds = crStimCoef >= LAnsCoef;
            if sum(ExCludeInds(1:floor(nFreqs/2))) % if any stim coef is larger than answer coef
                ExcludeCoefInds = [~ExCludeInds(1:floor(nFreqs/2)),false(1,ceil(nFreqs/2))];
                SigROICoefMtx(crStimCoefInds,ExcludeCoefInds) = 0;
            else
                SigROICoefMtx(crStimCoefInds,1:floor(nFreqs/2)) = 0;
            end
        end
    end
end
    % processing the right condition
if ~isempty(RAnsROIInds)
    for ccr = 1 : length(RAnsROIInds)
        cRAnsRInds = RAnsROIInds(ccr);
        RAnsCoef = ROIRespTypeCoef{cRAnsRInds,3}(1,2);
        if any(SigROIInds(:) == cRAnsRInds)
            crStimROIinds = SigROIInds(:) == cRAnsRInds;
            crStimCoef = SigROICoefMtx(crStimROIinds,:);
            SavedCoefInds = crStimCoef >= RAnsCoef;
            if sum(SavedCoefInds((1 + ceil(nFreqs/2)):end))
                ExcludeCoefInds = [false(1,ceil(nFreqs/2)),SavedCoefInds((1+ceil(nFreqs/2)):end)];
                SigROICoefMtx(crStimROIinds,ExcludeCoefInds) = 0;
            else
                SigROICoefMtx(crStimROIinds,(1+ceil(nFreqs/2)):end) = 0;
            end
        end
    end
end
nStimSigROIs = length(SigROIInds);
StimExcludeInds = zeros(nStimSigROIs,1);
for cr = 1 : nStimSigROIs
    if sum(SigROICoefMtx(cr,:)) < 0.01
        StimExcludeInds(cr) = 1;
    end
end
%vExclude false stim response
SigROIInds = SigROIInds(~StimExcludeInds);
SigROICoefMtx = SigROICoefMtx(~StimExcludeInds,:);

%% processing delayed ans function coef index
LAnsDelayROIInds = find(ROIRespType(:,5));
RAnsDelayROIInds = find(ROIRespType(:,6));
% left
LAnsDelayROINum = numel(LAnsDelayROIInds);
LAnsDMaxCoef = zeros(LAnsDelayROINum,1);
for cLAnsDR = 1 : LAnsDelayROINum
    LAnsDMaxCoef(cLAnsDR) = ROIRespTypeCoef{LAnsDelayROIInds(cLAnsDR),5}(1,2);
end
%right
RAnsDelayROINum = numel(RAnsDelayROIInds);
RAnsDMaxCoef = zeros(RAnsDelayROINum,1);
for cRAnsDR = 1 : RAnsDelayROINum
    RAnsDMaxCoef(cRAnsDR) = ROIRespTypeCoef{RAnsDelayROIInds(cRAnsDR),6}(1,2);
end

 %% 
[~,maxInds] = max(SigROICoefMtx,[],2);
[~,sortSeq] = sort(maxInds);
hhhf = figure;
imagesc(SigROICoefMtx(sortSeq,:),[0 2]);
xlabel('Freqs');
set(gca,'ytick',1:cSigROIs,'yticklabel',SigROIInds(sortSeq));
title('SP pred ROI Tun Coef');
%%
saveas(hhhf,'SPPred ROITun Coef Plots');
saveas(hhhf,'SPPred ROITun Coef Plots','png');
close(hhhf);

LAnsMergedInds = find(ROIRespType(:,5) | ROIRespType(:,2));
RAnsMergedInds = find(ROIRespType(:,6) | ROIRespType(:,3));

save SigSelectiveROIInds.mat SigROIInds LAnsROIInds RAnsROIInds SigROICoefMtx ...
    LAnsDelayROIInds LAnsDMaxCoef RAnsDelayROIInds RAnsDMaxCoef LAnsMergedInds RAnsMergedInds -v7.3
%%

OnTunBF = cellfun(@(x) x(1,1),OnTunData);
OffTunBF = cellfun(@(x) x(1,1),OffTunData);

[CountOn,CentOn] = hist(OnTunBF);
[CountOff,CentOff] = hist(OffTunBF);
% hf = figure;
% hold on
% plot(CentOn,CountOn,'r-o','linewidth',1.6);
% plot(CentOff,CountOff,'b-o','linewidth',1.6);
% 
% set(gca,'xlim',[0 9]);
% % saveas(hf,'')
%%
NEmpInds = ~cellfun(@isempty,OnOffMergeData);
NMDatas = OnOffMergeData(NEmpInds);
NM_BFAlls = cellfun(@(x) x(1,1),NMDatas);
NMROIIndex = find(NEmpInds);  % ROI index for each Tuning ROIs
nedges = 0.5:nFreqs+0.5;
[ALlCount,AllCent] = hist(NM_BFAlls,nedges);
hf = figure;
plot(1:nFreqs,ALlCount(1:end-1),'r-o','linewidth',1.6);
set(gca,'xlim',[0 nFreqs+1]);
xlabel('StimTypes');
ylabel('ROI Number');
%%
saveas(hf,'Tuning BF distribution plots','png');
saveas(hf,'Tuning BF distribution plots');
close(hf);

%% choice response ROI index

OnlyLAnsIndex = find(ROIRespType(:,2) & ~ROIRespType(:,3));
OnlyRAnsIndex = find(~ROIRespType(:,2) & ROIRespType(:,3));
BothAnsIndex = find(ROIRespType(:,2) & ROIRespType(:,3));

save ROIselectiveIndex.mat NMROIIndex nFreqs nROIs OnlyLAnsIndex OnlyRAnsIndex BothAnsIndex -v7.3
