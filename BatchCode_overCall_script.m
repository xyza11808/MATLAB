cclr;
SumSourPath = 'G:\cal520_imaging_4M_old_mice\';
WithinSourcePaths = dir(fullfile(SumSourPath,'*2019*'));
FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
UsedTargetFolder = WithinSourcePaths(FolderIndex);
NumFolders = length(UsedTargetFolder);
FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);
% FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
%%
% AllFolderDatas = cell(NumFolders,1);
for cf = 1:NumFolders
    cInputPath = FolderFullpaths{cf};
    fprintf('Processing folder:\n %s...\n',cInputPath);
%     FieldDatas_All = IsFieldDataPath(cInputPath);
    FieldDatas_AllCe = IsFieldDataPath_LOADMAT(cInputPath);
end

% cd('E:\xnn_data')
% save OverAllDatas.mat AllFolderDatas -v7.3
%%
cclr;
SumSourPath = 'E:\xnn_data\4Mdata_summary';
WithinSourcePaths = dir(fullfile(SumSourPath,'*2019*'));
FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
UsedTargetFolder = WithinSourcePaths(FolderIndex);
NumFolders = length(UsedTargetFolder);
FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);
FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
% AllFolderDatas = cell(NumFolders,1);
for cf = NumFolders:-1:1
    cInputPath = FolderFullpaths{cf};
    FieldDatas_AllCell = IsFieldDataPath(cInputPath);
end
% 
% cd('E:\xnn_data')
% save OverAllDatas.mat AllFolderDatas -v7.3


