function [UsedIDs_clus,Channel_idUseds,UsedIDs_inds,raw] = ClusterGroups_Reads(filename)
% used to read cluster informations

[filepath,name,ext] = fileparts(filename);
if isempty(filepath)
    filepath = pwd;
end
if strcmpi(ext,'.tsv')
    copyfile(fullfile(filepath,[name,ext]),fullfile(filepath,[name,'.csv']));
end

raw = readcell(fullfile(filepath,[name,'.csv']));
%%
UsedIDs_inds = find(cellfun(@(x) strcmpi(x,'good'),raw(2:end,4)) & cellfun(@(x) ~strcmpi(x,'noise'),raw(2:end,9))...
    & cellfun(@(x) x>=1,raw(2:end,8)));
Clu_idAlls = cell2mat(raw(2:end,1));
Channel_idAlls = cell2mat(raw(2:end,6))+1;

UsedIDs_clusraw = Clu_idAlls(UsedIDs_inds);
[UsedIDs_clus,clussortinds] = sort(UsedIDs_clusraw);
UsedIDs_inds = UsedIDs_inds(clussortinds);
Channel_idUseds = Channel_idAlls(UsedIDs_inds);
% Channel_idUseds = Channel_idUseds(clussortinds);



