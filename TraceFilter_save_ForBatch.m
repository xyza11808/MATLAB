
nROIs = length(ROIPeakDataAll);
ROIEventTypeAll = cell(nROIs,1);
ROIEventType_IndexAll = cell(nROIs,1);
for cROI = 1 : nROIs
    cROIEventData = ROIPeakDataAll{cROI};
    if isempty(cROIEventData)
        continue;
    end
    %
    nROIEvents = numel(cROIEventData.PeakIndex);
    cROITrace = DeltaFROIData(cROI,:);
    FiltTrace1 = filtfilt(cDes,cROITrace); % filter for plateau response
    FiltTrace2 = filtfilt(cDesNew,cROITrace); % filter for peak response
    cROIeventTypeInds = zeros(nROIEvents,1);
    cROIeventType_Index = zeros(nROIEvents,2);
    %
    for cEvent = 1 : nROIEvents
        cEventIndex = cROIEventData.PeakIndexRange(cEvent,:);
        cEvent_PlaFilt_Trace = FiltTrace1(cEventIndex(1):cEventIndex(2));
        cEvent_PeakFilt_Trace = FiltTrace2(cEventIndex(1):cEventIndex(2));
        
        if diff(cEventIndex) <= 30  % events duration should larger than 30 seconds for multipeak or plateau
            if diff(cEventIndex) <= 15
                 cROIeventTypeInds(cEvent) = 1;
                 cROIeventType_Index(cEvent,:) = cEventIndex;
            else
                LowPeakThres = std(FiltTrace2); % 2 time std used as peak threshold
                % check whether multiple peak exists
                [LowPks,LowLocs,LowWid] = findpeaks(cEvent_PeakFilt_Trace,'MinPeakHeight',LowPeakThres,...
                    'MinPeakDistance',5);
                if length(LowLocs) < 2 % less than one peak exists
                    cROIeventTypeInds(cEvent) = 1;
                    cROIeventType_Index(cEvent,:) = cEventIndex;
                else
                    cROIeventTypeInds(cEvent) = -12; % should be 2 in final version
                    cROIeventType_Index(cEvent,:) = cEventIndex;
                end
                clearvars LowPeakThres LowPks LowLocs LowWid
            end
        else
            % check peak value duration for plateau
            [Pla_Event_Peak, Pla_Event_PeakIndex] = max(cEvent_PlaFilt_Trace);
            Pla_DurThres = Pla_Event_Peak * 0.65; 
            StartInds = find(cEvent_PlaFilt_Trace(1:Pla_Event_PeakIndex) < Pla_DurThres,1,'last');
            if isempty(StartInds) %all values before peak was larger than thres
                StartInds = 1;
            else
                StartInds = StartInds + 1;
            end
            cRealStart_inds = StartInds + cEventIndex(1) - 1;
            
            EndInds = find(cEvent_PlaFilt_Trace((1+Pla_Event_PeakIndex):end) < Pla_DurThres,1,'first');
            if isempty(EndInds) %all values after peak was larger than thres
                EndInds = numel(cEvent_PlaFilt_Trace) - Pla_Event_PeakIndex;
            else
                EndInds = EndInds - 1;
            end
            cRealEnd_inds = cEventIndex(1) - 1 + EndInds + Pla_Event_PeakIndex;
            
            %
            if (cRealEnd_inds - cRealStart_inds) > 40 % larger duration will be classified as plateau directly
%                 [ccStartInds,ccEndInds] = PeakScaleFind(cEvent_PlaFilt_Trace,Pla_Event_PeakIndex,Pla_Event_Peak * 0.55);
                cROIeventTypeInds(cEvent) = 3;
%                 cROIeventType_Index(cEvent,:) = [ccRealStart_inds,ccRealEnd_inds]+cEventIndex(1)-1;
                cROIeventType_Index(cEvent,:) = cEventIndex;
