function sweep_response_plot
%this function is specilized for analysis sweep stimulus response of
%neurons

%%
%load ROI analysis result
disp('please select the ROI analysis result file path.\n');
filepath=uigetdir();
cd(filepath);
files=dir('*.mat');
for i=1:length(files);
    load(files(i).name);
    if strncmp(files(i).name,'CaTrials',8)
        export_filename_raw=files(i).name(1:end-4);
    end
    disp(['loading file ',files(i).name,'...\n']);
end

disp('Please select the stimulus file.\n');
[stim_file_name,stim_file_path]=uigetfile('*.*');
soundarray=textread([stim_file_path filesep stim_file_name]);
if ~exist([stim_file_path filesep stim_file_name],'file')
    error('file non-exist, quit analysis.\n');
end

%%
%data preparation
trial_length=length(CaTrials);
single_data_size=size(CaTrials(1).f_raw);
sweep_data=zeros([trial_length single_data_size]);

for m=1:trial_length
    sweep_data(m,:,:)=CaTrials(m).f_raw;
end
frame_rate=floor(1000/CaTrials(1).FrameTime);
% temp_data_half=zeros([trial_length/2 single_data_size]);
% temp_stim_array=zeros(trial_length/2,1);

stim_onset=input('Please input the stim onset time, with default value is 1s.\n');
if isempty(stim_onset)
    stim_onset=1;
end

%%
%stimlus data processing
center_freq_act=log2(soundarray(:,2)./soundarray(:,1));
% center_freq=soundarray.*(2.^center_freq_act);

% subplot(2,2);

if ~isdir('./sweep_plot/')
    mkdir('./sweep_plot/');
end
cd('./sweep_plot/');
clim=[];
for n=1:single_data_size(1)
    temp_clim_data=squeeze(sweep_data(:,n,:));
    clim(1)=min(temp_clim_data(:));
    clim(2)=max(temp_clim_data(:));
    h=figure;
    plot_item=['ROI' num2str(n)];
    temp_data_half=sweep_data(1:(trial_length/2),:,:);
    temp_stim_array=center_freq_act(1:(trial_length/2),:);
    
    index=find(temp_stim_array>0);
    temp_subplot_data=temp_data_half(index,:,:);
    temp_stim_subplot=temp_stim_array(index,:);
    [~,I]=sort(temp_stim_subplot(:,1));
    subplot(2,2,1);
    sub_plot_sweep(squeeze(temp_subplot_data(I,n,:)),temp_stim_array,frame_rate,plot_item,1,'upper\_sweep',stim_onset,clim);
    
    index=find(temp_stim_array<0);
    temp_subplot_data=temp_data_half(index,:,:);
    temp_stim_subplot=temp_stim_array(index,:,:);
    [~,I]=sort(temp_stim_subplot(:,1));
    subplot(2,2,3);
    sub_plot_sweep(squeeze(temp_subplot_data(I,n,:)),temp_stim_array,frame_rate,plot_item,1,'lower\_sweep',stim_onset,clim);
    
    temp_data_half=sweep_data((trial_length/2)+1:trial_length,:,:);
    temp_stim_array=center_freq_act((trial_length/2)+1:trial_length,:);
    index=find(temp_stim_array<0);
    temp_subplot_data=temp_data_half(index,:,:);
    temp_stim_subplot=temp_stim_array(index,:);
    [~,I]=sort(temp_stim_subplot(:,1));
    subplot(2,2,2);
    sub_plot_sweep(squeeze(temp_subplot_data(I,n,:)),temp_stim_array,frame_rate,plot_item,2,'upper\_sweep',stim_onset,clim);
    
    index=find(temp_stim_array>0);
    temp_subplot_data=temp_data_half(index,:,:);
    temp_stim_subplot=temp_stim_array(index,:);
    [~,I]=sort(temp_stim_subplot(:,1));
    subplot(2,2,4);
    sub_plot_sweep(squeeze(temp_subplot_data(I,n,:)),temp_stim_array,frame_rate,plot_item,2,'lower\_sweep',stim_onset,clim);
    
    suptitle(['sweep plot of ROI',num2str(n)]);
    saveas(h,[export_filename_raw 'sweep_plot.png'],'png');
    close;
    
end
cd ..;
