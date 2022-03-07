cclr

AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
sortingcode_string = 'ks2_5';
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumprocessedNPSess = length(SessionFolders);

%%
SessUnitCoefStrs = cell(NumprocessedNPSess,2);
for cSess = 1 : NumprocessedNPSess
    
    %     cPath = SessionFolders{cSess}(2:end-1);
    ksfolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'),'ks2_5');
    
    CoefStrc = load(fullfile(ksfolder, 'UnitRespTypeCoef.mat'),'AboveThresUnit','UnitUsedCoefs');
    load(fullfile(ksfolder, 'NPClassHandleSaved.mat'));
    ChnLocationStrc = load(fullfile(ksfolder, 'Chnlocation.mat'),'ChnArea_Strings');

    %
    % only the above threshold unit maximum channels were used
    UnitMaxampChnInds = ProbNPSess.ChannelUseds_id(CoefStrc.AboveThresUnit); 
    if ~isempty(UnitMaxampChnInds)
        AllChnStrs = ChnLocationStrc.ChnArea_Strings(2:end,:);
        UnitChnAreasAll = AllChnStrs(UnitMaxampChnInds,:);

        AllUnitCoefMtx = cell2mat(CoefStrc.UnitUsedCoefs);
        
        SessUnitCoefStrs(cSess,:) = {AllUnitCoefMtx, UnitChnAreasAll};
    end
    
end
%%
saveName = 'K:\Documents\me\projects\NP_reversaltask\UnitCoefSummary.mat';
save(saveName,'SessUnitCoefStrs','-v7.3');


%%
TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% TargetBrainArea_file = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
NumofTargetAreas = length(TargetRegionNamesAll);

%%
AllRespUnit_RespCoefs = cell2mat(SessUnitCoefStrs(:,1));
AllRespUnit_regions = cat(1,SessUnitCoefStrs{:,2});
RespUnitRegionIndex = cell2mat(AllRespUnit_regions(:,2));





