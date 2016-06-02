%%
%if there are some trials need to be excluded, run this section
if ~isempty(ExcludeInds)
    behavResults(ExcludeInds)=[];
    behavSettings(ExcludeInds)=[];
    CaTrials(ExcludeInds)=[];
end

%%

roiNo = 14; 

trNo = 81;
close all;
ts = (1: CaTrials(1).nFrames).*CaTrials(1).FrameTime/1000;
frame_rate = floor(1000/CaTrials(1).FrameTime);
f =  f_raw{roiNo}(trNo,:);
t_stimOn = double(behavResults.Time_stimOnset(trNo))/1000;
t_answer = double(behavResults.Time_answer(trNo))/1000;
trType_strs = {'Left', 'Right'}; choiceStrs = {'Correct','Error', 'Miss'}; 
trTypeStr = trType_strs{behavResults.Trial_Type(trNo) +1};

if behavResults.Trial_Type(trNo) == behavResults.Action_choice(trNo)
    choiceInd = 1;
elseif behavResults.Action_choice(trNo) == 2
    choiceInd = 3;
else
    choiceInd = 2;
end

choiceStr = choiceStrs{choiceInd};
% close;
figure; hold on;
h_ann = annotation('textbox',[.6 .7 .2 .15]);
set(h_ann, 'String', sprintf('Freq = %d\n%s\n%s',behavResults.Stim_toneFreq(trNo),trTypeStr,choiceStr));
% if ishandle(h_ann), delete(h_ann); end;
yl = [50 301];
patch([t_stimOn, t_stimOn, t_stimOn+0.3, t_stimOn+0.3], [yl(1), yl(2), yl(2),yl(1)],  [.7 .7 .7]);
line([t_answer t_answer], [yl(1) yl(2)], 'Color', 'r');
plot(ts, f);
%
f_fit=fit(ts',f','gauss3');
figure;
plot(f_fit,ts,f);
hold on
line([f_fit.b1 f_fit.b1], [yl(1) yl(2)], 'Color', 'g');
line([f_fit.b2 f_fit.b2], [yl(1) yl(2)], 'Color', 'c');
line([f_fit.b3 f_fit.b3], [yl(1) yl(2)], 'Color', 'y');
xlim([0 9])
%
% delta=std(f);
% [maxtab, ~]=peakdet(smooth(f), delta);
% scatter(maxtab(:,1)/frame_rate,maxtab(:,2),36,'r','fill');


%
% close;

% line([t_stimOn t_stimOn], [yl(1) yl(2)], 'Color', 'r');

%%

nTrials = length(CaTrials);

for trNo = 1:length(CaTrials)
    t_stimOn(trNo) = double(behavResults.Time_stimOnset(trNo))/1000;
end

blockSize = 40;
nBlocks = ceil(nTrials/blockSize);
for blockNo = 1: nBlocks
f = [];
for i = blockSize*(blockNo-1) + 1 : min(blockSize*(blockNo), length(CaTrials))
% for i = 1 : length(CaTrials)
    inds = find(ts<t_stimOn(i));
    f = [f f_raw{roiNo}(i, inds)];
end
[n, x] = hist(f,50);
f0(blockNo) = min(x(n==max(n)));
end

% figure; hold on;
dff = zeros(nTrials, length(ts));
for blockNo = 1:nBlocks
    
    for i = blockSize*(blockNo-1) + 1 :  min(blockSize*(blockNo), length(CaTrials))
        %    plot(ts, f_raw{roiNo}(i, :));
        dff_temp = (f_raw{roiNo}(i, :) - f0(blockNo)) / f0(blockNo) *100;
%         dff_temp(dff_temp<0)=0;
        dff(i,:) = dff_temp;
    end
end
% line([ts(1) ts(end)], [f0 f0], 'color','r')
% figure;
% imagesc(dff, [0 300]); 
% colorbar;

% Align traces and mean
event_time_to_align = behavResults.Time_stimOnset;
% event_time_to_align = behavResults.Time_answer;

% stim_type_freq=behavResults.Stim_toneFreq;
align_time_point=min(event_time_to_align);
alignment_frames=floor((double((event_time_to_align-align_time_point))/1000)*frame_rate);
framelength = CaTrials(1).nFrames - max(alignment_frames);
alignment_frames(alignment_frames<1)=1;
start_frame=floor((double(align_time_point)/1000)*frame_rate);

data_aligned = zeros(nTrials, framelength);
for n = 1: nTrials
    data_aligned(n,1:framelength) = dff(n,alignment_frames(n):(alignment_frames(n)+framelength-1));
end
figure;
imagesc(data_aligned, [0 300]);
title(sprintf('ROI--%d, align StimOn',roiNo),'fontsize',20)

% Plot aligned mean trace
% yl = [10 max(mean(data_aligned,1))];
t_stim_on = double(align_time_point)/1000;
ts = (1:framelength)*CaTrials(1).FrameTime/1000;

inds_left = behavResults.Trial_Type == 0;
inds_right = behavResults.Trial_Type == 1;

data_aligned_smooth = zeros(size(data_aligned));
% smooth every trials before averaging
for n = 1: nTrials
    data_aligned_smooth(n,: ) = smooth(data_aligned(n,:),8);
end

opt_plot.t_eventOn = t_stim_on;
opt_plot.eventDur = 0.3;
mean_left_trace = mean(data_aligned_smooth(inds_left,:), 1);
se_left_trace = std(data_aligned_smooth(inds_left,:), 0, 1)./sqrt(sum(inds_left));
mean_right_trace = mean(data_aligned_smooth(inds_right,:), 1);
se_right_trace = std(data_aligned_smooth(inds_right,:), 0, 1)./sqrt(sum(inds_right));
PopuStdLeft = mean([mean_left_trace mean_right_trace])+ 3*std(mean_left_trace);
PopuStdRight = mean([mean_left_trace mean_right_trace]) + 3*std(mean_right_trace);

h_fig = figure; 
clf;hold on;
H_L = plot_meanCaTrace(mean_left_trace, se_left_trace, ts, h_fig, opt_plot);

H_R = plot_meanCaTrace(mean_right_trace, se_right_trace, ts, h_fig, opt_plot);
text(5,31,{['PopuSigL = ' num2str(PopuStdLeft)],['PopuSigR = ' num2str(PopuStdRight)]});
title(sprintf('ROI--%d, align StimOn',roiNo),'fontsize',20)

set(H_L.meanPlot, 'color','b')
set(H_R.meanPlot, 'color','r')

%
% function plot_meanCaTrace(mean_trace, se_trace, h_fig, opt)
% 
% uE =  mean_trace + se_trace;
% lE =  mean_trace - se_trace;
% yP=[lE,fliplr(uE)];
% xP=[ts,fliplr(ts)];
% patchColor = [.7 .7 .7];
% faceAlpha = 1;
% h_ep = patch(xP,yP,1,'facecolor',patchColor,...
%               'edgecolor','none',...
%               'facealpha',faceAlpha);
% yaxis = axis();
% hpch = patch([t_stim_on, t_stim_on, t_stim_on+0.3, t_stim_on+0.3], [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],  [.1 .8 .1],'Edgecolor','none');
% hmean = plot(ts, mean_trace,'k','linewidth',3);
% title(sprintf('ROI--%d, align StimOn',roiNo),'fontsize',20)
% 
% end
% hse1 = plot(ts, mean_trace + se_trace, '-.', 'linewidth',1.5, 'color', [.5 .5 .5]);
% hse2 = plot(ts, mean_trace - se_trace, '-.', 'linewidth',1.5, 'color',  [.5 .5 .5]);