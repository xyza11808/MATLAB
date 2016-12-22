function [Lick_time_data,Lick_bias_side]=beha_lickTime_data(behavResults,end_point)
%this function use behavior analysis result as input and return a struct
%contains right and left lick times of each trial

Lick_time_data=struct('LickTimeLeft',[],'LickTimeRight',[],'LickNumLeft',[],'LickNumRight',[]);
trial_num=length(behavResults.Time_stimOnset);
Lick_bias_side=zeros(trial_num,1);
if iscell(behavResults.Action_lickTimeLeft(1))
%     lick_time_len_L=cellfun(@length,behavResults.Action_numLickLeft);
%     lick_time_len_R=cellfun(@length,behavResults.Action_numLickLeft);
    %     left_lick_length=max(lick_time_len_L);
    %     right_lick_length=max(lick_time_len_R);
    %     lick_time_left=zeros(trial_num,left_lick_length);
    %     lick_time_right=zeros(trial_num,right_lick_length);
    %     for n=1:trial_num
    %         temp_lick_time_L=behavResults.Action_numLickLeft{n};
    %         lick_time_left(n,:)=[lick_time_left ]
    for n=1:trial_num
        lick_time_str_left=strrep(behavResults.Action_lickTimeLeft{n},'|',' ');
        lick_time_str_R=strrep(behavResults.Action_lickTimeRight{n},'|',' ');
        left_lickTime_double=str2num(lick_time_str_left);
        right_lickTime_double=str2num(lick_time_str_R);
        left_lickTime_double(left_lickTime_double>=(end_point*1000))=[];
        right_lickTime_double(right_lickTime_double>=(end_point*1000))=[];
        
        Lick_time_data(n).LickTimeLeft=left_lickTime_double;
        Lick_time_data(n).LickTimeRight=right_lickTime_double;
        Lick_time_data(n).LickNumLeft=length(left_lickTime_double);
        Lick_time_data(n).LickNumRight=length(right_lickTime_double);
        Lick_bias_side(n)=2;  %indicates no bias side
%         if isempty(left_lickTime_double) && isempty(right_lickTime_double)
%             Lick_bias_side(n)=2;  %indicates no bias side
%         end
        if isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if min(right_lickTime_double)<behavResults.Time_stimOnset(n)
                 Lick_bias_side(n)=1;  %indicates right bias side
            end
        end
        if ~isempty(left_lickTime_double) && isempty(right_lickTime_double)
            if min(left_lickTime_double)<behavResults.Time_stimOnset(n)
                 Lick_bias_side(n)=0;  %indicates left bias side
            end
        end
        if ~isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if sum(left_lickTime_double<behavResults.Time_stimOnset(n)) < sum(right_lickTime_double<behavResults.Time_stimOnset(n))
                 Lick_bias_side(n)=1;
            elseif sum(left_lickTime_double<behavResults.Time_stimOnset(n)) == sum(right_lickTime_double<behavResults.Time_stimOnset(n))
                if min(left_lickTime_double) < min(right_lickTime_double)
                    Lick_bias_side(n)=0; 
                else
                    Lick_bias_side(n)=1;
                end
            else
                Lick_bias_side(n)=0;
            end
        end
    end
else
    
    for n=1:trial_num
        %     left_lickTime_cell=strsplit(behavResults.Action_lickTimeLeft(n,:),'|');
        %     right_lickTime_cell=strsplit(behavResults.Action_lickTimeRight(n,:),'|');
        %     left_lickTime_double=cell_to_double(left_lickTime_cell);
        %     right_lickTime_double=cell_to_double(right_lickTime_cell);
        
        left_lickTime_cell=strrep(behavResults.Action_lickTimeLeft(n,:),'|',' ');
        right_lickTime_cell=strrep(behavResults.Action_lickTimeRight(n,:),'|',' ');
        left_lickTime_double=str2num(left_lickTime_cell);
        right_lickTime_double=str2num(right_lickTime_cell);
        left_lickTime_double(left_lickTime_double>=(end_point*1000))=[];
        right_lickTime_double(right_lickTime_double>=(end_point*1000))=[];
        
        Lick_time_data(n).LickTimeLeft=left_lickTime_double;
        Lick_time_data(n).LickTimeRight=right_lickTime_double;
        Lick_time_data(n).LickNumLeft=length(left_lickTime_double);
        Lick_time_data(n).LickNumRight=length(right_lickTime_double);
        Lick_bias_side(n)=2;  %indicates no bias side
%         if isempty(left_lickTime_double) && isempty(right_lickTime_double)
%             Lick_bias_side(n)=2;  %indicates no bias side
%         end
        if isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if min(right_lickTime_double)<behavResults.Time_stimOnset(n)
                 Lick_bias_side(n)=1;  %indicates right bias side
            end
        end
        if ~isempty(left_lickTime_double) && isempty(right_lickTime_double)
            if min(left_lickTime_double)<behavResults.Time_stimOnset(n)
                 Lick_bias_side(n)=0;  %indicates left bias side
            end
        end
        if ~isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if sum(left_lickTime_double<behavResults.Time_stimOnset(n)) < sum(right_lickTime_double<behavResults.Time_stimOnset(n))
                 Lick_bias_side(n)=1;
            elseif sum(left_lickTime_double<behavResults.Time_stimOnset(n)) == sum(right_lickTime_double<behavResults.Time_stimOnset(n))
                if min(left_lickTime_double) < min(right_lickTime_double)
                    Lick_bias_side(n)=0; 
                else
                    Lick_bias_side(n)=1;
                end
            else
                Lick_bias_side(n)=0;
            end
        end
    end
end

