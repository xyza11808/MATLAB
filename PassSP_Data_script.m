
close
cROI = 6;
ROI1Data = squeeze(f_percent_change(:,cROI,:));
ROI1Trace = reshape(ROI1Data',[],1);
figure;plot(ROI1Trace)
% f_percent_change = f_percent_change;
%%

nnspike = Fluo2SpikeConstrainOOpsi(f_percent_change,[],[],frame_rate,2);



%%
close
cROI = 40;
ROI1Data = squeeze(f_percent_change(:,cROI,:));
ROI1Trace = reshape(ROI1Data',[],1);

ROISPData = squeeze(nnspike(:,cROI,:));
ROISPTrace = reshape(ROISPData',[],1);
figure;
% hold on
plot(ROI1Trace,'k');
yyaxis right
plot(ROISPTrace,'r')

%%
[~,SortInds] = sort(SelectSArray);
figure;imagesc(ROISPData(SortInds,:))

%%
Time_Win = 0.3;
FrameWin = round(Time_Win * frame_rate);
OnsetFrame = frame_rate;
OffsetFrame = frame_rate+FrameWin;

OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
OffTrResp = mean(ROISPData(:,OffsetFrame+1:OffsetFrame+FrameWin),2);
RespMtx = [OnsetTrResp,OffTrResp];

figure;
imagesc(RespMtx(SortInds,:))
