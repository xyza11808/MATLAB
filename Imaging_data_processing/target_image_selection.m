%finding the target image for alignment
cd('N:\batch\batch49\anm04_20171117\test01');
[im, ~] = load_scim_data('b49a04_test01_2x_rf_240um_20171117_048.tif');

selectframe=im(:,:,1:30);
figure;
imagesc(mean(selectframe,3),[-20 200]);
im_reg_target = mean(selectframe,3);
figure(gcf);
colormap gray;
%%
clc
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target
% dir_imreg_dest = [['F',dir_imreg_src(2:end)] filesep 'im_data_reg_cpu'];
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
% save TargetImage.mat im_reg_target
%
% % 
% load('P:\BatchData\batch52\20180423\anm05\test01\TargetImage.mat','im_reg_target');
% dir_imreg_src = 'S:\BatchData\Batch52\20180508\anm05\test01';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
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