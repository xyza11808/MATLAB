% batch scripts for ztt data analysis
clear
clc

GrandPath = 'R:\DuFangData';
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);

DataPath = {};
BehavMissPath = {};
nBehavMissPath = 0;

ErrorSessPath = {};
nErrorSessNum = 0;
ErrorPathMessage = {};

for np = 1 : DirLength
    cPATH = nameSplit{np};
    MatList =  dir(fullfile(cPATH,'CaTrials*.mat'));
    if isempty(MatList)
        continue;
    end
    cd(cPATH);
%     try
        fn1Strc = dir('CaTrials*.mat');
        fn1 = fn1Strc.name;
        fn2Strc = dir('ROIinfo*.mat');
        fn2 = fn2Strc.name;
        if ~isempty(dir('COM'))
            BehavFnStrc = dir('*COM*');
            BehavFn = BehavFnStrc.name;
            ffullpath = fullfile(cPATH,BehavFn);
        else
            RawBehavPath = strrep(cPATH,'\im_data_reg_cpu\result_save','');
            BehavFileStrc = dir([RawBehavPath filesep 'mouse*COM*']);
            if ~isempty(BehavFileStrc)
                fname = BehavFileStrc.name;
                ffullpath = fullfile(RawBehavPath,fname);
            else
                BehavFileStrc = dir([RawBehavPath filesep 'mouse*']);
                if ~isempty(BehavFileStrc)
                    fname = BehavFileStrc.name;
                    ffullpath = fullfile(RawBehavPath,fname);
                else
                    nBehavMissPath = nBehavMissPath + 1;
                    BehavMissPath{nBehavMissPath} = cPATH;
                    continue;
                end
            end
        end
        %
        load(fn1);
        load(fn2);
        fid = fopen(ffullpath);
        SoundText = textscan(fid,'%d %d %d');
        SoundArray = double(cell2mat(SoundText));
        ExcludeInds = SoundArray(:,1) == 0;
        SoundArray(ExcludeInds,:) = [];
        % data plots
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
        %
        NorData(ExcludeInds,:,:) = [];
        if size(NorData,1) ~= size(SoundArray,1)
            warning('Uneven number of tif file and behavior numbers is different.\n');
            nTrUsed = min([size(NorData,1),size(SoundArray,1)]);
            SoundArray = SoundArray(1:nTrUsed,:);
            NorData = NorData(1:nTrUsed,:,:);
        end
        %
        save NorMatFile.mat NorData -v7.3
        if ~isdir('ROI_resp_colorPlot')
            mkdir('ROI_resp_colorPlot');
        end
        cd('ROI_resp_colorPlot');
        if ~isdir('Uneven_colorPlot') || ~(exist('.\Uneven_colorPlot\UnevenPassdata.mat','file') > 0)
            UnevenRFrespPlot(NorData,DBArray,FreqArray,Frate); 
        end
        cd ..;
        RespWin = [0.2,1.2]; % 1s after stimulus onset
        %
        DBtypes = unique(SoundArray(:,2));
        FreqTypes = unique(SoundArray(:,1));
