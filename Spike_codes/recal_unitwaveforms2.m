
% ksfolder = pwd;

load(fullfile(ksfolder,'AdjustedClusterInfo.mat'))
TrigTimeData = load(fullfile(ksfolder,'TrigTimeANDallSampNum.mat'));


%%

SPClusTypes = unique(FinalSPClusters);
SPClusLabels = FinalksLabels.KSLabel(SPClusTypes+1);
SPClusMaxChn = FinalSPMaxChn(SPClusTypes+1);
SPClusGoodClusInds = cellfun(@(x) strcmpi(x,'good'),SPClusLabels);
SPTimes = single(FinalSPTimeSample)/30000;

GoodClusTypes = SPClusTypes(SPClusGoodClusInds);
GoodClusMaxChn = SPClusMaxChn(SPClusGoodClusInds);

OnAndOffTime4Task = [TrigTimeData.TaskTrigOnTimes(1), TrigTimeData.TaskTrigOnTimes(end)];
TaskDur = diff(OnAndOffTime4Task);
TaskSPTimes = SPTimes(SPTimes >= OnAndOffTime4Task(1) & SPTimes <= OnAndOffTime4Task(2));
TaskSPClus = FinalSPClusters(SPTimes >= OnAndOffTime4Task(1) & SPTimes <= OnAndOffTime4Task(2));

NumGoodClus = length(GoodClusTypes);
WithinTaskFRs = zeros(numel(GoodClusTypes),1);
for cClus = 1 : NumGoodClus
    %     cClusInds =  TaskSPClus == GoodClusTypes(cClus);
    WithinTaskFRs(cClus) = sum(TaskSPClus == GoodClusTypes(cClus))/TaskDur;
end

FRThres = WithinTaskFRs >= 0.1;
AboveThresClusIDs = GoodClusTypes(FRThres);
AboveThresClusMaxChn = GoodClusMaxChn(FRThres);
NumAboveThresClus = length(AboveThresClusIDs);


%%
% RawFilePath = 'F:\b107a08_raw\A2021226_b107a08_NPSess02_g0\A2021226_b107a08_NPSess02_g0_imec2';
RawFileStrc = dir(fullfile(RawFilePath,'*.ap.bin'));
if length(RawFileStrc) < 1
    warning('Raw data file cannot be found.\n');
    return;
end
fullpaths = fullfile(RawFilePath,RawFileStrc(1).name);

%% using freqd in matlab script
waveformDataSavefile = fullfile(ksfolder,'AdjUnitWaveforms');
if isfolder(waveformDataSavefile)
    rmdir(waveformDataSavefile,'s');
end
mkdir(waveformDataSavefile);
tic
ftempid = fopen(fullpaths);

WaveWinSamples = [-30,51];
WaveSampleLen = diff(WaveWinSamples);
NumofUnit = length(AboveThresClusIDs);
SavingClusLen = 150; % num of clusters to be saved after certain number of units
SavingTimes = ceil(NumofUnit/SavingClusLen);
cSavIndex = 1;
for cUnit = 1 : NumofUnit
    % cUnit = 137;
    if mod(cUnit, SavingClusLen) == 1
        if (NumofUnit - cUnit) > SavingClusLen
            UnitDatas = cell(SavingClusLen,3);
            UnitFeatures = cell(SavingClusLen,5);
        else
            cBLength = NumofUnit - cUnit;
            UnitDatas = cell(cBLength,3);
            UnitFeatures = cell(cBLength,5);
        end
    end
    cClusInds = AboveThresClusIDs(cUnit);
    cClusChannel = AboveThresClusMaxChn(cUnit)+1;
    cClus_Sptimes = FinalSPTimeSample(FinalSPClusters == cClusInds);
    if numel(cClus_Sptimes) < 2000
        UsedSptimes = cClus_Sptimes;
        SPNums = length(UsedSptimes);
    else
        UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
        SPNums = 2000;
    end
    cspWaveform = nan(SPNums,WaveSampleLen);
    AllChannelWaveData = nan(SPNums,384,WaveSampleLen);
    for csp = 1 : SPNums
        cspTime = UsedSptimes(csp);
        cspStartInds = cspTime+WaveWinSamples(1);
        cspEndInds = cspTime+WaveWinSamples(2);
        offsetTimeSample = cspStartInds - 1;
        if offsetTimeSample < 0 || cspEndInds > TrigTimeData.TotalSampleNums
            continue;
        end
        offsets = 385*(cspStartInds-1)*2;
        status = fseek(ftempid,offsets,'bof');
        if ~status
            % correct offset value is set
            AllChnDatas = fread(ftempid,[385 WaveSampleLen],'int16');
            cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
            AllChannelWaveData(csp,:,:) = AllChnDatas(1:384,:); % for waveform spread calculation
            %        cspWaveform(csp,:) = mean(AllChnDatas);
        end
    end
    
    huf = figure('position',[100 100 320 220],'visible','off');
    if size(cspWaveform,1) == 1
        AvgWaves = cspWaveform;
        UnitDatas{cUnit,2} = squeeze(AllChannelWaveData);
    else
        AvgWaves = mean(cspWaveform,'omitnan');
        UnitDatas{cUnit,2} = squeeze(mean(AllChannelWaveData,'omitnan'));
    end
    UnitDatas{cUnit,1} = single(cspWaveform);
