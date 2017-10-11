clear
clc
% load the calcium data mat file
[fn,fp,fi] = uigetfile('*.mat','Please select the calcium analysis data','MultiSelect','on');
if ~fi
    return;
end
cd(fp);
if ~iscell(fn)
    fprintf('Please select all output matfile.\n'); % select both CaTrialsSIM_* file and ROIinfoBU_* file
    return;
else
     load(fn{1});
     load(fn{2});
end

%% load behavior parameters
[fn,fp,fi] = uigetfile('*.*','Please select the stimulus file'); % select the stimulus file, such as "mouse4_75_97_2016110701_awake"
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
SoundText = textscan(fid,'%d %d %d');

%% data plots
FreqArray = double(SoundText{1});
DBArray = double(SoundText{2});
SoundArray = double(cell2mat(SoundText));

ExcludeInds = FreqArray == 0;
SessData = SavedCaTrials.f_raw;

SessData(ExcludeInds,:,:) = [];
FreqArray(ExcludeInds) = [];
DBArray(ExcludeInds) = [];
SoundArray(ExcludeInds,:) = [];

Frate = round(1000/SavedCaTrials.FrameTime);
NorData = zeros(size(SessData));
nROIs = size(SessData,2);
nTrs = size(SessData,1);
for cROI = 1 : nROIs
    for cTr = 1 : nTrs
        fbase = mean(squeeze(SessData(cTr,cROI,1:Frate)));
        NorData(cTr,cROI,:) = (squeeze(SessData(cTr,cROI,:)) - fbase)/fbase*100;
    end
end
% calculate the mod data
ModNorDataAll = zeros(size(SessData));
for cROI = 1 : nROIs
    cROIdata = squeeze(SessData(:,cROI,:));
    [cROIbaseCount,cROIbaseCenter] = hist(reshape(cROIdata(:,1:Frate),[],1),100);
    [~,maxInds] = max(cROIbaseCount);
    cROIbasemod = cROIbaseCenter(maxInds);
    cROINorData = (cROIdata - cROIbasemod)./cROIbasemod*100;
    ModNorDataAll(:,cROI,:) = cROINorData;
end

%%
save NorMatFile.mat NorData ModNorDataAll -v7.3
if ~isdir('ROI_resp_colorPlot')
    mkdir('ROI_resp_colorPlot');
end
cd('ROI_resp_colorPlot');

UnevenRFrespPlot(NorData,DBArray,FreqArray,Frate); 
%%
if ~isdir('ROI_resp_vShape')
    mkdir('ROI_resp_vShape');
end
cd('ROI_resp_vShape');

sound_array = double(cell2mat(SoundText));
[~,VSDataStrc] = in_site_freTuning_update(NorData,sound_array,'FreqTun_plot',Frate,'simple_fit',SavedCaTrials,0);
RFData = VSDataStrc.RFdataAll;
FreqUse = VSDataStrc.FreqTypes;
DBUse = VSDataStrc.DBTypes;
FreqTickStr = cellstr(num2str(FreqUse(:)/1000,'%.1f'));
for cROI = 1 : nROIs
    cROIdata = squeeze(RFData(cROI,:,:));
    hhf = figure('position',[500 500 950 560],'PaperPositionMode','auto');
    imagesc(cROIdata,VSDataStrc.RFclim(cROI,:));
    colormap gray;
    set(gca,'YDir','normal');
    set(gca,'xtick',1:length(FreqUse),'xticklabel',FreqTickStr,'ytick',1:length(DBUse),'yticklabel',flipud(DBUse),'FontSize',20);
    title(sprintf('ROI%d Frequency response',cROI));
    hbar = colorbar;
    set(get(hbar,'Title'),'string','\DeltaF/F_0','FontSize',14);
    set(hbar,'ytick',VSDataStrc.RFclim(cROI,:));
    saveas(hhf,sprintf('ROI%d vshape plot',cROI));
    saveas(hhf,sprintf('ROI%d vshape plot',cROI),'png');
    close(hhf);
end
save VshapeDataSave.mat VSDataStrc -v7.3
cd ..;
cd ..;

%%
RespWin = [0.2,1.2]; % 1s after stimulus onset