%         disp(DBtypes');
%         DBuseInds = input('Please select the used DB value, input the index:\n','s');
%         DBuseInds = str2num(DBuseInds);
        if length(DBtypes) == 1
            DBuseInds = 1;
        else
            Inds = find(DBtypes == 70 | DBtypes == 75);
            if isempty(Inds)
                DBuseInds = length(DBtypes);
            else
                DBuseInds = Inds;
            end
        end
        UsedInds = SoundArray(:,2) == DBtypes(DBuseInds);
        UsedFreqs = SoundArray(UsedInds,1);
        UsedData = NorData(UsedInds,:,:);
        UsedRespData = squeeze(mean(UsedData(:,:,(Frate+round(RespWin(1)*Frate)):(Frate+round(RespWin(2)*Frate))),3));
        %
        FreqRespData = zeros(length(FreqTypes),size(UsedRespData,2));
        for  cFreq = 1 : length(FreqTypes)
            cFreqInds = UsedFreqs == FreqTypes(cFreq);
            cFreqData = mean(UsedRespData(cFreqInds,:));
            FreqRespData(cFreq,:) = cFreqData;
        end
        ROImaxResp = max(FreqRespData);
        save CellRespDataSave.mat FreqRespData FreqTypes NorData SoundArray DBuseInds -v7.3
        if ~isempty(strfind(cPATH,'anes'))
%%             if ~isdir('Across_block_resp')
                % new section for plot the response change across time
                nTrs = size(NorData,1);
                nROIs = size(NorData,2);
                RespWin = [0.2,1.2]; % 1s after stimulus onset
                nFreqs = unique(SoundArray(:,1));
                nDBs = unique(SoundArray(:,2));
                
                if mod(nTrs,length(nFreqs)*length(nDBs))
                    error('Uneven number of trials for all frequency and DB combination');
                end
                % calculate the spontaneous activity change using mod f0 normalized data
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
                ThresRespData = repmat(PeakRespValue,nTrs,1);
                ValueAbove = double(ROImaxResp > ThresRespData);
                %%
                RoundRepeats = nTrs/(length(nFreqs)*length(nDBs));
                RoundTrNum = length(nFreqs)*length(nDBs);
                if RoundRepeats > 10
            %         disp(nDBs');
            %         DBuseInds = input('Please select the used DB value, input the index:\n','s');
            %         DBuseInds = str2num(DBuseInds);
                    UsedDB = nDBs(DBuseInds);
                    %
                    BlockRespData = zeros(RoundRepeats,length(nFreqs),size(NorData,2));
                    BlockEventsCount = zeros(RoundRepeats,1);
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
                        BlockData = ValueAbove(BlockSEInds(1):BlockSEInds(2),:);
                        BlockEventsCount(nBlock) = sum(sum(BlockData));
                    end
                    % plot the block by block response change
                    % plot the block by block response value changes for each ROI
                    FreqColor = jet(length(nFreqs));
                    BlockIndex = 1:RoundRepeats;
                    if ~isdir('Across_block_resp')
                        mkdir('Across_block_resp');
                    end
                    cd('Across_block_resp');
                    
                    hf = figure;
                    plot(1 : RoundRepeats,smooth(BlockEventsCount),'k','linewidth',1.6);
                    xlabel('Blocks');
                    ylabel('Events Count');
                    set(gca,'FontSize',16);
%                     saveas(hf,'BlockEventsNum_plot');
%                     saveas(hf,'BlockEventsNum_plot','png');
%                     close(hf);

%                     save BlockRespDataSave.mat BlockRespData RoundRepeats BlockEventsCount -v7.3
                end
                %%
        end
     %
%     catch ME
%         nErrorSessNum = nErrorSessNum + 1;
%         ErrorSessPath{nErrorSessNum} = cPATH;
%         ErrorPathMessage{nErrorSessNum} = ME;
%     end
end

%% summary the maximum ROI response data for all sessions
clear
clc

GrandPath = 'R:\DuFangData';
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);

DataPath = {};
nUsedPath = 0;
PairedDataSum = struct('PairedAwakeData',[],'PairedAnesData',[]);
ImpairedDataSum = struct('ImPairedAwakeData',[],'ImPairedAnesData',[]);

ErrorSessPath = {};
nErrorSessNum = 0;
ErrorPathMessage = {};

for np = 1 : DirLength
    cPATH = nameSplit{np};
    MatList =  dir(fullfile(cPATH,'PairedRespSave.mat'));
    if isempty(MatList)
        continue;
    end
    cd(cPATH);
    nUsedPath = nUsedPath + 1;
    DataPath{nUsedPath} = cPATH;
    RespDataStrc = load('PairedRespSave.mat');
    if RespDataStrc.IsPairedROI
        % paired ROI data
        PairedDataSum.PairedAwakeData = [PairedDataSum.PairedAwakeData;RespDataStrc.TaskRespData(:)];
        PairedDataSum.PairedAnesData = [PairedDataSum.PairedAnesData;RespDataStrc.PassRespData(:)];
    else
        ImpairedDataSum.ImPairedAwakeData = [ImpairedDataSum.ImPairedAwakeData;RespDataStrc.TaskRespData(:)];
        ImpairedDataSum.ImPairedAnesData = [ImpairedDataSum.ImPairedAnesData;RespDataStrc.PassRespData(:)];
    end
end
%%
SavePath = uigetdir(pwd,'Please select the data save path');
cd(SavePath);
save SummaryRespData.mat PairedDataSum ImpairedDataSum DataPath -v7.3
TaskRespData = PairedDataSum.PairedAwakeData;
PassRespData = PairedDataSum.PairedAnesData;
hmaxf = figure;
scatter(TaskRespData,PassRespData,50,'MarkerFaceColor','k','MarkerEdgeColor','none');
xlabel('Awake response');
ylabel('anes response');
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
line(xscales,xscales,'Color',[.7 .7 .7],'Linewidth',1.4,'LineStyle','--');
set(gca,'ylim',xscales);
[~,p] = ttest2(TaskRespData,PassRespData);
title(sprintf('p = %.2e',p));
text(xscales(2)*0.1,xscales(2)*0.8,sprintf('n=%d',length(TaskRespData)));
set(gca,'FontSize',16);
saveas(hmaxf,'Summary awake and anes maxresponse compare plot');
saveas(hmaxf,'Summary awake and anes maxresponse compare plot','png');

%% summary the blockwise response using maximum response for all frequencies
clear
clc

GrandPath = 'R:\DuFangData';
xpath = genpath(GrandPath);
nameSplit = strsplit(xpath,';');
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);

DataPath = {};
nUsedPath = 0;
PairedDataSum = struct('PairedAwakeData',[],'PairedAnesData',[]);
ImpairedDataSum = struct('ImPairedAwakeData',[],'ImPairedAnesData',[]);

ErrorSessPath = {};
nErrorSessNum = 0;
ErrorPathMessage = {};

