function ExtractTriggerInfo(obj)
if isfield(obj,'ops') && isfield(obj,'P')
    GUIprocess = 1;
else
    GUIprocess = 0;
end
if GUIprocess
   %function was called in a ksGUI
    BinFilePos = obj.ops.fbinary;
    BinFileDataSize = obj.P.datSize;
    mmf = memmapfile(BinFilePos,'Format',{class(obj.P.datMMfile.Data.x),...
        BinFileDataSize,'x'});
    TriggerChnData = mmf.Data.x(BinFileDataSize(1),:); % use the last channel as trigger channel
else
    % function was called in a ks script
    DataPath = obj.ksFolderPath;
    fnames = dir(fullfile(DataPath,'*.ap.bin'));
    fullbinfile = fullfile(DataPath,fnames(1).name);
    bytes       = get_file_size(ops.fbinary); % size in bytes of raw binary
    nTimepoints = floor(bytes/ops.NchanTOT/2); % number of total timepoints
    mmf = memmapfile(fullbinfile,'Format',{'int16',...
        [obj.NchanTOT nTimepoints],'x'});
    TriggerChnData = mmf.Data.x(obj.NchanTOT,:);
end

TrgChnNorm = TriggerChnData/max(TriggerChnData);

TriggerEvents = [];
k = 1;

TrgWaveStart = find(TrgChnNorm > 0.95,1,'first');

while ~isempty(TrgWaveStart)
    % StartSearchInds = TrgWaveStart;
    TrgwaveEndInds = find(TrgChnNorm(TrgWaveStart:end) < 0.95,1,'first');

    TriggerEvents(k,:) = [TrgWaveStart,TrgWaveStart+TrgwaveEndInds-1];
    
    TrgWaveStart = find(TrgChnNorm((TrgWaveStart+TrgwaveEndInds):end) > 0.95,1,'first')+TrgWaveStart+TrgwaveEndInds;
    k = k +1;
end

if GUIprocess
    % calculate the time interval for each square wave
    TriggerEventLen = (TriggerEvents(:,2) - TriggerEvents(:,1))/obj.ops.fs;
    ExcludeInds = TriggerEventLen<0.0005; % make sure the trigger len is larger than 0.5ms
    if sum(ExcludeInds)
        TriggerEventLen(ExcludeInds) = [];
        TriggerEvents(ExcludeInds,:) = [];
    end    
    TriggerLenTypes = unique(TriggerEventLen);
    TrgTypeNum = length(TriggerLenTypes);
    save(fullfile(obj.ops.saveDir,'TriggerDatas.mat'),'TriggerEvents',...
        'TriggerLenTypes','TrgTypeNum','-v7.3');
else
    TriggerEventLen = (TriggerEvents(:,2) - TriggerEvents(:,1))/obj.fs;
    ExcludeInds = TriggerEventLen<0.0005; % make sure the trigger len is larger than 0.5ms
    if sum(ExcludeInds)
        TriggerEventLen(ExcludeInds) = [];
        TriggerEvents(ExcludeInds,:) = [];
    end    
    TriggerLenTypes = unique(TriggerEventLen);
    TrgTypeNum = length(TriggerLenTypes);
    
    save(fullfile(obj.ksFolderPath,'TriggerDatas.mat'),'TriggerEvents',...
        'TriggerLenTypes','TrgTypeNum','-v7.3');
end




