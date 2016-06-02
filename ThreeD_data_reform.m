function ThreeD_data_reform
%this function is used for three Dimensional calcium imaging data
%pre-processing, the result data will be used for further analysis

[file,filepath]=uigetfile({'*.tif; *.tiff'},'Select Two Photon Imaging File');
if file==0
    error('Error file selected, quitting...');
else
    cd(filepath);
    files=dir('*.tif');
%     save_path=fullfile(filepath,'Mean_tif')
    %     filename=fulfile(filepath,file);
    %     file_name=[file(1:end-4) '_mean_pj.tif'];
    %     save_path=fullfile(filepath,'Mean_tif',file_name);
end

if ~isdir('./Mean_tif/')
    mkdir('./Mean_tif/');
end

for m=1:length(files);
    filename=files(m).name;
    file_name=[filename(1:end-4) '_mean_pj.tif'];
    save_path=fullfile(filepath,'Mean_tif',file_name);
    disp(['loading file ' filename '...']);
    [im_data,im_header]=load_scim_data(filename);
    imTagStruct = get_tiff_tag_to_struct(filename);
    data_size=size(im_data);
    
    if im_header.SI4.fastZEnable == 0
        warning('Fast Z disabled, no need to do three dimensional data reshape.');
        retuen;
    else
        volume_num= im_header.SI4.fastZNumVolumes;
        singlevolume_slices=im_header.SI4.stackNumSlices;
        slice_step=im_header.SI4.stackZStepSize;
        frame_rate = im_header.SI4.scanFrameRate;
        laser_start_power=im_header.SI4.stackStartPower;
        laser_end_power=im_header.SI4.stackEndPower;
    end
    
    if isnan(laser_start_power) || isnan(laser_end_power)
        warning('Power level keep constant for all slices');
        slice_power=[];
    else
        power_step_change=double(laser_end_power-laser_start_power)/double(singlevolume_slices-1);
        slice_power=laser_start_power:power_step_change:laser_end_power;
        ratio_step_power=slice_power/slice_power(1);
    end
    
    if singlevolume_slices*slice_step>20
        warning('Volume thickness over 20um, maybe not suit for Avg of the three dimensional image.');
    end
    
    double_im_data=double(im_data);
    four_dimensinal_data=zeros(data_size(1),data_size(2),volume_num,singlevolume_slices);
    reformed_data=zeros(data_size(1),data_size(2),volume_num);
    
    for n=1:volume_num
        four_dimensinal_data(:,:,n,:)=double_im_data(:,:,((n-1)*singlevolume_slices+1):(n*singlevolume_slices));
        reformed_data(:,:,n)=sum(squeeze(four_dimensinal_data(:,:,n,:)),3)/singlevolume_slices;
    end
%     im_compressed_tag
        im_compressed_tag=imTagStruct(1:singlevolume_slices:data_size(3));
    % write_data=int32(reformed_data);
    reformed_data=int16(reformed_data);
    write_data_to_tiff(save_path, reformed_data, im_compressed_tag);
    disp(['Avg data saved to ' save_path '...']);
end