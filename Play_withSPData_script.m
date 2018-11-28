
if iscell(nnspike)
    FrameInds = cellfun(@(x) size(x,2),nnspike);
    UsedFrame = ceil(prctile(FrameInds,80));
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
cROI = 1;
if iscell(nnspike)
    cROIDataCell = cellfun(@(x) (x(cROI,:))',nnspike,'Uniformoutput',false);
    cROIDataSP = cell2mat(cROIDataCell);
else
    cROIDataSP = squeeze(nnspike(:,cROI,:));
end

figure;
plot(cROIDataSP)
%% plot spike data sorted by frequency
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
[~,FreqSortInds] = sort(TrFreqsAll);

cROI = 1;
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
% close
cEOI = 27;
cROICellData = squeeze(Datas.ROIMeanTraceData(cEOI,:,:));
hf = figure;
hold on
cFreqNum = size(cROICellData,1);
CMaps = jet(cFreqNum);
FreqInds = cellstr(num2str((1:cFreqNum)'));
hlAll = [];
for cf = 1 : cFreqNum
    hl = plot(cROICellData{cf,1},'Color',CMaps(cf,:),'linewidth',1.8);
    hlAll = [hlAll,hl];
end
ylims = get(gca,'ylim');
line([Datas.AlignedFrame,Datas.AlignedFrame],ylims,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
legend(hlAll,FreqInds,'box','off')

%% batched session from loaded file path
[fn,fp,fi] = uigetfile('*.txt','Please select the session savage path file');
if ~fi
    return;
end
%%
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
%%
while ischar(tline)
    if isempty(tline)
        tline = fgetl(fid);
        continue;
    end
    cd(tline);
    
    TrSummarization_script;
    tline = fgetl(fid);
end

