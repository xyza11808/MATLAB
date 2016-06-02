function onset_delay_dis(base_data,frame_rate,type,varargin)
%base_data will be the data form comes from flu change according to
%baseline activity of each trial
%two types of onset time analysis form are provided
%one is used for onset time analysis according to apecific time event
%another is according to the peak form it self
%differnt analysis protocol receies different input from varargin

if strcmpi(type,'event')
    event_point=varargin{1};
    disp('Doing onset time analysis accodong to the apecific time event.\n');
    event_dis_struct=struct('Stim_Onset_Guess',[],'Reward_Onset_guess',[],'Mean_Stim_Onset',[],'Mean_Reward_onset',[], ...
        'Mode_Stim_Onset',[],'Mode_Reward_Onset',[]);
elseif strcmpi(type,'peak')
    disp('Doing onset time analysis according to peak form.\n');
    event_dis_struct=struct('Peak_Num',[],'Peak_Time',[]);
end

data_size=size(base_data);
data_BP=base_data;
popu_std=std(reshape(base_data,[],1));

if strcmpi(type,'event')
    event_point=floor((double(event_point)/1000)*frame_rate);
    time_scale=input('Please input the time scale that will be used for analysis of event onset analysis.\n','s');
    time_scale=str2num(time_scale);
    if isempty(time_scale)
        disp('No data input, using default value [0 2.5] for analysis.\n');
        time_scale=[0,2.5];
        time_scale=floor(time_scale*frame_rate);
        time_scale(1)=1;
    else
        time_scale=floor(time_scale*frame_rate);
        if time_scale(1)==0
            time_scale(1)=1;
        end
    end
    
    % if (max(event_point(:,2))+time_scale(2)))>data_size(3)
    % if (max(event_point(:,2))+time_scale(1)))>data_size(3)
    % error('Error time scale selected, reward event adds with time scale out of index range.\n');
    % else
    % time_scale(2)=data_size(3)-max(event_point(:,2));
    % end
    % end
    overflow_inds=find((event_point(:,2)+time_scale(2))>data_size(3));
    
    onset_event=event_point(:,1);
    alignment_onset_data=zeros(data_size(1),data_size(2),(time_scale(2)-time_scale(1)+1));
    onset_time_guess=zeros(data_size(1),data_size(2));
    for n=1:data_size(1)
        alignment_onset_data(n,:,:)=base_data(n,:,(onset_event(n)+time_scale(1)):(onset_event(n)+time_scale(2)));
        for m=1:data_size(2)
            single_align_trace=alignment_onset_data(n,m,:);
            single_align_trace=smooth(single_align_trace);
            [local_maxium,max_inds]=max(single_align_trace);
            if local_maxium<(3*popu_std)
                continue;
            end
            half_peak_inds=find(single_align_trace>(local_maxium/2), 1 );
            onset_assum_inds=max_inds-(2*(max_inds-half_peak_inds));
            onset_time_guess(n,m)=floor((double(onset_assum_inds-(onset_event(n)+time_scale(1)))/frame_rate)*1000); %conert the onset time into time by ms
        end
    end
    
    base_data(overflow_inds,:,:)=[];
    data_size_re=size(base_data);
    reward_event=event_point(:,2);
    reward_event(overflow_inds)=[];
    align_reward_data=zeros(data_size_re(1),data_size_re(2),(time_scale(2)-time_scale(1)+1));
    reward_time_guess=zeros(data_size_re(1),data_size_re(2));
    if length(reward_event)<20
        warning('Most of the reward time seems too late for analysis, the analysis result might not accurate.\n');
    end
    for n=1:data_size_re(1)
        align_reward_data(n,:,:)=base_data(n,:,(reward_event(n)+time_scale(1)):(reward_event(n)+time_scale(2)));
        for m=1:data_size_re(2)
            single_alignment_trace=align_reward_data(n,m,:);
            single_alignment_trace=smooth(single_alignment_trace);
            [local_maxium,max_inds]=max(single_alignment_trace);
            if local_maxium<(3*popu_std)
                continue;
            end
            half_peak_inds=find(single_alignment_trace>(local_maxium/2), 1 );
            reward_assum_inds=max_inds-(2*(max_inds-half_peak_inds));
            reward_time_guess(n,m)=floor((double(reward_assum_inds-(reward_event(n)+time_scale(1)))/frame_rate)*1000);
        end
    end
    
    if ~isdir('.\stim_onset_dis\')
        mkdir('.\stim_onset_dis\');
    end
    if ~isdir('.\reward_onset_dis\')
        mkdir('.\reward_onset_dis\');
    end
    
    %start stim onset time distribution analysis
    cd('.\stim_onset_dis\');
    for n=1:data_size(2)
        event_dis_struct(n).Stim_Onset_Guess=onset_time_guess(:,n);
        if sum(onset_time_guess(:,n)>0)<10   %this critiria  can be adjusted according to different requiremrnt
            warning(['Too few significant trials with response onset, quit analysis for ROI' num2str(n)]);
            continue;
        end
        h_stim=figure;
        [nelements,centers]=hist(onset_time_guess(:,n)); %with default number of 10 bins
        bar(centers,nelements,'g','EdgeColor',[1,0,1]);
        for k=1:length(nelements)
            text(centers(k),nelements(k)*1.01,sprintf('%d',nelements(k)));
        end
        title(['Stim resp onset time distribution of ROI' num2str(n)]);
        event_dis_struct(n).Mean_Stim_Onset=mean(onset_time_guess(:,n));
        event_dis_struct(n).Mode_Stim_Onset=mode(onset_time_guess(:,n));
        saveas(h_stim,['Onset_dis_of_ROI' num2str(n)],'png');
        close;
    end
    cd ..;
    
    %start reward onset time dis analysis
    cd('.\reward_onset_dis\');
    for n=1:data_size(2)
        event_dis_struct(n).Reward_Onset_Guess=reward_time_guess(:,n);
        if sum(reward_time_guess(:,n)>0)<10   %this critiria  can be adjusted according to different requiremrnt
            warning(['Too few significant trials with response onset, quit analysis for ROI' num2str(n)]);
            continue;
        end
        h_stim=figure;
        [nelements,centers]=hist(reward_time_guess(:,n));
         bar(centers,nelements,'g','EdgeColor',[1,0,1]);
         for k=1:length(nelements)
            text(centers(k),nelements(k)*1.01,sprintf('%d',nelements(k)));
         end
        title(['Reward resp onset time distribution of ROI' num2str(n)]);
        event_dis_struct(n).Mean_Reward_Onset=mean(reward_time_guess(:,n));
        event_dis_struct(n).Mode_Reward_Onset=mode(reward_time_guess(:,n));
        saveas(h_stim,['Onset_dis_of_ROI' num2str(n)],'png');
        close;
    end
    cd ..;
    
    save onset_dis_result.mat event_dis_struct -v7.3
elseif strcmpi(type,'peak')
    if ~isdir('.\peak_time_dis\')
        mkdir('.\peak_time_dis\');
    end
    cd('.\peak_time_dis\');
    for n=1:data_size(2)
        % single_ROI_data=squeeze(base_line(:,n,:));
        for m=1:data_size(1)
            smooth_data=smooth(base_data(m,n,:));
            [peak_value,peak_locs]=findpeaks(smooth_data);
            peak_locs(peak_value<(3*popu_std))=[];
            if isempty(peak_locs)
                warning('No significant response detected, go to next trial.\n');
                event_dis_struct(m,n).Peak_Num=0;
                event_dis_struct(m,n).Peak_Time=0;
            else
                event_dis_struct(m,n).Peak_Num=length(peak_locs);
                peak_locs=(double(peak_locs)/1000);
                event_dis_struct(m,n).Peak_Time=peak_locs;
            end
        end
    end
    cd ..;
end