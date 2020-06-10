%finding the target image for alignment
SourcePath = 'Z:\Lab_Members\Xin_Y\behavior_rig06_backup\behaviro_data\Batch_70\batch70';
TargetPath = '20200529\anm06\test02_rf';
cd([SourcePath,filesep,TargetPath]);

[im, ~] = load_scim_data('b70a06_test01_rf_2x_110um_20200529_045.tif');

selectframe=im(:,:,1:28);
figure;
imagesc(mean(selectframe,3),[-20 1000]);
im_reg_target = mean(selectframe,3);
figure(gcf);
colormap gray;
%%
TargUpperPath = 'E:\xnn_data\Batch_70\batch70';
clc
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target
dir_imreg_dest = [TargUpperPath filesep TargetPath filesep 'im_data_reg_cpu'];
% % dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
t_total=tic;
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
t=toc(t_total);
disp(t);
isFileBadAlign = cellfun(@isempty,BadAlignFrame);
cd(dir_imreg_dest);
if sum(~isFileBadAlign)
    save BadAlignF.mat BadAlignFrame -v7.3
end
% save TargetImage.mat im_reg_target
%
% % 
% % % load('P:\BatchData\batch52\20180423\anm05\test01\TargetImage.mat','im_reg_target');
TargetPath = '20200529\anm06\test01_spon';
dir_imreg_src = [SourcePath filesep TargetPath];
cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
dir_imreg_dest = [TargUpperPath filesep TargetPath filesep 'im_data_reg_cpu'];
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
isFileBadAlign = cellfun(@isempty,BadAlignFrame);
if sum(~isFileBadAlign)
    save BadAlignF.mat BadAlignFrame -v7.3
end

% % % dir_imreg_src = 'E:\xnn_data\Batch_70\anm05\test03_spontAF';
TargetPath = '20200529\anm06\test03_AFalterspon';
dir_imreg_src = [SourcePath filesep TargetPath];
cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
dir_imreg_dest = [TargUpperPath filesep TargetPath filesep 'im_data_reg_cpu'];
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
isFileBadAlign = cellfun(@isempty,BadAlignFrame);
if sum(~isFileBadAlign)
    save BadAlignF.mat BadAlignFrame -v7.3
end

% % % dir_imreg_src = 'E:\xnn_data\Batch_70\anm05\test04_spont10minsAF';
% TargetPath = '20200528\anm03\test03sp_afterAlter_4k32k';
% dir_imreg_src = [SourcePath filesep TargetPath];
% cd(dir_imreg_src);
% % dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% dir_imreg_dest = [TargUpperPath filesep TargetPath filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% isFileBadAlign = cellfun(@isempty,BadAlignFrame);
% if sum(~isFileBadAlign)
%     save BadAlignF.mat BadAlignFrame -v7.3
% end

% %
% 
% % load('P:\BatchData\batch52\20180423\anm05\test02\TargetImage.mat','im_reg_target');
% dir_imreg_src = 'S:\BatchData\Batch52\20180508\anm05\test01rf';
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