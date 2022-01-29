% script for median channel value substraction
cclr

Part1Binfile = 'K:\NPdatas\sound_test1_g0_cat\catgt_sound_test1_g0\Cat_sound_test1_g0_imec0\b104a03_20210428_NPSess02_g0_t0.imec0.ap.bin';

NewFileLocation = 'N:\NPDatas\b104a03_20210428_NPSess02_Merged\b104a03_20210428_NPSess02_g0_imec0\Merge.imec0.ap.bin';

BatchSize = 3000000;
ChnNums = 384; % the last channel will be excluded, since that channel is only a trigger channel

SubType = 0; % 0 indicates across channel median substraction, 1 indicates across time median substraction, 2 indicates all substraction

%%
% write Part1 bin data
fullbinfile = Part1Binfile;
bytes       = get_file_size(fullbinfile); % size in bytes of raw binary
nTimepoints = floor(bytes/ChnNums/2); % number of total timepoints
mmf = memmapfile(fullbinfile,'Format',{'int16',...
    [ChnNums nTimepoints],'x'});

BatchIndsNum = ceil(nTimepoints/BatchSize);

% if we need to perform temporal median substraction, we need to calculate
% the temporal median value firstly

if SubType == 1 || SubType == 2
    BatchTempMedians = zeros(ChnNums,BatchIndsNum);
    for cb = 1 : BatchIndsNum
        if cb == BatchIndsNum
            DataInds = ((cb-1)*BatchSize+1):nTimepoints;
        else
            DataInds = ((cb-1)*BatchSize+1):(cb*BatchSize);
        end
        TempData = mmf.Data.x(1:ChnNums,DataInds);
        BatchTempMedians(:,cb) = median(TempData,2);
    end
    UsedOverallMedian = median(BatchTempMedians,2);
end
clearvars TempData 
% performing median substraction according to the substraction type
fMergBinDataid = fopen(NewFileLocation,'w+');
for cb = 1 : BatchIndsNum
    if cb == BatchIndsNum
        DataInds = ((cb-1)*BatchSize+1):MaxTimeInds;
    else
        DataInds = ((cb-1)*BatchSize+1):(cb*BatchSize);
    end
    WriteData = mmf.Data.x(:,DataInds);
    SubstractData = int16(zeros(size(WriteData)));
    if SubType == 0 || SubType == 2
        SubstractData(1:ChnNums,:) = WriteData(1:ChnNums,:) - median(WriteData(1:ChnNums,:));
    end
    if SubType == 1 || SubType == 2
        SubstractData(1:ChnNums,:) = ((SubstractData(1:ChnNums,:))' - UsedOverallMedian')';
    end
    SubstractData((1+ChnNums):end,:) = WriteData((1+ChnNums):end,:);
    
    fwrite(fMergBinDataid,WriteData,'int16');
    
end
fclose(fMergBinDataid);
