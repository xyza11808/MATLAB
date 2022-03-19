cclr

AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
OmitUnitStrsAll = cell(NumUsedSess,1);
for cS = 1 :  NumUsedSess
    cSessPath = SessionFolders{cS}(2:end-1);
%     cSessPath = strrep(SessionFolders{cS}(2:end-1),'F:','I:\ksOutput_backup');
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    clearvars ProbNPSess
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexData.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    SessChnStrsfile = fullfile(ksfolder,'Chnlocation.mat');
    chnStrsAll = load(SessChnStrsfile,'ChnArea_Strings');
    load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
    try
        omittedUnitInds = SessAreaIndexData.SessAreaIndexStrc.Others.MatchedUnitInds;
        UnitMaxChnInds = ProbNPSess.ChannelUseds_id(omittedUnitInds);
        OmitUnitStrs = chnStrsAll.ChnArea_Strings(UnitMaxChnInds+1,3);
        OmitUnitStrsAll{cS} = OmitUnitStrs;
    catch
       fprintf('All units are target units for session %d.\n',cS); 
    end
    
end