function [varargout]=Split_TimePoint_plot(raw_data,trial_type,lick_frame_inds,time_point,frame_rate,description,varargin)
%raw_data contains all data needed to be ploted, only results of correct
%trials will be considered here
%trial_type give the trial info of each row data in raw_data, there it will
%only used for trial side indicates
%time_point gives all the time point data of each trial
%frame_rate is used to convert time data into frame sequences
%description is used for title description and saved file name
%varargin is used fr added function
%Mar. 3, 2015

if nargin<6
    error('Not enough input variables, quit analysis.\n');
end

if nargin>6
    trial_stim_freq=varargin{1};
else
    trial_stim_freq=[];
end

if nargin>7
    ColorBarDesp=varargin{2};
else
    ColorBarDesp='\DeltaF/F_0';
end
if isempty(ColorBarDesp)
    ColorBarDesp='\DeltaF/F_0';
end

data_size=size(raw_data);
time_point_size=size(time_point);
% description=strrep(description,'_','\_');
frame_point=floor((double(time_point)/1000)*frame_rate);  %the first col now indicates stim_onset time, and the second col indicates the reward time
left_inds=find(trial_type==0);
right_inds=find(trial_type==1);
% left_trial_freq=trial_stim_freq(left_inds);
% right_trial_freq=trial_stim_freq(right_inds);
% [~,I_left]=sort(left_trial_freq);
% [~,I_right]=sort(right_trial_freq);