%                 continue;
            else % the plateau duration is not longer enough, checking for peaks
                PeakThres = std(FiltTrace2)*2; % 2 time std used as peak threshold
                BaselineValue = mean(FiltTrace2); % baseline level for peak position consideration
                [Pks,Locs,Wid] = findpeaks(cEvent_PeakFilt_Trace,'MinPeakHeight',PeakThres,...
                    'MinPeakDistance',5);
                if isempty(Locs) % no significant peak value exists
                    LowPeakThres = std(FiltTrace2);
                    [LowPks,LowLocs,LowWid] = findpeaks(cEvent_PeakFilt_Trace,'MinPeakHeight',LowPeakThres,...
                    'MinPeakDistance',5);
                    if isempty(LowLocs) || length(LowLocs) == 1
                        cROIeventTypeInds(cEvent) = 1;
                        cROIeventType_Index(cEvent,:) = cEventIndex;
                    else
                        cROIeventTypeInds(cEvent) = 42; % should be 2 in final version
                        cROIeventType_Index(cEvent,:) = cEventIndex;
                    end
                    clearvars LowPeakThres LowPks LowLocs LowWid BaselineValue
                elseif numel(Locs) > 1 % possible MultiPeak Data
                    [LowPks,LowLocs,LowWid] = findpeaks(cEvent_PeakFilt_Trace,'MinPeakHeight',std(FiltTrace2),...
                    'MinPeakDistance',5);
                    [NegPks,NegLocs,NegWid] = findpeaks(-cEvent_PeakFilt_Trace(min(LowLocs):max(LowLocs)),...
                        'MinPeakHeight',std(FiltTrace2)*2,'MinPeakDistance',5);
                    
                    if length(LowLocs) > numel(Locs) && isempty(NegLocs)% more possiblely be a plateau events
                        cROIeventTypeInds(cEvent) = 3;
                        cROIeventType_Index(cEvent,:) = cEventIndex;
                    else
                        [InitStartInds,~] = PeakScaleFind(cEvent_PeakFilt_Trace,Locs(1),BaselineValue);
                        [~,EndStartInds] = PeakScaleFind(cEvent_PeakFilt_Trace,Locs(end),BaselineValue);

                        cROIeventTypeInds(cEvent) = 2;
                        cROIeventType_Index(cEvent,:) = [InitStartInds,EndStartInds]+cEventIndex(1)-1;
                    end
                else
                    LowPeakThres = std(FiltTrace2);
                    [LowPks,LowLocs,LowWid] = findpeaks(cEvent_PeakFilt_Trace,'MinPeakHeight',LowPeakThres,...
                    'MinPeakDistance',5);
                    % check whether only one peak was exists within events
                    
                    if diff(cEventIndex) > 35 && length(LowLocs) > 1
                        cROIeventTypeInds(cEvent) = 2;
%                         [csStartInds,csEndInds] = PeakScaleFind(cEvent_PlaFilt_Trace,Pla_Event_PeakIndex,Pla_Event_Peak * 0.55);
%                         cROIeventType_Index(cEvent,:) = [csStartInds,csEndInds]+cEventIndex(1)-1;
                        cROIeventType_Index(cEvent,:) = cEventIndex;
                    else
                        [cStartInds,cEndInds] = PeakScaleFind(cEvent_PeakFilt_Trace,Locs,BaselineValue);
                        cROIeventTypeInds(cEvent) = 1;
                        cROIeventType_Index(cEvent,:) = [cStartInds,cEndInds]+cEventIndex(1)-1;
                    end
                    clearvars LowPeakThres LowPks LowLocs LowWid BaselineValue
                end
            end
        end
    end
    %
    ROIEventTypeAll{cROI} = cROIeventTypeInds;
    ROIEventType_IndexAll{cROI} = cROIeventType_Index;
    
end
save EventTypeSavage.mat ROIEventTypeAll ROIEventType_IndexAll -v7.3
