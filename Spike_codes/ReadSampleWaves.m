function [cspWaveform, AllChannelWaveData] = ReadSampleWaves(fullpaths,UsedSptimes,WaveWinSamples,TotalSamples,cClusChannel)
ftempid = fopen(fullpaths);
SPNums = numel(UsedSptimes);
cspWaveform = nan(SPNums,diff(WaveWinSamples));
AllChannelWaveData = nan(SPNums,384,diff(WaveWinSamples));
for csp = 1 : SPNums
    cspTime = UsedSptimes(csp);
    cspStartInds = cspTime+WaveWinSamples(1);
    cspEndInds = cspTime+WaveWinSamples(2);
    offsetTimeSample = cspStartInds - 1;
    if offsetTimeSample < 0 || cspEndInds > TotalSamples
        continue;
    end
    offsets = 385*(cspStartInds-1)*2;
    status = fseek(ftempid,offsets,'bof');
    if ~status
        AllChnDatas = fread(ftempid,[385 diff(WaveWinSamples)],'int16');
        cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
        AllChannelWaveData(csp,:,:) = AllChnDatas(1:384,:); % for waveform spread calculation
    end
end
fclose(ftempid);