function AllDataExtraTest(dataAll,EventsTime,FrameRate,trialtype,varargin)
%this function will be used for extracting data from given data all and
%return the aligned data for ttest analysis
%variable EventsTime must be a columnwise structure

TimeSize=size(EventsTime);
DataSize=size(dataAll);

EventsFrame=EventsTime*FrameRate;

FrameRange=zeros(TimeSize(2),2);
SelectData=cell(TimeSize(2),1);
for n=1:TimeSize(2)
%     temp_range_str=inputdlg('Please input the time scale for extration (s)','Please input the scale range');
    temp_range_str=inputdlg({input_description},'Please input the scale range');
    temp_range_num=str2num(temp_range_str{1}); %#ok<*ST2NM>
    FrameRange(n,:)=floor(temp_range_num*FrameRate);
    if min(EventsFrame(:,n)) < (FrameRange(n,1)+1)
        disp('Front index range out of scale, adjust to start frame.\n');
        FrameRange(n,1) = min(EventsFrame(:,n)) - 1;
    end
    if (max(EventsFrame(:,n)) + FrameRange(n,2)) >= DataSize(3)
        disp('End index range out of scale, adjust to end frame.\n');
        FrameRange(n,2) = DataSize(3) - max(EventsFrame(:,n)) - 1;
    end
%     TempData=
    for m=1:DataSize(1)
        TempData=DataSize(:,:,(EventsTime(m,n)-FrameRange(n,1)):(EventsTime(m,n)+FrameRange(n,2)));
    end
    SelectData(n)={TempData};
end
save SelectDataAll.mat SelectData trialtype -v7.3

StimTypes=unique(trialtype);  %using frequency as trial types
SigRespTest=zeros(DataSize(2),TimeSize(2),length(StimTypes));
ROITuning=zeros(DataSize(2),TimeSize(2));
for m=1:TimeSize(2)
    SingleEventsData=SelectData{m};
    for k=1:DataSize(2)
        SingleROIEventsData=squeeze(SingleEventsData(:,k,:));
        SingleTuning=zeros(length(StimTypes));
        for n=1:length(StimTypes)
            TypeResp=sprintf('Freq%d',StimTypes(n));
            FreqRespResult(k,m).(TypeResp).Freq=StimTypes(n);
            TypeRespInds=trialtype==StimTypes(n);
            TempData=SingleROIEventsData(TypeRespInds,:);
            TTestDataPre=mean(TempData(:,1:FrameRange(m,1)),2);
            TTestDataPost=mean(TempData(:,(FrameRange(m,1)+1):end),2);
            TempDataMeanTrace=mean(TempData);
            [h,p,ci,stats]=ttest2(TTestDataPre,TTestDataPost,'Tail','left','Alpha',0.01);
            if h
                if TempDataMeanTrace(FrameRange(m,1)) < (max(TempDataMeanTrace)/2)
                    H=1;
                else
                    H=0;
                end
            end
            FreqRespResult(k,m).(TypeResp).H = H;
            FreqRespResult(k,m).(TypeResp).p = p;
            FreqRespResult(k,m).(TypeResp).ci = ci;
            FreqRespResult(k,m).(TypeResp).stats = stats;
            SigRespTest(k,m,n) = H;
            SingleTuning(n) = H;
        end
        
        %performing two types of classification
        %#######ROIs shows only one response to one freq will be considered as
        %single response cluster, will be used for single tuning plot
        %#######ROIs shows more than two response to the same side will be
        %considered as trial type tuning response
        %ROIs shows no response at all will be considered as non-responsive
        %ROIs, single response to both side will be considered as both
        %responsive
        if sum(SingleTuning) == 0
            ROITuning(k,m)=0; %zeros value means no tuning selectivity
        elseif sum(SingleTuning) == 1
            ROITuning(k,m) = StimTypes(logical(SingleTuning)); %single tuning result will be classified as frequency value
        elseif sum(SingleTuning)>1
            if sum(SingleTuning(1:length(StimTypes)/2)) > 1  &&  sum(SingleTuning((1+length(StimTypes)/2):end)) < 1
                ROITuning(k,m) = 0;   %if multiple tuning exist in one side, value will be considered as tuning of trial side
            elseif sum(SingleTuning(1:length(StimTypes)/2)) < 1  &&  sum(SingleTuning((1+length(StimTypes)/2):end)) > 1
                ROITuning(k,m) = 1;   %if multiple tuning exist in one side, value will be considered as tuning of trial side
            else
                ROITuning(k,m) = 2;  %value 2 means neurons shows tuning response to both side of the stimulus
            end
        end
        
    end
end
save TuningResultRand.mat FreqRespResult SigRespTest ROITuning -v7.3
