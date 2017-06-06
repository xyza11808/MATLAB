function [varargout]=behavScore_prob(varargin)

if nargin==0
    disp('please select your behavior analysis result data, the mat file contains animal behavior info.\n');
    filepath=uigetdir(pwd,'Select your behavior data analysis result');
    cd(filepath);
    batch_plot=1;
    IsIgnoringPerf = 0;
    %     load(filename);
elseif nargin == 1
    filepath = varargin{1};
    cd(filepath);
    batch_plot=1;
    IsIgnoringPerf = 0;
else
    behavResults=varargin{1};
    behavSettings=varargin{2};
    fn=varargin{3};
    IsIgnoringPerf = varargin{4};
    batch_plot=0;
end
data_save_path='./session_behav_plots/';
if (isdir(data_save_path))~=1
    mkdir(data_save_path);
end
%mkdir('./session_data_plots');
if batch_plot
    files = dir('*.mat');
    for n = 1:length(files)
        fn = files(n).name;
        load(fn);
        
        trialInds = 1:length(behavResults.Trial_Type);
        inds_leftTrials = find(behavResults.Trial_Type == 0);
        inds_rightTrials = find(behavResults.Trial_Type == 1);
        
        % Note, there are two ways to calculate percent correct:
        correct_a = behavResults.Trial_Type == behavResults.Action_choice;
        rewarded = behavResults.Time_reward ~= 0;
        % a and be should be the same if grace period is 0. If it's not 0, then
        % should use reward time, i.e., pcorrect_b.
        
        figure('color','w'); hold on;
        
        plot(trialInds, smooth(rewarded, 20),'k','linewidth',2)
        plot(trialInds(inds_leftTrials), smooth(rewarded(inds_leftTrials), 20),'b','linewidth',2);
        plot(trialInds(inds_rightTrials), smooth(rewarded(inds_rightTrials), 20),'r','linewidth',2);
        
        
        % draw a verticle line to indicate the start of each block (setting changes)
        inds_blockStart = find(behavResults.Trial_Num == 1);
        
        % Label setting changes during the session
        for i = 1:length(inds_blockStart)
            
            x1 = inds_blockStart(i);
            line([x1 x1], [0 1],'color','g');
            
            % get stimulus (tone frequency)
            if isfield(behavSettings, 'toneFreq')
                if ~iscell(behavSettings.toneFreq)
                    stim_str = num2str(behavSettings.toneFreq(x1,:));
                elseif ~ischar(behavSettings.toneFreq{x1})
                    stim_str = num2str(behavSettings.toneFreq{x1});
                else
                    stim_str = behavSettings.toneFreq{x1}; % '2Groups';
                end
                text(x1, 0.1*i, stim_str,'color','g')
                if ~strncmp(stim_str,'8000',4)
                    
                    if i==length(inds_blockStart)
                        %temp_trialInds=trialInds(x1:end);
                        temp_inds_leftTrials=inds_leftTrials(inds_leftTrials>=x1);
                        temp_inds_rightTrials=inds_rightTrials(inds_rightTrials>=x1);
                    else
                        %temp_trialInds=trialInds(inds_blockStart(i):inds_blockStart(i+1));
                        temp_inds_leftTrials=inds_leftTrials(ismember(inds_leftTrials,[inds_blockStart(i):inds_blockStart(i+1)]));
                        temp_inds_rightTrials=inds_rightTrials(ismember(inds_rightTrials,[inds_blockStart(i):inds_blockStart(i+1)]));
                    end
                    proble_result=fopen('proble_trial_result.txt','a');
                    proble_left_reward=mean(rewarded(temp_inds_leftTrials));
                    proble_right_reward=mean(rewarded(temp_inds_rightTrials));
                    fprintf(proble_result,'\n %s \n',stim_str);
                    fprintf(proble_result,'%s  %f\t','proble_left_reward',proble_left_reward);
                    fprintf(proble_result,'%s  %f\n','proble_right_reward',proble_right_reward);
                    fclose(proble_result);
                end
            end
            
            if isfield(behavSettings, 'gracePeriod')
                text(x1, 0.05*i, sprintf('GP=%d',behavSettings.gracePeriod(x1)),'color','m')
                if behavSettings.leftProb(x1) ~= 50
                    text(x1, 0.05*i - 0.03, sprintf('LeftProb=%d%',behavSettings.leftProb(x1)),'color','c')
                end
            end
        end
        
        ylabel('Frac Correct','fontsize',20); xlabel('Trial Number','fontsize',20);
        set(gca,'fontsize',25,'xlim',[0 length(trialInds)]);
        title(fn(1:end-4),'fontsize',20,'interpreter','none');
        
        saveas(gcf,sprintf('./session_behav_plots/plot_%s.png', fn(1:end-4)), 'png');
        saveas(gcf,sprintf('./session_behav_plots/plot_%s.png', fn(1:end-4)));
        close;
        
        %use subplot function to plot all result of the given data
        
    end
