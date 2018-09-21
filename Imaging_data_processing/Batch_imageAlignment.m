%finding the target image for alignment
cd('W:\#members\xy\batch\batch55\20180918\anm07\test06');
[im, ~] = load_scim_data('b55a07_test06_2x_2afc_160um_20180918_115.tif');

selectframe=im(:,:,1:30);
figure;
imagesc(mean(selectframe,3),[-10 200]);
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

cd('S:\BatchData\batch53');
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
    %%
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
    %%
    tline = fgetl(fid);
end
%
% % 
% dir_imreg_src = 'F:\batch\batch49\20171205\anm05\test02';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% isFileBadAlign = cellfun(@isempty,BadAlignFrame);
% if sum(~isFileBadAlign)
%     save BadAlignF.mat BadAlignFrame -v7.3
% end
%
% dir_imreg_src = 'P:\BatchData\20180417\anm05\test01longdur';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% isFileBadAlign = cellfun(@isempty,BadAlignFrame);
% cd(dir_imreg_dest);
% if sum(~isFileBadAlign)
%     save BadAlignF.mat BadAlignFrame -v7.3
% end
%
% cd('K:\batch38\20161212\anm04\test02');
% [im, ~] = load_scim_data('b38a04_test02_3x_2afc_120um_20161212_170.tif');
% colormap gray;
% selectframe=im(:,:,1:70);
% imagesc(mean(selectframe,3),[0 500]);
% im_reg_target = mean(selectframe,3);
% % figure(gcf);
% %
% dir_imreg_src = pwd;
%% save TargetImage.mat im_reg_target
% dir_imreg_dest = 'N:\testCamKII\test04_1_5h_after';
% dir_imreg_src = 'N:\testCamKII\test04_1_5h_after';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% isFileBadAlign = cellfun(@isempty,BadAlignFrame);
% cd(dir_imreg_dest);
% % if sum(~isFileBadAlign)
% %     save BadAlignF.mat BadAlignFrame -v7.3
% % end
% 
% % % % 
% dir_imreg_src = 'N:\testCamKII\test05_2h_after';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% % if sum(BadAlignFrame) > 0
% %     save BadAlignF.mat BadAlignFrame -v7.3
% end