if isdir('.\sequence_sort_plot\')==0
    mkdir('.\sequence_sort_plot\');
end
if isdir('.\sequence_sort_plot\stim_onset_sort\')==0
    mkdir('.\sequence_sort_plot\stim_onset_sort\');
end
if isdir('.\sequence_sort_plot\reward_onset_sort\')==0
    mkdir('.\sequence_sort_plot\reward_onset_sort\');
end
if isdir('.\sequence_sort_plot\first_lick_sort\')==0
    mkdir('.\sequence_sort_plot\first_lick_sort\');
end

% if isdir('.\sequence_freq_sort_plot\')==0
%     mkdir('.\sequence_freq_sort_plot\');
% end

xtick=frame_rate:frame_rate:data_size(3);
xTick_lable=1:floor(data_size(3)/frame_rate);
ROINum=data_size(2);
ROIclims=zeros(ROINum,2);
cd('.\sequence_sort_plot\');
StimDirStr='.\stim_onset_sort\';
RewardDirStr='.\reward_onset_sort\';
LickDirStr='.\first_lick_sort\';
if isempty(trial_stim_freq)
    for k=1:ROINum
        Single_ROI_data=squeeze(raw_data(:,k,:));
        clims=[];
        clims(1)=max(min(Single_ROI_data(:)),0);
        clims(2)=max(Single_ROI_data(:));
        if clims(2)>(10*median(Single_ROI_data(:)))
            clims(2) = (clims(2)+median(Single_ROI_data(:)))/3;
        end
        if clims(2) > 500
            clims(2) = 400;
        end
        ROIclims(k,:)=clims;
        % if time_point_size(2)==2
        %     cell_description=cell(2,1);
        %     cell_description(1)={'stim_onset'};
        %     cell_description(2)={'reward_onset'};
        % else
        %     disp('Please input the customized time point description\n');
        %     cell_description=cell(time_point_size(2),1);
        %     for m=1:time_point_size
        %         tem_des=input(['Please input the description for timepoint ',num2str(m),'\n'],'s');
        %         cell_description(m)={tem_des};
        %     end
        % end
        
        raw_left_data=Single_ROI_data(left_inds,:);
        raw_right_data=Single_ROI_data(right_inds,:);
        % sort_left_data=zeros(size(raw_left_data));
        % sort_right_data=zeros(size(raw_right_data));
        frame_point_left=frame_point(left_inds,:);
        frame_point_right=frame_point(right_inds,:);
        [~,I_left]=sort(frame_point_left(:,1));
        [~,I_left_reward]=sort(frame_point_left(:,2));
        [~,I_left_Flick]=sort(frame_point_left(:,3));
        [~,I_right]=sort(frame_point_right(:,1));
        [~,I_right_reward]=sort(frame_point_right(:,2));
        [~,I_right_Flick]=sort(frame_point_right(:,3));
        %     cd('.\stim_onset_sort\');
        %####################################################################
        %start with plot of correct trials sorted by stim onset
        sort_left_data=raw_left_data(I_left,:);
        sort_right_data=raw_right_data(I_right,:);
        sort_frame_left=frame_point_left(I_left,:);
        sort_frame_right=frame_point_right(I_right,:);
        
        Valid_struct=sum([isempty(lick_frame_inds(1).Action_LeftLick_frame),isempty(lick_frame_inds(1).Action_RightLick_frame)]);
        if Valid_struct~=2
            left_lick_time=lick_frame_inds(left_inds);
            right_lick_time=lick_frame_inds(right_inds);
            
            left_lick_time_sorted=left_lick_time(I_left);
            right_lick_time_sorted=right_lick_time(I_right);
        end
        
        
        h=figure('color','w','position',[450 140 1000 820]);
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
        
        subplot(1,2,1);
        imagesc(sort_left_data,clims);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        %     set(gca,'ytick',[]);
        ylabel('Left\_corr\_trial');
        %     hh_left=axis;
        %     line_height=(hh_left(4)-hh_left(3))/length(I_left);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_left)
            temp_frame_point=sort_frame_left(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                left_lick_frame=left_lick_time_sorted(n).Action_LeftLick_frame;
                left_rightlick_frame=left_lick_time_sorted(n).Action_RightLick_frame;
                plot(left_lick_frame,repmat(n,1,length(left_lick_frame)),'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                plot(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)),'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 sg=scatter(left_lick_frame,repmat(n,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 sg2=scatter(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.4
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.4
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(left_lick_time_sorted(n).Action_LeftLick_frame)
                %                 scatter(left_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        
        subplot(1,2,2);
        imagesc(sort_right_data,clims);
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
        set(get(h_bar,'Title'),'string',ColorBarDesp);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        set(gca,'ytick',[]);
        ylabel('Right\_corr\_trial');
        %     hh_right=axis;
        %     line_height=(hh_right(4)-hh_right(3))/length(I_right);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_right)
            temp_frame_point=sort_frame_right(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                right_lick_frame=right_lick_time_sorted(n).Action_RightLick_frame;
                right_leftlick_frame=right_lick_time_sorted(n).Action_LeftLick_frame;
                plot(right_lick_frame,repmat(n,1,length(right_lick_frame)),'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                plot(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)),'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%               
%                 sg=scatter(right_lick_frame,repmat(n,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 sg2=scatter(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(right_lick_frame)
                %                 scatter(right_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        suptitle(['ROI' num2str(k) 'sorted by stim onset']);
        saveas(h,sprintf('%s%s_ROI_stim_sort%d',StimDirStr,description,k),'fig');
        saveas(h,sprintf('%s%s_ROI_stim_sort%d',StimDirStr,description,k),'png');
        %     saveas(h,[description '_ROI_stim_sort' num2str(k) '.png'],'png');
        close;
        %end of stim onet plot
        %####################################################################################
        %     cd ..;
        %     cd('.\reward_onset_sort\');
        %####################################################################################
        %start of reward onset sort
        sort_left_data=raw_left_data(I_left_reward,:);
        sort_right_data=raw_right_data(I_right_reward,:);
        sort_frame_left=frame_point_left(I_left_reward,:);
        sort_frame_right=frame_point_right(I_right_reward,:);
        
        Valid_struct=sum([isempty(lick_frame_inds(1).Action_LeftLick_frame),isempty(lick_frame_inds(1).Action_RightLick_frame)]);
        if Valid_struct~=2
            left_lick_time=lick_frame_inds(left_inds);
            right_lick_time=lick_frame_inds(right_inds);
            left_lick_time_sorted=left_lick_time(I_left_reward);
            right_lick_time_sorted=right_lick_time(I_right_reward);
        end
        
        h=figure('color','w','position',[450 140 1000 820]);
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
        subplot(1,2,1);
        imagesc(sort_left_data,clims);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        set(gca,'ytick',[]);
        ylabel('Left\_corr\_trial');
        %     hh_left=axis;
        %     line_height=(hh_left(4)-hh_left(3))/length(I_left);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_left)
            temp_frame_point=sort_frame_left(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                left_lick_frame=left_lick_time_sorted(n).Action_LeftLick_frame;
                left_rightlick_frame=left_lick_time_sorted(n).Action_RightLick_frame;
                plot(left_lick_frame,repmat(n,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                plot(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%               
%                 sg=scatter(left_lick_frame,repmat(n,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 sg2=scatter(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(left_lick_time_sorted(n).Action_LeftLick_frame)
                %                 scatter(left_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        
        subplot(1,2,2);
        imagesc(sort_right_data,clims);
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
        set(get(h_bar,'Title'),'string',ColorBarDesp);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        set(gca,'ytick',[]);
        ylabel('Right\_corr\_trial');
        %     hh_right=axis;
        %     line_height=(hh_right(4)-hh_right(3))/length(I_right);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_right)
            temp_frame_point=sort_frame_right(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                right_lick_frame=right_lick_time_sorted(n).Action_RightLick_frame;
                right_leftlick_frame=right_lick_time_sorted(n).Action_LeftLick_frame;
                plot(right_lick_frame,repmat(n,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                plot(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%               
%                 sg=scatter(right_lick_frame,repmat(n,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 sg2=scatter(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1, with 10% opaque left
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1, with 10% opaque left
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(right_lick_frame)
                %                 scatter(right_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        suptitle(['ROI' num2str(k) ' sorted by reward onset']);
        saveas(h,sprintf('%s%s_ROI_reward_sort%d',RewardDirStr,description,k),'fig');
        saveas(h,sprintf('%s%s_ROI_reward_sort%d',RewardDirStr,description,k),'png');
        %     saveas(h,[description '_ROI_reward_sort' num2str(k) '.png'],'png');
        close;
        %end of reward sort plot
        %##########################################################################################################################
        %     cd ..;
        
        %##########################################################################################################################
        %first lick time sorted plot
        %     cd('.\first_lick_sort\');
        sort_left_data=raw_left_data(I_left_Flick,:);
        sort_right_data=raw_right_data(I_right_Flick,:);
        sort_frame_left=frame_point_left(I_left_Flick,:);
        sort_frame_right=frame_point_right(I_right_Flick,:);
        
        Valid_struct=sum([isempty(lick_frame_inds(1).Action_LeftLick_frame),isempty(lick_frame_inds(1).Action_RightLick_frame)]);
        if Valid_struct~=2
            left_lick_time=lick_frame_inds(left_inds);
            right_lick_time=lick_frame_inds(right_inds);
            
            left_lick_time_sorted=left_lick_time(I_left_Flick);
            right_lick_time_sorted=right_lick_time(I_right_Flick);
        end
        
        
        h=figure('color','w','position',[450 140 1000 820]);
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
        subplot(1,2,1);
        imagesc(sort_left_data,clims);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        %     set(gca,'ytick',[]);
        ylabel('Left\_corr\_trial');
        %     hh_left=axis;
        %     line_height=(hh_left(4)-hh_left(3))/length(I_left);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_left_Flick)
            temp_frame_point=sort_frame_left(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                left_lick_frame=left_lick_time_sorted(n).Action_LeftLick_frame;
                left_rightlick_frame=left_lick_time_sorted(n).Action_RightLick_frame;
                plot(left_lick_frame,repmat(n,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                plot(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%               
%                 sg=scatter(left_lick_frame,repmat(n,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 sg2=scatter(left_rightlick_frame,repmat(n,1,length(left_rightlick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.4
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.4
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(left_lick_time_sorted(n).Action_LeftLick_frame)
                %                 scatter(left_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        
        subplot(1,2,2);
        imagesc(sort_right_data,clims);
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
        set(get(h_bar,'Title'),'string',ColorBarDesp);
        hold on;
        % set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        set(gca,'ytick',[]);
        ylabel('Right\_corr\_trial');
        %     hh_right=axis;
        %     line_height=(hh_right(4)-hh_right(3))/length(I_right);
        % temp_frame_point=zeros(1,time_point_size(2));
        for n=1:length(I_right_Flick)
            temp_frame_point=sort_frame_right(n,:);
            for m=1:time_point_size(2)
                line([temp_frame_point(m),temp_frame_point(m)],[n-0.5,n+0.5],'color',([1 0 1]*0.1*(10-m)),'LineWidth',1.8);
            end
            if Valid_struct~=2
                right_lick_frame=right_lick_time_sorted(n).Action_RightLick_frame;
                right_leftlick_frame=right_lick_time_sorted(n).Action_LeftLick_frame;
                plot(right_lick_frame,repmat(n,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                plot(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%               
%                 sg=scatter(right_lick_frame,repmat(n,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                 sg2=scatter(right_leftlick_frame,repmat(n,1,length(right_leftlick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
%                 try
%                     sMarkers=sg.MarkerHandle; %hidden marker handle
%                     sMarkers.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                     
%                     sMarkers2=sg2.MarkerHandle; %hidden marker handle
%                     sMarkers2.FaceColorData = uint8(255*[1;0;0;0.4]); %fourth element allows setting alpha with 0.1
%                     sMarkers2.EdgeColorData = uint8(255*[1;0;0;0]); %set edge color in a similar way
%                 catch
%                     %                 disp('failed to adjust the transparancy level');
%                 end
                %             for l=1:length(right_lick_frame)
                %                 scatter(right_lick_frame(l),n,5,'MarkerFaceColor','g','MarkerEdgeColor','g');
                %             end
            end
        end
        hold off;
        suptitle(['ROI' num2str(k) 'sorted by first lick']);
        saveas(h,sprintf('%s%s_ROI_FL_sort%d',LickDirStr,description,k),'fig');
        saveas(h,sprintf('%s%s_ROI_FL_sort%d',LickDirStr,description,k),'png');
        %     saveas(h,[description '_ROI_FL_sort' num2str(k) '.png'],'png');
        close;
        %end of first lick plot
        %####################################################################################
        %     cd ..;
    end
%     for n=1:ROINum
%         open(sprintf('%s%s_ROI_stim_sort%d.fig',StimDirStr,description,n));
%         print(gcf,'-dpng','-r200',sprintf('%s%s_ROI_stim_sort%d.png',StimDirStr,description,n));
%         close(gcf);
%         
%         open(sprintf('%s%s_ROI_reward_sort%d.fig',RewardDirStr,description,n));
%         print(gcf,'-dpng','-r200',sprintf('%s%s_ROI_reward_sort%d.png',RewardDirStr,description,n));
%         close(gcf);
%         
%         open(sprintf('%s%s_ROI_FL_sort%d.fig',LickDirStr,description,n));
%         print(gcf,'-dpng','-r200',sprintf('%s%s_ROI_FL_sort%d.png',LickDirStr,description,n));
%         close(gcf);
%     end
    
else
    %############################################################################################################################
    %start of stim onset plot for random puretone data
%     cd('./stim_onset_sort/');
   for k=1:data_size(2)
        Single_ROI_data=squeeze(raw_data(:,k,:));
        clims=[];
        clims(1)=max(min(Single_ROI_data(:)),0);
        clims(2)=min(max(Single_ROI_data(:)),300);
        
        
        stim_type=unique(trial_stim_freq);
        Valid_struct=sum([isempty(lick_frame_inds(1).Action_LeftLick_frame),isempty(lick_frame_inds(1).Action_RightLick_frame)]);
        
        h_rand=figure('color','w','position',[450 140 1000 820]);
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
        %         sub_plot_size=length(stim_type);
        for n=1:(length(stim_type)/2)
            single_freq_data_inds=trial_stim_freq==stim_type(n);
            %             if Valid_struct~=2
            %                 lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
            %              end
            single_freq_data=Single_ROI_data(single_freq_data_inds,:);
            single_freq_onset=frame_point(single_freq_data_inds,:);
            [single_freq_onset_sorted,I]=sortrows(single_freq_onset,1);
            
            subplot((length(stim_type)/2),2,2*n-1);
            imagesc(single_freq_data(I,:),clims);
            set(gca,'xtick',xtick,'xticklabel',xTick_lable);
            set(gca,'ytick',[]);
            ylabel('ROI response');
            title([num2str(stim_type(n)) 'Hz']);
            hold on;
            %              hh=axis;
            %              single_line_height=(hh(4)-hh(3))/size(single_freq_data,1);
            for q=1:length(I)
                temp_frame_point=single_freq_onset_sorted(q,:);
                for p=1:length(temp_frame_point)
                    line([temp_frame_point(p),temp_frame_point(p)],[q-0.5,q+0.5],'color',([.1 .1 .1]*0.2*p),'LineWidth',1.8);
                end
                if Valid_struct~=2
                    %                      lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    right_lick_frame=lick_time_SingleFreq(q).Action_RightLick_frame;
                    left_lick_frame=lick_time_SingleFreq(q).Action_LeftLick_frame;
                    plot(right_lick_frame,repmat(q,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                    plot(left_lick_frame,repmat(q,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
               
%                     scatter(right_lick_frame,repmat(q,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                     scatter(left_lick_frame,repmat(q,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                end
                
            end
            
            single_freq_data_inds=trial_stim_freq==stim_type(n+(length(stim_type)/2));
            single_freq_data=Single_ROI_data(single_freq_data_inds,:);
            single_freq_onset=frame_point(single_freq_data_inds,:);
            [single_freq_onset_sorted,I]=sortrows(single_freq_onset,1);
            
            
            subplot((length(stim_type)/2),2,2*n);
            imagesc(single_freq_data(I,:),clims);
            set(gca,'xtick',xtick,'xticklabel',xTick_lable);
            set(gca,'ytick',[]);
            ylabel('ROI response');
            title([num2str(stim_type(n+(length(stim_type)/2))) 'Hz']);
            if n==length(stim_type)/2
                h_bar=colorbar;
                plot_position_3=get(h_bar,'position');
                set(h_bar,'position',[plot_position_3(1)*1.15 plot_position_3(2) plot_position_3(3)*0.4 plot_position_3(4)]);
                set(get(h_bar,'Title'),'string',ColorBarDesp);
            end
            hold on;
            %              hh=axis;
            %              single_line_height=(hh(4)-hh(3))/size(single_freq_data,1);
            for q=1:length(I)
                temp_frame_point=single_freq_onset_sorted(q,:);
                for p=1:length(temp_frame_point)
                    line([temp_frame_point(p),temp_frame_point(p)],[q-0.5,q+0.5],'color',([.1 .1 .1]*0.2*p),'LineWidth',1.8);
                end
                if Valid_struct~=2
                    %                      lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    right_lick_frame=lick_time_SingleFreq(q).Action_RightLick_frame;
                    left_lick_frame=lick_time_SingleFreq(q).Action_LeftLick_frame;
                    plot(right_lick_frame,repmat(q,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                    plot(left_lick_frame,repmat(q,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                
%                     scatter(right_lick_frame,repmat(q,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                     scatter(left_lick_frame,repmat(q,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                end
            end
        end
        suptitle(['ROI', num2str(k) ' sorted by stim onset']);
        saveas(h_rand,sprintf('%s%s_ROI_stim_sort%d.png',StimDirStr,description,k));
%         saveas(h_rand,[description '_ROI_stim_sort' num2str(k) '.png'],'png');
        close;
    end
    %end of stim onset plot for random puretone data
    %###############################################################################################################################
%     cd ..;
%     cd('./reward_onset_sort/');
    %###############################################################################################################################
    %start of reward onset sort plot for random puretone data
    for k=1:data_size(2)
        Single_ROI_data=squeeze(raw_data(:,k,:));
        clims=[];
        clims(1)=max(min(Single_ROI_data(:)),0);
        clims(2)=min(max(Single_ROI_data(:)),300);
        
        h_rand=figure;
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
        stim_type=unique(trial_stim_freq);
        Valid_struct=sum([isempty(lick_frame_inds(1).Action_LeftLick_frame),isempty(lick_frame_inds(1).Action_RightLick_frame)]);
        %         sub_plot_size=length(stim_type);
        for n=1:(length(stim_type)/2)
            single_freq_data_inds=trial_stim_freq==stim_type(n);
            single_freq_data=Single_ROI_data(single_freq_data_inds,:);
            single_freq_onset=frame_point(single_freq_data_inds,:);
            [single_freq_onset_sorted,I]=sortrows(single_freq_onset,2);
            subplot((length(stim_type)/2),2,2*n-1);
            imagesc(single_freq_data(I,:),clims);
            set(gca,'xtick',xtick,'xticklabel',xTick_lable);
            set(gca,'ytick',[]);
            ylabel('ROI response');
            title([num2str(stim_type(n)) 'Hz']);
            hold on;
            %              hh=axis;
            %              single_line_height=(hh(4)-hh(3))/size(single_freq_data,1);
            for q=1:length(I)
                temp_frame_point=single_freq_onset_sorted(q,:);
                for p=1:length(temp_frame_point)
                    line([temp_frame_point(p),temp_frame_point(p)],[q-0.5,q+0.5],'color',([.1 .1 .1]*0.2*p),'LineWidth',1.8);
                end
                if Valid_struct~=2
                    %                      lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    right_lick_frame=lick_time_SingleFreq(q).Action_RightLick_frame;
                    left_lick_frame=lick_time_SingleFreq(q).Action_LeftLick_frame;
                    plot(right_lick_frame,repmat(q,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                    plot(left_lick_frame,repmat(q,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                
%                     scatter(right_lick_frame,repmat(q,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                     scatter(left_lick_frame,repmat(q,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                end
            end
            
            single_freq_data_inds=trial_stim_freq==stim_type(n+(length(stim_type)/2));
            single_freq_data=Single_ROI_data(single_freq_data_inds,:);
            single_freq_onset=frame_point(single_freq_data_inds,:);
            [single_freq_onset_sorted,I]=sortrows(single_freq_onset,2);
            subplot((length(stim_type)/2),2,2*n);
            imagesc(single_freq_data(I,:),clims);
            set(gca,'xtick',xtick,'xticklabel',xTick_lable);
            set(gca,'ytick',[]);
            ylabel('ROI response');
            title([num2str(stim_type(n+(length(stim_type)/2))) 'Hz']);
            if n==length(stim_type)/2
                h_bar=colorbar;
                plot_position_3=get(h_bar,'position');
                set(h_bar,'position',[plot_position_3(1)*1.15 plot_position_3(2) plot_position_3(3)*0.4 plot_position_3(4)]);
                set(get(h_bar,'Title'),'string',ColorBarDesp);
            end
            hold on;
            %              hh=axis;
            %              single_line_height=(hh(4)-hh(3))/size(single_freq_data,1);
            for q=1:length(I)
                temp_frame_point=single_freq_onset_sorted(q,:);
                for p=1:length(temp_frame_point)
                    line([temp_frame_point(p),temp_frame_point(p)],[q-0.5,q+0.5],'color',([.1 .1 .1]*0.2*p),'LineWidth',1.8);
                end
                if Valid_struct~=2
                    %                      lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    lick_time_SingleFreq=lick_frame_inds(single_freq_data_inds);
                    right_lick_frame=lick_time_SingleFreq(q).Action_RightLick_frame;
                    left_lick_frame=lick_time_SingleFreq(q).Action_LeftLick_frame;
                    plot(right_lick_frame,repmat(q,1,length(right_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
                    plot(left_lick_frame,repmat(q,1,length(left_lick_frame)) ,'o','MarkerSize',2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                
%                     scatter(right_lick_frame,repmat(q,1,length(right_lick_frame)),2.4,'MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',0.01);
%                     scatter(left_lick_frame,repmat(q,1,length(left_lick_frame)),2.4,'MarkerFaceColor','g','MarkerEdgeColor','g','LineWidth',0.01);
                end
            end
        end
        suptitle(['ROI', num2str(k) ' sorted by reward onset']);
        saveas(h_rand,sprintf('%s%s_ROI_reward_sort%d.png',RewardDirStr,description,k));
%         saveas(h_rand,[description '_ROI_reward-sort' num2str(k) '.png'],'png');
        close;
    end
    
    %end of reward onset sort plot for random puretone data
    %###############################################################################################################################
%     cd ..;
end
cd ..;

if nargout>0
    varargout{1}=ROIclims;
end