else
    
    trialInds = 1:length(behavResults.Trial_Type);
    inds_leftTrials = find(behavResults.Trial_Type == 0);
    inds_rightTrials = find(behavResults.Trial_Type == 1);
    
    % Note, there are two ways to calculate percent correct:
    correct_a = behavResults.Trial_Type == behavResults.Action_choice;
    rewarded = behavResults.Time_reward ~= 0;
    % a and be should be the same if grace period is 0. If it's not 0, then
    % should use reward time, i.e., pcorrect_b.
    
    figure('color','w'); hold on;
    
    plot(trialInds, smooth(double(rewarded), 20),'k','linewidth',2)
    plot(trialInds(inds_leftTrials), smooth(double(rewarded(inds_leftTrials)), 20),'b','linewidth',2);
    plot(trialInds(inds_rightTrials), smooth(double(rewarded(inds_rightTrials)), 20),'r','linewidth',2);
    Avg_all_corr=mean(rewarded);
    Avg_left_corr=mean(rewarded(inds_leftTrials));
    Avg_right_corr=mean(rewarded(inds_rightTrials));
    
    % draw a verticle line to indicate the start of each block (setting changes)
    inds_blockStart = find(behavResults.Trial_Num == 1);
    
    % Label setting changes during the session
    for i = 1:length(inds_blockStart)
        
        x1 = inds_blockStart(i);
        line([x1 x1], [0 1],'color','g');
        
        % get stimulus (tone frequency)
        if isfield(behavSettings, 'toneFreq')
            if ~iscell(behavSettings.toneFreq)
                stim_str = num2str(behavSettings.toneFreq(x1,:));
            elseif ~ischar(behavSettings.toneFreq{x1})
                stim_str = num2str(behavSettings.toneFreq{x1});
            else
                stim_str = behavSettings.toneFreq{x1}; % '2Groups';
            end
            text(x1, 0.1*i, stim_str,'color','g')
            if ~strncmp(stim_str,'8000',4)
                
                if i==length(inds_blockStart)
                    %temp_trialInds=trialInds(x1:end);
                    temp_inds_leftTrials=inds_leftTrials(inds_leftTrials>=x1);
                    temp_inds_rightTrials=inds_rightTrials(inds_rightTrials>=x1);
                else
                    %temp_trialInds=trialInds(inds_blockStart(i):inds_blockStart(i+1));
                    temp_inds_leftTrials=inds_leftTrials(ismember(inds_leftTrials,[inds_blockStart(i):inds_blockStart(i+1)]));
                    temp_inds_rightTrials=inds_rightTrials(ismember(inds_rightTrials,[inds_blockStart(i):inds_blockStart(i+1)]));
                end
                proble_result=fopen('proble_trial_result.txt','a');
                proble_left_reward=mean(rewarded(temp_inds_leftTrials));
                proble_right_reward=mean(rewarded(temp_inds_rightTrials));
                fprintf(proble_result,'\n %s \n',stim_str);
                fprintf(proble_result,'%s  %f\t','proble_left_reward',proble_left_reward);
                fprintf(proble_result,'%s  %f\n','proble_right_reward',proble_right_reward);
                fclose(proble_result);
            end
        end
        
        if isfield(behavSettings, 'gracePeriod')
            text(x1, 0.05*i, sprintf('GP=%d',behavSettings.gracePeriod(x1)),'color','m')
            if behavSettings.leftProb(x1) ~= 50
                text(x1, 0.05*i - 0.03, sprintf('LeftProb=%d%',behavSettings.leftProb(x1)),'color','c')
            end
        end
    end
    
    ylabel('Frac Correct','fontsize',20); xlabel('Trial Number','fontsize',20);
    set(gca,'fontsize',25,'xlim',[0 length(trialInds)]);
    title(fn(1:end-4),'fontsize',20,'interpreter','none');
    
    saveas(gcf,sprintf('./session_behav_plots/plot_%s.png', fn(1:end-4)), 'png');
    saveas(gcf,sprintf('./session_behav_plots/plot_%s.png', fn(1:end-4)));
    close;
    
    %defining trial types for further analysis
    StimFreq=unique(behavResults.Stim_toneFreq);
    SessionType = 'Undefined';
    if length(StimFreq)==2
        SessionType='puretone';
    elseif length(StimFreq) > 2
        if max(behavResults.Trial_isProbeTrial)
            if length(StimFreq) > 6
                SessionType='RandompuretoneProb';
            else
                SessionType='prob';
            end
        elseif length(StimFreq) >= 6
            SessionType='Randompuretone';
        end
    end
    if IsIgnoringPerf
        %use subplot function to plot all result of the given data
        if (Avg_all_corr < 0.7) || (Avg_left_corr<0.7 || Avg_right_corr < 0.7)
            GoonChoice=input('The correction rate of this session is not good, are you sure want to go on with the following analysis?\n','s');
            if strcmpi(GoonChoice,'n')
                disp('Quit following analysis...\n');
                UserChoice=1;
            else
                UserChoice=0;
            end
        else
            UserChoice=0;
        end
    else
        UserChoice = 0;
    end
    
    if nargout==1
        varargout{1}={{UserChoice},{SessionType}};
    elseif nargout==2
        varargout{1}=UserChoice;
        varargout{2}=SessionType;
    end
