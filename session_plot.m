function session_plot(data_aligned,stim_type_freq,session_date,plot_data_inds,frame_rate,varargin)
    %if there are some vargin inputs, it should at least contains 2 inputs, the first one is given input time, and the second one should include the plot choice.
   % for the extra choice selection, default value is to plot all of the trial results. if user have some specific need for some selected plot, they can change there option by adding extra inputs.
   

if nargin<4
    error('Not enough input for session plot function');
end

if nargin<5
    frame_rate=55;
end

if ~isempty(varargin)
    if length(varargin) > 1
        stim_start=varargin{1};
        extra_choice=varargin{2};
    elseif length(varargin) == 1
        stim_start=varargin{1};
        extra_choice = 0;
    end

else
    extra_choice=0;
    stim_start=1;
end

start_frame=floor((double(stim_start)/1000)*frame_rate);

if ~isstruct(plot_data_inds)
    error('the import data index is not a struct.');
end

% plot_inds=struct('left_trials_inds',[],'right_trials_inds',[],'left_trials_bingo_inds',[],'right_trials_bingo_inds',[],...
%     'left_trials_oops_inds',[],'right_trials_oops_inds',[]);
% if ~varargin
%     for i=1:length(varargin)
%         plot_inds.(cell2mat(varargin(i)))=1;
%     end
% end

data_size=size(data_aligned);
x_step=floor(frame_rate);
time=floor(data_size(3)/x_step);
x_tick=x_step:x_step:x_step*time;
x_label=1:time;

