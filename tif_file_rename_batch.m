filepath='S:\BatchData\Batch52\20180430\anm01\test02rf';
cd(filepath);
files=dir('*.tif');
for n=1:length(files)
    filename=files(n).name;
    filename_base=filename(1:end-7);
    file_index=filename(end-6:end-4);
    filenum=str2num(file_index);
    if filenum > 61
        real_num=filenum-2;
        file_name_new=[filename_base,num2str(real_num,'%03d'),'.tif'];
        disp(['Renaming file number ' num2str(real_num,'%03d') '...\n']);
        movefile(filename,file_name_new);
    end
end