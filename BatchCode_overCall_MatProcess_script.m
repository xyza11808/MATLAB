%%
cclr;
SumSourPath = 'E:\xnn_data\temp_0915';
WithinSourcePaths = dir(fullfile(SumSourPath,'*2019*'));
FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
UsedTargetFolder = WithinSourcePaths(FolderIndex);
NumFolders = length(UsedTargetFolder);
FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);
FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
AllFolderDatas = cell(NumFolders,1);
for cf = 1:NumFolders
    cInputPath = FolderFullpaths{cf};
    FieldDatas_AllCell = IsFieldDataPath_LOADMAT(cInputPath);
    AllFolderDatas{cf} = FieldDatas_AllCell;
end

cd('E:\xnn_data')
save OverAllDatas.mat AllFolderDatas -v7.3
