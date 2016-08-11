
xpath = genpath('H:\data\behavior\2p_data\behaviro_data\batch28');
nameSplit = strsplit(xpath,';');
DirLength = length(nameSplit);

for n = 1 : DirLength
    cPATH = nameSplit{n};
    systemstr = ['ipython H:\Python\save_behavData_2_mat_batch.py ',cPATH];
    list = dir([cPATH,'\*.beh']);
    if isempty(list)
        fprintf('Folder path %s have no .beh files indside.\n',cPATH);
        continue;
    end
    [status,~] = system(systemstr);
    if status
        fprintf('!!!!Folder path %s error exist!!!!\n',cPATH);
    end
end