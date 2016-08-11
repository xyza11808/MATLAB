filepath='M:\batch\batch19\20151127\anm01\test01\im_data_reg_gpu';
cd(filepath);
files=dir('*.tif');
for n=1:length(files)
filename=files(n).name;
filename_base=filename(1:end-7);
file_index=filename(end-6:end-4);
filenum=str2num(file_index);
real_num=filenum-96;
file_name_new=[filename_base,'rename_',num2str(real_num,'%03d'),'.tif'];
disp(['Renaming file number ' num2str(real_num,'%03d') '...\n']);
movefile(filename,file_name_new);
end