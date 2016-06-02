function trial_response_plot(data_aligned,stim_type_freq,inds_1,inds_2,onset_f,frame_rate,session_describetion)

data_size=size(data_aligned);
x_tick=frame_rate:frame_rate:data_size(3);
x_label=1:floor(data_size(3)/frame_rate);
stim_freq_1=stim_type_freq(inds_1);
[~,I_1]=sort(stim_freq_1);
stim_freq_2=stim_type_freq(inds_2);
[~,I_2]=sort(stim_freq_2);
clims=[];
for i=1:data_size(2)
        temp_ROI_data=squeeze(data_aligned(:,i,:));
        clims(1)=min(temp_ROI_data(:));
        clims(2)=max(temp_ROI_data(:));
        if clims(2)>(10*median(temp_ROI_data(:)))
             clims(2) = (clims(2)+median(temp_ROI_data(:)))/3;
         end
         if clims(2) > 500
                 clims(2) = 400;
         end
        if clims(2) <= clims(1) || sum(isnan(clims))
            disp(['Empty data for ROI' num2str(i) ',skip ROI plot.\n']);
            continue;
        end
        temp_plot_data_left=squeeze(data_aligned(inds_1,i,:));
%         clims(1)=min(temp_plot_data_left(:));
%         clims(2)=max(temp_plot_data_left(:));
        temp_plot_data_right=squeeze(data_aligned(inds_2,i,:));
        ava_response_left=mean(temp_plot_data_left);
        ava_response_right=mean(temp_plot_data_right);
        h=figure;
        subplot(2,2,1);
        h1=imagesc(temp_plot_data_left(I_1,:),clims);
%         colormap(hot);
        title_part=session_describetion{1};
        title_part_str=strrep(title_part{1},'_','\_');
        title(['All ' title_part_str ' results']);
        set(gca,'XTick',x_tick,'XTickLabel',x_label);
         xlabel('Time(s)');
         if onset_f>0
             hold on;
             hh1=axis;
             plot([onset_f,onset_f],[hh1(3),hh1(4)],'color','y','LineWidth',2);
              hold off;
         end

        
        subplot(2,2,3);
        h2=plot(ava_response_left);
        title_part=session_describetion{1};
        title_part_str=strrep(title_part{1},'_','\_');
        title(['Mean ' title_part_str ' response']);
        set(gca,'XTick',x_tick,'XTickLabel',x_label);
        xlabel('Time(s)');
        if onset_f>0
            hold on;
             hh2=axis;
             plot([onset_f,onset_f],[hh2(3),hh2(4)],'color','y','LineWidth',2);
             hold off;
         end
        
%         clims(1)=min(temp_plot_data_right(:));
%         clims(2)=max(temp_plot_data_right(:));
        subplot(2,2,2);
        h3=imagesc(temp_plot_data_right(I_2,:),clims);
        % colormap(flipud(hot));
%         colormap(hot);
        set(gca,'XTick',x_tick,'XTickLabel',x_label);
        title_part=session_describetion{2};
        title_part_str=strrep(title_part{1},'_','\_');
        title(['All ' title_part_str ' results']);
         xlabel('Time(s)');
         h_bar=colorbar;
            plot_position_2=get(h_bar,'position');
            set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
            set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        if onset_f>0
             hold on;
             hh3=axis;
             plot([onset_f,onset_f],[hh3(3),hh3(4)],'color','y','LineWidth',2);
             hold off;
         end    
        
        subplot(2,2,4);
        h4=plot(ava_response_right);
        title_part=session_describetion{2};
        title_part_str=strrep(title_part{1},'_','\_');
        title(['Mean ' title_part_str ' response']);
        set(gca,'XTick',x_tick,'XTickLabel',x_label);
        xlabel('Time(s)');
        if onset_f>0
        hold on;
             hh4=axis;
             plot([onset_f,onset_f],[hh4(3),hh4(4)],'color','y','LineWidth',2);
             hold off;
        end
%         sup_title_raw_part1=session_describetion{1};
%         sup_title_raw_part2=session_describetion{2};
        sup_title_raw_part3=session_describetion{3};
        if size(sup_title_raw_part3{1},1)~=1
            sup_title_raw_part3={sup_title_raw_part3{1}'};
        end
%         session_describetion_modi=strrep(session_describetion,'_','\_');
        sup_title_temp_part1=strrep(session_describetion{1},'_','\_');
        sup_title_temp_part2=strrep(session_describetion{2},'_','\_');
%         sup_title_temp_part3=session_describetion_modi{3};
        suptitle(['Plot of all ' sup_title_temp_part1{1} ' and ' sup_title_temp_part2{1} ' trial results for ROI',num2str(i)]);
        saveas(h,['plot of ',sup_title_raw_part3{1},' ROI',num2str(i),'_result'],'png');
        close;
end
