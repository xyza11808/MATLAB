cclr
AssignFilePath = 'K:\UnitwaveRecalPath.xlsx';

sortingcode_string = 'ks2_5';

SessionFoldersC = readcell(AssignFilePath,'Range','A:A',...
        'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
SessionFoldersAll = SessionFoldersC(2:end);
UsedFolderInds = cellfun(@ischar,SessionFoldersAll);
SessionFolders = SessionFoldersAll(UsedFolderInds);
NumprocessedNPSess = length(SessionFolders);

RawFileFoldersC = readcell(AssignFilePath,'Range','B:B',...
        'Sheet',1);
RawFileFoldersAll = RawFileFoldersC(2:end);
RawFileFolders = RawFileFoldersAll(UsedFolderInds);

%%

for cProcess = 1 : NumprocessedNPSess
    
%     try
        ksfolder = fullfile(strrep(SessionFolders{cProcess},'E:\NPCCGs','I:\ksOutput_backup'));
        
        fprintf('Processing session %d...\n', cProcess);
        RawFilePath = RawFileFolders{cProcess};
        recal_unitwaveforms2;
%     catch ME
%         disp(ME);
%         fprintf('Error processing for session %d.\n',cProcess);
%     end
    
end 
        

