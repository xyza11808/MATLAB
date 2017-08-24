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
SessData = SavedCaTrials.f_raw;
% SessData(121:122,:,:) = [];
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
%%
save NorMatFile.mat NorData -v7.3
if ~isdir('ROI_resp_colorPlot');
    mkdir('ROI_resp_colorPlot');
end
cd('ROI_resp_colorPlot');

UnevenRFrespPlot(NorData,DBArray,FreqArray,Frate); 
%
if ~isdir('ROI_resp_vShape');
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
SoundArray = double(cell2mat(SoundText));
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
[fn,fp,~] = uigetfile('CellRespDataSave.mat','Please select the task data');
TaskfilePath = fullfile(fp,fn);
[fn,fp,~] = uigetfile('CellRespDataSave.mat','Please select the Passive data');
PassFilePath = fullfile(fp,fn);
TaskData = load(TaskfilePath);
PassData = load(PassFilePath);
%% after last block
TaskRespData = max(TaskData.FreqRespData);
PassRespData = max(PassData.FreqRespData);
nFreqs = TaskData.FreqTypes;

ColorPlot = jet(length(nFreqs));
hhf = figure;
hold on
for nf = 1 : length(nFreqs)
    scatter(TaskData.FreqRespData(nf,:),PassData.FreqRespData(nf,:),50,...
        'MarkerFaceColor',ColorPlot(nf,:),'MarkerEdgeColor','none');
end
xscales = get(gca,'xlim');
line(xscales,xscales,'Color',[.7 .7 .7],'Linewidth',1.4,'LineStyle','--');
%% after last block
hmaxf = figure;
scatter(TaskRespData,PassRespData,50,'MarkerFaceColor','r','MarkerEdgeColor','none');
xlabel('Awake response');
ylabel('anes response');
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
line(xscales,xscales,'Color',[.7 .7 .7],'Linewidth',1.4,'LineStyle','--');
set(gca,'ylim',yscales);
[~,p] = ttest2(TaskRespData,PassRespData);
title(sprintf('p = %.2e',p));
set(gca,'FontSize',16);

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