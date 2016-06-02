function licknum_response_corr(base_data,lick_number,reward_time,frame_rate,ava_scale,varargin)
%this fucntion is used for analysis correlations between lick number and
%avarage firing response
%only correct trials are considered here as raw data
%ava_scale should be a time range that will be used for avarage range
%raw_data is the data have already aligned to specific time events
%XIN Yu

if nargin<5
    ava_scale=input('Please input the time range that will be used for avarage analysis.\n');
    if ~isempty(ava_scale)
        frame_scale=str2num(ava_scale);
        frame_scale=floor(frame_scale*frame_rate);
        if frame_scale(1)==0
            frame_scale(1)=1;
        end
    else
        error('wrong input range used for analysis, quit analysis...\n');
    end
elseif nargin>=5
    frame_scale=floor(ava_scale*frame_rate);
    data_describtion=varargin{1};
end

data_size=size(base_data);
reward_frame=floor(((double(reward_time)/1000)*frame_rate));
% if frame_scale(2)>data_size(3)
%     frame_scale(2)=data_size(3);
% else
if diff(frame_scale)<0
    error('Error selected time scale for further analysis, this num must be monotonically increased.\n');
end
if ~isdir('.\licknum_resp_corr\')
    mkdir('.\licknum_resp_corr\');
end
cd('.\licknum_resp_corr\');

critiria_level=std(reshape(base_data,[],1));
% smooth_data=zeros(data_size);
% sig_inds=zeros(data_size(1),1);
% max_resp_list=zeros(data_size(1),1);
for m=1:data_size(2)
    sig_inds=zeros(data_size(1),1);
    max_resp_list=zeros(data_size(1),1);
    max_list_area=zeros(data_size(1),1);
    for n=1:data_size(1)
        smooth_data=smooth(base_data(n,m,:));
        if (frame_scale(2)+reward_frame(n))>data_size(3)
            continue;
        end
        start_frame=frame_scale(1)+reward_frame(n);
        end_frame=frame_scale(2)+reward_frame(n);
        segmnent_data=smooth_data(start_frame:end_frame);
        [max_resp,max_inds]=max(segmnent_data);
        max_inds=max_inds+start_frame;
        if max_resp>=(3*critiria_level)
            sig_inds(n)=1;
            max_resp_list(n)=max_resp;
            half1_peak_inds=find(smooth_data(start_frame:max_inds)<(max_resp/2),1,'last')+start_frame;
            half2_peak_inds=find(smooth_data(max_inds:end_frame)<(max_resp/2),1,'first')+start_frame;
            if isempty(half1_peak_inds)
                half1_peak_inds=start_frame;
            end
            if isempty(half2_peak_inds)
                half2_peak_inds=end_frame;
            end
            start_peak_inds=max_inds-2*(max_inds-half1_peak_inds);
            end_peak_inds=max_inds+2*(half2_peak_inds-max_inds);
            if start_peak_inds<start_frame
                start_peak_inds=start_frame;
            end
            if end_peak_inds>end_frame
                end_peak_inds=end_frame;
            end
            max_list_area(n)=sum(smooth_data(start_peak_inds:end_peak_inds));
        else
            continue;
        end
    end
    if sum(sig_inds>0)<10
        warning(['Too few significant trials for ROI' num2str(m) ', quit ROI correlation analysis.\n']);
        continue;
    end
    lilck_num_list=lick_number(logical(sig_inds));
    max_resp_list=max_resp_list(logical(sig_inds));
    max_list_area=max_list_area(logical(sig_inds));
    
    h_point=figure;
    scatter(lilck_num_list,max_resp_list,'MarkerEdgeColor','g','MarkerFaceColor','c','LineWidth',1.5);
    plot_axis=axis(gca);
    title(['licknum and peak value corr for ROI' num2str(m)]);
    xlabel('Number of lick');
    ylabel('Maxium fluo change');
    hold on;
    [lin_fit,goodness,~]=fit(lilck_num_list,max_resp_list,'poly1');
    %this place can be replaced as
    %model=fitlm(lilck_num_list,max_resp_list) in order for a statistic
    %analysis.
    %p_value=model.Coefficients.pValue
    %R_squared=model.Rsquared  (use the original value)
    %variable_value=model.Coefficients.Estimate
    %but it seems that there are no easy way to calculate fitted result for
    %given data scale, but have to use the original calculation way.
%     var_value=[lin_fit.p1,lin_fit.p2];
    x_scale=linspace(min(lilck_num_list),max(lilck_num_list),50);
    plot(x_scale,lin_fit(x_scale),'r','LineWidth',2);
    hold off;
    legend('data','fit','location','NorthEastOutside');
    text(1.03*plot_axis(1),0.95*plot_axis(4),['R=' sprintf('%7.5f',goodness.rsquare)]);
    saveas(h_point,[data_describtion '_licknum_PeakValue_corr_ROI' num2str(m) '.png']);
    close;
    fit_result=struct('Coefficient',lin_fit,'Goodness',goodness);
    save(['peak_value_fit_result_save_ROI' num2str(m) '.mat'],'fit_result','-v7.3');
    
    h_area=figure;
    scatter(lilck_num_list,max_list_area,'MarkerEdgeColor','r','MarkerFaceColor','g','LineWidth',1.5);
    plot_axis=axis(gca);
    title(['licknum and peak area corr for ROI' num2str(m)]);
    xlabel('Number of lick');
    ylabel('Fluo change area');
    hold on;
    [lin_fit,goodness,~]=fit(lilck_num_list,max_list_area,'poly1');
    x_scale=linspace(min(lilck_num_list),max(lilck_num_list),50);
    plot(x_scale,lin_fit(x_scale),'r','LineWidth',2);
    hold off;
    legend('data','fit','location','NorthEastOutside');
    text(1.03*plot_axis(1),0.95*plot_axis(4),['R=' sprintf('%7.5f',goodness.rsquare)]);
    saveas(h_area,[data_describtion '_licknum_PeakArea_corr_ROI' num2str(m) '.png']);
    close;
    fit_result=struct('Coefficient',lin_fit,'Goodness',goodness);
    save(['peak_area_fit_result_save_ROI' num2str(m) '.mat'],'fit_result','-v7.3');
end
cd ..;