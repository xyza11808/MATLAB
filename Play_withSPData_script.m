
FrameInds = cellfun(@(x) size(x,2),nnspike);
UsedFrame = ceil(prctile(FrameInds,80));

if iscell(nnspike)
    SPsizeData = [length(nnspike),size(nnspike{1},1),max(FrameInds)];
    SPDataAll = zeros(SPsizeData);
    for cTr = 1 : length(nnspike)
        SPDataAll(cTr,:,:) = [nnspike{cTr},nan(SPsizeData(2),SPsizeData(3) - FrameInds(cTr))];
    end
    UsedSPData = SPDataAll(:,:,1:UsedFrame);
    SPsizeDataNew = size(UsedSPData);
else
    UsedSPData = nnspike;
    SPsizeDataNew = size(UsedSPData);
end

%%
AlignedSortPlotAll_ForSP(UsedSPData,behavResults,frame_rate,FRewardLickT,frame_lickAllTrials,[],ROIstate);

%%
cROI = 106;
cROIDataCell = cellfun(@(x) (x(cROI,:))',nnspike,'Uniformoutput',false);

cROIDataSP = cell2mat(cROIDataCell);
figure;
plot(cROIDataSP)
%% plot spike data sorted by frequency
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
[~,FreqSortInds] = sort(TrFreqsAll);

cROI = 22;
cROIData = squeeze(UsedSPData(:,cROI,:));
figure
imagesc(cROIData(FreqSortInds,:))

%%
cROI = 1;
cROIDataCell = cellfun(@(x) (x(cROI,:))',DataRaw,'Uniformoutput',false);

cROIData = cell2mat(cROIDataCell);
yyaxis right
plot(cROIData)

%%
HiSNRData = cROIDataSP;
HiSNRData((cROIDataSP < 3*std(cROIDataSP))) = 0;
yyaxis left
hold on
plot(HiSNRData,'m')

%%
Datas = load('PlotRelatedDataSP.mat');
%%
close
cEOI = 1;
cROICellData = squeeze(Datas.ROIMeanTraceData(cEOI,:,:));
hf = figure;
hold on
cFreqNum = size(cROICellData,1);
CMaps = jet(cFreqNum);
for cf = 1 : cFreqNum
    plot(cROICellData{cf,1},'Color',CMaps(cf,:),'linewidth',1.8);
end
ylims = get(gca,'ylim');
line([Datas.AlignedFrame,Datas.AlignedFrame],ylims,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');


%% aligned data for each behavior events



