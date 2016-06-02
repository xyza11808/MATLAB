function [varargout]=Seperate_align_plot_update(re_data,trial_type,alignment_point,frame_rate,session_disp,varargin)
%re_data is a three dimensional data form with the same data formation like
%the others, which is (tiral_num,ROI_num,frame_num)
%alignemnt point indicates the time events in a single session, the column
%number decides the segmental plot numberupdate version of
%Seperate_align_plot function, add spport for variad length of plot segment
%alignment_point with columns for alignment events and rows for each trial
%
%  The input variable trial_type can be either a vector of 1 and o to
%  indicates left or right, or can be a vector of diiffernt values
%  indicates multiple (more than 2) trial frequencies.
%
%June, 04, 2015 XIN Yu
%the distinguish criteria is setted at 22,June,2015

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
event_frame=floor((double(alignment_point)/1000)*frame_rate);
if data_size(1)~=time_size(1)
    warning('TimeSize is not the same as trial number in given data, quit function.\n');
    return;
end
if size(session_disp,2)==1
    title_name=session_disp';
else
    title_name=session_disp;
end

if length(unique(trial_type))==2
    
    sub_num=time_size(2);
    seg_data=cell(1,sub_num);
    
    % x_tick=frame_rate:frame_rate:data_size(3);
    % x_tick_label=1:floor(double(data_size(3))/frame_rate);
    
    if sub_num==3
        cell_description=cell(3,1);
        cell_description(1)={'stim\_onset'};
        cell_description(2)={'reward\_onset'};
        cell_description(3)={'first\_lick'};
    else
        disp('Please input the customized time point description\n');
        cell_description=cell(sub_num,1);
        for m=1:sub_num
            tem_des=input(['Please input the description for timepoint ',num2str(m),'\n'],'s');
            tem_des=strrep(tem_des,'_','\_');
            cell_description(m)={tem_des};
        end
    end
    
    frame_range=zeros(sub_num,2);
    for n=1:sub_num
        input_description=[strrep(cell_description{n},'\_','_') 'scale'];
        temp_range_str=inputdlg({input_description},'Please input the scale range');
        temp_range_num=str2num(temp_range_str{1}); %#ok<*ST2NM>
        if max(temp_range_num)<5
            frame_range(n,:)=floor(temp_range_num*frame_rate);
        else
            frame_range(n,:)=temp_range_num;
        end
        if (min(event_frame(:,n)) - frame_range(n,1)) < 1
            disp('Some of the selected frames out of the start inds, do correction to the start frame.\n');
            frame_range(n,1) = (min(event_frame(:,n))-1);
        elseif (max(event_frame(:,n)) - frame_range(n,2)) > data_size(3)
            disp('Some of the selected frames out of the start inds, do correction to the end frame.\n');
            frame_range(n,2) = data_size(3) - (max(event_frame(:,n)));
        end
        temp_data=zeros(data_size(1),data_size(2),(frame_range(n,1)+frame_range(n,2)));
        for m=1:data_size(1)
            temp_data(m,:,:) = re_data(m,:,(event_frame(m,n)-frame_range(n,1)):(event_frame(m,n)+frame_range(n,2)-1));
        end
        seg_data(n) = {temp_data};
    end
    
    % frame_index_check=0;
    % while(frame_index_check==0)
    %     Select_range=[];
    %     Select_range_raw=input('Please input the time range before and after each time point.\n','s');
    %     if isempty(Select_range_raw)
    %         Select_range=[0.5 0.5];
    %     else
    %         Select_range_raw=strrep(Select_range_raw,' ',',');
    %         Select_range=str2num(Select_range_raw);
    %         if length(Select_range)==1
    %             Select_range=[Select_range Select_range];
    %         elseif length(Select_range)>2
    %             error('Error input range, quit analysis...\n');
    %         end
    %     end
    %
    %     if sum(Select_range>5)==2
    %          frame_range = Select_range;
    %     else
    %         frame_range=floor(Select_range*frame_rate);
    %     end
    %
    %     if (max(event_frame(:))+frame_range(2))>data_size(3)
    %         warning('Reward time out of selected frame range, quit multipoint alignment analysis...\n');
    %         break;
    %     elseif min(event_frame(:))-frame_range(1)<1
    %         warning('Onset time out of selected frame range, quit alignment analysis...\n');
    %         break;
    %     end
    
    % left_corr_data=re_data(trial_type==0,:,:);
    % right_corr_data=re_data(trial_type==1,:,:);
    
    %     %%
    %     %extract needed data from raw data
    %     extract_data=zeros(time_size(2),data_size(1),data_size(2),sum(frame_range));
    %     for n=1:data_size(1)
    %         for m=1:sub_num
    %             frame_inds=[];
    %             frame_inds(1)=event_frame(n,m)-frame_range(1);
    %             frame_inds(2)=event_frame(n,m)+frame_range(2)-1;
    %             extract_data(m,n,:,:)=squeeze(re_data(n,:,frame_inds(1):frame_inds(2)));
    %         end
    %     end
    % left_extract_data=extract_data(m,trial_type==0,:,:);
    % right_extract_data=extract_data(m,trial_type==1,:,:);
    
    %%
    %sublot of extracted data
    if ~isdir('./segment_plot_ROI/')
        mkdir('./segment_plot_ROI/');
    end
    
    %     if ~isdir('./segment_plot_Ava/')
    %         mkdir('./segment_plot_Ava/');
    %     end
    %
    %     if ~isdir('./segment_plotyy_Ava/')
    %         mkdir('./segment_plotyy_Ava/');
    %     end
    y_tick_max=zeros(data_size(2),sub_num);
    c_clim=zeros(data_size(2),sub_num);
    ROIAvgData=cell(1,sub_num*2);
    
    parfor n=1:data_size(2)
        for m=1:sub_num
            data_plot_ROI = seg_data{m};
            single_ROI_data = squeeze(data_plot_ROI(:,n,:));
            temp_left_ROI_data=single_ROI_data(trial_type==0,:);
            temp_right_ROI_data=single_ROI_data(trial_type==1,:);
            left_mean_trace=mean(temp_left_ROI_data);
            right_mean_trace=mean(temp_right_ROI_data);
            y_dir_max=max([max(left_mean_trace),max(right_mean_trace)]);
            y_tick_max(n,m)=abs(y_dir_max)*1.1;
            if y_tick_max(n,m)==0
                y_tick_max(n,m)=0.1;
            end
            c_clim(n,m)=max(single_ROI_data(:));
            if c_clim(n,m)>(10*median(single_ROI_data(:)))
                c_clim(n,m) = (c_clim(n,m)+median(single_ROI_data(:)))/3;
            end
            if c_clim(n,m) > 500
                c_clim(n,m) = 300;
            end
            if c_clim(n,m)==0 || sum(isnan(c_clim(n,m)))
                disp(['Empty data for ROI' num2str(n) ',skip ROI plot.\n']);
                c_clim(n,m)=NaN;
            end
        end
    end
    
    y_tick_value=max(y_tick_max,[],2);
    c_clim_value=max(c_clim,[],2);
    statistic_result=struct();
    resp_inds=zeros(data_size(2),2*sub_num);  %the first two value indicate the test result of left trials, last two stands for test result for right trials
    cd('./segment_plot_ROI/');
    for n=1:data_size(2)
        h_fig=figure('color','w','position',[450 140 1000 820]);
        suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
        for m=1:sub_num
            data_plot_ROI = seg_data{m};
            single_ROI_data = squeeze(data_plot_ROI(:,n,:));
            %             ROI_std=std(single_ROI_data(:));
            ROI_mad=mad(single_ROI_data(:));
            %             clims(1)=min(single_ROI_data(:));
            %             clims(2)=max(single_ROI_data(:));
            %             if clims(2)>(10*median(single_ROI_data(:)))
            %                 clims(2) = (clims(2)+median(single_ROI_data(:)))/3;
            %             end
            %             if clims(2) > 500
            %                 clims(2) = 300;
            %             end
            if isnan(c_clim_value(n))
                disp(['Empty data for ROI' num2str(n) ',skip ROI plot.\n']);
                continue;
            end
            temp_left_ROI_data=single_ROI_data(trial_type==0,:);
            temp_right_ROI_data=single_ROI_data(trial_type==1,:);
            left_mean_trace=mean(temp_left_ROI_data);
            right_mean_trace=mean(temp_right_ROI_data);  %when calculate the max_norm value or the zscore value for further analysis, the max value or the zscore ocmponent should be comes from both of the two segments of left and right
            ROIAvgData(n,m)={left_mean_trace};
            ROIAvgData(n,m+sub_num)={right_mean_trace};
            time_point_pos=frame_range(m,1);
            low_frame_inds=time_point_pos-frame_rate;
            high_frame_inds=time_point_pos+frame_rate;
            if low_frame_inds<1
                low_frame_inds = 1;
            end
            
            if high_frame_inds>size(temp_left_ROI_data,2)
                high_frame_inds=size(temp_left_ROI_data,2);
            end
            
            
            %             y_dir_max=max([max(left_mean_trace),max(right_mean_trace)]);
            %             y_dir_max=y_dir_max*1.1;
            
            
            subplot(4,sub_num,m);
            imagesc(temp_left_ROI_data,[0 c_clim_value(n)]);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            set(gca,'YDir','normal');
            x_tick=[0,time_point_pos,size(temp_left_ROI_data,2)];
            %             x_tick_label=x_tick/frame_rate;
            set(gca,'xtick',x_tick);
            if m==1
                ylabel('left corr plot');
            end
            hold on;
            
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
            %###########################################################################
            %statistic test
            
            base_resp=mean(temp_left_ROI_data(:,low_frame_inds:time_point_pos),2);
            post_resp=mean(temp_left_ROI_data(:,time_point_pos:high_frame_inds),2);
            [h,p,ci,status]=ttest2(base_resp,post_resp,'Tail','left','Alpha',0.01,'Vartype','unequal');
            save_form=table(h,p,{ci},{status});
            field_name=[strrep(cell_description{m},'\_','_') 'left'];
            statistic_result(n).(field_name)=save_form;
            stat_left=[mean(left_mean_trace(low_frame_inds:time_point_pos)),mean(left_mean_trace(time_point_pos:high_frame_inds)),...
                std(left_mean_trace(low_frame_inds:time_point_pos)),std(left_mean_trace(time_point_pos:high_frame_inds)),ROI_mad];
            if h
                %((stat_left(2)-stat_left(4)) > (stat_left(1)+stat_left(3)))  &&
                if ((stat_left(2)-stat_left(4)) > (stat_left(1)+stat_left(3)))  && (stat_left(2) > ROI_mad)
                    if left_mean_trace(time_point_pos) < (max(left_mean_trace)/3)
                        resp_inds(n,m)=1;
                    end
                end
            end
            %###########################################################################
            
            subplot(4,sub_num,m + sub_num);
            plot(left_mean_trace,'color','g','LineWidth',2);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            set(gca,'ylim',[0 y_tick_value(n)]);
            x_tick=[0,time_point_pos,size(temp_left_ROI_data,2)];
            %             x_tick_label=x_tick/frame_rate;
            set(gca,'xtick',x_tick);
            if m==1
                ylabel('Mean left trace');
            end
            hold on;
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            
            field_name_mean=[strrep(cell_description{m},'\_','_') 'leftMean'];
            statistic_result(n).(field_name_mean)=stat_left;
            
            
            time_point_pos=frame_range(m,1);
            low_frame_inds=time_point_pos-frame_rate;
            high_frame_inds=time_point_pos+frame_rate;
            if low_frame_inds<1
                low_frame_inds = 1;
            end
            if high_frame_inds>size(temp_right_ROI_data,2)
                high_frame_inds=size(temp_right_ROI_data,2);
            end
            
            subplot(4,sub_num,m+2*sub_num);
            imagesc(temp_right_ROI_data,[0 c_clim_value(n)]);
            box off;
            set(gca,'TickDir','out');
            set(gca,'xticklabel',[]);
            set(gca,'YDir','normal');
            x_tick=[0,time_point_pos,size(temp_right_ROI_data,2)];
            %             x_tick_label=x_tick/frame_rate;
            set(gca,'xtick',x_tick);
            if m==1
                ylabel('right corr plot');
            end
            hold on;
            
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
            
            %###########################################################################
            %statistic test
            
            base_resp=mean(temp_right_ROI_data(:,low_frame_inds:time_point_pos),2);
            post_resp=mean(temp_right_ROI_data(:,time_point_pos:high_frame_inds),2);
            [h,p,ci,status]=ttest2(base_resp,post_resp,'Tail','left','Alpha',0.01,'Vartype','unequal');
            save_form=table(h,p,{ci},{status});
            field_name=[strrep(cell_description{m},'\_','_') 'right'];
            statistic_result(n).(field_name)=save_form;
            stat_right=[mean(right_mean_trace(low_frame_inds:time_point_pos)),mean(right_mean_trace(time_point_pos:high_frame_inds)),...
                std(right_mean_trace(low_frame_inds:time_point_pos)),std(right_mean_trace(time_point_pos:high_frame_inds)),ROI_mad];
            if h
                %((stat_right(2)-stat_right(4)) > (stat_right(1)+stat_right(3))) &&
                if (stat_right(2) > ROI_mad) && (stat_right(2)-stat_right(4)) > (stat_right(1)+stat_right(3))
                    if right_mean_trace(time_point_pos) < max(right_mean_trace)/2
                        resp_inds(n,m+sub_num)=1;
                    end
                end
            end
            %#####################################################################
            
            subplot(4,sub_num,m+3*sub_num);
            plot(right_mean_trace,'color','g','LineWidth',2);
            box off;
            set(gca,'TickDir','out');
            %             set(gca,'xticklabel',[]);
            set(gca,'ylim',[0 y_tick_value(n)]);
            xlabel('time(s)');
            x_tick=[0,time_point_pos,size(temp_right_ROI_data,2)];
            x_tick_label=x_tick/frame_rate;
            set(gca,'xtick',x_tick,'xticklabel',cellstr(num2str(x_tick_label(:),'%.2f')));
            if m==1
                ylabel('Mean right trace');
            end
            hold on;
            temp_axis=axis;
            plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
            hold off;
            
            field_name_mean=[strrep(cell_description{m},'\_','_') 'rightMean'];
            statistic_result(n).(field_name_mean)=stat_right;
            
        end
        
        saveas(h_fig,[title_name '_ROI' num2str(n) '.png'],'png');
        saveas(h_fig,[title_name '_ROI' num2str(n) '.fig']);
        close;
    end
    
    save ROI_response_summary.mat statistic_result resp_inds -v7.3;
    save ROI_data_Avg.mat ROIAvgData frame_range -v7.3;
    
