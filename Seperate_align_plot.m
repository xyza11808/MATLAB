function Seperate_align_plot(re_data,trial_type,alignment_point,frame_rate,session_disp,varargin)
%re_data is a three dimensional data form with the same data formation like
%the others, which is (tiral_num,ROI_num,frame_num)
%alignemnt point indicates the time events in a single session, the column
%number decides the segmental plot number
%Mar. 04

%%
%input data preparing
% if vargin<5
%     y_label=[];
% else
%     y_label=varargin{1};
%     sterrep(y_label,'_','\_');
% end

data_size=size(re_data);
time_size=size(alignment_point);
sub_num=time_size(2);
if size(session_disp,2)==1
    title_name=session_disp';
else
    title_name=session_disp;
end
% x_tick=frame_rate:frame_rate:data_size(3);
% x_tick_label=1:floor(double(data_size(3))/frame_rate);

if sub_num==2
    cell_description=cell(2,1);
    cell_description(1)={'stim\_onset'};
    cell_description(2)={'reward\_onset'};
else
    disp('Please input the customized time point description\n');
    cell_description=cell(sub_num,1);
    for m=1:time_point_size
        tem_des=input(['Please input the description for timepoint ',num2str(m),'\n'],'s');
        tem_des=strrep(tem_des,'_','\_');
        cell_description(m)={tem_des};
    end
end


