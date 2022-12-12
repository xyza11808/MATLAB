% cclr
% pause(3600); % wait untill the data transfer is finished
cclr
if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'D:\catprosessdata\sound_test4_DiItest_g0_cat\catgt_sound_test4_DiItest_g0';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
PossDataPath = nameSplit(PossibleInds);

% Find processed folders 
ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,'ks2_5','spike_times.npy'),'file'),PossDataPath);
UnprocessedFolds = PossDataPath(~(ProcessedFoldInds>0));
NumNeedProcessFs = length(UnprocessedFolds);

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
for cf = 1 : NumNeedProcessFs
    try
        cfpath = UnprocessedFolds{cf};
        clearvars rez rootZ rootH
        rootZ = fullfile(cfpath,'kilosort3');
        %
        rootH = fullfile(rootZ,'rezdata.mat');
        load(rootH);
        rezToPhy2(rez, rootZ);
%         save(fullfile(rootZ,'rezdata.mat'),'rez','rezCPU','-v7.3');
        %
    catch
        fprintf('Error for session <%d>.\n',cf);
    end
end
