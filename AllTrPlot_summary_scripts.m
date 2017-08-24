clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
m = 1;
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = [tline,'\All BehavType Colorplot'];
    else
        SessPath = tline;
    end
    if m == 1
        PPTname = input('Please input the pptx file name:\n','s');
        if isempty(strfind(PPTname,'.ppt')) || isempty(strfind(PPTname,'.pptx'))
            PPTname = [PPTname,'.pptx'];
        end
        SavePath = uigetdir(pwd,'Please select a path to save the ppt file');
    end
    pptfullname = fullfile(SavePath,PPTname);
    if ~exist(pptfullname,'file')
         exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of session aligned sort plots');
    else
        exportToPPTX('open',pptfullname);
    end
    cd(SessPath);
    cPathPngs = dir('*.png');
    nfiles = length(cPathPngs);
    for nf = 1 : nfiles
        exportToPPTX('addslide');
        cfname = cPathPngs(nf).name;
        ImportFig = imread(cfname);
        exportToPPTX('addtext',cfname(1:end-4),'Position',[0 1 2 7],'FontSize',24);
        exportToPPTX('addnote',pwd);
        exportToPPTX('addpicture',ImportFig,'Position',[2 0 13.5 9]);
    end
    m = m + 1;
    SaveName = exportToPPTX('saveandclose',pptfullname);
    tline = fgetl(fid);
end
