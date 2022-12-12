% batched through all used sessions
cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);

SessIndexCell = readcell(AllSessFolderPathfile,'Range','D:D',...
        'Sheet',1);
SessIndexAll = SessIndexCell(2:end);
SessIndexUsed = cat(1,SessIndexAll{UsedFolderInds});

UniqueSessTypes = unique(SessIndexUsed);

NumSess = length(UniqueSessTypes);

%%
% SessPairedDataSavePath = 'I:\ksOutput_backup\PairedSessionDatas';
SessPairedDataSavePath = 'K:\';

% AllSessFolderDatas = cell(NumSess, 2);
AllSessCalDatas = cell(NumSess, 3);
for cSess = 1 : NumSess
    cSessIndex = UniqueSessTypes(cSess);
    cSessfolders = SessionFolders(SessIndexUsed == cSessIndex);
    SessNumfolders = length(cSessfolders);
    cSfoldersData = cell(SessNumfolders,4);
    cSf_AreaNum = zeros(SessNumfolders, 1);
    for cSf = 1 : SessNumfolders
%         cSfolder = cSessfolders{cSf};
        cSfolder = fullfile(strrep(cSessfolders{cSf},'F:','I:\ksOutput_backup'),sortingcode_string);
        cSf_datafile = fullfile(cSfolder,'jeccAnA','CCACalDatas.mat');
        cSf_dataStrc = load(cSf_datafile);
        cSfoldersData(cSf,:) = {cSf_dataStrc.BlockVarDatas,cSf_dataStrc.TrialVarDatas,...
            cSf_dataStrc.ExistField_ClusIDs,cSf_dataStrc.NewAdd_ExistAreaNames};
        cSf_AreaNum(cSf) = length(cSfoldersData{cSf,4});
    end
    %
    % loop through each session folders to calculate all area pairs
    AllLoopNum = SessNumfolders*(SessNumfolders-1)/2;
    cSessFolderDatas = cell(AllLoopNum, 2);
    SessFoldInds = cell(AllLoopNum, 2);
    k = 1;
    for cf1 = 1 : SessNumfolders
        for cf2 = cf1+1 : SessNumfolders
            cf1data = cSfoldersData(cf1,:);
            cf2data = cSfoldersData(cf2,:);
            SessFoldInds{k, 1} = [cf1,cf2];
            
            AreaInds = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),1);
            %%%
%             PairedAreaCorrs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),6);
%             PairedAreaAvgs = cell(cSf_AreaNum(cf1)*cSf_AreaNum(cf2),4);
            ks = 1;
            for cf1Area = 1 : cSf_AreaNum(cf1)
                for cf2Area = 1 : cSf_AreaNum(cf2)
                    if isempty(cf1data{3}) || isempty(cf2data{3})
                        continue;
                    end
                    AreaInds{ks} = [cf1Area, cf2Area];
%                     cf1AreaInds = cf1data{3}{cf1Area,2};
%                     cf2AreaInds = cf2data{3}{cf2Area,2};
%                     
%                     cf1AreaNameStr = cf1data{4}{cf1Area};
%                     cf2AreaNameStr = cf2data{4}{cf2Area};
%                     
%                     % Block var baseline kernal
%                     cf1AreaBaseData = cf1data{1}{1}(:,cf1AreaInds,:);
%                     cf1AreaBaseValidData = cf1data{1}{2}(:,cf1AreaInds,:);
%                     
%                     cf2AreaBaseData = cf2data{1}{1}(:,cf2AreaInds,:);
%                     cf2AreaBaseValidData = cf2data{1}{2}(:,cf2AreaInds,:);
%                     
%                     [BVar_basecorrData, BVar_baseAvgs] = crossValCCA_SepData(cf1AreaBaseData,cf1AreaBaseValidData,...
%                         cf2AreaBaseData,cf2AreaBaseValidData,0.5);
%                     
%                     % Block var afterResp kernal
%                     cf1AreaAFData = cf1data{1}{3}(:,cf1AreaInds,:);
%                     cf1AreaAFValidData = cf1data{1}{4}(:,cf1AreaInds,:);
%                     
%                     cf2AreaAFData = cf2data{1}{3}(:,cf2AreaInds,:);
%                     cf2AreaAFValidData = cf2data{1}{4}(:,cf2AreaInds,:);
%                     
%                     [BVar_AFcorrData, BVar_AFAvgs] = crossValCCA_SepData(cf1AreaAFData,cf1AreaAFValidData,...
%                         cf2AreaAFData,cf2AreaAFValidData,0.5);
%                     
%                     % Trial var baseline kernal
%                     cf1AreaBase2Data = cf1data{2}{1}(:,cf1AreaInds,:);
%                     cf1AreaBase2ValidData = cf1data{2}{2}(:,cf1AreaInds,:);
%                     
%                     cf2AreaBase2Data = cf2data{2}{1}(:,cf2AreaInds,:);
%                     cf2AreaBase2ValidData = cf2data{2}{2}(:,cf2AreaInds,:);
%                     
%                     [TrVar_base2corrData, TrVar_base2Avgs] = crossValCCA_SepData(cf1AreaBase2Data,cf1AreaBase2ValidData,...
%                         cf2AreaBase2Data,cf2AreaBase2ValidData,0.5);
%                     
%                     % Trial var afterResp kernal
%                     cf1AreaAF2Data = cf1data{2}{3}(:,cf1AreaInds,:);
%                     cf1AreaAF2ValidData = cf1data{2}{4}(:,cf1AreaInds,:);
%                     
%                     cf2AreaAF2Data = cf2data{2}{3}(:,cf2AreaInds,:);
%                     cf2AreaAF2ValidData = cf2data{2}{4}(:,cf2AreaInds,:);
%                     
%                     [TrVar_AF2corrData, TrVar_AF2Avgs] = crossValCCA_SepData(cf1AreaAF2Data,cf1AreaAF2ValidData,...
%                         cf2AreaAF2Data,cf2AreaAF2ValidData,0.5);
%                     
%                     PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AFcorrData, TrVar_base2corrData, ...
%                         TrVar_AF2corrData,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
%                         [numel(cf1AreaInds),numel(cf2AreaInds)]};
%                     PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AFAvgs,TrVar_base2Avgs,TrVar_AF2Avgs};
                    ks = ks + 1;
                end
            end
%             cSessFolderDatas(k,:) = {PairedAreaCorrs, PairedAreaAvgs};
            SessFoldInds{k,2} = cat(1, AreaInds{:});
            k = k + 1;
        end
    end
    AllSessCalDatas(cSess,:) = {cSfoldersData, cSf_AreaNum, SessFoldInds};
%     AllSessFolderDatas{cSess,1} = cat(1,cSessFolderDatas{:,1});
%     AllSessFolderDatas{cSess,2} = cat(1,cSessFolderDatas{:,2});
    fprintf('Sess %d is processed.\n', cSess);
end

%%
savefileName = fullfile(SessPairedDataSavePath,'AcrossProbe_CCA_calResults.mat');
save(savefileName,'AllSessFolderDatas','AllSessCalDatas','-v7.3');