DBtypes = unique(SoundArray(:,2));
FreqTypes = unique(SoundArray(:,1));
disp(DBtypes');
DBuseInds = input('Please select the used DB value, input the index:\n','s');
DBuseInds = str2num(DBuseInds);
UsedInds = SoundArray(:,2) == DBtypes(DBuseInds);
UsedFreqs = SoundArray(UsedInds,1);
UsedData = NorData(UsedInds,:,:);
UsedRespData = squeeze(mean(UsedData(:,:,(Frate+round(RespWin(1)*Frate)):(Frate+round(RespWin(2)*Frate))),3));
%%
FreqRespData = zeros(length(FreqTypes),size(UsedRespData,2));
for  cFreq = 1 : length(FreqTypes)
    cFreqInds = UsedFreqs == FreqTypes(cFreq);
    cFreqData = mean(UsedRespData(cFreqInds,:));
    FreqRespData(cFreq,:) = cFreqData;
end
ROImaxResp = max(FreqRespData);
save CellRespDataSave.mat FreqRespData FreqTypes NorData SoundArray DBuseInds -v7.3

%% compare between awake and anes session
clear
clc
[fn,fp,~] = uigetfile('CellRespDataSave.mat','Please select the awake data');
TaskfilePath = fullfile(fp,fn);
cd(fp);
[fn,fp,~] = uigetfile('CellRespDataSave.mat','Please select the anes data');
PassFilePath = fullfile(fp,fn);
TaskData = load(TaskfilePath);
PassData = load(PassFilePath);
%% after last block
TaskRespData = max(TaskData.FreqRespData);
PassRespData = max(PassData.FreqRespData);
nFreqs = TaskData.FreqTypes;
IsPairedROI = 0;
if size(TaskRespData,2) == size(PassRespData,2)
    ColorPlot = jet(length(nFreqs));
    FreqLengStr = cell(1,length(nFreqs));
    FreqLengh = [];
    hf = figure;
    hold on
    for nf = 1 : length(nFreqs)
        cHl = scatter(TaskData.FreqRespData(nf,:),PassData.FreqRespData(nf,:),50,...
            'MarkerFaceColor',ColorPlot(nf,:),'MarkerEdgeColor','none');
        FreqLengh = [FreqLengh,cHl];
        [~,p] = ttest(TaskData.FreqRespData(nf,:),PassData.FreqRespData(nf,:));
        FreqLengStr{nf} = sprintf('%.1fkHz, p=%.2e',TaskData.FreqTypes(nf)/1000,p);
    end
    xscales = get(gca,'xlim');
    line(xscales,xscales,'Color',[.7 .7 .7],'Linewidth',1.4,'LineStyle','--');
    IsPairedROI = 1;
    xlabel('awake');
    ylabel('anes');
    title('awake and anes response compare');
    set(gca,'FontSize',18);
    legend(FreqLengh,FreqLengStr,'FontSize',8);
    legend boxoff
else
    warning('Task and passive seems to have different ROI numbers, using group wise test');
    % using only the maximum value to indicates the response value 
    TaskResps = TaskRespData;
    PassResps = PassRespData;
    hf = figure('Paperpositionmode','auto');
    hold on
    patch([0.8,1.2,1.2,0.8],[0,0,mean(TaskResps),mean(TaskResps)],1,...
        'facecolor',[.7 .7 .7],'edgeColor','None');
    patch([1.8,2.2,2.2,1.8],[0,0,mean(PassResps),mean(PassResps)],1,...
        'facecolor','c','edgeColor','None');
%     bar(1,mean(TaskResps),0.4,'facecolor',[.7 .7 .7],'edgeColor','None');
%     bar(2,mean(PassResps),0.4,'facecolor','c','edgeColor','None');
    scatter(ones(numel(TaskResps),1),TaskResps,20, 'MarkerFaceColor','k','MarkerEdgeColor','none');
    scatter(ones(numel(PassResps),1)*2,PassResps,20, 'MarkerFaceColor','k','MarkerEdgeColor','none');
    p = ttest2(TaskResps,PassResps);
    hf = GroupSigIndication([1,2],[mean(TaskResps),mean(PassResps)],p,hf,1.15);
    text([1.2,2.2],[mean(TaskResps),mean(PassResps)],{sprintf('n=%d',numel(TaskResps)),sprintf('n=%d',numel(PassResps))});
    set(gca,'xtick',[1,2],'xticklabel',{'awake','anes'},'xlim',[0.5 2.5]);
    xlabel('');
    ylabel('Mean Response');
    title('awake and anes response compare');
    set(gca,'FontSize',18);
end
save PairedRespSave.mat TaskRespData PassRespData IsPairedROI -v7.3
saveas(hf,'awake and anes response compare plot');
saveas(hf,'awake and anes response compare plot','png');

% after last block
if IsPairedROI
    hmaxf = figure;
    scatter(TaskRespData,PassRespData,50,'MarkerFaceColor','r','MarkerEdgeColor','none');
    xlabel('Awake response');
    ylabel('anes response');
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    line(xscales,xscales,'Color',[.7 .7 .7],'Linewidth',1.4,'LineStyle','--');
    set(gca,'ylim',xscales);
    [~,p] = ttest2(TaskRespData,PassRespData);
    title(sprintf('p = %.2e',p));
    set(gca,'FontSize',16);
    saveas(hmaxf,'awake and anes maxresponse compare plot');
    saveas(hmaxf,'awake and anes maxresponse compare plot','png');
end
%% new section for plot the response change across time
nTrs = size(NorData,1);
RespWin = [0.2,1.2]; % 1s after stimulus onset
nFreqs = unique(SoundArray(:,1));
nDBs = unique(SoundArray(:,2));

if mod(nTrs,length(nFreqs)*length(nDBs))
    error('Uneven number of trials for all frequency and DB combination');
end
RoundRepeats = nTrs/(length(nFreqs)*length(nDBs));
RoundTrNum = length(nFreqs)*length(nDBs);

disp(nDBs');
DBuseInds = input('Please select the used DB value, input the index:\n','s');
DBuseInds = str2num(DBuseInds);
UsedDB = nDBs(DBuseInds);
%
BlockRespData = zeros(RoundRepeats,length(nFreqs),size(NorData,2));
for nBlock = 1 : RoundRepeats
    BlockSEInds = [(nBlock - 1)*RoundTrNum+1,RoundTrNum*nBlock];
    BlockData = NorData(BlockSEInds(1):BlockSEInds(2),:,:);
    SoundArrayBlock = SoundArray(BlockSEInds(1):BlockSEInds(2),:);
    UsedInds = SoundArrayBlock(:,2) == UsedDB;
    UsedFreqs = SoundArrayBlock(UsedInds,1);
%     UsedData = BlockData(UsedInds,:,:);
    UsedRespData = squeeze(mean(BlockData(UsedInds,:,(Frate+round(RespWin(1)*Frate)):...
        (Frate+round(RespWin(2)*Frate))),3));
    [~,Inds] = sort(UsedFreqs);
    SortBlockRespData = UsedRespData(Inds,:); % nFreq by nROIs
    BlockRespData(nBlock,:,:) = SortBlockRespData;
end
%% plot the block by block response change
% plot the block by block response value changes for each ROI
FreqColor = jet(length(nFreqs));
BlockIndex = 1:RoundRepeats;
if ~isdir('Across_block_resp')
    mkdir('Across_block_resp');
end
cd('Across_block_resp');

for cROI = 1 : size(NorData,2)
    %
    cROIresp = squeeze(BlockRespData(:,:,cROI));
    lineh = [];
    hf = figure;
    hold on
    for cFreq = 1 : length(nFreqs)
        hl = plot(BlockIndex,cROIresp(:,cFreq),'linewidth',1.5,'color',FreqColor(cFreq,:));
        lineh = [lineh,hl];
    end
    xlabel('Block number');
    ylabel('\DeltaF/F_0 (%)');
    title(sprintf('ROI%d',cROI));
    set(gca,'FontSize',16);
    legend(lineh,cellstr(num2str(nFreqs(:)/1000,'%.2fHz')),'FontSize',10);
    legend boxoff
    saveas(hf,sprintf('ROI%d Across block response',cROI));
    saveas(hf,sprintf('ROI%d Across block response',cROI),'png');
    close(hf);
end

%% calculate the spontaneous activity change using mod f0 normalized data
SmoothData = zeros(size(NorData));
ROImaxResp = zeros(nTrs,nROIs);
ROIstdAll = zeros(1,nROIs);
ROIbaseValue = zeros(1,nROIs);
for cROI = 1 : nROIs
    cROIdata = squeeze(NorData(:,cROI,:));
    ROIstdAll(cROI) = mad(reshape(cROIdata',[],1),1)*1.4826;
    for cTrs = 1 : nTrs
        cTrace = cROIdata(cTrs,:);
        SmoothData(cTrs,cROI,:) = smooth(cTrace,5);
    end
    
    cROIsmoData = squeeze(SmoothData(:,cROI,:));
    cROIsmoMax = max(cROIsmoData,[],2);
    ROImaxResp(:,cROI) = cROIsmoMax;
    ROIbaseValue(cROI) = mean(cROIsmoMax(1:50)); % using first 50 trials as baseline maximum activity
end
PeakRespValue = ROIbaseValue + ROIstdAll * 3;
%%
ThresRespData = repmat(PeakRespValue,nTrs,1);
ValueAbove = double(ROImaxResp > ThresRespData);
% SigEventNum = sum(ValueAbove,2);
RoundRepeats = nTrs/(length(nFreqs)*length(nDBs));
RoundTrNum = length(nFreqs)*length(nDBs);
BlockEventsCount = zeros(RoundRepeats,1);
for nBlock = 1 : RoundRepeats
    BlockSEInds = [(nBlock - 1)*RoundTrNum+1,RoundTrNum*nBlock];
    BlockData = ValueAbove(BlockSEInds(1):BlockSEInds(2),:);
    BlockEventsCount(nBlock) = sum(sum(BlockData));
end
hf = figure;
plot(1 : RoundRepeats,smooth(BlockEventsCount),'k','linewidth',1.6);
xlabel('Blocks');
ylabel('Events Count');
set(gca,'FontSize',16);
saveas(hf,'BlockEventsNum_plot');
saveas(hf,'BlockEventsNum_plot','png');
close(hf);
