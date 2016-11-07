%finding the target image for alignment
cd('K:\batch35\anm04\test01');
[im, ~] = load_scim_data('b35a04_test01_2afc_140um_20161001_100.tif');
colormap gray;
selectframe=im(:,:,70:105);
imagesc(mean(selectframe,3),[0 200]);
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
dir_imreg_src = 'K:\batch35\anm04\test01rf';
dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'K:\batch34\20161001\anm01\test12rf';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test04';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test05';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