for np = 1 : DirLength
    cPATH = nameSplit{np};
    MatList =  dir(fullfile(cPATH,'BlockRespDataSave.mat'));
    if isempty(MatList)
        continue;
    end
    cd(cPATH);
    nUsedPath = nUsedPath + 1;
    DataPath{nUsedPath} = cPATH;
    clearvars BlockRespData RoundRepeats
    load('BlockRespDataSave.mat');
    %%
    UsedBlockNum = 1:42;
    BlockRespDataBP = BlockRespData;
    BlockRespData = BlockRespData(1:42,:,:);
    RoundRepeats = size(BlockRespData,1);
    BlockMaxResp = zeros(size(BlockRespData,1),size(BlockRespData,3));
    ZsMaxResp = zeros(size(BlockRespData,1),size(BlockRespData,3));
    for cROI = 1 : size(BlockRespData,3)
        cROIdata = squeeze(BlockRespData(:,:,cROI));
        cROImax = max(cROIdata,[],2);
        BlockMaxResp(:,cROI) = cROImax;
        ZsMaxResp(:,cROI) = zscore(cROImax);
    end
    
    
    h_rawMax = figure;
    hf = plot_meanCaTrace(mean(BlockMaxResp,2),std(BlockMaxResp,[],2)./sqrt(size(BlockMaxResp,2)),1:RoundRepeats,h_rawMax,[]);
    set(hf.meanPlot,'color','k');
    xlabel('Block Number');
    ylabel('Mean max response(\DeltaF/F_0(%))');
    title('Block Max response');
    set(gca,'FontSize',16);
    %%
    saveas(h_rawMax,'Block Popu MaxMean plot');
    saveas(h_rawMax,'Block Popu MaxMean plot','png');
    saveas(h_rawMax,'Block Popu MaxMean plot','pdf');
    %%
    h_zsMax = figure;
    hf = plot_meanCaTrace(mean(ZsMaxResp,2),std(ZsMaxResp,[],2)./sqrt(size(ZsMaxResp,2)),1:RoundRepeats,h_zsMax,[]);
    set(hf.meanPlot,'color','k');
    xlabel('Block Number');
    ylabel('Mean max ZSresponse(\DeltaF/F_0(%))');
    title('Block ZSMax response');
    set(gca,'FontSize',16);
    saveas(h_zsMax,'Block Popu ZSMaxMean plot');
    saveas(h_zsMax,'Block Popu ZSMaxMean plot','png');
    %
    close(h_rawMax);
    close(h_zsMax);
    save PopuMaxRespSave.mat BlockMaxResp ZsMaxResp -v7.3
end

%% summarize all data together
cclr
clc
[fn,fp,fi] = uigetfile('BlockResp_DataPath.txt','Please select the used data file path');
fPath = fullfile(fp,fn);

%%
ffid = fopen(fPath);
tline = fgetl(ffid);
m = 1;
BlockCounts = [];
BlockRespTrCount = {};
BlockMaxRespAll = {};
BlockZSMaxRespAll = {};

while ischar(tline)
    if isempty(strfind(tline,'BlockRespDataSave.mat'))
        tline = fgetl(ffid);
        continue;
    end
    cDataPath = tline;
    
    clearvars BlockRespData RoundRepeats BlockEventsCount
    load(cDataPath);
    
    %
%     UsedBlockNum = 1:42;
    BlockRespDataBP = BlockRespData;
%     BlockRespData = BlockRespData(1:42,:,:);
    RoundRepeats = size(BlockRespData,1);
    BlockMaxResp = zeros(size(BlockRespData,1),size(BlockRespData,3));
    ZsMaxResp = zeros(size(BlockRespData,1),size(BlockRespData,3));
    for cROI = 1 : size(BlockRespData,3)
        cROIdata = squeeze(BlockRespData(:,:,cROI));
        cROImax = max(cROIdata,[],2);
        BlockMaxResp(:,cROI) = cROImax;
        ZsMaxResp(:,cROI) = zscore(cROImax);
    end
    BlockCounts(m) = RoundRepeats;
    BlockRespTrCount{m} = BlockEventsCount;
    BlockMaxRespAll{m} = mean(BlockMaxResp,2);
    BlockZSMaxRespAll{m} = mean(ZsMaxResp,2);
    
    tline = fgetl(ffid);
    m = m + 1;
end

fclose(ffid);
%% summarize all block response 
UsedBlockNum = min(BlockCounts);
BlockEventsDataCell = cellfun(@(x) (x(1:UsedBlockNum))',BlockRespTrCount,'UniformOutput',false);
BlockEventsDataMtx = cell2mat(BlockEventsDataCell');

BlockAvgSigTr = mean(BlockEventsDataMtx);
BlockSemSigTr = std(BlockEventsDataMtx)/sqrt(length(UsedBlockNum));

h_Summary = figure('position',[2000 100 380 300]);
hf = plot_meanCaTrace(BlockAvgSigTr,BlockSemSigTr*0.5,1:UsedBlockNum,h_Summary,[]);
yscales = get(gca,'ylim');
text(UsedBlockNum/2,yscales(2)*0.8,sprintf('n = %d',length(BlockCounts)));
set(hf.meanPlot,'color','k');
xlabel('Block Number');
ylabel('Significant response trial number');
% title('Block ZSMax response');
set(gca,'xlim',[0 UsedBlockNum+1],'FontSize',12);

