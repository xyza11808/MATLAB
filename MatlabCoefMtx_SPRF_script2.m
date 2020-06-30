% script for analysis same FOV different session correlation matrix data

% path for all sessions
SourcePath = 'T:\batch\batch70\20200528\anm06';

cd(SourcePath);

Sessfolders = dir(fullfile(SourcePath,'test*'));
NumFolders = length(Sessfolders);
SessNames = cell(NumFolders,1);
SessCorrMtx = cell(NumFolders,1);
for cpath = 1 : NumFolders
    cPathName = Sessfolders(cpath).name;
    cPathData_path = ['./',cPathName ,'/im_data_reg_cpu/result_save/dffMatfile.mat'];
    cPathDataStrc = load(cPathData_path);
    cPathCorrMtx = corrcoef(cPathDataStrc.MoveFreeDataMtx');
    SessCorrMtx{cpath} = cPathCorrMtx;
    SessNames{cpath} = cPathName;
end

%%
NumSess = length(SessCorrMtx);
hf = figure('position',[20 200 1400 640]);
NonRepeatCoefs = cell(NumSess, 1);

for cS = 1 : NumSess
    subplot(2,NumSess,cS);
    imagesc(SessCorrMtx{cS},[-0.5 0.5]);
    title(strrep(SessNames{cS},'_','\_'));
    
    aax = subplot(2,NumSess,cS+NumSess);
    AllCoefValues = SessCorrMtx{cS}(logical(tril(ones(size(SessCorrMtx{cS})),-1)));
    NonRepeatCoefs{cS} = AllCoefValues;
    
    hist(AllCoefValues,50);
    yscales = get(aax,'ylim');
    AvgCoefs = mean(AllCoefValues);
    MedianCoef = median(AllCoefValues);
    line([AvgCoefs AvgCoefs], yscales, 'Color', 'r', 'linewidth', 1.5);
    line([MedianCoef MedianCoef], yscales, 'Color', 'c', 'linewidth', 1.5);
    text(AvgCoefs+0.05, yscales(2)*0.8, num2str(AvgCoefs,'%.3f'),'Color','m');
    box off
end

%%
zz = linkage(1-SessCorrMtx{2},'complete','correlation');
Numzz = length(zz);
NumClusters = zeros(Numzz,1);
for cz = 1 : Numzz
    groups = cluster(zz,'cutoff',zz(cz,3),'criterion','distance');
%     groups = cluster(zz,'cutoff',0.9,'criterion','distance');
    Gr_Types = unique(groups);
    NumClusters(cz) = length(Gr_Types);
end
% figure('position',[600 100 420 350]);
% dendrogram(zz)
% groups = cluster(zz,'cutoff',0.9,'criterion','distance');

%%
UsedThreshold = zz(Numzz-4,3);
groups = cluster(zz,'cutoff',UsedThreshold,'criterion','distance');
Gr_Types = unique(groups);
[SortGrInds, R_Inds] = sort(groups);
figure;
imagesc(SessCorrMtx{2}(R_Inds,R_Inds),[-0.5 0.5]);