else
    %while the trial type number is more than 2 trial types, performing
    %response check to each trial type and return corresponded results
    TrialTypes=unique(trial_type);
    if numel(event_frame)~=length(trial_type)
        warning('Events Time input is not the same size as trial type vector, may causing some error\n');
        waitforbuttonpress;
    end
    frame_range=[];
    input_description='Type_StimOn_range';
    temp_range_str=inputdlg({input_description},'Please input the scale range');
    temp_range_num=str2num(temp_range_str{1}); %#ok<*ST2NM>
    if max(temp_range_num)<5
        frame_range=floor(temp_range_num*frame_rate);
    else
        frame_range=temp_range_num;
    end
    if (min(event_frame(:)) - frame_range(1)) < 1
        disp('Some of the selected frames out of the start inds, do correction to the start frame.\n');
        frame_range(1) = (min(event_frame(:))-1);
    elseif (max(event_frame(:)) - frame_range(2)) > data_size(3)
        disp('Some of the selected frames out of the start inds, do correction to the end frame.\n');
        frame_range(2) = data_size(3) - (max(event_frame(:)));
    end
    SelectData=cell(length(TrialTypes),data_size(2));
    MeanTrace=zeros(length(TrialTypes),data_size(2),sum(frame_range));
    resp_inds=zeros(length(TrialTypes),data_size(2));
    TtestStruct=struct(length(TrialTypes),data_size(2));
    ROIColorscale=zeros(data_size(2),2);
    parfor n=1:data_size(2)
        TempData=squeeze(re_data(:,n,:));
        ROIColorscale(n,2)=min([300,max(TempData(:))]);
    end
    clearvars TempData
    
    for TypeNum=1:length(TrialTypes)
        CurrentType=TrialTypes(TypeNum);
        CurrentTrials=trial_type==CurrentType;
        CurrentData=re_data(CurrentTrials,:,:);
        CurrentAlignFrames=event_frame(CurrentTrials);
        CurrentDataSize=size(CurrentData);
        TempSegData=zeros(CurrentDataSize(1),CurrentDataSize(2),sum(frame_range));
        for Trialnum=1:CurrentDataSize(1)
            TempSegData(Trialnum,:,:)=CurrentData(Trialnum,:,(CurrentAlignFrames(Trialnum)-frame_range(1)):(CurrentAlignFrames(Trialnum)+frame_range(2)-1));
        end
        %         SelectData={TempSegData};
        MeanTrace(TypeNum,:,:)=squeeze(squeeze(mean(TempSegData)));
        for ROINum=1:CurrentDataSize(2)
            SelectData(TypeNum,ROINum)={squeeze(TempSegData(:,ROINum,:))};
            SingleCData=squeeze(CurrentData(:,ROINum,:));
            BeforeData=SingleCData(:,1:(frame_range(1)-1));
            AfterData=SingleCData(:,(frame_range(1)+1):end);
            CurrentMeanTrace=mean(SingleCData);
            stat_Summary=[mean(CurrentMeanTrace(1:frame_range(1))),mean(CurrentMeanTrace(frame_range(1):end)),std(CurrentMeanTrace(1:frame_range(1))),...
                std(CurrentMeanTrace(frame_range(1):end))];
            [h,p,ci,status]=ttest2(BeforeData(:),AfterData(:),'Tail','left','Alpha',0.01,'Vartype','unequal');
            TtestStruct(TypeNum,ROINum).H=h; 
            TtestStruct(TypeNum,ROINum).P=p;
            TtestStruct(TypeNum,ROINum).CI=ci;
            TtestStruct(TypeNum,ROINum).TestStaus=status;
            if h
                %((stat_right(2)-stat_right(4)) > (stat_right(1)+stat_right(3))) &&
                if (stat_Summary(2) > max(stat_Summary(3:4))) && (stat_Summary(2)-stat_Summary(4)) > (stat_Summary(1)+stat_Summary(3))  %peak value constraints
                    if CurrentMeanTrace(frame_range(1)) < max(CurrentMeanTrace)/2 && CurrentMeanTrace(frame_range(1)) < CurrentMeanTrace(frame_range(1)+1)  %peak position constraints
                        if CurrentMeanTrace(frame_range(1)+floor(frame_rate*0.5)) > max(CurrentMeanTrace)/2  %onset time constraints
                            resp_inds(TypeNum,ROINum)=1;
                        end
                    end
                end
            end
        end
    end
    DeleteVName=who('Current*');
    for n=1:length(DeleteVName);
        clearvars(DeleteVName{n});
    end
    xtick=[0 frame_range(1) sum(frame_range)];
    xticklabel=xtick/frame_rate;
    for ROInum=1:data_size(2)
        SIngleROICell=SelectData(:,ROInum);
        SingleMeanTrace=squeeze(MeanTrace(:,ROInum,:));
        hROI=figure('color','w','position',[120 50 1600 940]);
        for TypeNum=1:length(TrialTypes)
            subplot(2,length(TrialTypes),TypeNum);
            CurrentData=SIngleROICell{TypeNum};
            CurrentTrace=SingleMeanTrace(TypeNum,:);
            imagesc(CurrentData,[ROIColorscale(ROInum,1),ROIColorscale(ROInum,2)]);
            temp_axis=axis;
            line([frame_range(1) frame_range(1)],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
            text(frame_range(1)*0.75,temp_axis(4)*1.07,'StimOn');
            title(sprintf('Freq=%d',TrialTypes(TypeNum)),'FontSize',15);
            set(gca,'xtick',xtick,'xticklabel',cellstr(num2str(xticklabel(:),'%.2f')));
            set(gca,'TickDir','out');
            if TypeNum==1
                ylabel('Trials');
            end
            if TypeNum==length(TrialTypes)
                hbar=colorbar;
                BarPosition=get(hbar,'position');
                set(hbar,'position',BarPosition.*[1.13 1 0.4 1]);
                set(get(hbar,'Title'),'string','\DeltaF/f_0');
            end
            
            subplot(2,length(TrialTypes),TypeNum+length(TrialTypes));
            plot(CurrentTrace,'color','g','LineWidth',1.5);
            box off;
            set(gca,'TickDir','out');
            if TypeNum==1
                ylabel('Mean \DeltaF/f_0');
            end
            title(sprintf('Freq=%d',TrialTypes(TypeNum)),'FontSize',15);
            temp_axis=axis;
            line([frame_range(1) frame_range(1)],[temp_axis(3),temp_axis(4)],'color','r','LineWidth',1.5);
            text(frame_range(1)*0.75,temp_axis(4)*1.07,'StimOn');
            set(gca,'xtick',xtick,'xticklabel',cellstr(num2str(xticklabel(:),'%.2f')));
        end
        saveas(hROI,sprintf('ROI%d Segmental plot.png',ROInum));
        saveas(hROI,sprintf('ROI%d Segmental plot.fig',ROInum));
        close(hROI);
    end
    save ROI_response_summary.mat TtestStruct resp_inds -v7.3;
    save ROI_data_Avg.mat SelectData MeanTrace frame_range -v7.3;
end


if nargout==1
    varargout{1}=resp_inds;
end

cd ..;

%     %%
%     for n=1:data_size(2)
%         cd('./segment_plot_ROI/');
%         h=figure('color','w');
%         temp_single_ROI_data=squeeze(extract_data(:,:,n,:));
%         clims(1)=min(temp_single_ROI_data(:));
%         clims(2)=max(temp_single_ROI_data(:));
%         if clims(2)>(10*median(temp_single_ROI_data(:)))
%              clims(2) = (clims(2)+median(temp_single_ROI_data(:)))/3;
%          end
%          if clims(2) > 500
%                  clims(2) = 300;
%          end
%         if clims(2) <= clims(1) || sum(isnan(clims))
%             disp(['Empty data for ROI' num2str(n) ',skip ROI plot.\n']);
%             continue;
%         end
%         temp_left_ROI_data=temp_single_ROI_data(:,trial_type==0,:);
%         temp_right_ROI_data=temp_single_ROI_data(:,trial_type==1,:);
%
%         %%
%         %colormap plot of alignment plot
%         for m=1:sub_num
%             subplot(2,sub_num,m);
%             temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
%             imagesc(temp_single_time_left,clims);
%             box off;
%             set(gca,'TickDir','out');
%             set(gca,'xticklabel',[]);
%             set(gca,'YDir','normal');
%             if m~=1
%                 set(gca,'YColor','w');
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(gca,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%             else
%                 temp_posi=get(gca,'position');
%                 %ytick
%                 ylabel('left\_corr\_trial');
%             end
%             hold on;
%             time_point_pos=frame_range(1);
%             temp_axis=axis;
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             if m==time_size(2)
%                 h_bar=colorbar;
%                 plot_position_2=get(h_bar,'position');
%                 set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%                 set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             end
%         end
%
%         for m=1:sub_num
%             subplot(2,sub_num,m+sub_num);
%             temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
%             imagesc(temp_single_time_right,clims);
%             box off;
%             set(gca,'TickDir','out');
%             set(gca,'xticklabel',[]);
%             set(gca,'YDir','normal');
%             if m~=1
%                 set(gca,'YColor','w');
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(gca,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%             else
%                 temp_posi=get(gca,'position');
%                 %ytick
%                 ylabel('right\_corr\_trial');
%             end
%             hold on;
%             time_point_pos=frame_range(1);
%             temp_axis=axis;
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             if m==sub_num
%                 h_bar=colorbar;
%                 plot_position_2=get(h_bar,'position');
%                 set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%                 set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             end
%         end
%         suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
%         saveas(h,[title_name '_ROI' num2str(n) '.png'],'png');
%         close;
%         cd ..;
%
%         %%
%         %plot of each trial trajactory
%         cd('./segment_plot_Ava/');
%         figure('color','w');
%         for m=1:sub_num
%             subplot(2,sub_num,m);
%             hold on;
%             temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
%             %         h_left=legend('Mean\_response');
%             %         set(h_left,'FontSize',3,'EdgeColor','w');
%             %         imagesc(temp_single_time_left,clims);
%             for k=1:size(temp_single_time_left,1)
%                 plot(temp_single_time_left(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
%             end
%             plot(mean(temp_single_time_left),'color','r','LineWidth',2);
%             %             x_line_spcae=1:sum(frame_range);
%             %             [haxes,hline1,hline2]=plotyy(x_line_spcae)
%             set(gca,'ylim',clims,'xlim',[1,sum(frame_range)]);
%             box off;
%             set(gca,'TickDir','out');
%             set(gca,'xticklabel',[]);
%             if m~=1
%                 set(gca,'YColor','w');
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(gca,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%             else
%                 temp_posi=get(gca,'position');
%                 %ytick
%                 ylabel('left\_corr\_trial');
%             end
%             time_point_pos=frame_range(1);
%             temp_axis=axis;
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             %         if m==sub_num
%             %             h_bar=colorbar;
%             %             plot_position_2=get(h_bar,'position');
%             %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%             %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             %         end
%         end
%
%         for m=1:sub_num
%             subplot(2,sub_num,m+sub_num);
%             hold on;
%             temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
%             %         h_right=legend('Mean\_response');
%             %         set(h_right,'FontSize',3,'EdgeColor','w');
%             for k=1:size(temp_single_time_right,1)
%                 plot(temp_single_time_right(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
%             end
%             plot(mean(temp_single_time_right),'color','r','LineWidth',2);
%             set(gca,'ylim',clims,'xlim',[1,sum(frame_range)]);
%             box off;
%             set(gca,'TickDir','out');
%             set(gca,'xticklabel',[]);
%             if m~=1
%                 set(gca,'YColor','w');
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(gca,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%             else
%                 temp_posi=get(gca,'position');
%                 %ytick
%                 ylabel('right\_corr\_trial');
%             end
%             hold on;
%             time_point_pos=frame_range(1);
%             temp_axis=axis;
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             %         if m==sub_num
%             %             h_bar=colorbar;
%             %             plot_position_2=get(h_bar,'position');
%             %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%             %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             %         end
%         end
%         suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
%         saveas(h,[title_name '_line_ROI' num2str(n) '.png'],'png');
%         close;
%         cd ..;
%
%         %%
%         %plot of each trial trajactory with two different y axis, in order
%         %to have a better look at the ava trajactory
%         cd('./segment_plotyy_Ava/');
%         figure('color','w');
%         for m=1:sub_num
%             subplot(2,sub_num,m);
%             hold on;
%             temp_single_time_left=squeeze(temp_left_ROI_data(m,:,:));
%             %         h_left=legend('Mean\_response');
%             %         set(h_left,'FontSize',3,'EdgeColor','w');
%             %         imagesc(temp_single_time_left,clims);
%             %             for k=1:size(temp_single_time_left,1)
%             %                 plot(temp_single_time_left(k,:),'color',[0.85 0.85 0.85],'LineWidth',0.25);
%             %             end
%             %             plot(mean(temp_single_time_left),'color','r','LineWidth',2);
%             temp_single_time_left_ava=smooth(mean(temp_single_time_left),9);
%             x_line_spcae=1:sum(frame_range);
%             [haxes,hline1,hline2]=plotyy(x_line_spcae,temp_single_time_left,x_line_spcae,temp_single_time_left_ava);
%             set(hline1,'color',[0.85 0.85 0.85],'LineWidth',0.25);
%             set(hline2,'color','r','LineWidth',1.5);
%             set(haxes(1),'ylim',clims);
%             set(haxes(2),'ylim',[min(temp_single_time_left_ava) max(temp_single_time_left_ava)],'ycolor','r');
%             set(haxes,'xlim',[1,sum(frame_range)]);
%             box off;
%             set(haxes,'TickDir','out');
%             set(haxes,'xticklabel',[]);
%             if m~=1
%                 set(haxes(1),'YColor','w');
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(haxes,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%             else
%                 temp_posi=get(haxes(1),'position');
%                 %ytick
%                 ylabel('left\_corr\_trial');
%             end
%             time_point_pos=frame_range(1);
%             temp_axis=axis(haxes(1));
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             %         if m==sub_num
%             %             h_bar=colorbar;
%             %             plot_position_2=get(h_bar,'position');
%             %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%             %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             %         end
%         end
%
%         for m=1:sub_num
%             subplot(2,sub_num,m+sub_num);
%             hold on;
%             temp_single_time_right=squeeze(temp_right_ROI_data(m,:,:));
%             %         h_right=legend('Mean\_response');
%             %         set(h_right,'FontSize',3,'EdgeColor','w');
%             temp_single_time_right_ava=smooth(mean(temp_single_time_right),9);
%             x_line_spcae=1:sum(frame_range);
%             [haxes,hline1,hline2]=plotyy(x_line_spcae,temp_single_time_right,x_line_spcae,temp_single_time_right_ava);
%             set(hline1,'color',[0.85 0.85 0.85],'LineWidth',0.25);
%             set(hline2,'color','r','LineWidth',1.5);
%             set(haxes(1),'ylim',clims);
%             set(haxes(2),'ylim',[min(temp_single_time_right_ava) max(temp_single_time_right_ava)],'ycolor','r');
%             set(haxes,'xlim',[1,sum(frame_range)]);
%             box off;
%             set(haxes,'TickDir','out');
%             set(haxes,'xticklabel',[]);
%             if m~=1
%                 set(haxes(1),'YColor','w','yticklabel',[]);
%                 temp_posi=[temp_posi(1)+temp_posi(3)*1.13 temp_posi(2:4)];
%                 set(haxes,'position',temp_posi);
%                 temp_posi=get(gca,'position');
%
%             else
%                 temp_posi=get(haxes(1),'position');
%                 %ytick
%                 ylabel('Right\_corr\_trial');
%             end
%             time_point_pos=frame_range(1);
%             temp_axis=axis(haxes(1));
%             plot([time_point_pos,time_point_pos],[temp_axis(3),temp_axis(4)],'color',[0.8 0.8 0.8],'LineWidth',1.5);
%             text(time_point_pos*0.75,temp_axis(4)*1.07,cell_description{m});
%             hold off;
%             %         if m==sub_num
%             %             h_bar=colorbar;
%             %             plot_position_2=get(h_bar,'position');
%             %             set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)]);
%             %             set(get(h_bar,'Title'),'string','\DeltaF/F_0');
%             %         end
%         end
%         %         suptitle(strrep([title_name 'ROI' num2str(n)],'_','\_'));
%         saveas(h,[title_name '_line_ROI' num2str(n) '.png'],'png');
%         close;
%         cd ..;
%     end
% %     frame_index_check=1;
% % end
