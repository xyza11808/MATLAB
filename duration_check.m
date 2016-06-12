
LeftMeanData = MeanAlignData.LeftRawData;
RightMeanData = MeanAlignData.RightRawData;
AlignedFrame = TimeOnset;
nROIs = size(LeftMeanData,1);
fRate = FrameRate;

%%
nDuration = zeros(nROIs,2);  %first column for Left data duration. and the second column for Right data
nIsResp = zeros(nROIs,2);  
LeftHalfMaxInds = zeros(nROIs,2);
RightHalfMaxInds = zeros(nROIs,2);
TimeTrace = (1:size(LeftMeanData,2))/fRate;
AlignTime = AlignedFrame/fRate; 

% %%
for ROINum = 1 : nROIs
%     %%
    cLeftData = LeftMeanData(ROINum,:);
    LeftBaseData = mean(cLeftData(1:AlignedFrame));
    LeftRespMax = max(cLeftData((AlignedFrame+1):(AlignedFrame+floor(fRate*1.5))));
    
    cRightData = RightMeanData(ROINum,:);
    RightBaseData = mean(cRightData(1:AlignedFrame));
    RightRespMax = max(cRightData((AlignedFrame+1):(AlignedFrame+floor(fRate*1.5))));
    
%     %%
    if ((LeftRespMax > 2 * LeftBaseData) && (LeftRespMax > 10)) || (LeftRespMax > 80)
        nIsResp(ROINum,1) = 1; % Left trace significant
        [maxValue,MaxInds] = max(cLeftData((AlignedFrame+1):(AlignedFrame+floor(fRate*1.5))));
        HalfPeakV = maxValue/2;
        StartInds = find(cLeftData(1:(AlignedFrame+MaxInds)) < HalfPeakV,1,'last');
        if ~isempty(StartInds)
            EndInds = find(cLeftData((AlignedFrame+MaxInds):end) < HalfPeakV,1,'first');
            if isempty(EndInds)
                EndInds = length(cRightData);
                REndInds = EndInds;
            else
                REndInds = EndInds+AlignedFrame+MaxInds;
            end
            if AlignedFrame > StartInds
                StartInds = AlignedFrame;
            end

            LeftHalfMaxInds(ROINum,:) = [StartInds,REndInds];
            nDuration(ROINum,1) = REndInds - StartInds; %Left Trace duration

            if (nDuration(ROINum,1) < fRate) || (cLeftData(StartInds) > (cLeftData(REndInds)+5))
                LeftHalfMaxInds(ROINum,:) = [0,0];
                nDuration(ROINum,1) = 0;
                nIsResp(ROINum,1) = 0; 
            end
        else
             nIsResp(ROINum,1) = 0;
        end
    end
%     LeftInds = []
%     %%
    if ((RightRespMax > 2 * RightBaseData) && (RightRespMax > 10)) || (RightRespMax > 80)
        nIsResp(ROINum,2) = 1; % Right trace significant
        [maxValue,MaxInds] = max(cRightData((AlignedFrame+1):(AlignedFrame+floor(fRate*1.5))));
        HalfPeakV = maxValue/2;
        StartInds = find(cRightData(1:(AlignedFrame+MaxInds)) < HalfPeakV,1,'last');
        if ~isempty(StartInds)
            EndInds = find(cRightData((AlignedFrame+MaxInds):end) < HalfPeakV,1,'first');
            if isempty(EndInds)
                EndInds = length(cRightData);
                REndInds = EndInds;
            else
                REndInds = EndInds+AlignedFrame+MaxInds;
            end

            if AlignedFrame > StartInds
                StartInds = AlignedFrame;
            end

            RightHalfMaxInds(ROINum,:) = [StartInds,REndInds];
            nDuration(ROINum,2) = REndInds - StartInds; %Right trace duration

            if (nDuration(ROINum,2) < fRate) || (cRightData(StartInds) > (cRightData(REndInds)+5))
                RightHalfMaxInds(ROINum,:) = [0,0];
                nDuration(ROINum,2) = 0;
                nIsResp(ROINum,2) = 0;
            end
        else
            nIsResp(ROINum,2) = 0;
        end
    end
%     %%
    hhh = figure('position',[200 140 1350 900]);
    subplot(1,2,1)
    hold on
    plot(TimeTrace,cLeftData,'b');
    if nIsResp(ROINum,1)
     plot(TimeTrace(LeftHalfMaxInds(ROINum,:)),cLeftData(RightHalfMaxInds(ROINum,:)),'--k*','MarkerSize',12);
    end
    xlabel('Time(s)');
    ylabel('\DeltaF/F_0');
    title('Left Data');
    
    subplot(1,2,2)
    hold on
    plot(TimeTrace,cRightData,'r');
    if nIsResp(ROINum,2)
        plot(TimeTrace(RightHalfMaxInds(ROINum,:)),cRightData(RightHalfMaxInds(ROINum,:)),'--k*','MarkerSize',12);
    end
    xlabel('Time(s)');
    ylabel('\DeltaF/F_0');
    title('Right Data');
    
    suptitle(sprintf('ROI %d',ROINum));
%     %%
    waitforbuttonpress;
    close(hhh);
end

