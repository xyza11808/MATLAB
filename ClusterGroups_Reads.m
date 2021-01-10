function [UsedIDs_clus,Channel_idUseds,UsedIDs_inds,raw] = ClusterGroups_Reads(filename)
% used to read cluster informations

[~,name,ext] = fileparts(filename);
if strcmpi(ext,'.tsv')
    copyfile(fullfile(pwd,filename),fullfile(pwd,[name,'.csv']));
end

raw = readcell(fullfile(pwd,[name,'.csv']));
%%
UsedIDs_inds = cellfun(@(x) strcmpi(x,'good'),raw(2:end,4)) & cellfun(@(x) ~strcmpi(x,'noise'),raw(2:end,9));
Clu_idAlls = cell2mat(raw(2:end,1));
Channel_idAlls = cell2mat(raw(2:end,6))+1;

UsedIDs_clus = Clu_idAlls(UsedIDs_inds);
Channel_idUseds = Channel_idAlls(UsedIDs_inds);



