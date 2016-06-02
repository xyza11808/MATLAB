function Sound_response_check(data_mode,triger_time,frame_rate,varargin)
%data_mode is a percentage change of raw data where the baseline
%fluorescence is calculate by mode function
%by XY, Apr, 4, 2015
%updated June, 18, 2015 using the avarage trace as an critiria, this will
%works for those really sharp tuning rois

ROI_response_data=struct('ROI_nmb',[],'p_value',[],'responsity',[],'ci',[],'total_roi',[],'responsive_total_num',[],...
    'trial_activity',[],'active_roi',[]);
data_size=size(data_mode);
ROI_response_data.total_roi=data_size(2);
significant_level=3*std(reshape(data_mode,[],1));   %std(data_mode(:))
time_scale=input('please input the lower and upper value of the mean calculate time scale.\n');
if isempty(time_scale)
    time_scale=[1,2.5];
end
frame_scale=floor(time_scale*frame_rate);
if frame_scale(1)==0
    frame_scale(1)=1;
    warning('There might be no baseline value for t-test, since only one baseline value are used.\n');
end
triger_frame=triger_time*frame_rate;

smooth_data=zeros(data_size);
for n=1:data_size(1)
    for m=1:data_size(2)
        smooth_data(n,m,:)=smooth(data_mode(n,m,:));
    end
end

sig_response_num=0;
for n=1:data_size(2)
    ROI_response_data.ROI_nmb(n)=n;
    single_roi_data=squeeze(smooth_data(:,n,:));
    mean_trace=zscore(mean(single_roi_data));
%     plot(mean_trace);
%     pause(1);
%     close;
    for m=1:data_size(1)
        roi_sig_inds(m,n)=max(single_roi_data(m,frame_scale))>significant_level; %the value of active trial is 1,and zero for inactive trials
    end
    sig_trial_roi=squeeze(smooth_data(roi_sig_inds(:,n),n,:));
    if size(sig_trial_roi,2)==1
        sig_trial_roi=sig_trial_roi';
    end
    base_line_value=mean(sig_trial_roi(:,1:triger_frame),2);
    response_value=mean(sig_trial_roi(:,frame_scale(1):frame_scale(2)),2);
    if length(base_line_value)<10
        max_response=max(mean_trace(frame_scale(1):frame_scale(2)));
         warning(['Not enough active trial for statistic analysis, skip paired t test for ROI',num2str(n)]);
        if max_response > 3  %this place still need to be decided
            ROI_response_data.p_value(n)=-2;
            ROI_response_data.responsity(n)=1;
            ROI_response_data.ci(n,:)=[0 0];
            sig_response_num=sig_response_num+1;
            ROI_response_data.active_roi=[ROI_response_data.active_roi n];
            continue;
        else
           
            ROI_response_data.p_value(n)=-1;
            ROI_response_data.responsity(n)=0;
             ROI_response_data.ci(n,:)=[0 0];
            continue;
        end
    else
        [h,p,ci,~]=ttest(base_line_value,response_value);
         ROI_response_data.p_value(n)= p;
        ROI_response_data.responsity(n)=h;
        ROI_response_data.ci(n,:)=ci;
        if p<0.05
            sig_response_num=sig_response_num+1;
            ROI_response_data.active_roi=[ROI_response_data.active_roi n];
        end
    end
end
ROI_response_data.responsive_roi=sig_response_num;
ROI_response_data.trial_activity=roi_sig_inds;  %the rows for each trial and columns for each ROI

if ~isdir('./ROI_resp_sum/')
    mkdir('./ROI_resp_sum/');
end
cd('./ROI_resp_sum/');

save ROI_response_sum.mat ROI_response_data -v7.3
disp('ROI response analysis complete.\n');
cd ..;
