%finding the target image for alignment
cd('D:\data\xinyu\Data\batch58\20181025\anm01\test04');
[im, ~] = load_scim_data('b58a01_test04_2x_rf_130um_20181025_047.tif');

selectframe=im(:,:,1:30);
figure('position',[100 100 480 420]);
imagesc(mean(selectframe,3),[-10 100]);
im_reg_target = mean(selectframe,3);
figure(gcf);
colormap gray;
%%
clc
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target dir_imreg_src -v7.3
%% dir_imreg_dest = [['F',dir_imreg_src(2:end)] filesep 'im_data_reg_cpu'];
clear
clc

if ismac
    GrandPath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'D:\data\xinyu\Data\batch58';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end

IsTargetIMExist = cellfun(@(x) exist(fullfile(x,'TargetImage.mat'),'file'),nameSplit);
UsedDataPath = nameSplit(IsTargetIMExist > 0);
DirLength = length(UsedDataPath);
%%
for cs = 1 : DirLength
    tline = UsedDataPath{cs};
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
%