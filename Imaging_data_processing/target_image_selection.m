%finding the target image for alignment
cd('K:\batch39\anm04\20170412\test01');
[im, ~] = load_scim_data('b39a04_test01_3x_2afc_20170412_230um_189.tif');
colormap gray;
selectframe=im(:,:,1:60);
imagesc(mean(selectframe,3),[0 600]);
im_reg_target = mean(selectframe,3);
figure(gcf);

%%
dir_imreg_src = pwd;
save TargetImage.mat im_reg_target
dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
t_total=tic;
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
t=toc(t_total);
disp(t);
if sum(BadAlignFrame) > 0
    save BadAlignF.mat BadAlignFrame -v7.3
end
% save TargetImage.mat im_reg_target
%
% % 
dir_imreg_src = 'K:\batch39\anm04\20170412\test01rf';
cd(dir_imreg_src);
dir_imreg_dest = [dir_imreg_src filesep 'im_data_reg_cpu'];
BadAlignFrame = dft_reg_dir_2_zy(dir_imreg_src, dir_imreg_dest, [], im_reg_target);
if sum(BadAlignFrame) > 0
    save BadAlignF.mat BadAlignFrame -v7.3
end
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