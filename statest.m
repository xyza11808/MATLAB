function [StatResult,DataSelected]=statest(Data,EventsOn,frameRate,varargin)
%this function will be used for statistic analysis of given data to test
%whether there is an significant difference between given Events
%XIN Yu, Nov, 17, 2015
if nargin>3
    SelectRange = varargin{1};
else
    SelectRange = [1,1];
end

DataSize=size(Data);
if ndims(Data)>2 %#ok<ISMAT>
    disp('Three dimensional data input, taking the second dim as ROI number, performing following analysis.\n');
    MultiDData = 1;
    FrameLength = DataSize(3);
    TrialNum = DataSize(1);
    ROINum = DataSize(2);
else
    disp('Two dimnsional data input.\n');
    MultiDData = 0;
    FrameLength = DataSize(2);
    TrialNum = DataSize(1);
end

if length(unique(EventsOn)) == 1
    disp('Aligned data input!\n');
    DataAlign = 1;
else
    disp('The input data haven''t been aligned, doing data alignemnt first.\n');
    DataAlign = 0;
end

EventsOnFrame = EventsOn;
FrameRange = SelectRange * frameRate;

if ~DataAlign
    if min(EventsOnFrame) < (FrameRange(1)+1)
        FrameRange(1) = min(EventsOnFrame) -1;
        disp('Lower boundary out of matrix index, adjust to start index.\n');
    end
    if (max(EventsOnFrame)+FrameRange(2)) > FrameLength
        FrameRange(2) = FrameLength - max(EventsOnFrame) - 1;
        disp('Upper boundary out of matrix index, adjust to end index.\n');
    end
    
    if MultiDData
        DataSelected = zeros(TrialNum,ROINum,sum(FrameRange)+1);
        for n=1:TrialNum
            for m=1:ROINum
                DataSelected(n,m,:) = Data(n,m,(EventsOnFrame(n)-FrameRange(1)):(EventsOnFrame(n)+FrameRange(2)));
            end
        end
    else
        DataSelected = zeros(TrialNum,sum(FrameRange)+1);
        for n=1:TrialNum
            DataSelected(n,:) = Data(n,(EventsOnFrame(n)-FrameRange(1)):(EventsOnFrame(n)+FrameRange(2)));
        end
    end
else
    if EventsOnFrame < (FrameRange(1)+1)
        FrameRange(1) = EventsOnFrame - 1;
        disp('Lower boundary out of matrix index, adjust to start index.\n');
    end
    if (EventsOnFrame + FrameRange(2)) > FrameLength
        FrameRange(2) = FrameLength - EventsOnFrame - 1;
        disp('Upper boundary out of matrix index, adjust to maxium index.\n');
    end
    
    if MultiDData
        DataSelected = zeros(TrialNum,ROINum,sum(FrameRange));
        for n=1:TrialNum
            for m=1:ROINum
                DataSelected(n,m,:) = Data(n,m,(EventsOnFrame-FrameRange(1)):(EventsOnFrame+FrameRange(2)));
            end
        end
    else
        DataSelected = zeros(TrialNum,sum(FrameRange));
        for n=1:TrialNum
            DataSelected(n,:) = Data(n,(EventsOnFrame-FrameRange(1)):(EventsOnFrame+FrameRange(2)));
        end
    end
end

NewEventsOnFrame = FrameRange(1);
StatResult=struct('H',[],'StatSummary',[],'DataSummary',[]);

if MultiDData
    for n=1:ROINum
        tempData = squeeze(DataSelected(:,n,:));
        SingleROIMad = mad(tempData(:));
        PreEventData = tempData(:,1:NewEventsOnFrame);
        PostEventData = tempData(:,NewEventsOnFrame:end);
        PreEventDataMean = mean(PreEventData,2);
        PostEventDataMean = mean(PostEventData,2);
        TimeMeanTrace = mean(tempData);
        [h,p,ci,status]=ttest2(PreEventDataMean,PostEventDataMean,'Tail','left','Alpha',0.01,'Vartype','unequal');
        save_form=table(h,p,{ci},{status});
        StatResult(n).StatSummary = save_form;
        DataSum=[mean(TimeMeanTrace(1:NewEventsOnFrame)),mean(TimeMeanTrace(NewEventsOnFrame:end)),...
            std(TimeMeanTrace(1:NewEventsOnFrame)),std(TimeMeanTrace(NewEventsOnFrame:end)),SingleROIMad];
        StatResult(n).DataSummary = DataSum;
        StatResult(n).H = 0;
        if h
            if ((DataSum(2)-DataSum(4)) > (DataSum(1)+DataSum(3)))  && (DataSum(2) > SingleROIMad)
                if TimeMeanTrace(NewEventsOnFrame) < (max(TimeMeanTrace)/2)
                    StatResult(n).H = 1;
                end
            end
        end
    end
else
    tempData = DataSelected;
    SingleROIMad = mad(tempData(:));
    PreEventData = tempData(:,1:NewEventsOnFrame);
    PostEventData = tempData(:,NewEventsOnFrame:end);
    PreEventDataMean = mean(PreEventData,2);
    PostEventDataMean = mean(PostEventData,2);
    TimeMeanTrace = mean(tempData);
    [h,p,ci,status]=ttest2(PreEventDataMean,PostEventDataMean,'Tail','left','Alpha',0.01,'Vartype','unequal');
    save_form=table(h,p,{ci},{status});
    StatResult.StatSummary = save_form;
    DataSum=[mean(TimeMeanTrace(1:NewEventsOnFrame)),mean(TimeMeanTrace(NewEventsOnFrame:end)),...
        std(TimeMeanTrace(1:NewEventsOnFrame)),std(TimeMeanTrace(NewEventsOnFrame:end)),SingleROIMad];
    StatResult.DataSummary = DataSum;
     StatResult(n).H = 0;
    if h
        if ((DataSum(2)-DataSum(4)) > (DataSum(1)+DataSum(3)))  && (DataSum(2) > SingleROIMad)
            if TimeMeanTrace(NewEventsOnFrame) < (max(TimeMeanTrace)/2)
                StatResult.H = 1;
            end
        end
    end
end