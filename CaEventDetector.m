function events_time = CaEventDetector(trace, Threshold, DecayThresh,slope_span, slopeThresh)
% events_time = CaEventDetector(trace, Threshold, DecayThresh, slopeThresh, slope_span)
% % Event Detection
% thr_crit, threshold criteria, 1, 2, 3, or 4

% % - NX, 8/2009

events_time = [];
lm_dx = 5; % length of the piece for local maxima searching
if nargin<4
    slope_span = 7; % length of piece to get local slope, empiracally decided
end
slope=zeros(1,(length(trace)-slope_span));
for i=1:length(trace)
    if i+slope_span > length(trace)
        break
    end
    slope(i) = (trace(i+slope_span)-trace(i))/slope_span;
end
% slope_smth = smooth(slope,5,'moving');

% trace_raw = trace;
% trace = smooth(trace,3,'moving');
if nargin < 2
    SD = mad(trace(~isnan(trace))) * 1.4826;
    Threshold = 3 * SD; % sd; % 2*sd; %
    DecayThresh = SD;
end
Threshold2 = Threshold/2;
slope_SD = mad(slope)*1.4826;
if nargin< 5
    slopeThresh = 2 * slope_SD;
end

Threshold_secondary = Threshold/2;
% RiseThresh = DecayThresh;
% DecayPercent = 0.5/100;

if size(trace,1)==1
    trace = trace';
end

% find local maxima of slope, and then choose those exceeding the slopeThres
[slope_peaks, inds] = lmax_pw(slope',lm_dx);
slope_detector1 = inds(slope_peaks >= slope_SD);
slope_detector2 = inds(slope_peaks >= slope_SD*2);
slope_detector3 = inds(slope_peaks >= slope_SD*0.5);

count = 1; 
eventNum = 1;
while count < length(trace)-slope_span
    t1=[]; t2=[]; 
    criteria(1) = trace(count)> Threshold && ismember(count,slope_detector2);
    criteria(2) = trace(count+slope_span)> Threshold2 && ismember(count,slope_detector2);
     %any(slope(max(1,count-slope_span):count)>slopeThresh*0.7);
    criteria(3) = trace(count)> Threshold*1.5 && trace(count+1)> trace(count);% ismember(count,slope_detector3)&& trace(count+slope_span)> DecayThresh;
%     criteria(4) = criteria(1)*criteria(3) + criteria(2)*criteria(3);
    if sum(criteria) == true
        % Make sure the events start at rising phase
        t1 = count;
        t_thresh = count;
        if trace(t1)<= Threshold % if detection by slope criteria, step forward by slope_span before search for t2.
            count = count + slope_span;
        end
        % Search to the left of t1 and find the point as the onset of the event.
        % The search should not pass the end point of the previous event
        if t1 == 1, t1 = t1+1; end
        while trace(t1)>Threshold2 || (slope(t1)> 0 && trace(t1)>trace(t1-1)) 
            % reaching the end of the preceding event
            if eventNum >1 && t1<= events_time(eventNum-1, 2)
                break;
            end
%             if t1<=1
%                 break;
%             end
%             if  slope(t1)<=0 && trace(t1)< trace(t1-1)
%                 t1 = t1 + slope_span;
%                 break;
%             end
            t1 = t1 - 1;
            if t1<=1
                t1 = 1;
                break
            end
        end
        % Than make a correction to t1 so that it start at the rising phase
        while trace(t1+1) < trace(t1)
            t1 = t1 + 1;
        end
        if count < t1, count = t1; end;
        count = count+1;
         % Search to the right for the offset of the event
        while count < length(trace) - slope_span
            % Find the offset point of the event using DecayThresh
            if trace(count) < trace(count-1) % make sure the search is in decay phase
                % the criteria for offset: below decay threshold, or the
                % signal is rising rapidly in the next a few frames (e.g., 6 frames)
                if trace(count)<= DecayThresh && slope(count)>=0
                    t2 = count;
                    break
                elseif slope(count)>=slopeThresh/2 % && trace(count)<= max(trace(t1:count))/2 % max(Threshold_secondary, max(trace(t1:count))/2)% || count <= length(trace)-slope_span
                    % if the value already decrease to below half maximum,
                    % and tends to stop decreasing
                    t2 = count;
                    break
                elseif trace(count) >= Threshold && slope(count)>0
                    t2 = count;
                    break
                end
            end
            count = count+1;
            if count>=length(trace)-slope_span
                count = length(trace);
            end
            t2 = count;
        end
        % If the signal did not come back to half-maximum, consider this as
        % an incomplete event. Give up and jump out.
        if isempty(t2)%  || trace(t2)> max(trace)/2
            count = count+1;
            continue
        end;
        % Now find local maxima
        if trace(t1) == max(trace(t1:t2))
            % if the first value is the maximum
            lmval = trace(t1);
            ind = 1;
        elseif trace(t2) == max(trace(t1:t2))
            lmval = trace(t2);
            ind = length(t1:t2);
        else
            [lmval, ind] = lmax_pw(trace(t1:t2), lm_dx); % get local maxima.
        end;
        events_time(eventNum, :) = [t1 t2 t_thresh]; 
        eventNum = eventNum+1;
    else
        count = count+1;
    end
end

    
                