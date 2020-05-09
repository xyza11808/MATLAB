%finding the target image for alignment
cd('S:\BatchData\batch58\20181024\anm05\test02');
[im, ~] = load_scim_data('b58a05_test02_2x_rf_190um_20181024_045.tif');

selectframe=im(:,:,1:30);
figure('position',[100 100 480 420]);
imagesc(mean(selectframe,3),[0 100]);
im_reg_target = mean(selectframe,3);
figure(gcf);
colormap gray;
%%
clc
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target dir_imreg_src -v7.3
%%
dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
isFileBadAlign = cellfun(@isempty,BadAlignFrame);
cd(dir_imreg_dest);
if sum(~isFileBadAlign)
    save BadAlignF.mat BadAlignFrame -v7.3
end

%% delete extra raw tif files
cellfun(@(x) delete(fullfile(x,'*.tif')),RawTifDataPath);

%% dir_imreg_dest = [['F',dir_imreg_src(2:end)] filesep 'im_data_reg_cpu'];
clear
%%
clc

if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'W:\#members\xy\batch\batch60\20190622';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end

IsTargetIMExist = cellfun(@(x) exist(fullfile(x,'TargetImage.mat'),'file'),nameSplit);
UsedDataPath = nameSplit(IsTargetIMExist > 0);
ExPathIndex = contains(UsedDataPath,'20190607'); %cellfun(@isempty,strfind(UsedDataPath,'20190607'));
UsedDataPath = UsedDataPath(~ExPathIndex);
DirLength = length(UsedDataPath);
%%
% pause(3000);
TargetUpPath = 'F:\batch';
for cs = 1 : DirLength
    tline = UsedDataPath{cs};
    %
    cd(tline);
    clearvars im_reg_target dir_imreg_src
    %
    load(fullfile(tline,'TargetImage.mat'));
    [StInds,EdInds] = regexp(tline,'batch60');
    TagPath = [TargetUpPath,tline(StInds:end)];
%     NewStr = strrep(dir_imreg_src,'0520','0420');
%     dir_imreg_src = NewStr;-
%     save TargetImage.mat im_reg_target dir_imreg_src -v7.3
%     tline = fgetl(fid);
    % clc
    % dir_imreg_src = pwd;
    % save TargetImage.mat im_reg_target
    dir_imreg_dest = [TagPath filesep 'im_data_reg_cpu'];
    dir_imreg_src = tline;
    t_total=tic;
    BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
    t=toc(t_total);
    disp(t);
    isFileBadAlign = cellfun(@isempty,BadAlignFrame);
    cd(dir_imreg_dest);
    if sum(~isFileBadAlign)
        save BadAlignF.mat BadAlignFrame -v7.3
    end
    
    %align possible passive session data
    PosPassDir = [tline,'rf'];
    PosPassTagDir = [TargetUpPath,tline(StInds:end),'rf'];
    if isdir(PosPassDir)
        NewAlignDir = PosPassDir;
        cd(NewAlignDir);
        dir_imreg_dest = [PosPassTagDir filesep 'im_data_reg_cpu'];
        BadAlignFrame = dft_reg_dir_2_zy(NewAlignDir, dir_imreg_dest, [], im_reg_target);
        isFileBadAlign = cellfun(@isempty,BadAlignFrame);
        cd(dir_imreg_dest);
        if sum(~isFileBadAlign)
            save BadAlignF.mat BadAlignFrame -v7.3
        end
    end

end
%
%% 
clear
clc

cd('D:\data\xinyu\batch55');
[fn,fp,fi] = uigetfile('*.txt','Please select your data path to be aligned');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
%%
% pause(1800)
while ischar(tline)
    if ~isdir(tline)
        tline = fgetl(fid);
        continue;
    end
    %
    cd(tline);
    clearvars im_reg_target dir_imreg_src
    %
    load(fullfile(tline,'TargetImage.mat'));
    
%     NewStr = strrep(dir_imreg_src,'0520','0420');
%     dir_imreg_src = NewStr;
%     save TargetImage.mat im_reg_target dir_imreg_src -v7.3
%     tline = fgetl(fid);
    % clc
    % dir_imreg_src = pwd;
    % save TargetImage.mat im_reg_target
    dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
    t_total=tic;
    BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
    t=toc(t_total);
    disp(t);
    isFileBadAlign = cellfun(@isempty,BadAlignFrame);
    cd(dir_imreg_dest);
    if sum(~isFileBadAlign)
        save BadAlignF.mat BadAlignFrame -v7.3
    end
    
    %align possible passive session data
    PosPassDir = [tline,'rf'];
    if isdir(PosPassDir)
        NewAlignDir = PosPassDir;
        cd(NewAlignDir);
        dir_imreg_dest = [NewAlignDir filesep 'im_data_reg_cpu'];
        BadAlignFrame = dft_reg_dir_2_zy(NewAlignDir, dir_imreg_dest, [], im_reg_target);
        isFileBadAlign = cellfun(@isempty,BadAlignFrame);
        cd(dir_imreg_dest);
        if sum(~isFileBadAlign)
            save BadAlignF.mat BadAlignFrame -v7.3
        end
    end
    %
    tline = fgetl(fid);
end
%%
% clear
% clc
% 
if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'K:\batch38';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);

PossibleInds = cellfun(@(x) length(dir(fullfile(x,'*.tif'))) > 20,nameSplit);
PossDataPath = nameSplit(PossibleInds);
AllAlignedPInds = cellfun(@(x) strcmpi(x(end-14:end),'im_data_reg_cpu'),PossDataPath);
PosRawTifWithAlignPath = cellfun(@(x) x(1:end-15),PossDataPath(AllAlignedPInds),'UniformOutput',false);
% RawTifDataPath = PossDataPath(~AllAlignedPInds);

%%
cellfun(@(x) delete(fullfile(x,'*.tif')),PosRawTifWithAlignPath);

%% Selsect File alignment codes
% ##############################################################################################################
% ##############################################################################################################
% ##############################################################################################################
%finding the target image for alignment
% cd('E:\tempdata\data_test_xsn\20190514'); 
cd('K:\testsave\xnntest\test_02\anm03_20190526');
[im, ~] = load_scim_data('anm03_field03_2x_250um_sess05_001.tif');
%%
selectframe=im(:,:,300:700);
figure('position',[100 100 480 420]);
imagesc(mean(selectframe,3),[100 1000]);
im_reg_target = mean(selectframe,3);
figure(gcf);
colormap gray;
%%
clc
[fn,fp,fi] = uigetfile('*.tif','Please select your alignment file','MultiSelect','on');

if ~iscell(fn)
    dir_imreg_src(1) = {fp(1:end-1)};
    dir_imreg_src(2) = {fn};
else
    dir_imreg_src = cell(length(fn)+1,1);
    dir_imreg_src{1} = fp(1:end-1);
    dir_imreg_src(2:end) = fn;
end

%%
AlignFSaveFold = input('Please input the savage folder name:\n','s');
if isempty(AlignFSaveFold)
    AlignFSaveFold = 'im_data_reg_cpu';
end
dir_imreg_dest = [fp filesep AlignFSaveFold];
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
isFileBadAlign = cellfun(@isempty,BadAlignFrame);
cd(dir_imreg_dest);
if sum(~isFileBadAlign)
    save BadAlignF.mat BadAlignFrame -v7.3
end
save TargetImage.mat im_reg_target dir_imreg_src -v7.3


