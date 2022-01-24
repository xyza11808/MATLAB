function [Lick_time_data,Lick_bias_side]=beha_lickTime_data(behavResults,end_point)
%this function use behavior analysis result as input and return a struct
%contains right and left lick times of each trial

Lick_time_data=struct('LickTimeLeft',[],'LickTimeRight',[],'LickNumLeft',[],'LickNumRight',[],'FirstLickTime',[0,0]); % First lick time indicates first lick time and side
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
        StimOnTime = double(behavResults.Time_stimOnset(n));
        
        Lick_time_data(n).LickTimeLeft=left_lickTime_double;
        Lick_time_data(n).LickTimeRight=right_lickTime_double;
        Lick_time_data(n).LickNumLeft=length(left_lickTime_double);
        Lick_time_data(n).LickNumRight=length(right_lickTime_double);
        Lick_time_data(n).FirstLickTime = [0,0];
        Lick_bias_side(n)=2;  %indicates no bias side
%         if isempty(left_lickTime_double) && isempty(right_lickTime_double)
%             Lick_bias_side(n)=2;  %indicates no bias side
%         end
        if isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if min(right_lickTime_double)<StimOnTime
                 Lick_bias_side(n)=1;  %indicates right bias side
            end
             % the active lick should be at least 50ms after stimulus onset
            FlickTimeInds = find(right_lickTime_double > (StimOnTime+50),1,'first');
            if ~isempty(FlickTimeInds)
                Lick_time_data(n).FirstLickTime = [right_lickTime_double(FlickTimeInds)-StimOnTime, 1];
            end
        end
        if ~isempty(left_lickTime_double) && isempty(right_lickTime_double)
            if min(left_lickTime_double)<StimOnTime
                 Lick_bias_side(n)=0;  %indicates left bias side
            end
            
            FlickTimeInds = find(left_lickTime_double > (StimOnTime+50),1,'first');
            if ~isempty(FlickTimeInds)
                Lick_time_data(n).FirstLickTime = [left_lickTime_double(FlickTimeInds)-StimOnTime, 0];
            end
        end
        if ~isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if sum(left_lickTime_double<StimOnTime) < sum(right_lickTime_double<StimOnTime)
                 Lick_bias_side(n)=1;
            elseif sum(left_lickTime_double<StimOnTime) == sum(right_lickTime_double<StimOnTime)
                if sum(left_lickTime_double<StimOnTime) ~= 0
                    if min(left_lickTime_double) < min(right_lickTime_double)
                        Lick_bias_side(n)=0; 
                    else
                        Lick_bias_side(n)=1;
                    end
                end
            else
                Lick_bias_side(n)=0;
            end
            LFlickTimeInds = find(left_lickTime_double > (StimOnTime+50),1,'first');
            RFlickTimeInds = find(right_lickTime_double > (StimOnTime+50),1,'first');
            if isempty(LFlickTimeInds) && ~isempty(RFlickTimeInds)
                Lick_time_data(n).FirstLickTime = [right_lickTime_double(RFlickTimeInds)-StimOnTime, 1];
            elseif ~isempty(LFlickTimeInds) && isempty(RFlickTimeInds)
                Lick_time_data(n).FirstLickTime = [left_lickTime_double(LFlickTimeInds)-StimOnTime, 0];
            elseif ~isempty(LFlickTimeInds) && ~isempty(RFlickTimeInds)
                leftRightFirstLickTime = [left_lickTime_double(LFlickTimeInds),right_lickTime_double(RFlickTimeInds)];
                [MinlickTime,MinlickInds] = min(leftRightFirstLickTime);
                Lick_time_data(n).FirstLickTime = [MinlickTime-StimOnTime,MinlickInds-1];
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
        StimOnTime = double(behavResults.Time_stimOnset(n));
        
        Lick_time_data(n).LickTimeLeft=left_lickTime_double;
        Lick_time_data(n).LickTimeRight=right_lickTime_double;
        Lick_time_data(n).LickNumLeft=length(left_lickTime_double);
        Lick_time_data(n).LickNumRight=length(right_lickTime_double);
        Lick_bias_side(n)=2;  %indicates no bias side
%         if isempty(left_lickTime_double) && isempty(right_lickTime_double)
%             Lick_bias_side(n)=2;  %indicates no bias side
%         end
        if isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if min(right_lickTime_double)<StimOnTime
                 Lick_bias_side(n)=1;  %indicates right bias side
            end
            FlickTimeInds = find(right_lickTime_double > (StimOnTime+50),1,'first');
            if ~isempty(FlickTimeInds)
                Lick_time_data(n).FirstLickTime = [right_lickTime_double(FlickTimeInds)-StimOnTime, 1];
            end
        end
        if ~isempty(left_lickTime_double) && isempty(right_lickTime_double)
            if min(left_lickTime_double)<StimOnTime
                 Lick_bias_side(n)=0;  %indicates left bias side
            end
            FlickTimeInds = find(left_lickTime_double > (StimOnTime+50),1,'first');
            if ~isempty(FlickTimeInds)
                Lick_time_data(n).FirstLickTime = [left_lickTime_double(FlickTimeInds)-StimOnTime, 0];
            end
        end
        if ~isempty(left_lickTime_double) && ~isempty(right_lickTime_double)
            if sum(left_lickTime_double<StimOnTime) < sum(right_lickTime_double<StimOnTime)
                 Lick_bias_side(n)=1;
            elseif sum(left_lickTime_double<StimOnTime) == sum(right_lickTime_double<StimOnTime)
                if sum(left_lickTime_double<StimOnTime) ~= 0
                    if min(left_lickTime_double) < min(right_lickTime_double)
                        Lick_bias_side(n)=0; 
                    else
                        Lick_bias_side(n)=1;
                    end
                end
            else
                Lick_bias_side(n)=0;
            end
            % first lick time 
            LFlickTimeInds = find(left_lickTime_double > (StimOnTime+50),1,'first');
            RFlickTimeInds = find(right_lickTime_double > (StimOnTime+50),1,'first');
            if isempty(LFlickTimeInds) && ~isempty(RFlickTimeInds)
                Lick_time_data(n).FirstLickTime = [right_lickTime_double(RFlickTimeInds), 1];
            elseif ~isempty(LFlickTimeInds) && isempty(RFlickTimeInds)
                Lick_time_data(n).FirstLickTime = [left_lickTime_double(LFlickTimeInds), 0];
            elseif ~isempty(LFlickTimeInds) && ~isempty(RFlickTimeInds)
                leftRightFirstLickTime = [left_lickTime_double(LFlickTimeInds),right_lickTime_double(RFlickTimeInds)];
                [MinlickTime,MinlickInds] = min(leftRightFirstLickTime);
                Lick_time_data(n).FirstLickTime = [MinlickTime-StimOnTime,MinlickInds-1];
            end
        end
    end
end

