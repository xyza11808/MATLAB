function length_vary_alignment(raw_data,trial_type,time_point,method,frame_rate,description,varargin)
%this funtion is used for align the timepoints of different time onset
%events form the behavior data
%the raw_data which is a three dimensional data which all follows the same dimensional distribution like the old data form
%the time_point is a two columns data form with the first column is
%stim_onset time, the second column is reward time
%methods refers to different alignment methods
%temporarily designed variance trial_type includes three columns with the
%first one indicates the trial type and the second one gives about the
%action choice, the third gives the corresponded stim frequency
%Feb. 27, 2015
if nargin<6
    error('Not enough input variables, quit analysis.\n');
end
data_size=size(raw_data);
time_point_size=size(time_point);
diff_time=zeros(time_point_size);
description=strrep(description,'_','\_');

if time_point_size(2)==2
    cell_description=cell(2,1);
    cell_description(1)={'stim_onset'};
    cell_description(2)={'reward_onset'};
else
    disp('Please input the customized time point description\n');
    cell_description=cell(time_point_size(2),1);
    for m=1:time_point_size
        tem_des=input(['Please input the description for timepoint ',num2str(m),'\n'],'s');
        cell_description(m)={tem_des};
    end
end

%well, only the correct trials should be considered here,otherwise the
%reward time should be less than stim_onset time
%####################################################################################

%####################################################################################
% diff_time(:,2:end)=diff(time_point,1,2);
% diff_time(:,1)=time_point(:,1);

if method==1
    method_description='Compassed alignment';
    alignment_point=min(time_point);
elseif method==2
    method_description='Expand alignment';
    alignment_point=max(time_point);
else
    error('Error alignment method choice, quit analysis.\n');
end
% temp_time_trace=zeros(1,data_size(3));
alignment_data=zeros(data_size);
% temp_time_trace=zeros(1,data_size(3));
for n=1:data_size(2)
    for m=1:data_size(1)
        temp_time_trace=squeeze(raw_data(m,n,:));
%         post_data=sequence_align(temp_time_trace,time_point(m),alignment_point,method);
        post_data=sequence_align(temp_time_trace,time_point(m,:),alignment_point);
        alignment_data(m,n,:)=post_data;
    end
end
if isempty(trial_type)
    % temp_data=zeros(data_size(1),data_size(3));
    clims=[];
    xtick=frame_rate:frame_rate:size_raw_trials(3);
    xTick_lable=1:floor(size_raw_trials(3)/frame_rate);
    for n=1:data_size(2)
        temp_data=squeeze(raw_data(:,n,:));
        clims(1)=min(temp_data(:));
        clims(2)=max(temp_data(:));
        h=figure;
        imagesc(temp_data,clims);
        colorbar;
        title([description ' ROI' num2str(n)]);
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        hold on;
        hh1=axis;
        triger_position=alignment_point*frame_rate;
        for m=1:length(triger_position)
            plot([triger_position(m),triger_position(m)],[hh1(3),hh1(4)],'color','y','LineWidth',2);
            text(triger_position(m),1.03*hh1(4),cell_description{m});
        end
        hold off;
        saveas(h,[description '_aligned_plot_ROI' num2str(n)],'png');
    end
else
    clims=[];
%     xtick=frame_rate:frame_rate:size_raw_trials(3);
%     xTick_lable=1:floor(size_raw_trials(3)/frame_rate);
    for n=1:data_size(2)
        temp_data=squeeze(raw_data(:,n,:));
        clims(1)=min(temp_data(:));
        clims(2)=max(temp_data(:));
        miss_inds=trial_type(:,2)==2;
        corr_left_trial_inds = trial_type(:,1)==0 & trial_type(:,2)==0;
        erro_left_trial_inds = trial_type(:,1)==0 & trial_type(:,2)==1;
        corr_right_trial_inds = trial_type(:,1)==1 & trial_type(:,2)==1;
        erro_right_trial_inds = trial_type(:,1)==1 & trial_type(:,2)==0;
        h=figure;
%         temp_sub_data=temp_data(miss_inds,:);
        temp_stim_freq=trial_type(:,3);
%         temp_stim_freq_sub=temp_stim_freq(miss_inds);
%         [~,I]=sort(temp_stim_freq_sub);
        subplot(3,2,5);
        plot_for_random_2afc(temp_data,temp_stim_freq,miss_inds,frame_rate,cell_description,'miss\_trial',clims);
        
        subplot(3,2,1);
        plot_for_random_2afc(temp_data,temp_stim_freq,corr_left_trial_inds,frame_rate,cell_description,'corr\_L\_trial',clims);
        
        subplot(3,2,3);
        plot_for_random_2afc(temp_data,temp_stim_freq,erro_left_trial_inds,frame_rate,cell_description,'erro\_L\_trial',clims);
        subplot(3,2,2);
        plot_for_random_2afc(temp_data,temp_stim_freq,corr_right_trial_inds,frame_rate,cell_description,'corr\_R\_trial',clims);
        subplot(3,2,4);
        plot_for_random_2afc(temp_data,temp_stim_freq,erro_right_trial_inds,frame_rate,cell_description,'erro\_R\_trial',clims);
        
      suptitle(['Sum plot for ROI' num2str(n)]);
      saveas(h,[description '_sum_plot_ROI' num2str(n)]);
      close;
    end
end