end




% %%
% % The following code has been put to a function:
% % sum_beh_session_for_psychMetric.m
% disp('please input the filename you want to check with settings: ')
% filename=input('please input the finename:','s');
% fn=ls([filename '*.mat']);
% % anmName = 'animal04';
% % expDate = '2014_05_08';
% % fn = ls([expDate '_' anmName '*.mat']);
% fn = strtrim(fn); % remove trailing white space
% load(fn);
%
% trialInds = 1:length(behavResults.Trial_Type);
% inds_leftTrials = find(behavResults.Trial_Type == 0);
% inds_rightTrials = find(behavResults.Trial_Type == 1);
%
% %% Plot settings over trials
% figure;
% hold on;
% settingNames = {'gracePeriod','ExtraITIDur', 'waterValveDelay','toneFreq'};
%
% for i = 1:length(settingNames)
%     subplot(length(settingNames), 1, i);
%     plot(trialInds, behavSettings.(settingNames{i}), 'o')
%     ylabel(settingNames{i})
% end
% % plot(behavSettings.gracePeriod,'ro')
% % plot(behavSettings.ExtraITIDur,'bo')
%
% %% Score with or without grace period
% left_ = 0;
% right_ = 1;
%
% trim_l = 50;
% trim_t = 100;
%
% inds_gp = find(behavSettings.gracePeriod > 0);
% inds_nogp = behavSettings.gracePeriod == 0;
%
% rewarded = behavResults.Time_reward ~= 0;
%
% % mean(correct_b(inds_gp))
% mean(rewarded(inds_nogp));
% anmName=input('please input the imported animal name:','s');
% sum_behavResults.anmName = anmName;
% expDate=input('please input the exported date:','s');
% sum_behavResults.expDate = expDate;
% sum_behavResults.blockInds = {};
% sum_behavResults.left_stim = []; % List of left simulus used in this session
% sum_behavResults.right_stim = []; % List of right stimulus used
% sum_behavResults.leftTrial_choice = []; % List of choice in all Left trials
% sum_behavResults.rightTrial_choice = []; % List of choice in all Right trials
% sum_behavResults.left_score = []; % Score of left trials
% sum_behavResults.right_score = []; % Score of Right trials
% sum_behavResults.tot_score = []; % Total score
% sum_behavResults.rewarded_trials = [];
%
% sum_behavResults.inds_left = [];
% sum_behavResults.inds_right = [];
%
%
% x1 = find(behavResults.Trial_Num == 1);
% for i = 1:length(x1)-1,
%     sum_behavResults.blockInds{i} = x1(i) : x1(i+1)-1;
% end
%
% sum_behavResults.blockInds{i+1} = x1(i+1) : length(behavResults.Trial_inds);
%
% sum_behavResults.inds_left = find(behavResults.Trial_Type == left_);
% sum_behavResults.inds_right = find(behavResults.Trial_Type == right_);
%
% sum_behavResults.left_stim = unique(behavSettings.toneFreq(inds_leftTrials));
% sum_behavResults.right_stim = unique(behavSettings.toneFreq(inds_rightTrials));
% sum_behavResults.leftTrial_choice = behavResults.Action_choice(inds_leftTrials);
% sum_behavResults.rightTrial_choice = behavResults.Action_choice(inds_rightTrials);
% sum_behavResults.left_score = mean(rewarded(inds_leftTrials));
% sum_behavResults.right_score = mean(rewarded(inds_rightTrials));
% sum_behavResults.tot_score = mean(rewarded);
% sum_behavResults.rewarded_trials = behavResults.Time_reward ~= 0;
%
% %%
% % data_for_psycMtr = [];
% s.anmName = 'animal04';
% s.expDate = '2014_05_08';
% s.stim_freq_left = 6000;
% s.stim_freq_right = 12000;
%
% s.trialInds = 1:length(sum_behavResults.rewarded_trials);
%
% s.inds_trial_use = sum_behavResults.blockInds{2}(50:end-50);
% s.inds_trial_use_left = ismember(sum_behavResults.inds_left, s.inds_trial_use);
% s.inds_trial_use_right = ismember(sum_behavResults.inds_right, s.inds_trial_use);
%
% s.percent_left_choice_left = sum(sum_behavResults.leftTrial_choice(s.inds_trial_use_left) == left_)/sum(s.inds_trial_use_left)*100;
% s.percent_left_choice_right = sum(sum_behavResults.rightTrial_choice(s.inds_trial_use_right) == left_)/sum(s.inds_trial_use_right)*100;
%
% s.d_octave_left = (s.stim_freq_left - s.stim_freq_right)/s.stim_freq_left;
% s.d_octave_right = (s.stim_freq_right - s.stim_freq_left)/s.stim_freq_left;
%
% data_for_psycMtr = [data_for_psycMtr s];

