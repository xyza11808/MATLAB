
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
%
saveas(hf,'Tuning BF distribution plots','png');
saveas(hf,'Tuning BF distribution plots');
close(hf);

%% choice response ROI index

OnlyLAnsIndex = find(ROIRespType(:,2) & ~ROIRespType(:,3));
OnlyRAnsIndex = find(~ROIRespType(:,2) & ROIRespType(:,3));
BothAnsIndex = find(ROIRespType(:,2) & ROIRespType(:,3));

save ROIselectiveIndex.mat NMROIIndex nFreqs nROIs OnlyLAnsIndex OnlyRAnsIndex BothAnsIndex -v7.3
