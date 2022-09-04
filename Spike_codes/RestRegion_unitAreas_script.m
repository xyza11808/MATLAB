cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
OmitUnitStrsAll = cell(NumUsedSess,1);
for cS = 1 :  NumUsedSess
%    cSessPath = SessionFolders{cS};
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup');
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    clearvars ProbNPSess
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataAligned.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    if ~isfield(SessAreaIndexData.SessAreaIndexStrc,'Others') || ...
            isempty(SessAreaIndexData.SessAreaIndexStrc.Others)
       fprintf('All units are target units for session %d.\n',cS); 
    else
        
        SessChnStrsfile = fullfile(ksfolder,'Chnlocation.mat');
        chnStrsAll = load(SessChnStrsfile,'AlignedAreaStrings');
        load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
    
        omittedUnitInds = SessAreaIndexData.SessAreaIndexStrc.Others.MatchedUnitInds;
        UnitMaxChnInds = ProbNPSess.ChannelUseds_id(omittedUnitInds);
        OmitUnitStrs = chnStrsAll.AlignedAreaStrings{2}(UnitMaxChnInds);
        OmitUnitStrsAll{cS} = OmitUnitStrs;
    end    
    %
end

%% total unit number counts
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);

SessUnitNumsAll = zeros(NumUsedSess,1);
for cS = 1 :  NumUsedSess
%    cSessPath = SessionFolders{cS};
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup');
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    clearvars ProbNPSess
%%     SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataAligned.mat');
    NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
    NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
    NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
    NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
    if strcmpi(NewAdd_ExistAreaNames(end),'Others')
        NewAdd_ExistAreaNames(end) = [];
    end
    NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

    Numfieldnames = length(NewAdd_ExistAreaNames);
    ExistField_ClusIDs = cell(Numfieldnames,4);
    AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
    for cA = 1 : Numfieldnames
        cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
        cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
        ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
            NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
        AreaUnitNumbers(cA) = numel(cA_clus_inds);
    end
    %%
    SessUnitNumsAll(cS) = sum(AreaUnitNumbers);
%     SessAreaIndexData = load(SessAreaIndexDatafile);
%     if ~isfield(SessAreaIndexData.SessAreaIndexStrc,'Others') || ...
%             isempty(SessAreaIndexData.SessAreaIndexStrc.Others)
%        fprintf('All units are target units for session %d.\n',cS); 
%     else
%         
%         SessChnStrsfile = fullfile(ksfolder,'Chnlocation.mat');
%         chnStrsAll = load(SessChnStrsfile,'AlignedAreaStrings');
%         load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
%     
%         omittedUnitInds = SessAreaIndexData.SessAreaIndexStrc.Others.MatchedUnitInds;
%         UnitMaxChnInds = ProbNPSess.ChannelUseds_id(omittedUnitInds);
%         OmitUnitStrs = chnStrsAll.AlignedAreaStrings{2}(UnitMaxChnInds);
%         OmitUnitStrsAll{cS} = OmitUnitStrs;
%     end    
    %
end





%%
AllAreaStrs = cat(1,OmitUnitStrsAll{:});
[UniqStr,~,Counts] = unique(AllAreaStrs);
TypeCounts = zeros(length(UniqStr),1);
for cT = 1 : length(UniqStr)
    TypeCounts(cT) = sum(Counts == cT);
end
