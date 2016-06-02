%%
if ~isdir('./ROC_result/')
    mkdir('./ROC_result/');
end
cd('./ROC_result/');
TrialType=behavResults.Trial_Type;
mean_data=mean(data_aligned(:,:,(start_frame:(start_frame+frame_rate))),3);
for n=1:size(mean_data,2)
    test_data=[squeeze(mean_data(:,n)),TrialType'];
    rocOnline(test_data);
    saveas(gcf,['ROC result for ROI' num2str(n)],'png');
    close(gcf);
end
cd ..;

%%
if ~isdir('./trace_result/')
    mkdir('./trace_result/');
end
cd('./trace_result/');
TraceLevel=zeros(size(data_aligned,1),size(data_aligned,2),4);
for m=1:size(data_aligned,2)
    for k=1:size(data_aligned,1)
        single_trace=squeeze(data_aligned(k,m,:));
        TraceLevel(k,m,1)=mean(single_trace);
        TraceLevel(k,m,2)=median(single_trace);
        TraceLevel(k,m,3)=std(single_trace);
        TraceLevel(k,m,4)=mad(single_trace);
    end
    h=figure;
    subplot(2,2,1)
    hist(reshape(TraceLevel(:,m,1),[],1));
    mean_value=mean(reshape(TraceLevel(:,m,1),[],1));
    title(sprintf('Mean value(mean=%5.3f)',mean_value));
    
    subplot(2,2,2)
    hist(reshape(TraceLevel(:,m,2),[],1));
    mean_value=mean(reshape(TraceLevel(:,m,2),[],1));
    title(sprintf('Median value(mean=%5.3f)',mean_value));
    
    subplot(2,2,3)
    hist(reshape(TraceLevel(:,m,3),[],1));
    mean_value=mean(reshape(TraceLevel(:,m,3),[],1));
    title(sprintf('Std value(mean=%5.3f)',mean_value));
    
    subplot(2,2,4)
    hist(reshape(TraceLevel(:,m,4),[],1));
    mean_value=mean(reshape(TraceLevel(:,m,4),[],1));
    title(sprintf('Mad value(mean=%5.3f)',mean_value));
    suptitle(['trace result for ROI' num2str(m)]);
    saveas(h,['trace result distribution for ROI' num2str(m)],'png');
    close(h);
end
cd ..;