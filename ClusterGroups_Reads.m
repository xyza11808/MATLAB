function ClusterGroups_Reads(filename)
% used to read cluster informations

[~,name,ext] = fileparts(filename);
if strcmpi(ext,'.tsv')
    copyfile(fullfile(pwd,filename),fullfile(pwd,[name,'.csv']));
end

raw = readcell(fullfile(pwd,[name,'.csv']));