%     UnitDatas{cUnit,2} = single(AllChannelWaveData);
    UnitDatas{cUnit,3} = cClusInds;
    clearvars AllChannelWaveData cspWaveform
    
    plot(AvgWaves);
    try
        [isabnorm,isUsedVec,waveAmplitude,toughPeakInds] = iswaveformatypical(AvgWaves,WaveWinSamples,false);
    catch ME
        fprintf('Errors');
    end
    %     title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
    title(sprintf('ClusID %d, Chn %d, IsPass %d',cClusInds,cClusChannel,1-isabnorm));
    %     if length(AvgWaves) == 1
    %         fprintf('Too few spikes for calculation.\n');
    %     end
    try
        wavefeature = SPwavefeature(AvgWaves,WaveWinSamples,toughPeakInds);
        text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
            sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);
        
        if wavefeature.IsPrePosPeak
            text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
        end
    catch
        wavefeature = [];
    end
    UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec,waveAmplitude,toughPeakInds};
    
    if mod(cUnit, SavingClusLen) == 0
        TempSaveFile = fullfile(ksfolder,'AdjUnitWaveforms',sprintf('TempSavingData%d.mat',cSavIndex));
        save(TempSaveFile,'UnitDatas', 'UnitFeatures', '-v7.3');
        clearvars UnitDatas UnitFeatures 
        cSavIndex = cSavIndex + 1;
    end
    %
    set(gca,'FontSize',10);
    saveName = fullfile(waveformDataSavefile,sprintf('ClusID %d waveform plot save',cClusInds));
    saveas(huf,saveName);
    saveas(huf,saveName,'png');
    
    close(huf);
    
end
fclose(ftempid);
toc
%% obj.UnitWaves = UnitDatas;
% obj.UnitWaveFeatures = UnitFeatures;
% save(fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitwaveformDatas.mat'), 'UnitDatas', 'UnitFeatures', '-v7.3');

% %% using freqd in mex file
%
% tic
% WaveWinSamples = [-30,51];
% WaveSampleLen = diff(WaveWinSamples);
% NumofUnit = length(AboveThresClusIDs);
% UnitDatas = cell(NumofUnit,2);
% UnitFeatures = cell(NumofUnit,5);
% for cUnit = 1 : 10 %NumofUnit
%     % cUnit = 137;
%     cClusInds = AboveThresClusIDs(cUnit);
%     cClusChannel = AboveThresClusMaxChn(cUnit)+1;
%     cClus_Sptimes = FinalSPTimeSample(FinalSPClusters == cClusInds);
%     if numel(cClus_Sptimes) < 2000
%         UsedSptimes = cClus_Sptimes;
%         SPNums = length(UsedSptimes);
%     else
%         UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
%         SPNums = 2000;
%     end
% %     cspWaveform = nan(SPNums,WaveSampleLen);
% %     AllChannelWaveData = nan(SPNums,384,WaveSampleLen);
% %     for csp = 1 : SPNums
% %         cspTime = UsedSptimes(csp);
% %         cspStartInds = cspTime+WaveWinSamples(1);
% %         cspEndInds = cspTime+WaveWinSamples(2);
% %         offsetTimeSample = cspStartInds - 1;
% %         if offsetTimeSample < 0 || cspEndInds > TrigTimeData.TotalSampleNums
% %             continue;
% %         end
% %         offsets = 385*(cspStartInds-1)*2;
% %         status = fseek(ftempid,offsets,'bof');
% %         if ~status
% %             % correct offset value is set
% %             AllChnDatas = fread(ftempid,[385 WaveSampleLen],'int16');
% %             cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
% %             AllChannelWaveData(csp,:,:) = AllChnDatas(1:384,:); % for waveform spread calculation
% %             %        cspWaveform(csp,:) = mean(AllChnDatas);
% %         end
% %     end
%     [cspWaveform, AllChannelWaveData] = ReadSampleWaves_mex(fullpaths,UsedSptimes,...
%         WaveWinSamples,TrigTimeData.TotalSampleNums,cClusChannel);
%     huf = figure('position',[100 100 320 220],'visible','off');
%     if size(cspWaveform,1) == 1
%         AvgWaves = cspWaveform;
%         UnitDatas{cUnit,2} = squeeze(AllChannelWaveData);
%     else
%         AvgWaves = mean(cspWaveform,'omitnan');
%         UnitDatas{cUnit,2} = squeeze(mean(AllChannelWaveData,'omitnan'));
%     end
%     UnitDatas{cUnit,1} = cspWaveform;
%
%     %
%     plot(AvgWaves);
%     try
%         [isabnorm,isUsedVec,waveAmplitude,toughPeakInds] = iswaveformatypical(AvgWaves,WaveWinSamples,false);
%     catch ME
%         fprintf('Errors');
%     end
% %     title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
%     title(sprintf('ClusID %d, Chn %d, IsPass %d',cClusInds,cClusChannel,1-isabnorm));
% %     if length(AvgWaves) == 1
% %         fprintf('Too few spikes for calculation.\n');
% %     end
%     wavefeature = SPwavefeature(AvgWaves,WaveWinSamples);
%     text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
%         sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);
%
%     if wavefeature.IsPrePosPeak
%         text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
%     end
%     UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec,waveAmplitude,toughPeakInds};
%     %
%     set(gca,'FontSize',10);
%     saveName = fullfile(waveformDataSavefile,sprintf('ClusID %d waveform plot save',cClusInds));
%     saveas(huf,saveName);
%     saveas(huf,saveName,'png');
%
%     close(huf);
%
% end
% % fclose(ftempid);
% toc
%



