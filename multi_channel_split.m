function multi_channel_split(varargin)
%this function is used for three Dimensional calcium imaging data
%pre-processing, the result data will be used for further analysis
if nargin < 1
    [~,filepath,fi]=uigetfile({'*.tif; *.tiff'},'Select Two Photon Imaging Files with multichannels');
    if fi==0
        warning('Error file selected, quitting...');
        return;
    else
         cd(filepath);
    %     [~,im_header]=load_scim_data(file);
    %     channel_num=length(im_header.SI4.channelsSave);
    %     imTagStruct = get_tiff_tag_to_struct(file);

        files=dir('*.tif');
    %     save_path=fullfile(filepath,'Mean_tif')
        %     filename=fulfile(filepath,file);
        %     file_name=[file(1:end-4) '_mean_pj.tif'];
        %     save_path=fullfile(filepath,'Mean_tif',file_name);
    end
else
    filepath = varargin{1};
    cd(filepath);
    files=dir('*.tif');
end
    
poolobj=gcp('nocreate');
if isempty(poolobj)
    parpool('local',12);
end
fprintf('Total file number is %d.\n', length(files));
parfor m=1:length(files)
    filename=files(m).name;
    file_name=filename(1:end-4);
%     save_path=fullfile(filepath,'Mean_tif',file_name);
    disp(['loading file ' filename '...']);
    [im_data,im_header]=load_scim_data(filename);
    channel_num=length(im_header.SI4.channelsSave);
    imTagStruct = get_tiff_tag_to_struct(filename);
%     if m==1
%         channel_num=length(im_header.SI4.channelsSave);
        if channel_num==1
            disp('The selected data file is not multi-channel data, go to next...\n');
            continue;
        else
            for num=1:channel_num
                if ~isdir(['./channel' num2str(num)])
                     mkdir(['./channel' num2str(num)]);
                end
            end
        end
%     end
%     imTagStruct = get_tiff_tag_to_struct(filename);
    data_size=size(im_data);
    
    for n=1:channel_num
        channel_inds=n:channel_num:data_size(3);
        channel_data=int16(im_data(:,:,channel_inds));
%         channel_data=permute(channel_data,[2,3,1]);
        im_channel_tag=imTagStruct(channel_inds);
        save_path=fullfile(filepath,['channel' num2str(n)],[file_name(1:end-3) 'c' num2str(n) file_name(end-3:end) '.tif']);
        disp(['channel' num2str(n) ' data saved to ' save_path '...']);
        write_data_to_tiff(save_path, channel_data, im_channel_tag);
    end
end
        
disp('All file have been splitted, function complete!\n');
    