function image_data_dir_proc(imdir)

cd(imdir)
mkdir raw_image_data
mkdir reg_image_data
datafiles = dir('*.tif');
% filesizes = [datafiles.bytes];
for i = 1:length(datafiles)
    if datafiles(i).bytes > 1e7
        movefile(datafiles(i).name, 'raw_image_data');
    end
end

%% Perform whole-frame registration for motion correction
dft_reg_dir_2('raw_image_data', 'reg_image_data');
%
fprintf('----------------- Finished dft-reg for %s ------------------\n', imdir);
%% Batch generate max delta images
% cd([imdir '/reg_image_data']);
reg_data_files = dir('*.tif');
mkdir max_delta_images 
mkdir mean_images
parfor i = 1:length(reg_data_files)
    [imdata, header] = load_scim_data(reg_data_files(i).name);
%     im_maxdelta = im_max_delta(imdata,0);
%     max_delta_save_name= ['max_delta_images/' reg_data_files(i).name(1:end-4) '_maxDelta.tif'];
%     imwrite(uint8(im_maxdelta), max_delta_save_name, 'Compression','none');
    im_mean = mean(imdata,3);
    meanImage_save_name= ['mean_images/' reg_data_files(i).name(1:end-4) '_mean.tif'];
    imwrite(uint8(im_mean), meanImage_save_name, 'Compression','none');
    
%     write_data_to_tiff(max_delta_save_name, im_maxdelta);
end

