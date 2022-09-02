cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
OmitUnitStrsAll = cell(NumUsedSess,1);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS};
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup');
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    clearvars ProbNPSess
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataAligned.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    SessChnStrsfile = fullfile(ksfolder,'Chnlocation.mat');
    chnStrsAll = load(SessChnStrsfile,'ChnArea_Strings');
    load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
    try
        omittedUnitInds = SessAreaIndexData.SessAreaIndexStrc.Others.MatchedUnitInds;
        UnitMaxChnInds = ProbNPSess.ChannelUseds_id(omittedUnitInds);
        OmitUnitStrs = chnStrsAll.ChnArea_Strings(UnitMaxChnInds,3);
        OmitUnitStrsAll{cS} = OmitUnitStrs;
    catch
       fprintf('All units are target units for session %d.\n',cS); 
    end
    
end

%%
[UniqStr,~,Counts] = unique(AllAreaStrs);
TypeCounts = zeros(length(UniqStr),1);
for cT = 1 : length(UniqStr)
    TypeCounts(cT) = sum(Counts == cT);
end
