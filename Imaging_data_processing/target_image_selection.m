%finding the target image for alignment
cd('F:\batch\batch49\20171118\anm05\test01');
[im, ~] = load_scim_data('b49a05_test01_2x_rf_150um_20171118_050.tif');
colormap gray;
selectframe=im(:,:,1:15);
imagesc(mean(selectframe,3),[0 40]);
im_reg_target = mean(selectframe,3);
figure(gcf);

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
% dir_imreg_src = 'O:\batch40\20170611\anm01\test02';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% isFileBadAlign = cellfun(@isempty,BadAlignFrame);
% if sum(~isFileBadAlign)
%     save BadAlignF.mat BadAlignFrame -v7.3
% end
%
% dir_imreg_src = 'R:\batch\batch46\20171029\anm04\test01rf';
% cd(dir_imreg_src);
% dir_imreg_dest = [['F',dir_imreg_src(2:end)] filesep 'im_data_reg_cpu'];
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
% save TargetImage.mat im_reg_target
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% t_total=tic;
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% t=toc(t_total);
% disp(t);
% if sum(BadAlignFrame) > 0
%     save BadAlignF.mat BadAlignFrame -v7.3
% end
% save TargetImage.mat im_reg_target
%
% % % 
% dir_imreg_src = 'K:\batch38\20161212\anm04\test02rf';
% cd(dir_imreg_src);
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
% BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
% if sum(BadAlignFrame) > 0
%     save BadAlignF.mat BadAlignFrame -v7.3
% end