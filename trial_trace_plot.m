function trial_trace_plot(data_raw,data_smooth,trial_inds_left,trial_inds_right,ROI_center,varargin)
%this function is used to plot every response ROIs in a single trial
%following time sequence
%ROI_center is a variable which gives each ROIs location in a two
%dimensional figure
%this function will be called by AFC_ROI_analysis
%XIN Yu, May 30th,2015

if nargin>4
    criterion=varargin{1};
elseif narargin==4
    criterion=3;
end

data_size=size(data_smooth);
% ROI_std=zeros(1,data_size(2));
% for n=1:data_size(2)
%     temp_data=squeeze(data_smooth(:,n,:));
%     ROI_std(n)=std(temp_data(:));
% end
ROI_std=zeros(1,data_size(2));
for n=1:data_size(2)
    Single_ROI_data=reshape(data_raw(:,n,:),[],1);
    tracec_fit=smooth(Single_ROI_data,7,'sgolay',5); %using Savitzky¨CGolay filter to do the data smooth
    noise_trace=Single_ROI_data-tracec_fit;
    ROI_std(n)=std(noise_trace);
end
% popu_std=std(data_smooth(:));

trial_resp_max=zeros(data_size(1),data_size(2));
trial_max_inds=zeros(data_size(1),data_size(2));
ROI_num=zeros(data_size(1),data_size(2));
for n=1:data_size(2)
    for m=1:data_size(1)
        [trial_resp_max(m,n),trial_max_inds(m,n)]=max(data_smooth(m,n,:));
        if trial_resp_max(m,n) <= (criterion*ROI_std(n)) && trial_resp_max(m,n) > 50
            trial_resp_max(m,n)=0;
            trial_max_inds(m,n)=0;
            ROI_num(m,n)=0;
        else
            ROI_num(m,n)=n;
        end
    end
end

if ~isdir('./trial_trace_plot/')
    mkdir('./trial_trace_plot/');
end
cd('./trial_trace_plot/');

% data_left=data_smooth(trial_inds(:,1),:,:);
% data_right=data_smooth(trial_inds(:,2),:,:);
trial_resp_max_plot=trial_resp_max(trial_inds_left,:);
trial_max_inds_plot=trial_max_inds(trial_inds_left,:);
ROI_num_plot=ROI_num(trial_inds_left,:);
h_left=figure('color','white');
scatter(ROI_center(:,2),ROI_center(:,1),20, 'r');
hold on;
for n=1:data_size(2)
    text(ROI_center(n,2),ROI_center(n,1),num2str(n),'color' ,'r', 'FontSize',10,'HorizontalAlignment' ,'right','VerticalAlignment','bottom');
end
set(gca,'YDir','reverse');
axis off;
box off;
for n=1:size(trial_resp_max_plot,1)
    resp_ROIs=find(trial_resp_max_plot(n,:));
    if isempty(resp_ROIs)
        disp([ 'No responsive trial in left trial number ' num2str(n) ',go to next trial.\n']);
        continue;
    end
    ROI_number=ROI_num_plot(n,resp_ROIs);
    ROI_sequence=trial_max_inds_plot(n,resp_ROIs);
    [~,I]=sort(ROI_sequence);
    ROI_number=ROI_number(I);
    if length(resp_ROIs)==1
        plot(ROI_center(ROI_number,2),ROI_center(ROI_number,1),'o','MarkerFaceColor','g');
    else
        plot(ROI_center(ROI_number(1),2),ROI_center(ROI_number(1),1),'o', 'MarkerSize',10,'MarkerFaceColor','y','LineWidth',0.5,'MarkerEdgeColor','y');
        for k=2:length(resp_ROIs)
            plot([ROI_center(ROI_number(k),2),ROI_center(ROI_number(k-1),2)],[ROI_center(ROI_number(k),1),ROI_center(ROI_number(k-1),1)]);
        end
        plot(ROI_center(ROI_number(k),2),ROI_center(ROI_number(k),1),'o', 'MarkerSize',7,'MarkerFaceColor','g','LineWidth',0.1,'MarkerEdgeColor','g');
    end
end
hold off;
title('Left trial trajectory');
saveas(h_left,'Left_trial_trajectory','png');
close;

trial_resp_max_plot=trial_resp_max(trial_inds_right,:);
trial_max_inds_plot=trial_max_inds(trial_inds_right,:);
ROI_num_plot=ROI_num(trial_inds_right,:);
h_right=figure('color','white');
scatter(ROI_center(:,2),ROI_center(:,1),20, 'r');
hold on;
for n=1:data_size(2)
    text(ROI_center(n,2),ROI_center(n,1),num2str(n),'color' ,'r', 'FontSize',10,'HorizontalAlignment' ,'right','VerticalAlignment','bottom');
end
set(gca,'YDir','reverse');
axis off;
box off;
for n=1:size(trial_resp_max_plot,1)
    resp_ROIs=find(trial_resp_max_plot(n,:));
    if isempty(resp_ROIs)
        disp([ 'No responsive trial in right trial number ' num2str(n) ',go to next trial.\n']);
        continue;
    end
    ROI_number=ROI_num_plot(n,resp_ROIs);
    ROI_sequence=trial_max_inds_plot(n,resp_ROIs);
    [~,I]=sort(ROI_sequence);
    ROI_number=ROI_number(I);
    if length(resp_ROIs)==1
        plot(ROI_center(ROI_number,2),ROI_center(ROI_number,1),'o','MarkerFaceColor','g');
    else
        plot(ROI_center(ROI_number(1),2),ROI_center(ROI_number(1),1),'o', 'MarkerSize',10,'MarkerFaceColor','y','LineWidth',0.5,'MarkerEdgeColor','y');
        for k=2:length(resp_ROIs)
            plot([ROI_center(ROI_number(k),2),ROI_center(ROI_number(k-1),2)],[ROI_center(ROI_number(k),1),ROI_center(ROI_number(k-1),1)]);
        end
        plot(ROI_center(ROI_number(k),2),ROI_center(ROI_number(k),1),'o', 'MarkerSize',7,'MarkerFaceColor','g','LineWidth',0.1,'MarkerEdgeColor','g');
    end
end
hold off;
title('right trial trajectory');
saveas(h_right,'Right_trial_trajectory','png');
close;

cd ..;
