cclr;
SumSourPath = 'E:\xnn_data\data_202005_mats';
cd(SumSourPath);
WithinSourcePaths = dir(fullfile(SumSourPath,'*2020*'));
FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
UsedTargetFolder = WithinSourcePaths(FolderIndex);
NumFolders = length(UsedTargetFolder);
FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);

% FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
%%
% AllFolderDatas = cell(NumFolders,1);
for cf = 6:6
    cInputPath = FolderFullpaths{cf};
    fprintf('Processing folder:\n %s...\n',cInputPath);
%     FieldDatas_All = IsFieldDataPath(cInputPath);
    FieldDatas_AllCe = IsFieldDataPath(cInputPath);
end

% cd('E:\xnn_data')
% save OverAllDatas.mat AllFolderDatas -v7.3
%
% cclr;
% SumSourPath = 'F:\';
% WithinSourcePaths = dir(fullfile(SumSourPath,'*2020*'));
% FolderIndex = arrayfun(@(x) x.isdir,WithinSourcePaths);
% UsedTargetFolder = WithinSourcePaths(FolderIndex);
% NumFolders = length(UsedTargetFolder);
% FolderFullpaths = arrayfun(@(x) fullfile(x.folder,x.name),UsedTargetFolder,'UniformOutput',false);
% FolderNames = arrayfun(@(x) x.name,UsedTargetFolder,'UniformOutput',false);
% AllFolderDatas = cell(NumFolders,1);
for cf = 6:6
    cInputPath = FolderFullpaths{cf};
    FieldDatas_AllCell = IsFieldDataPath_LOADMAT(cInputPath);
end
% 
% cd('E:\xnn_data')
% save OverAllDatas.mat AllFolderDatas -v7.3

%%

for cf = 1:NumFolders
    cInputPath = FolderFullpaths{cf};
    IsFieldDataPath_SessFrameIndex(cInputPath);
end

