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
    fnames = dir(fullfile(DataPath,'*.bin'));
    fullbinfile = fullfile(DataPath,fnames(1).name);
    bytes       = get_file_size(fullbinfile); % size in bytes of raw binary
    nTimepoints = floor(bytes/obj.NchanTOT/2); % number of total timepoints
    mmf = memmapfile(fullbinfile,'Format',{'int16',...
        [obj.NchanTOT nTimepoints],'x'});
    TriggerChnData = mmf.Data.x(obj.NchanTOT,:);
end

TrgChnNorm = TriggerChnData/min(64,max(TriggerChnData));
% clearvars TriggerChnData

%%
TriggerEvents = [];
k = 1;
IsInitInput = 1;
TrgWaveStart = find(TrgChnNorm(30000*60*5:end) > 0.95,1,'first');

while ~isempty(TrgWaveStart)
    % StartSearchInds = TrgWaveStart;
    if IsInitInput
        TrgWaveStart = TrgWaveStart + 30000*60*5 - 1;
        IsInitInput = 0;
    end
    TrgwaveEndInds = find(TrgChnNorm(TrgWaveStart:end) < 0.95,1,'first');
    if isempty(TrgwaveEndInds)
        break;
    end
    if TrgwaveEndInds < 15 % 500us
        TrgWaveStart = find(TrgChnNorm((TrgWaveStart+TrgwaveEndInds):end) > 0.95,1,'first')+...
            TrgWaveStart+TrgwaveEndInds;
        continue;
    end
    TriggerEvents(k,:) = [TrgWaveStart,TrgWaveStart+TrgwaveEndInds-1];
    
    TrgWaveStart = find(TrgChnNorm((TrgWaveStart+TrgwaveEndInds):end) > 0.95,1,'first')+TrgWaveStart+TrgwaveEndInds;
    k = k + 1;
end
%%
if GUIprocess
    % calculate the time interval for each square wave
    TriggerEventLen = (TriggerEvents(:,2) - TriggerEvents(:,1))/obj.ops.fs;
    TriggerLenTypes = unique(TriggerEventLen);
    TrgTypeNum = length(TriggerLenTypes);
    save(fullfile(obj.ops.saveDir,'TriggerDatas.mat'),'TriggerEvents',...
        'TriggerLenTypes','TrgTypeNum','-v7.3');
else
    TriggerEventLen = (TriggerEvents(:,2) - TriggerEvents(:,1))/obj.fs;
    TriggerLenTypes = unique(TriggerEventLen);
    TrgTypeNum = length(TriggerLenTypes);
    save(fullfile(obj.ksFolderPath,'TriggerDatas.mat'),'TriggerEvents',...
        'TriggerLenTypes','TrgTypeNum','-v7.3');
end




