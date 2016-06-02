function All_trial_plot(data_aligned,plot_data_inds,frame_rate,align_time_point,tria_disp,session_date)

%######################################################
    size_data=size(data_aligned);
    %plot of all trial results
    if strcmpi(tria_disp,'Stim onset')
        if ~isdir('.\ALLTrial_plot_save_StimOn\')
            mkdir('.\ALLTrial_plot_save_StimOn\');
        end
        cd('.\ALLTrial_plot_save_StimOn\');
    elseif strcmpi(tria_disp,'Reward time')
        if ~isdir('.\ALLTrial_plot_save_rewardOn\')
            mkdir('.\ALLTrial_plot_save_rewardOn\');
        end
        cd('.\ALLTrial_plot_save_rewardOn\');
    end
    data_size=size(data_aligned);
    framelength=data_size(3);
    C_lim_all=[];
    x_tick=frame_rate:frame_rate:framelength;
    x_tick_label=1:floor(double(framelength)/frame_rate);
    for n=1:size_data(2)
        temp_data=squeeze(data_aligned(:,n,:));
        C_lim_all(1)=max(min(temp_data(:)),0);
         C_lim_all(2)=min(max(temp_data(:)),200);
%          if C_lim_all(2)>(10*median(temp_data(:)))
%              C_lim_all(2) = (C_lim_all(2)+median(temp_data(:)))/3;
%          end
%          if C_lim_all(2) > 500
%                  C_lim_all(2) = 400;
%          end
         if diff(C_lim_all)<=0 || sum(isnan(C_lim_all))~=0
             disp(['Error data present for ROI' num2str(n) ', skip this ROI.\n']);
             continue;
         end
        h_all=figure;
        subplot(3,2,1);
        imagesc(temp_data(plot_data_inds.left_trials_bingo_inds,:),C_lim_all);
        set(gca,'xticklabel',[],'yticklabel',[]);
        ylabel('correct\_left\_trial');
        hold on;
        hh2=axis;   
        triger_position=floor((double(align_time_point)/1000)*frame_rate);
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        subplot(3,2,3);
        imagesc(temp_data(plot_data_inds.left_trials_oops_inds,:),C_lim_all);
        set(gca,'xticklabel',[],'yticklabel',[]);
        ylabel('Error\_left\_trial');
        hold on;
        hh2=axis;   
%         triger_position=align_time_point*frame_rate;
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        subplot(3,2,5);
        imagesc(temp_data(plot_data_inds.left_trials_miss_inds,:),C_lim_all);
        set(gca,'xtick',x_tick,'xticklabel',x_tick_label,'yticklabel',[]);
        ylabel('Miss\_left\_trial');
        hold on;
        hh2=axis;   
%         triger_position=align_time_point*frame_rate;
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        subplot(3,2,2);
        imagesc(temp_data(plot_data_inds.right_trials_bingo_inds,:),C_lim_all);
        set(gca,'xticklabel',[],'yticklabel',[]);
        ylabel('correct\_right\_trial');
         hold on;
        hh2=axis;   
%         triger_position=align_time_point*frame_rate;
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        subplot(3,2,4);
        imagesc(temp_data(plot_data_inds.right_trials_oops_inds,:),C_lim_all);
        set(gca,'xticklabel',[],'yticklabel',[]);
        ylabel('Error\_right\_trial');
         hold on;
        hh2=axis;   
%         triger_position=align_time_point*frame_rate;
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        subplot(3,2,6);
        imagesc(temp_data(plot_data_inds.right_trials_miss_inds,:),C_lim_all);
        set(gca,'xtick',x_tick,'xticklabel',x_tick_label,'yticklabel',[]);
        ylabel('Miss\_right\_trial');
         h_bar=colorbar;
        plot_position_all=get(h_bar,'position');
        set(h_bar,'position',[plot_position_all(1)*1.13 plot_position_all(2) plot_position_all(3)*0.4 plot_position_all(4)])
        set(get(h_bar,'Title'),'string','\DeltaF/F_0');
         hold on;
        hh2=axis;   
%         triger_position=align_time_point*frame_rate;
        plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
        hold off;
        
        tria_disp=strrep(tria_disp,'_',' ');
        suptitle(['ROI ',num2str(n,'%03d'),' Aligned by ',tria_disp]);
        tria_disp=strrep(tria_disp,' ','_');
        saveas(h_all,[session_date','_' tria_disp 'sort_ROI_',num2str(n,'%03d'),'.png']);
        close;
    end
    cd ..;