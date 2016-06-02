function maakedir;

mainfile='mouse';
cd('D:\\folder\');
for i=1:12
    if (i<10)
        subfile=num2str(i);
        subfolder=strcat(mainfile,'0',subfile);
        mkdir(subfolder);
    else
         subfile=num2str(i);
         subfolder=strcat(mainfile,subfile);
         mkdir(subfolder);
    end
end
disp('folder creation complete.')

end