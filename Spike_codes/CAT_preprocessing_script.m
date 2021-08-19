cclr
sessionSaveFolder = 'I:\b103a04_NPdata\b103a04_20210408_NPSess01_g0'; % this is the session folder name for each days recording session
datasave_folder = 'F:\testfolder';
sessionProbeNameStrc = dir(fullfile(sessionSaveFolder,'*imec*')); % number of imec folders, corresponded to probe number
sessionProbeNums = length(sessionProbeNameStrc);
if sessionProbeNums < 1
    return;
end
%%
imecStrc = cell(sessionProbeNums,2);
for cimec = 1 : sessionProbeNums
   cimec_folderName =  sessionProbeNameStrc(cimec).name;
   [imecstart, imecend] = regexp(cimec_folderName,'imec\d{1}');
   imecStrc{cimec,1} = cimec_folderName(imecstart : imecend);
   imecStrc{cimec,2} = cimec_folderName;
end

UpperfolderPath = fileparts(sessionSaveFolder);
pathfoldername_spilt = strsplit(sessionSaveFolder,filesep);
CurrentfolderName = pathfoldername_spilt{end};

cat_batfile_path = 'F:\CatGT-win\runit.bat';
[gStart, gEnd] = regexp(CurrentfolderName,'_g\d{1}');
gNumber = CurrentfolderName((gStart+1):gEnd);

if ~strcmp(CurrentfolderName(end-1:end),gNumber)
    error('The current foldername (run name) must be ended with _g(number)');
end
run_name = CurrentfolderName(1:end-3); % run name must will have _g0 excluded
    
catsaveName = [CurrentfolderName,'_cat'];
catsave_fullpath = fullfile(datasave_folder, catsaveName);
if ~isdir(catsave_fullpath)
    mkdir(catsave_fullpath);
end
%
powershellLocation = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';
systemstr = sprintf('%s %s -dir=%s -prb=0:4 -gbldmx -dest=%s -aphipass=300 -run=%s -g=%s -t=0 -ap -prb_fld -prb_miss_ok',...
    powershellLocation, cat_batfile_path, UpperfolderPath, catsave_fullpath, run_name,gNumber(end));
%
status = system(systemstr);
disp(status);

%%
catSavePathstrc = dir(fullfile(catsave_fullpath,sprintf('*_%s',CurrentfolderName)));
catfileSavepath = fullfile(catsave_fullpath,catSavePathstrc(1).name);

if status
    error('Catbat excution report wrong.');
end
%%
% move each probe's data into seperate folders, and copy the *.lF.bin (LFP
% data) data into corresponded folders

for cprobe = 1 : sessionProbeNums
    cprobe_imec_str = imecStrc{cprobe,1};
    Rawfilepath = fullfile(sessionSaveFolder, imecStrc{cprobe,2});
    
    % create new imec saved folder path
    save_imec_filder = fullfile(catfileSavepath,sprintf('Cat_%s',imecStrc{cprobe,2}));
    if ~isdir(save_imec_filder)
        mkdir(save_imec_filder);
    end
    
    % move ap.bin file
    Newsaved_imecfile_strc = dir(fullfile(catfileSavepath,sprintf('*.%s.ap.bin',cprobe_imec_str)));
    Newsaved_imecfile_path = fullfile(catfileSavepath, Newsaved_imecfile_strc(1).name);
    Target_imecfile_path = fullfile(save_imec_filder,Newsaved_imecfile_strc(1).name);
    stat1 = movefile(Newsaved_imecfile_path,Target_imecfile_path,'f');
    
    % move ap.meta file
    Newsaved_imecfile_strc = dir(fullfile(catfileSavepath,sprintf('*.%s.ap.meta',cprobe_imec_str)));
    Newsaved_imecfile_path = fullfile(catfileSavepath, Newsaved_imecfile_strc(1).name);
    Target_imecfile_path = fullfile(save_imec_filder,Newsaved_imecfile_strc(1).name);
    stat2 = movefile(Newsaved_imecfile_path,Target_imecfile_path,'f');
    
    % move lF.bin file
    Newsaved_imecfile_strc = dir(fullfile(Rawfilepath,sprintf('*.%s.lf.bin',cprobe_imec_str)));
    Oldpath_imecfile_path = fullfile(Rawfilepath, Newsaved_imecfile_strc(1).name);
    Target_imecfile_path = fullfile(save_imec_filder,Newsaved_imecfile_strc(1).name);
    stat3 = copyfile(Oldpath_imecfile_path,Target_imecfile_path,'f');
    
    % move lf.meta file
    Newsaved_imecfile_strc = dir(fullfile(Rawfilepath,sprintf('*.%s.lf.meta',cprobe_imec_str)));
    Oldpath_imecfile_path = fullfile(Rawfilepath, Newsaved_imecfile_strc(1).name);
    Target_imecfile_path = fullfile(save_imec_filder,Newsaved_imecfile_strc(1).name);
    stat4 = copyfile(Oldpath_imecfile_path,Target_imecfile_path,'f');
    
    if ~all([stat1,stat2,stat3,stat4])
        disp([stat1,stat2,stat3,stat4]);
        error('At least one of the operation is failed.');
    end
end












