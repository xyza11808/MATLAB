function ExtractTriggerInfo(obj,IsQuickStart)
% The variable IsQuickStart is used to determin whether to skip the
% initial 5 mins trigger data to simplify the search process, which is used
% when the acq process was abrupted and re-initiated during training
% session
if ~exist('IsQuickStart','var')
    IsQuickStart = 0;
end
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
    ReadChnIndex = BinFileDataSize(1);
    TotalsampleNums = BinFileDataSize(2);
else
    % function was called in a ks script
    DataPath = obj.ksFolderPath;
    fnames = dir(fullfile(DataPath,'*.ap.bin'));
    fullbinfile = fullfile(DataPath,fnames(1).name);
    
    bytes       = get_file_size(fullbinfile); % size in bytes of raw binary
    nTimepoints = floor(bytes/obj.NchanTOT/2); % number of total timepoints
    mmf = memmapfile(fullbinfile,'Format',{'int16',...
        [obj.NchanTOT nTimepoints],'x'});
    ReadChnIndex = obj.NchanTOT;
    TotalsampleNums = nTimepoints;
%     TriggerChnData = mmf.Data.x(obj.NchanTOT,:);
end

%%
[~,sys] = memory;
if sys.PhysicalMemory.Total/(1.0737e+09) > 80 % convert from byte to GB
    TriggerChnData = mmf.Data.x(ReadChnIndex,:); % use the last channel as trigger channel

    TrgChnNorm = TriggerChnData/min(64,max(TriggerChnData));
    % clearvars TriggerChnData

    %
    TriggerEvents = [];
    k = 1;
    IsInitInput = 1;
    if IsQuickStart
        TrgWaveStart = find(TrgChnNorm > 0.95,1,'first');
    else
        TrgWaveStart = find(TrgChnNorm(30000*60*5:end) > 0.95,1,'first');
    end

    while ~isempty(TrgWaveStart)
        % StartSearchInds = TrgWaveStart;
        if IsInitInput
            if ~IsQuickStart
                TrgWaveStart = TrgWaveStart + 30000*60*5 - 1;
            end
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
    
else
    % the physical memory is too low, using batched reading to reduce
    % memory usage
    BatchSize = 5000000; % batch size to read at each iteration
    fid = fopen(fullbinfile);
    
    TriggerEvents = [];
    k = 1;
    if IsQuickStart
%         TrgWaveStart = find(TrgChnNorm > 0.95,1,'first');
        NumBatches = ceil(TotalsampleNums/BatchSize);
    else
%         TrgWaveStart = find(TrgChnNorm(30000*60*5:end) > 0.95,1,'first');
        NumBatches = ceil((TotalsampleNums-30000*60*5)/BatchSize);
    end
    
    for cB = 1 : NumBatches
        cBStartInds = (cB-1)*BatchSize+1;
        if ~IsQuickStart
            cBStartInds = cBStartInds + 30000*60*5;
        end
        offsets = ReadChnIndex*(cBStartInds-1)*2;
        status = fseek(fid,offsets,'bof');
        cBatchDatas = fread(fid,[ReadChnIndex BatchSize],'int16');
        UsedData = cBatchDatas(ReadChnIndex,:);
        clearvars cBatchDatas
        
        ChnDataNorm = UsedData/64;
        if cB > 1 % in case there is a lasting high-level wave followed from previous batch
            if TempWavebox(1) > 0 && TempWavebox(2) == 0
                TrgwaveEndInds = find(ChnDataNorm < 0.95,1,'first');
                if isepmty(TrgwaveEndInds)
                    break;
                end
                RealEndInds = TrgwaveEndInds + cBStartInds - 1;
                TempWavebox(2) = RealEndInds;
                TriggerEvents(k,:) = TempWavebox;
                k = k + 1;
                TrgWaveStart = find(ChnDataNorm(TrgwaveEndInds+1:end) > 0.95,1,'first');
                TempWavebox = [0 0]; 
                StartInds = TrgwaveEndInds+1;
            else
                TrgWaveStart = find(ChnDataNorm > 0.95,1,'first');
                TempWavebox = [0 0]; % the temp index for current square wave signal
                StartInds = 1;
            end
        else
            TrgWaveStart = find(ChnDataNorm > 0.95,1,'first');
            TempWavebox = [0 0]; % the temp index for current square wave signal
            StartInds = 1;
        end
            
        
        while ~isempty(TrgWaveStart)
            % StartSearchInds = TrgWaveStart;
            TempWavebox(1) = TrgWaveStart + cBStartInds - 2 + StartInds;
            TrgwaveEndInds = find(ChnDataNorm((StartInds+TrgWaveStart):end) < 0.95,1,'first');
            if isempty(TrgwaveEndInds)
                break;
            end
            if TrgwaveEndInds < 15 % 500us
                TrgWaveStart = find(ChnDataNorm((TrgWaveStart+TrgwaveEndInds):end) > 0.95,1,'first')+...
                    TrgWaveStart+TrgwaveEndInds;
                continue;
            end
            TempWavebox(2) = TrgWaveStart+TrgwaveEndInds-1;
            TriggerEvents(k,:) = TempWavebox;
            TempWavebox = [0 0];
            TrgWaveStart = find(ChnDataNorm((TrgWaveStart+TrgwaveEndInds):end) > 0.95,1,'first')+TrgWaveStart+TrgwaveEndInds;
            k = k + 1;
        end
    end
end
%%
if isempty(TriggerEvents)
    fprintf('No trigger events detected.\n');
    return;
end
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




