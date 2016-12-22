files = dir('*.tif');
nfiles = length(files);
fileTrnum = zeros(nfiles,1);
for nmnm = 1 : nfiles
    filename = files(nmnm).name;
    fileTrnum(nmnm) = str2num(filename(end-6:end-4));
end
%%
[fn,fp,fi] = uigetfile('*.txt','Please select the passive sound file for current session');
if fi
    datapath = fullfile(fp,fn);
    fid = fopen(datapath);
    SoundArray = textscan(fid,'%f %f %f');
    fclose(fid);
end
SArray = cell2mat(SoundArray);

%%
NewSoundArray = SArray(fileTrnum,:);
Newfname = [fn(1:end-4),'_new.txt'];
fID = fopen(fullfile(fp,Newfname),'w+');
fFormat = '%d\t%d\t%d\r\n';
for n = 1 : nfiles
    fprintf(fID,fFormat,NewSoundArray(n,1),NewSoundArray(n,2),NewSoundArray(n,3));
end
fclose(fID);
