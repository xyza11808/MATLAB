function prob_logistic_analysis
disp('please input the data path where you behavior data saved.\n');
FilePath=uigetdir();
cd(FilePath);
data_save_path='./probe_data_plots';
if (isdir(data_save_path))~=1
    mkdir(data_save_path);
end
files = dir('*.mat');
probe_sum=struct('SessionName',[],'ProbeType',[],'ProbeCorrRate',[],'LeftCorr',[],'RightCorr',[]);

for n = 1:length(files)
    fn = files(n).name;
    load(fn);
    trialInds = 1:length(behavResults.Trial_Type);
    inds_leftTrials = find(behavResults.Trial_Type == 0);
    inds_rightTrials = find(behavResults.Trial_Type == 1);
    
    %     correct_a = behavResults.Trial_Type == behavResults.Action_choice;
    rewarded = behavResults.Time_reward ~= 0;
    figure('color','w'); hold on;
    
    plot(trialInds, smooth(rewarded, 20),'k','linewidth',2)
    plot(trialInds(inds_leftTrials), smooth(rewarded(inds_leftTrials), 20),'b','linewidth',2);
    plot(trialInds(inds_rightTrials), smooth(rewarded(inds_rightTrials), 20),'r','linewidth',2);
    hold off;
    cd(data_save_path);
    saveas(gcf,[fn(1:end-4),'_correct_rate.png'],'png');
    close;
    
    %probe trial extraction
    if(~max(behavSettings.Frac_Probe_Trials))
        prob_inds_left=find(behavResults.Trial_Type == 0 & behavResults.Trial_isProbeTrial == 1);
        prob_inds_right=find(behavResults.Trial_Type == 1 & behavResults.Trial_isProbeTrial == 1);
        probe_stim_left=unique(behavResults.Stim_toneFreq(prob_inds_left));
        probe_stim_right=unique(behavResults.Stim_toneFreq(prob_inds_right));
        corr_rate_left=zeros(1,length(probe_stim_left));
        corr_rate_right=zeros(1,length(probe_stim_right));
            for m=1:length(probe_stim_left)
                corr_rate_left(m)=mean(rewarded(behavResults.Stim_toneFreq == probe_stim_left(m)));
            end
            for n=1:length(probe_stim_right)
                corr_rate_right=mean(rewarded(behavResults.Stim_toneFreq == probe_stim_right(m)));
            end
            
    end

end