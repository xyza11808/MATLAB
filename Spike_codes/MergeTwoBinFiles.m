cclr

Part1Binfile = 'N:\NPDatas\b104a03_20210428_NPSess02_g0\b104a03_20210428_NPSess02_g0_imec0\b104a03_20210428_NPSess02_g0_t0.imec0.ap.bin';
Part1UsedSampleNum = 80969446; % The left data points will be excluded

% Part2Binfile = 'N:\NPDatas\b104a03_20210428_NPSess02-2_g0\b104a03_20210428_NPSess02-2_g0_imec2\b104a03_20210428_NPSess02-2_g0_t0.imec2.ap.bin';
% Part2UsedSampleNum = -1; % All data was used

NewFileLocation = 'N:\NPDatas\b104a03_20210428_NPSess02_Merged\b104a03_20210428_NPSess02_g0_imec0\Merge.imec0.ap.bin';

BatchSize = 3000000;
ChnNums = 385;
%%
% write Part1 bin data
fullbinfile = Part1Binfile;
bytes       = get_file_size(fullbinfile); % size in bytes of raw binary
nTimepoints = floor(bytes/ChnNums/2); % number of total timepoints
mmf = memmapfile(fullbinfile,'Format',{'int16',...
    [ChnNums nTimepoints],'x'});
if Part1UsedSampleNum > 0
    BatchIndsNum = ceil(Part1UsedSampleNum/BatchSize);
    MaxTimeInds = Part1UsedSampleNum;
else
    BatchIndsNum = ceil(nTimepoints/BatchSize);
    MaxTimeInds = nTimepoints;
end

fMergBinDataid = fopen(NewFileLocation,'w+');
for cb = 1 : BatchIndsNum
    if cb == BatchIndsNum
        DataInds = ((cb-1)*BatchSize+1):MaxTimeInds;
    else
        DataInds = ((cb-1)*BatchSize+1):(cb*BatchSize);
    end
    WriteData = mmf.Data.x(:,DataInds);
    fwrite(fMergBinDataid,WriteData,'int16');
    
end
fclose(fMergBinDataid);
%%
% write Part2 bin data
fullbinfile2 = Part2Binfile;
bytes2       = get_file_size(fullbinfile2); % size in bytes of raw binary
nTimepoints2 = floor(bytes2/ChnNums/2); % number of total timepoints
mmf2 = memmapfile(fullbinfile2,'Format',{'int16',...
    [ChnNums nTimepoints2],'x'});
if Part2UsedSampleNum > 0
    BatchIndsNum = ceil(Part2UsedSampleNum/BatchSize);
    MaxTimeInds = Part2UsedSampleNum;
else
    BatchIndsNum = ceil(nTimepoints2/BatchSize);
    MaxTimeInds = nTimepoints2;
end

for cb = 1 : BatchIndsNum
    if cb == BatchIndsNum
        DataInds = ((cb-1)*BatchSize+1):MaxTimeInds;
    else
        DataInds = ((cb-1)*BatchSize+1):(cb*BatchSize);
    end
    WriteData = mmf2.Data.x(:,DataInds);
    fwrite(fMergBinDataid,WriteData,'int16');
end
fclose(fMergBinDataid);

TotalTimeSamples = nTimepoints2 + nTimepoints;
TotalSampleSize = get_file_size(NewFileLocation);

% clear