%inputname can return the input variables name in string
% >> a=['www',num2str(1)];
% >> b.(a)=10
%
% b =
%
%     www1: 10
%b is a struct
%temp_plot_data_left=zeros(data_size(1),data_size(3));
%temp_plot_data_right=zeros(data_size(1),data_size(3));
% if isempty(varargin(2))   %maybe this place should change into an input option
  if   extra_choice == 0
    if isdir('.\left_and_right_plot\')==0
        mkdir('.\left_and_right_plot\');
    end
    cd('.\left_and_right_plot\');
    %use this function instead
    %trial_response_plot(data_aligned,inds_1,inds_2,session_describetion)
    %##############################################################################################
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.left_trials_inds,plot_data_inds.right_trials_inds,start_frame,frame_rate,{{'left'},{'right'},{session_date'}});    %the last cell data is used for plot describtion, must needed
    %##############################################################################################
    
    
%     for i=1:data_size(2)
%         clims=[0,0];
%         temp_plot_data_left=squeeze(data_aligned(plot_data_inds.left_trials_inds,i,:));
%         clims(1)=min(temp_plot_data_left(:));
%         clims(2)=max(temp_plot_data_left(:));
%         temp_plot_data_right=squeeze(data_aligned(plot_data_inds.right_trials_inds,i,:));
%         ava_response_left=mean(temp_plot_data_left);
%         ava_response_right=mean(temp_plot_data_right);
%         h=figure;
%         subplot(2,2,1);
%         imagesc(temp_plot_data_left,clims);
%         colormap(flipud(hot));
%         title('All left trials results');
%         set(gca,'XTick',x_tick,'XTickLabel',x_label);
%         
%         subplot(2,2,3);
%         plot(ava_response_left);
%         title('Mean left trial response');
%         set(gca,'XTick',x_tick,'XTickLabel',x_label);
%         xlabel('Time(s)');
%         
%         clims(1)=min(temp_plot_data_right(:));
%         clims(2)=max(temp_plot_data_right(:));
%         subplot(2,2,2);
%         imagesc(temp_plot_data_right,clims);
%         colormap(flipud(hot));
%         set(gca,'XTick',x_tick,'XTickLabel',x_label);
%         title('All right trials results.');
%         
%         subplot(2,2,4);
%         plot(ava_response_right);
%         title('Mean right trial response');
%         set(gca,'XTick',x_tick,'XTickLabel',x_label);
%         xlabel('Time(s)');
%         
%         suptitle(['Plot of all left and right trial results for ROI',num2str(i)]);
%         saveas(h,['plot of ',session_date,' ROI',num2str(i),' result'],'png');
%         close;
%     end
    cd ..;
    
    if isdir('.\left_corr_and_erro_plot\')==0
        mkdir('.\left_corr_and_erro_plot\');
    end
    cd('.\left_corr_and_erro_plot\');
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.left_trials_bingo_inds,plot_data_inds.left_trials_oops_inds,start_frame,frame_rate,{{'left_corr'},{'left_err'},{session_date'}});
    % for i=1:data_size(2)
    %     temp_plot_data_left_corr=squeeze(data_aligned(plot_data_inds.left_trials_bingo_inds,i,:));
    %     temp_plot_data_left_erro=squeeze(data_aligned(plot_data_inds.left_trials_oops_inds,i,:));
    %     h=figure;
    %     subplot(1,2,1);
    %     imagesc(temp_plot_data_left_corr,[0 300]);
    %     colormap(flipud(hot));
    %     title('All correct left trials results.');
    %     set(gca,'XTick',x_tick,'XTickLabel',x_label);
        
    %     subplot(1,2,2);
    %     imagesc(temp_plot_data_left_erro,[0 300]);
    %     colormap(flipud(hot));
    %     title('All error left trials results.');
    %     set(gca,'XTick',x_tick,'XTickLabel',x_label);
        
    %     suptitle('Plot of all left trial results');
    %     saveas(h,['plot of ',session_date,' ROI',num2str(i),' result'],'png');
    %     close;
    % end
    cd ..;
    
    if isdir('.\right_corr_and_erro_plot\')==0
        mkdir('.\right_corr_and_erro_plot\');
    end
    cd('.\right_corr_and_erro_plot\');
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.right_trials_bingo_inds,plot_data_inds.right_trials_oops_inds,start_frame,frame_rate,{{'right_corr'},{'right_err'},{session_date'}});
    % for i=1:data_size(2)
    % for i=1:data_size(2)
    %     temp_plot_data_right_corr=squeeze(data_aligned(plot_data_inds.left_trials_bingo_inds,i,:));
    %     temp_plot_data_right_erro=squeeze(data_aligned(plot_data_inds.left_trials_oops_inds,i,:));
    %     h=figure;
    %     subplot(1,2,1);
    %     imagesc(temp_plot_data_right_corr,[0 300]);
    %     colormap(flipud(hot));
    %     title('All correct right trials results.');
    %     set(gca,'XTick',x_tick,'XTickLabel',x_label);
        
    %     subplot(1,2,2);
    %     imagesc(temp_plot_data_right_erro,[0 300]);
    %     colormap(flipud(hot));
    %     title('All error right trials results.');
    %     set(gca,'XTick',x_tick,'XTickLabel',x_label);
        
    %     suptitle('Plot of all right trial results');
    %     saveas(h,['plot of ',session_date,' ROI',num2str(i),' result'],'png');
    %     close;
    % end
    cd ..;
    
    if isdir('.\left_miss_and_right_miss\')==0
        mkdir('.\left_miss_and_right_miss\');
    end
    cd('.\left_miss_and_right_miss\');
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.left_trials_miss_inds,plot_data_inds.right_trials_miss_inds,start_frame,frame_rate,{{'left_miss'},{'right_miss'},{session_date'}});
    cd ..;
    
    disp('All plots have been done successfully.');
elseif extra_choice == 1
    if isdir('.\left_and_right_plot\')==0
        mkdir('.\left_and_right_plot\');
    end
    cd('.\left_and_right_plot\');
    %use this function instead
    %trial_response_plot(data_aligned,inds_1,inds_2,session_describetion)
    %##############################################################################################
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.left_trials_inds,plot_data_inds.right_trials_inds,start_frame,frame_rate,{{'left'},{'right'},{session_date'}}); 
    cd ..;

elseif extra_choice == 2

    if isdir('.\left_corr_and_erro_plot\')==0
        mkdir('.\left_corr_and_erro_plot\');
    end
    cd('.\left_corr_and_erro_plot\');
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.left_trials_bingo_inds,plot_data_inds.left_trials_oops_inds,start_frame,frame_rate,{{'left_corr'},{'left_err'},{session_date'}});
    cd ..;

elseif extra_choice == 3
    if isdir('.\right_corr_and_erro_plot\')==0
        mkdir('.\right_corr_and_erro_plot\');
    end
    cd('.\right_corr_and_erro_plot\');
    trial_response_plot(data_aligned,stim_type_freq,plot_data_inds.right_trials_bingo_inds,plot_data_inds.right_trials_oops_inds,start_frame,frame_rate,{{'right_corr'},{'right_err'},{session_date'}});
    cd ..;
else
    error('Error choice select, quit analysis.');
end
    

% else
    % if isdir('.\select_plot\')==0
    %     mkdir('.\select_plot\');
    % end
    % cd('.\select_plot\');
    % for i=1:length(varargin)
    %     h=figure;
    %     temp_plot_data=squeeze(data_aligned(plot_data_inds.(cell2mat(varargin(i))),i,:));
    %     imagesc(temp_plot_data,[0 300]);
    %     colormap(flipud(hot));
    %     title(['plot of ',cell2mat(varargin(i))]);
    %     set(gca,'XTick',x_tick,'XTickLabel',x_label);
    %     saveas(h,['plot of ',cell2mat(varargin(i)),' ROI',num2str(i),' result'],'png');
    %     close;
    % end
% end

