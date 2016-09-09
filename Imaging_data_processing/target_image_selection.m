%finding the target image for alignment
cd('M:\batch\batch32\20160814\anm04\test02');
[im, ~] = load_scim_data('b32a04_test02_3x_rf_3x_190um_20160814_100.tif');
colormap gray;
selectframe=im(:,:,350:500);
imagesc(mean(selectframe,3),[0 500]);
im_reg_target = mean(selectframe,3);
figure(gcf);

%%
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target
dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
t_total=tic;
dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
t=toc(t_total);
disp(t);
% save TargetImage.mat im_reg_target
%
% % % 
% dir_imreg_src = 'M:\batch\batch32\20160814\anm02\test02';
% dir_imreg_dest = ['M:\batch\batch32\20160814\anm02\test02' filesep 'im_data_reg_cpu'];
% dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % % % 
% dir_imreg_src = 'M:\batch\batch32\20160814\anm02\test12rf';
% dir_imreg_dest = [dir_imreg_src filesep filesep 'im_data_reg'];
% dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test04';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test05';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
