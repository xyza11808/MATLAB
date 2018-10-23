DataPath = pwd;
UsedFiles = dir('*.mat');
nFiles = length(UsedFiles);

for cf = 1 : nFiles
    cfname = UsedFiles(cf).name;
    if strfind(cfname,'saline')
        if strfind(cfname,'Cortex')
            SessStr = 'Cortex_saline';
        else
            SessStr = 'Saline';
        end
    elseif strfind(cfname,'clozapine')
        if strfind(cfname,'Cortex')
            SessStr = 'Cortex_clozapine';
        else
            SessStr = 'Clozapine';
        end
    end
    cfData = load(cfname);
    