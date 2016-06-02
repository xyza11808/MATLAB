%finding the target image for alignment
cd('H:\data\batch\batch27_PV\20160427\anm01\test01');
[im, ~] = load_scim_data('b27a03_test01_3x_2afc_245um_20160427_087.tif');
colormap gray;
selectframe=im(:,:,1:80);
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
dir_imreg_src = 'H:\data\batch\batch27_PV\20160427\anm01\test01rf\channel1';
dir_imreg_dest = ['H:\data\batch\batch27_PV\20160427\anm01\test01rf\channel1' filesep 'im_data_reg_cpu'];
dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test03';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test04';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
% % 
% dir_imreg_src = 'H:\data\batch\batch22_yang\20160123\anm03\test05';
% dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg'];
% dft_reg_dir_2(dir_imreg_src, dir_imreg_dest, [], im_reg_target)