frame_index_check=0;
while(frame_index_check==0)
    Select_range=[];
    Select_range_raw=input('Please input the time range before and after each time point.\n','s');
    if isempty(Select_range_raw)
        Select_range=[0.5 0.5];
    else
        Select_range_raw=strrep(Select_range_raw,' ',',');
        Select_range=str2num(Select_range_raw);
        if length(Select_range)==1
            Select_range=[Select_range Select_range];
        elseif length(Select_range)>2
            error('Error input range, quit analysis...\n');
        end
    end
    
    if sum(Select_range>5)==2
         frame_range = Select_range;
    else
        frame_range=floor(Select_range*frame_rate);
    end
    
    event_frame=floor((double(alignment_point)/1000)*frame_rate);
    if (max(event_frame(:))+frame_range(2))>data_size(3)
        warning('Reward time out of selected frame range, quit multipoint alignment analysis...\n');
        break;
    elseif min(event_frame(:))-frame_range(1)<1
        warning('Onset time out of selected frame range, quit alignment analysis...\n');
        break;
    end
    
    % left_corr_data=re_data(trial_type==0,:,:);
    % right_corr_data=re_data(trial_type==1,:,:);
    
    %%
    %extract needed data from raw data
    extract_data=zeros(time_size(2),data_size(1),data_size(2),sum(frame_range));
    for n=1:data_size(1)
        for m=1:sub_num
            frame_inds=[];
            frame_inds(1)=event_frame(n,m)-frame_range(1);
            frame_inds(2)=event_frame(n,m)+frame_range(2)-1;
            extract_data(m,n,:,:)=squeeze(re_data(n,:,frame_inds(1):frame_inds(2)));
        end
    end
    % left_extract_data=extract_data(m,trial_type==0,:,:);
    % right_extract_data=extract_data(m,trial_type==1,:,:);
    
    %%
    %sublot of extracted data
    if ~isdir('./segment_plot_ROI/')
        mkdir('./segment_plot_ROI/');
    end
    
    if ~isdir('./segment_plot_Ava/')
        mkdir('./segment_plot_Ava/');
    end
    
    if ~isdir('./segment_plotyy_Ava/')
        mkdir('./segment_plotyy_Ava/');
    end
    
    clims=[];
    for n=1:data_size(2)
        cd('./segment_plot_ROI/');
        h=figure('color','w');
        temp_single_ROI_data=squeeze(extract_data(:,:,n,:));
        clims(1)=min(temp_single_ROI_data(:));
        clims(2)=max(temp_single_ROI_data(:));
        if clims(2)>(10*median(temp_single_ROI_data(:)))
             clims(2) = (clims(2)+median(temp_single_ROI_data(:)))/3;
         end
         if clims(2) > 500
                 clims(2) = 400;
         end
        if clims(2) <= clims(1) || sum(isnan(clims))
            disp(['Empty data for ROI' num2str(n) ',skip ROI plot.\n']);
            continue;
        end
        temp_left_ROI_data=temp_single_ROI_data(:,trial_type==0,:);
        temp_right_ROI_data=temp_single_ROI_data(:,trial_type==1,:);
        
        %%
        %colormap plot of alignment plot
        for m=1:sub_num
            subplot(2,sub_num,m);
            temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
            imagesc(temp_single_time_left,clims);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            set(gca,'YDir','normal');
            if m~=1
                set(gca,'YColor','w');
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(gca,'position',temp_posi);
                temp_posi=get(gca,'position');
            else
                temp_posi=get(gca,'position');
                %ytick
                ylabel('left\_corr\_trial');
            end
            hold on;
            time_point_pos=frame_range(1);
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            if m==time_size(2)
                h_bar=colorbar;
                plot_position_2=get(h_bar,'position');
                set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
                set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            end
        end
        
        for m=1:sub_num
            subplot(2,sub_num,m+sub_num);
            temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
            imagesc(temp_single_time_right,clims);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            set(gca,'YDir','normal');
            if m~=1
                set(gca,'YColor','w');
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(gca,'position',temp_posi);
                temp_posi=get(gca,'position');
            else
                temp_posi=get(gca,'position');
                %ytick
                ylabel('right\_corr\_trial');
            end
            hold on;
            time_point_pos=frame_range(1);
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            if m==sub_num
                h_bar=colorbar;
                plot_position_2=get(h_bar,'position');
                set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
                set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            end
        end
        suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
        saveas(h,[title_name '_ROI' num2str(n) '.png'],'png');
        close;
        cd ..;
        
        %%
        %plot of each trial trajactory
        cd('./segment_plot_Ava/');
        figure('color','w');
        for m=1:sub_num
            subplot(2,sub_num,m);
            hold on;
            temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
            %         h_left=legend('Mean\_response');
            %         set(h_left,'FontSize',3,'EdgeColor','w');
            %         imagesc(temp_single_time_left,clims);
            for k=1:size(temp_single_time_left,1)
                plot(temp_single_time_left(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
            end
            plot(mean(temp_single_time_left),'color','r','LineWidth',2);
            %             x_line_spcae=1:sum(frame_range);
            %             [haxes,hline1,hline2]=plotyy(x_line_spcae)
            set(gca,'ylim',clims,'xlim',[1,sum(frame_range)]);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            if m~=1
                set(gca,'YColor','w');
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(gca,'position',temp_posi);
                temp_posi=get(gca,'position');
            else
                temp_posi=get(gca,'position');
                %ytick
                ylabel('left\_corr\_trial');
            end
            time_point_pos=frame_range(1);
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            %         if m==sub_num
            %             h_bar=colorbar;
            %             plot_position_2=get(h_bar,'position');
            %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
            %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            %         end
        end
        
        for m=1:sub_num
            subplot(2,sub_num,m+sub_num);
            hold on;
            temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
            %         h_right=legend('Mean\_response');
            %         set(h_right,'FontSize',3,'EdgeColor','w');
            for k=1:size(temp_single_time_right,1)
                plot(temp_single_time_right(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
            end
            plot(mean(temp_single_time_right),'color','r','LineWidth',2);
            set(gca,'ylim',clims,'xlim',[1,sum(frame_range)]);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            if m~=1
                set(gca,'YColor','w');
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(gca,'position',temp_posi);
                temp_posi=get(gca,'position');
            else
                temp_posi=get(gca,'position');
                %ytick
                ylabel('right\_corr\_trial');
            end
            hold on;
            time_point_pos=frame_range(1);
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            %         if m==sub_num
            %             h_bar=colorbar;
            %             plot_position_2=get(h_bar,'position');
            %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
            %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            %         end
        end
        suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
        saveas(h,[title_name '_line_ROI' num2str(n) '.png'],'png');
        close;
        cd ..;
        
        %%
        %plot of each trial trajactory with two different y axis, in order
        %to have a better look at the ava trajactory
        cd('./segment_plotyy_Ava/');
        figure('color','w');
        for m=1:sub_num
            subplot(2,sub_num,m);
            hold on;
            temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
            %         h_left=legend('Mean\_response');
            %         set(h_left,'FontSize',3,'EdgeColor','w');
            %         imagesc(temp_single_time_left,clims);
            %             for k=1:size(temp_single_time_left,1)
            %                 plot(temp_single_time_left(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
            %             end
            %             plot(mean(temp_single_time_left),'color','r','LineWidth',2);
            temp_single_time_left_ava=smooth(mean(temp_single_time_left),9);
            x_line_spcae=1:sum(frame_range);
            [haxes,hline1,hline2]=plotyy(x_line_spcae,temp_single_time_left,x_line_spcae,temp_single_time_left_ava);
            set(hline1,'color',[0.85 0.85 0.85],'LineWidth',0.25);
            set(hline2,'color','r','LineWidth',1.5);
            set(haxes(1),'ylim',clims);
            set(haxes(2),'ylim',[min(temp_single_time_left_ava) max(temp_single_time_left_ava)],'ycolor','r');
            set(haxes,'xlim',[1,sum(frame_range)]);
            box off;
            set(haxes,'TickDir','out');
            set(haxes,'xticklabel',[]);
            if m~=1
                set(haxes(1),'YColor','w');
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(haxes,'position',temp_posi);
                temp_posi=get(gca,'position');
            else
                temp_posi=get(haxes(1),'position');
                %ytick
                ylabel('left\_corr\_trial');
            end
            time_point_pos=frame_range(1);
            temp_axis=axis(haxes(1));
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            %         if m==sub_num
            %             h_bar=colorbar;
            %             plot_position_2=get(h_bar,'position');
            %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
            %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            %         end
        end
        
        for m=1:sub_num
            subplot(2,sub_num,m+sub_num);
            hold on;
            temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
            %         h_right=legend('Mean\_response');
            %         set(h_right,'FontSize',3,'EdgeColor','w');
            temp_single_time_right_ava=smooth(mean(temp_single_time_right),9);
            x_line_spcae=1:sum(frame_range);
            [haxes,hline1,hline2]=plotyy(x_line_spcae,temp_single_time_right,x_line_spcae,temp_single_time_right_ava);
            set(hline1,'color',[0.85 0.85 0.85],'LineWidth',0.25);
            set(hline2,'color','r','LineWidth',1.5);
            set(haxes(1),'ylim',clims);
            set(haxes(2),'ylim',[min(temp_single_time_right_ava) max(temp_single_time_right_ava)],'ycolor','r');
            set(haxes,'xlim',[1,sum(frame_range)]);
            box off;
            set(haxes,'TickDir','out');
            set(haxes,'xticklabel',[]);
            if m~=1
                set(haxes(1),'YColor','w','yticklabel',[]);
                temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
                set(haxes,'position',temp_posi);
                temp_posi=get(gca,'position');
                
            else
                temp_posi=get(haxes(1),'position');
                %ytick
                ylabel('Right\_corr\_trial');
            end
            time_point_pos=frame_range(1);
            temp_axis=axis(haxes(1));
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            %         if m==sub_num
            %             h_bar=colorbar;
            %             plot_position_2=get(h_bar,'position');
            %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
            %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
            %         end
        end
        %         suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
        saveas(h,[title_name '_line_ROI' num2str(n) '.png'],'png');
        close;
        cd ..;
    end
    frame_index_check=1;
end
