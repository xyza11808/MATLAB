% cclr
% pause(3600); % wait untill the data transfer is finished
cclr
if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    RawfileFolder = '/Volumes/XIN-Yu-potable-disk/batch53_data'; % raw bin file folder contains all raw data files path for each probe
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
    Rawxpath = genpath(RawfileFolder);
    RawnameSplit = (strsplit(Rawxpath,':'))';
elseif ispc
    GrandPath ='H:\catprosessdata\20221203batch_055_cat\055_20221203_LOFC_g0_cat\catgt_055_20221203_LOFC_g0'; % cat processing file folder
    RawfileFolder = 'H:\catprosessdata\20221203batch_055_cat\055_20221203_LOFC_g0_cat\catgt_055_20221203_LOFC_g0';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
    Rawxpath = genpath(RawfileFolder);
    RawnameSplit = (strsplit(Rawxpath,':'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
if isempty(RawnameSplit{end})
    RawnameSplit(end) = [];
end
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
PossDataPath = nameSplit(PossibleInds);

PossibleIndsRaw = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),RawnameSplit);
PossDataPathRaw = RawnameSplit(PossibleIndsRaw);

if length(PossDataPath) ~= length(PossDataPathRaw)
    warning('The detected cat file folder number is different from raw folders.\n');
    return;
end

% Find processed folders 
ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,'ks2_5','spike_times.npy'),'file'),PossDataPath);
UnprocessedFolds = PossDataPath(~(ProcessedFoldInds>0));
NumNeedProcessFs = length(UnprocessedFolds);
rawmapInds = zeros(NumNeedProcessFs, 1);
for cf = 1 : NumNeedProcessFs
    cfPath = UnprocessedFolds{cf};
    % find imec index
    [StartIn, endInds] = regexp(cfPath,'imec\d{1,2}');
    ProbeIndsStr = cfPath(StartIn(1):endInds(1));
    cf2RawMapInds = find(contains(PossDataPathRaw, ProbeIndsStr));
    if isempty(cf2RawMapInds)
        warning('There is no matched raw file folder for current path:\n%s\n',cfPath);
        continue;
    end
    rawmapInds(cf) = cf2RawMapInds;
end
MappedRawfolders = PossDataPathRaw(rawmapInds);
%%
% error for 7th session
Errors = cell(NumNeedProcessFs,1);
for cf = 1 : NumNeedProcessFs
    %
%     try
        cfpath = UnprocessedFolds{cf};
        clearvars rez rootZ rootH
        rootZ = cfpath;
        rootH = fullfile(rootZ,'temp');
        rootRaw = MappedRawfolders{cf};
        close all;
        fprintf('Processing folder: \n %s ...\n',rootZ);
        main_kilosort;
%         tempcodes;
%     catch ME
%         Errors{cf} = ME;
%     end
    %
end


%%
% for cf = 1 : NumNeedProcessFs
%     try
%         cfpath = UnprocessedFolds{cf};
%         clearvars rez rootZ rootH
%         rootZ = fullfile(cfpath,'kilosort3');
%         %
%         rootH = fullfile(rootZ,'rezdata.mat');
%         load(rootH);
%         rezToPhy2(rez, rootZ);
% %         save(fullfile(rootZ,'rezdata.mat'),'rez','rezCPU','-v7.3');
%         %
%     catch
%         fprintf('Error for session <%d>.\n',cf);
%     end
% end
