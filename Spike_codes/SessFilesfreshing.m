cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);
sortingcode_string = 'ks2_5';
%%
UnitNumsAll = zeros(NumprocessedNPSess,1);
for cP = 1 : NumprocessedNPSess
     fprintf('Processing session %d...\n',cP);
%     cPath = SessionFolders{cP};
%     cPath = strrep(SessionFolders{cP},'F:\','E:\NPCCGs\');
%     cPath = fullfile(strrep(SessionFolders{cP},'F:','I:\ksOutput_backup'),sortingcode_string); %
    cPath = fullfile(strrep(SessionFolders{cP},'F:','P:'),sortingcode_string);
    if ~isfolder(fullfile(cPath,'TobeDeleted'))
        mkdir(fullfile(cPath,'TobeDeleted'));
    end
    
    if exist(fullfile(cPath,'OldNPClassHandleSaved.mat'),'file')
        movefile(fullfile(cPath,'OldNPClassHandleSaved.mat'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    for cB = 1 : 4
        if exist(fullfile(cPath,sprintf('Block%d_plot_stimBin',cB)),'dir')
            movefile(fullfile(cPath,sprintf('Block%d_plot_stimBin',cB)),...
                fullfile(cPath,'TobeDeleted'),'f');
        end
        if exist(fullfile(cPath,sprintf('Block%d_spRaster_stimBin',cB)),'dir')
            movefile(fullfile(cPath,sprintf('Block%d_spRaster_stimBin',cB)),...
                fullfile(cPath,'TobeDeleted'),'f');
        end
    end
    if exist(fullfile(cPath,'SessAreaIndexData.mat'),'file')
        movefile(fullfile(cPath,'SessAreaIndexData.mat'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    if exist(fullfile(cPath,'SessAreaIndexData2.mat'),'file')
        movefile(fullfile(cPath,'SessAreaIndexData2.mat'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    if exist(fullfile(cPath,'SessAreaIndexDataNew.mat'),'file')
        movefile(fullfile(cPath,'SessAreaIndexDataNew.mat'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    if exist(fullfile(cPath,'Old_BaselinePredofBT'),'dir')
        movefile(fullfile(cPath,'Old_BaselinePredofBT'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    if exist(fullfile(cPath,'Old_BaselinePredofBTSVM'),'dir')
        movefile(fullfile(cPath,'Old_BaselinePredofBTSVM'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    if exist(fullfile(cPath,'Old_BTANDChoiceAUC_compPlot'),'dir')
        movefile(fullfile(cPath,'Old_BTANDChoiceAUC_compPlot'),...
            fullfile(cPath,'TobeDeleted'),'f');
    end
    try
        rmdir(fullfile(cPath,'BaselinePredofBlocktype'),'s');
        rmdir(fullfile(cPath,'BaselinePredofBlocktypeSVM'),'s');
        rmdir(fullfile(cPath,'BTANDChoiceAUC_compPlot'),'s');
        rmdir(fullfile(cPath,'BTANDChoiceAUC_TrWise'),'s');
    end
end