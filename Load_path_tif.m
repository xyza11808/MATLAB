function cfData = Load_path_tif(fPath)
% hObject    handle to Load_path_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% fPath = uigetdir(pwd,'Please select your data folder');
if isempty(dir(fullfile(fPath,'*.tif')))
    yy = warndlg('Current folder have no tif files.','Error folder selection');
    delete(yy);
    return;
else
    Allfiles = dir(fullfile(fPath,'*.tif'));
    nfNumbers = length(Allfiles);
end
fprintf('Loading all %d frames...\n',nfNumbers);
% loading tif files
warning off
ttf = Tiff(fullfile(fPath,Allfiles(1).name),'r');
ImHeight = getTag(ttf,'ImageLength');
ImWidth = getTag(ttf,'ImageWidth');

cfData = zeros(ImHeight,ImWidth,nfNumbers);
for cfs = 1 : nfNumbers
    cfName = Allfiles(cfs).name;
    ctf = Tiff(fullfile(fPath,cfName));
    cfData(:,:,cfs) = double(read(ctf));
end
warning on
% ImdataStrcs.fImDataAll = cfData;
fprintf('Read %d frames complete!\n',nfNumbers);
