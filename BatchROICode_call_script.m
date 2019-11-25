cclr

if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'E:\xnn_data\temp_0825';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
%%
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) strcmpi(x(end-12:end),'Aligned_datas'),nameSplit);
PossDataPath = nameSplit(PossibleInds);
UsedPathInds = cellfun(@(x) exist(fullfile(x,'ROIinfoData.mat'),'file'),PossDataPath);
UsedPaths = PossDataPath(UsedPathInds > 0);
NumUsedPaths = length(UsedPaths);


%%
for cSess = 1 : NumUsedPaths
    cfp = UsedPaths{cSess};
    cd(cfp);
    BatchROICode_batch_script;
end

