
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
nFreqs = (length(ROIAboveThresInds{1,1}) - 2)/2;
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
[~,maxInds] = max(SigROICoefMtx,[],2);
[~,sortSeq] = sort(maxInds);
hhhf = figure;
imagesc(SigROICoefMtx(sortSeq,:),[0 2]);
xlabel('Freqs');
set(gca,'ytick',1:cSigROIs,'yticklabel',SigROIInds(sortSeq));
title('SP pred ROI Tun Coef');
saveas(hhhf,'SPPred ROITun Coef Plots');
saveas(hhhf,'SPPred ROITun Coef Plots','png');
close(hhhf);

LAnsROIInds = find(ROIRespType(:,2));
RAnsROIInds = find(ROIRespType(:,3));
if ~isempty(LAnsROIInds)
    for cr = 1 : length(LAnsROIInds)
        cLAnsRInds = LAnsROIInds(cr);
        LAnsCoef = ROIRespTypeCoef{cLAnsRInds,2};
        if any(SigROIInds(:) == cLAnsRInds)
            crStimCoefInds = SigROIInds(:) == cLAnsRInds;
            crStimCoef = SigROICoefMtx(crStimCoefInds,:);
            ExCludeInds = crStimCoef >= LAnsCoef;
            if sum(ExCludeInds(1:nFreqs/2)) % if any stim coef is larger than answer coef
                
    
save SigSelectiveROIInds.mat SigROIInds LAnsROIInds RAnsROIInds SigROICoefMtx -v7.3
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
