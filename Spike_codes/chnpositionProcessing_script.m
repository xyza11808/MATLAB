
cclr
AnmSess_sourcepath = 'I:\ksOutput_backup\b103a04_ksoutput';
[fname, fpath, fidx] = uigetfile({'*.xlsx';'*.xls'},'Select chnposition spreadsheet file','probe_chn_location.xlsx');
if ~fidx
    return;
end
AnatomyChnposFile = fullfile(fpath, fname);
% AnatomyChnposFile = 'E:\datas\anatomy\b107a07_RGBfiles\slices\probe_chn_location.xlsx';
% try
%     DataCellWithNames = readcell(AnatomyChnposFile);
% catch
%     [~,~,DataCellWithNames] = xlsread(AnatomyChnposFile);
% end

% file_pointer = spreadsheetDatastore(AnatomyChnposFile);
chnposdata_range = 'A:C';
probeSessInfo_range = 'D1:G2';

%% read probe position information for the xls sheet
sheetnamesAll = sheetnames(AnatomyChnposFile);
NumofSheets = length(sheetnamesAll);

probechnpos_info_All = cell(NumofSheets,3);
isBadProbeRecover = zeros(NumofSheets,1);
for cSheet = 1 : NumofSheets
    %
    cSheetName = sheetnamesAll{cSheet};
    ChnposDatas = readcell(AnatomyChnposFile,'Range',chnposdata_range,...
        'Sheet',cSheetName);
    probeSessinfo = readcell(AnatomyChnposFile,'Range',probeSessInfo_range,...
        'Sheet',cSheetName);
    chnpos_ccfIndex = [cell2mat(ChnposDatas(2:end,1)),cell2mat(ChnposDatas(2:end,2))];
    
    probeSessionInfo = struct('ProbeName',cSheetName,'ProbeNum',str2num(cSheetName(6:end))); %#ok<*ST2NM>
    
    for cInfoContents = 1 : 4 % four field of infomation is needed for session folder extraction
        if isnan(probeSessinfo{2,cInfoContents})
            isBadProbeRecover(cSheet) = 1;
            break;
        end
        probeSessionInfo.(probeSessinfo{1,cInfoContents}) = probeSessinfo{2,cInfoContents};
        
    end
    probechnpos_info_All(cSheet,:) = {chnpos_ccfIndex,probeSessionInfo,ChnposDatas};
    %
end
if sum(isBadProbeRecover)
    probechnpos_info_All(isBadProbeRecover > 0,:) = [];
end
%% list all possible NP sessions and save the folder path

xpath = genpath(AnmSess_sourcepath);
nameSplit = (strsplit(xpath,';'))';

if isempty(nameSplit{end})
    nameSplit(end) = [];
end
% DirLength = length(nameSplit);
% PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
% PossDataPath = nameSplit(PossibleInds);
sortingcode_string = 'ks2_5';
% Find processed folders 
ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,sortingcode_string,'spike_times.npy'),'file'),nameSplit);
NPsessionfolders = nameSplit((ProcessedFoldInds>0));
NumprocessedNPSess = length(NPsessionfolders);
if NumprocessedNPSess < 1
    warning('No valid NP session was found in current path.');
end
%% loop through all sheet file datas and find the corresponded NP session folder path
MatchedProbeInds = nan(NumprocessedNPSess,1);
for cSessInds = 1 : NumprocessedNPSess
    %
    SessFolder = NPsessionfolders{cSessInds};
    Sess2ProbeInds = cellfun(@(x) contains(SessFolder,x.AnmID),probechnpos_info_All(:,2)) & ...
        cellfun(@(x) contains(SessFolder,x.ProbeIndex),probechnpos_info_All(:,2)) & ...0
        (cellfun(@(x) contains(SessFolder,num2str(x.Date,'%d')),probechnpos_info_All(:,2)) | ...
        cellfun(@(x) contains(SessFolder,num2str(x.NPSessIndex,'NPSess%02d')),probechnpos_info_All(:,2)));
    if sum(Sess2ProbeInds) > 1
        warning('Session %d have multiple(%d) matched probes, please check the matching logics.\n',...
            cSessInds,sum(Sess2ProbeInds));
        continue;
    end
    if sum(Sess2ProbeInds) == 1
       matchedInds = find(Sess2ProbeInds);
       MatchedProbeInds(cSessInds) = matchedInds;
    end
    
end
disp(MatchedProbeInds');
%% write chn position data into each NP session folder path
% also read probeCCF data and save individual probe datas within target
% session path
probeCCFfilePath = fullfile(fpath,'probe_ccf.mat');
probeCCFData = load(probeCCFfilePath);

for cf = 1 : NumprocessedNPSess
    if isnan(MatchedProbeInds(cf))
        continue;
    end
    SessFolder = NPsessionfolders{cf};
    SavedFileName = fullfile(SessFolder, sortingcode_string, 'Chnlocation.mat');
    ProbeCCFSavefile = fullfile(SessFolder, sortingcode_string, 'ProbeCCFdata.mat');
    
    ProbeSessDatas = probechnpos_info_All(MatchedProbeInds(cf),:);
    ChnArea_indexes = ProbeSessDatas{1};
    ChnArea_Strings = ProbeSessDatas{3};
    ChnArea_info = ProbeSessDatas{2};
    
    ProbeIndex = MatchedProbeInds(cf);
    ProbeCCF = probeCCFData.probe_ccf(ProbeIndex);
    
    save(SavedFileName,'ChnArea_indexes','ChnArea_Strings','ChnArea_info','-v7.3');
    save(ProbeCCFSavefile,'ProbeCCF','ProbeIndex','-v7.3');
end

