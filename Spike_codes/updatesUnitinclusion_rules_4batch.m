
% batched through all used sessions
cclr

% AllSessFolderPathfile = 'K\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);


%%
ErrosSess = zeros(NumprocessedNPSess,1);
% ProcessSess = [36,37,38,56,57];
for cfff = 2 : NumprocessedNPSess
% for cff = 1 : length(ProcessSess)
    
%     cfff = ProcessSess(cff);
    
%     ksfolder = fullfile(SessionFolders{cfff},sortingcode_string);
    
    ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','E:\NPCCGs'),sortingcode_string);

    fprintf('Processing session %d...\n', cfff);
    
    load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
    ProbNPSess.CurrentSessInds = [true,false];
    ProbNPSess.ksFolder = ksfolder;
    Newclasshandle = ProbNPSess.ClusScreeningFun;
    disp(mean(ProbNPSess.SurviveInds == Newclasshandle.SurviveInds));
    
    saveName = fullfile(ksfolder,'NPClassHandleSavedNew.mat');
    save(saveName,'Newclasshandle','-v7.3');
    
end