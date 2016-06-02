%% browser the signal from one ROI following all frames
% Attention: the mat.file named 'getkey2.m' and 'frame_browser_lite_01.m'
roiNo=24;
trialNo= 333;
 %[im,header] = load_scim_data(CaTrials(trialNo).FileName); 
figure(gcf);
plot(CaTrials(trialNo).f_raw(roiNo,:));
line([trial_time_stimOnset(trialNo)/CaTrials(1).FrameTime,trial_time_stimOnset(trialNo)/CaTrials(1).FrameTime],...
    [min(CaTrials(trialNo).f_raw(roiNo,:)) max(CaTrials(trialNo).f_raw(roiNo,:))],'color','r','linewidth',2);
line([trial_time_answer(trialNo)/CaTrials(1).FrameTime,trial_time_answer(trialNo)/CaTrials(1).FrameTime],...
    [min(CaTrials(trialNo).f_raw(roiNo,:)) max(CaTrials(trialNo).f_raw(roiNo,:))],'color','k','linewidth',2);
roiPos = CaTrials(trialNo).ROIinfo.ROIpos;
 %frame_browser_lite_01(im, [-100 300],roiPos([roiNo]));%([roiNo])
