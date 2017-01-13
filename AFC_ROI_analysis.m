function AFC_ROI_analysis(data,session_date,exclude_inds,CaTrials_signal,varargin)
%This function is used for ROI analysis conbined with 2AFC result processed
%by python
%This function will be sited by function post_ROI_calculation, which gives
%the input data. The vargin is just an option for future uses
%data should be a three dimensional data form which the three dimensions
%corresponded to trial_num, ROI num, and frames
%vargin temporally used to define whether need to do trajectory distance
%calculation. when vargin equals 1, this calculation will be processed

%%default value of input
if nargin<5
    ROI_cf=[];
    traj_choice=0;
    if nargin<4
        error(message('MATLAB:ode45:NotEnoughInputs'));
    end
end

if nargin==5
    ROI_cf=varargin{1};
    traj_choice=0;
    input_data_type='mode';
elseif nargin==6
    ROI_cf=varargin{1};
    traj_choice=varargin{2};
    input_data_type='mode';
%     SessionType='puretone';
elseif nargin==7
    ROI_cf=varargin{1};
    traj_choice=varargin{2};
    input_data_type=varargin{3};
elseif nargin > 7
    ROI_cf=varargin{1};
    traj_choice=varargin{2};
    input_data_type=varargin{3};
    
end
if length(varargin) >= 7
    VShapeData = varargin{7};
end

% %%################################################################################################
% ##################################################################################################
% global settings section
%define a index structure used for data plot index save
plot_data_inds=struct('left_trials_inds',[],'right_trials_inds',[],'left_trials_bingo_inds',[],'right_trials_bingo_inds',[],...
    'left_trials_oops_inds',[],'right_trials_oops_inds',[],'left_stim_tone',[],'right_stim_tone',[],...
    'left_trials_miss_inds',[],'right_trials_miss_inds',[],'left_stim_tone_prob',[],'right_stim_tone_prob',[]);
isProbAsRandTone = 0;
% global settings end
% %%################################################################################################
% ##################################################################################################





SessionDesp = 'Twotone2afc';
size_data=size(data);
frame_rate=floor(1000/CaTrials_signal(1).FrameTime);
session_name=CaTrials_signal(1).FileName_prefix(:);
ROI_info=CaTrials_signal(1).ROIinfo;
[center_ROI,EmptyROIs]=ROI_insite_label(ROI_info);

save ROICenters.mat center_ROI EmptyROIs -v7.3
%%
% if strcmpi(input_data_type,'mode')
%     disp('please select the full data path for behavior file(*.beh) analysis result.\n');
%     [fn2,file_path2]=uigetfile('*.*');
%     filepath2=[file_path2,filesep,fn2];  %this can be achieved by the  fullfile function
%     if ~exist(filepath2,'file')
%         error('wrong file path for behavior result!');
%     end
%     load(filepath2);
% elseif strcmpi(input_data_type,'baseline')
   if nargin>7
        behavResults=varargin{4};
        behavSettings=varargin{5};
        SessionType=varargin{6};
   else
        SessionType='puretone';
        disp('please select the full data path for behavior file(*.beh) analysis result.\n');
        [fn2,file_path2]=uigetfile('*.*');
        filepath2=[file_path2,filesep,fn2];  %this can be achieved by the  fullfile function
        if ~exist(filepath2,'file')
            error('wrong file path for behavior result!');
        end
        load(filepath2); 
   end
% end
%%
    %##########################################################################################
    %added function for normal 2afc task analysis
    %##########################################################################################
    field_count=sum(isfield(behavResults,{'Action_lickTimeRight','Action_lickTimeLeft'}));
    if field_count==2
        imaging_time=(double(size_data(3))/frame_rate);
        [lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,imaging_time); %this function is used for converting lick time strings into arrays and save in a struct
    end
    for n=1:size_data(1)
        temp_data=squeeze(data(n,:,:));
        nan_test=isnan(temp_data);
        if sum(nan_test(:))~=0
            exclude_inds=[exclude_inds n];
        end
    end
%     data(exclude_inds,:,:);
if ~isempty(exclude_inds)
    behavResults.Trial_Type(exclude_inds)=[];
    behavResults.Time_reward(exclude_inds)=[];
    behavResults.Action_choice(exclude_inds)=[];
%     behavResults.Stim_toneFreq(exclude_inds)=[];
    behavResults.Time_stimOnset(exclude_inds)=[];
    behavResults.Stim_toneFreq(exclude_inds)=[];
    behavResults.Time_answer(exclude_inds)=[];
    behavResults.Trial_Num(exclude_inds)=[];
    behavResults.Trial_isProbeTrial(exclude_inds)=[];
    behavResults.Trial_isOptoProbeTrial(exclude_inds)=[];
    behavResults.ManWater_choice(exclude_inds)=[];
%     behavResults.Time_optoStimOffTime(exclude_inds)=[];
    
    behavResults.Trial_isOptoTraingTrial(exclude_inds)=[];
    behavResults.Time_optoStimOnset(exclude_inds)=[];
    
     behavResults.Stim_Type(exclude_inds,:)=[];
    if max(behavResults.Trial_isProbeTrial)
        behavResults.Trial_isProbeTrial(exclude_inds)=[];
    end
    if isfield(behavResults,'Setted_TimeOnset')
        behavResults.Setted_TimeOnset(exclude_inds)=[];
    end
    if field_count==2
        lick_time_struct(exclude_inds)=[];
        Lick_bias_side(exclude_inds)=[];
%         behavResults.Action_lickTimeRight(exclude_inds)=[];
%         behavResults.Action_lickTimeLeft(exclude_inds)=[];
%         behavResults.Action_numLickLeft(exclude_inds)=[];
%         behavResults.Action_numLickRight(exclude_inds)=[];
    end
    if isfield(behavResults,'isRewardIgnore') && isfield(behavResults,'isActiveReward')
        behavResults.isRewardIgnore(exclude_inds)=[];
        behavResults.isActiveReward(exclude_inds)=[];
    end
     if isfield(behavResults,'Trial_isRandRGiven')
         behavResults.Trial_isRandRGiven(exclude_inds)=[];
     end
end

corr_trial_inds = behavResults.Action_choice == behavResults.Trial_Type;
Error_trial_inds = (behavResults.Action_choice ~= behavResults.Trial_Type) & (behavResults.Action_choice ~= 2);
miss_tiral = behavResults.Action_choice == 2;
trial_outcome = zeros(length(corr_trial_inds),1);
trial_outcome(corr_trial_inds) = 1;
trial_outcome(Error_trial_inds) = 0;
trial_outcome(miss_tiral) = 2;
OnsetStruct=struct('StimOnset',behavResults.Time_stimOnset,'StimDuration',300);

[FLickT,FRewardLickT,FlickInds]=FirstLickTime(lick_time_struct,behavResults.Action_choice,trial_outcome,OnsetStruct,behavResults.Time_answer);
%  BehavLickPlot(behavResults,behavSettings,[])

% FLickFrame=floor((double(FLickT)/1000)*frame_rate);

if isfield(behavResults,'Setted_TimeOnset')
    diff_real_set=diff([behavResults.Time_stimOnset;behavResults.Setted_TimeOnset]);
    difference_test=sum(diff_real_set<-3 | diff_real_set>3);
    if difference_test~=0
        warning('The printed stim onset time is different from set, use set time for analysis.\n');
        behavResults.Time_stimOnset=behavResults.Setted_TimeOnset;
    end
else
    disp('It seems the behavior data is printed by old version behavior training code, performing stim onset time correction?\n');
    choice_char=input('Go on(y/n)?\n','s');
    if strcmpi(choice_char,'y')
%         disp('please input the random onset range before stim onset in setting file.\n');
        set_range=input('please input the random onset range before stim onset in setting file.\n','s');
        set_range_Avg=mean(str2num(set_range));
        print_mean=mean(behavResults.Time_stimOnset);
        diff_print_set=print_mean-set_range_Avg;
        for n=1:size_data(1)
            if ~isempty(lick_time_struct(n).LickTimeLeft)
                lick_time_struct(n).LickTimeLeft=lick_time_struct(n).LickTimeLeft-diff_print_set;
            end
            if ~isempty(lick_time_struct(n).LickTimeRight)
                lick_time_struct(n).LickTimeRight=lick_time_struct(n).LickTimeRight-diff_print_set;
            end
        end
%             lick_time_struct.LickTimeLeft=
        behavResults.Time_stimOnset=behavResults.Time_stimOnset-diff_print_set;
        behavResults.Time_reward=behavResults.Time_reward-diff_print_set;
    else
        disp('Ignoring printed stim onset time adjustion.\n');
    end
end


% variable_name={'corr_left','erro_left','corr_right','erro_right'};
% if vargin=1
%     output_result=variable_name;
% else
%     output_result={};
% end


% cd(filepath);
% files=dir('*.mat');
% for i=1:length(files);
%     load(files(i).name);
%     disp(['loading file ',files(i).name]);
% end
% num_trials=length(behavResults.Trial_Type);
%trial_side=zeros(1,num_trials);
% trial_side=behavResults.Trial_Type; %0 means left side while 1 means right side

plot_data_inds.left_trials_inds=find(behavResults.Trial_Type==0);
plot_data_inds.right_trials_inds=find(behavResults.Trial_Type==1);
plot_data_inds.left_trials_bingo_inds=find(behavResults.Trial_Type==0 & behavResults.Time_reward>0);
plot_data_inds.right_trials_bingo_inds=find(behavResults.Trial_Type==1 & behavResults.Time_reward>0);
plot_data_inds.left_trials_oops_inds=find(behavResults.Trial_Type==0 & behavResults.Action_choice==1);
plot_data_inds.right_trials_oops_inds=find(behavResults.Trial_Type==1 & behavResults.Action_choice==0);
plot_data_inds.left_trials_miss_inds=find(behavResults.Trial_Type==0 & behavResults.Action_choice==2);
plot_data_inds.right_trials_miss_inds=find(behavResults.Trial_Type==1 & behavResults.Action_choice==2);

%#########################################################################################
%given suggestion for reward time selection, the final result is gived by
%frame numbers
reward_T=behavResults.Time_reward;
reward_T=reward_T(reward_T>0);
left_range=floor((double(min(reward_T))/1000)*frame_rate)-1;
right_range=size_data(3)-floor((double(max(reward_T))/1000)*frame_rate)+1;
disp(['The suggested frame range for Seperate_align_plot function is: ' num2str(left_range) ' and ' num2str(right_range) '.\n']);

% % %###########################################################################
% %analysis correlations between lick number and mean response
% if strcmpi(input_data_type,'baseline')
%     left_side_data=data(plot_data_inds.left_trials_bingo_inds,:,:);
%     lick_number_left=zeros(length(plot_data_inds.left_trials_bingo_inds),1);
%     for k=1:length(plot_data_inds.left_trials_bingo_inds)
%         lick_number_left(k)=lick_time_struct(plot_data_inds.left_trials_bingo_inds(k)).LickNumLeft;
%     end
% %     lick_number_left=lick_time_struct(plot_data_inds.left_trials_bingo_inds).LickNumLeft;
%     reward_time_left= behavResults.Time_reward(plot_data_inds.left_trials_bingo_inds);
%     licknum_response_corr(left_side_data,lick_number_left,reward_time_left,frame_rate,[0 3],'Left_trial');
%     left_stim_onset=behavResults.Time_stimOnset(plot_data_inds.left_trials_bingo_inds);
%     left_reward= behavResults.Time_reward(plot_data_inds.left_trials_bingo_inds);
%     onset_delay_dis(left_side_data,frame_rate,'event',[left_stim_onset',left_reward']);
%     
%     right_side_data=data(plot_data_inds.right_trials_bingo_inds,:,:);
%     lick_number_right=zeros(length(plot_data_inds.right_trials_bingo_inds),1);
%     for k=1:length(plot_data_inds.right_trials_bingo_inds)
%         lick_number_right(k)=lick_time_struct(plot_data_inds.right_trials_bingo_inds(k)).LickNumRight;
%     end
% %     lick_number_right=lick_time_struct(plot_data_inds.right_trials_bingo_inds).LickNumRight;
%     reward_time_right= behavResults.Time_reward(plot_data_inds.right_trials_bingo_inds);
%     licknum_response_corr(right_side_data,lick_number_right,reward_time_right,frame_rate,[0 3],'Right_trial');
%     right_stim_onset=behavResults.Time_stimOnset(plot_data_inds.right_trials_bingo_inds);
%     right_reward= behavResults.Time_reward(plot_data_inds.right_trials_bingo_inds);
%     onset_delay_dis(right_side_data,frame_rate,'event',[right_stim_onset',right_reward']);
%     
% end
%% %###########################################################################

%################################
%Inds extraction of all kinds of behavior types

radom_inds=[];
radom_inds_correct=[];
pure_tone_inds=[];
pure_tone_corr_inds=[];
sweep_inds=[];
sweep_corr_inds=[];
RewardOmitInds=[];
ActiveRewardInds=[];
ProbTrialInds=[];
IsRewardGivenInds = [];
PureProbTrInds = [];
for n=1:length(behavResults.Trial_Type)
    if ~behavResults.Trial_isProbeTrial(n)
        if iscell(behavResults.Stim_Type(n))
            CurrentTr = behavResults.Stim_Type(n);
        else
            CurrentTr = behavResults.Stim_Type(n,:);
        end
        if strcmpi(CurrentTr,'randompureTone')
            radom_inds=[radom_inds n];
            if behavResults.Time_reward(n)>0
                radom_inds_correct=[radom_inds_correct n];
            end
        elseif strcmpi(CurrentTr,'pureTone') || strcmpi(behavResults.Stim_Type(n),'SAMtone')
            pure_tone_inds=[pure_tone_inds n];
            if behavResults.Time_reward(n)>0
                pure_tone_corr_inds=[pure_tone_corr_inds n];
            end
        elseif strcmpi(CurrentTr,'sweep')
            sweep_inds=[sweep_inds n];
            if behavResults.Time_reward(n)>0
                sweep_corr_inds=[sweep_corr_inds n];
            end
        else
            error('Unrecognized stimulus type, quit 2AFC analysis and please contact with the one who wrote this code.\n');
        end
    else
        ProbTrialInds=[ProbTrialInds n]; %this index will be used for future analysis
        if isfield(behavResults,'isRewardIgnore') && isfield(behavResults,'isActiveReward')
            if behavResults.isRewardIgnore(n)
                RewardOmitInds=[RewardOmitInds n];
            elseif behavResults.isActiveReward(n)
                ActiveRewardInds=[ActiveRewardInds n];
            end
        else
            PureProbTrInds = [PureProbTrInds n];
        end
       
    end
    
end
RandomSession=0;
if isProbAsRandTone && ~isempty(PureProbTrInds)  % only when there is any prob puretone trial exists
    radom_inds_correct = sort([pure_tone_inds,PureProbTrInds]);
    SessionDesp = 'RandomPuretone';
    RandomSession=1;
    radom_inds = radom_inds_correct;
end
%%
left_trials_stim=behavResults.Trial_Type(behavResults.Trial_Type==0 & behavResults.Trial_isProbeTrial==0);
right_trials_stim=behavResults.Trial_Type(behavResults.Trial_Type==1 & behavResults.Trial_isProbeTrial==0);
plot_data_inds.left_stim_tone=unique(left_trials_stim);
plot_data_inds.right_stim_tone=unique(right_trials_stim);
if max(behavResults.Trial_isProbeTrial)
    left_trials_stim_prob=behavResults.Trial_Type(behavResults.Trial_Type==0 & behavResults.Trial_isProbeTrial==1);
    right_trials_stim_prob=behavResults.Trial_Type(behavResults.Trial_Type==1 & behavResults.Trial_isProbeTrial==1);
    plot_data_inds.left_stim_tone_prob=unique(left_trials_stim);
    plot_data_inds.right_stim_tone_prob=unique(right_trials_stim);
end

%################################################################################################
%population zscore calculation and for further alignment plot
zscore_data=zeros(size_data);
TrialSelfZS_data=zeros(size_data);
%################################################################################################
%population normalized data for further analysis
NorData=zeros(size_data);
% nSpikes = zeros(size_data);
ROIstd=zeros(1,size_data(2));

%parameter struc
V.Ncells = 1;
V.T = size_data(3);
V.Npixels = 1;
V.dt = 1/frame_rate;
P.lam = 10;

for n=1:size_data(2)
    temp_data=squeeze(data(:,n,:));
    SingleTrialMean=mean(temp_data,2);
    SingleTrialMeanMatrix=repmat(SingleTrialMean,1,size_data(3));
    mean_temp=mean(temp_data(:));
    std_temp=mad(reshape(temp_data',[],1));
    ROIstd(n)=1.4826*std_temp;
    zscore_data(:,n,:)=(temp_data-mean_temp)/ROIstd(n);
    TrialSelfZS_data(:,n,:)=(temp_data-SingleTrialMeanMatrix)/ROIstd(n);
    
    NorBase=max(smooth(temp_data(:)));
    NorData(:,n,:)=temp_data/NorBase;
    
%     P.sig = ROIstd(n);
%     parfor nt = 1 : size_data(1)
%         cTrace = temp_data(nt,:);
%         cTrace(1:5) = mean(cTrace(1:5));
%          [n_best,~,~,~]=fast_oopsi(cTrace,V,P);
%          n_best(1:6) = 0;
%          n_best = n_best / V.dt;
%          nSpikes(nt,n,:) = n_best;
%     end
end

% save SpikeResult.mat nSpikes ROIstd V -v7.3
%%
frame_lick_inds=struct('Action_LeftLick_frame',[],'Action_RightLick_frame',[]);
    %%
    %check whether random trial exists, and do post analysis if there are
    %some

if ~isempty(radom_inds_correct)
    if length(radom_inds_correct)<60
        warning('Not enough correct random trial result, the analysis result maybe inaccurate.\n');
    end
    disp('Random trial exists, performing random trial analysis.\n');
    random_type_stim=behavResults.Stim_toneFreq(radom_inds_correct);
    random_stim_onset=behavResults.Time_stimOnset(radom_inds_correct);
    random_stim_freq=behavResults.Stim_toneFreq(radom_inds_correct);
%     random_reward_time=behavResults.RewardTime(radom_inds);
    rand_trial_type=behavResults.Trial_Type(radom_inds_correct);
    rand_reward_time=behavResults.Time_reward(radom_inds_correct);
%     rand_action_choice=behavResults.Action_choice(radom_inds_correct);
    rand_trial_outcome = trial_outcome(radom_inds);
%     unique_stim_type=unique(random_type_stim);
    rand_first_lick=FLickT(radom_inds_correct);
    
    if field_count==2
        rand_lick_time=lick_time_struct(radom_inds_correct);
        for n=1:length(rand_lick_time)
            frame_lick_inds(n).Action_LeftLick_frame=floor((double(rand_lick_time(n).LickTimeLeft)/1000)*frame_rate);
            frame_lick_inds(n).Action_RightLick_frame=floor((double(rand_lick_time(n).LickTimeRight)/1000)*frame_rate);
        end
    end
    
    rand_trial_data=zeros(length(random_type_stim),size_data(2),size_data(3));
%     m=1:length(random_type_stim);
    rand_trial_data=data(radom_inds_correct,:,:);
    if isProbAsRandTone
        rand_plot(behavResults,3,[],1);
    else
        rand_plot(behavResults,3);
    end
    RandomSession=1;
    SessionDesp = 'RandomPuretone';
    %###########################################################################################
%     random_all_plot(data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),behavResults.Time_stimOnset(radom_inds),rand_trial_outcome,frame_rate,...
%         behavResults.Time_answer(radom_inds),session_date');
    %#############################################################################################
    %##############################################################################################
%     Seperate_align_plot_update(rand_trial_data,rand_trial_type',[random_stim_onset',rand_reward_time',rand_first_lick'],frame_rate,session_date');
    %###############################################################################################
%     Split_TimePoint_plot(rand_trial_data,rand_trial_type',frame_lick_inds,[random_stim_onset',rand_reward_time',rand_first_lick'],frame_rate,session_date',random_stim_freq);
    %###############################################################################################

%     length_vary_alignment(rand_trial_data,[rand_trial_type',rand_action_choice',random_type_stim'],[random_stim_onset',rand_reward_type'],1,frame_rate,[session_date','_compressed_align']);
end
    
%%
%check whether puretone trial exists and performing post analysis if is
%true

if ~isempty(pure_tone_inds)
    if length(pure_tone_inds)<20
        warning('Not enough correct pure tone trial result, the analysis result maybe inaccurate.\n');
    end
    disp('pure tone trial exists, performing pure tone trial analysis.\n');
    PT_type_stim=behavResults.Stim_toneFreq(pure_tone_corr_inds);
    PT_stim_onset=behavResults.Time_stimOnset(pure_tone_corr_inds);
    PT_stim_freq=behavResults.Stim_toneFreq(pure_tone_corr_inds);
%     random_reward_time=behavResults.RewardTime(radom_inds);
    PT_trial_type=behavResults.Trial_Type(pure_tone_corr_inds);
    PT_reward_time=behavResults.Time_reward(pure_tone_corr_inds);
    PT_first_lick=FLickT(pure_tone_corr_inds);
    PT_action_choice=behavResults.Action_choice(pure_tone_corr_inds);
%     unique_stim_type=unique(random_type_stim);

    if field_count==2
        PT_lick_time=lick_time_struct(pure_tone_corr_inds);
        for n=1:length(PT_lick_time)
            frame_lick_inds(n).Action_LeftLick_frame=floor((double(PT_lick_time(n).LickTimeLeft)/1000)*frame_rate);
            frame_lick_inds(n).Action_RightLick_frame=floor((double(PT_lick_time(n).LickTimeRight)/1000)*frame_rate);
        end
    end
    
    PT_trial_data=zeros(length(PT_type_stim),size_data(2),size_data(3));
    m=1:length(PT_type_stim);
    PT_trial_data(m,:,:)=data(pure_tone_corr_inds(m),:,:);
    PT_ZS_data=TrialSelfZS_data(pure_tone_corr_inds,:,:);
%     %##############################################################################################
% % %     Seperate_align_plot(PT_trial_data,PT_trial_type',[PT_stim_onset',PT_reward_time'],frame_rate,session_date');
%     
%       Seperate_align_plot_update(PT_trial_data,PT_trial_type',[PT_stim_onset',PT_reward_time',PT_first_lick'],frame_rate,session_date');
%     %###############################################################################################
%       PTclims=Split_TimePoint_plot(PT_trial_data,PT_trial_type',frame_lick_inds,[PT_stim_onset',PT_reward_time',PT_first_lick'],frame_rate,session_date');
%       if ~isdir('./ZS_data_plot/')
%           mkdir('./ZS_data_plot/');
%       end
%       cd('./ZS_data_plot/');
% %       Split_TimePoint_plot(PT_ZS_data,PT_trial_type',frame_lick_inds,[PT_stim_onset',PT_reward_time',PT_first_lick'],frame_rate,session_date',[],'z\_score');
%       cd ..;
%       
%     %###############################################################################################
end
if exist('PTclims','var')
    save Puretone_clims.mat PTclims -v7.3
end
%
% %this needed to be adjusted according to the final python analysis result
% if strcmp(behavResults.Stim_Type,'puretone')
%     left_stim=behavSettings.toneFreq(1,1);
%     right_stim=behavSettings.toneFreq(1,2);
% elseif strcmp(behavResults.Stim_Type,'sweep')  %not settled yet, based on the python output
%        left_stim= behavSettings.SweepFreq(1);
%        right_stim= behavSettings.SweepFreq(2);
% elseif strcmp(behavResults.Stim_Type , 'noise')
%        left_stim= behavSettings.NoiseFreq(1);
%        right_stim= behavSettings.NoiseFreq(2);
% end


% %##############################################
% if ~isempty(ProbTrialInds)
%     Probtype = squeeze(behavSettings.probe_stimType);
%     CurrentSessionPType = Probtype(1,:);
%     fprintf('Prob trials type within currect session is %s',CurrentSessionPType);
%     if strcmpi(CurrentSessionPType,'CP')
%         % % place for choice probability calculation
%     else
%         disp('Prob trial exists, performing prob and non-prob trials comparation plot.\n');
%          probe_trial_inds=ProbTrialInds;
%           prob_type_stim=behavResults.Stim_toneFreq(probe_trial_inds);
%         prob_stim_onset=behavResults.Time_stimOnset(probe_trial_inds);
%         prob_stim_freq=behavResults.Stim_toneFreq(probe_trial_inds);
%     %     random_reward_time=behavResults.RewardTime(radom_inds);
%         prob_trial_type=behavResults.Trial_Type(probe_trial_inds);
%         prob_reward_time=behavResults.Time_reward(probe_trial_inds);
%         prob_action_choice=behavResults.Action_choice(probe_trial_inds);
%     %     unique_stim_type=unique(random_type_stim);
% 
%         if field_count==2
%             prob_lick_time=lick_time_struct(probe_trial_inds);
%             for n=1:length(prob_lick_time)
%                 frame_lick_inds(n).Action_LeftLick_frame=floor((double(prob_lick_time(n).LickTimeLeft)/1000)*frame_rate);
%                 frame_lick_inds(n).Action_RightLick_frame=floor((double(prob_lick_time(n).LickTimeRight)/1000)*frame_rate);
%             end
%         end
%         Prob_trial_data=data(probe_trial_inds,:,:);
%         prob_trial_outcome = trial_outcome(radom_inds);
%         random_all_plot(Prob_trial_data,behavResults.Stim_toneFreq(probe_trial_inds),behavResults.Time_stimOnset(probe_trial_inds),prob_trial_outcome,frame_rate,session_date','prob');
%           %###############################################################################################
%           Seperate_align_plot_update(Prob_trial_data,prob_trial_type',[prob_stim_onset',prob_reward_time'],frame_rate,session_date');
%     %     %###############################################################################################
%           Split_TimePoint_plot(Prob_trial_data,prob_trial_type',frame_lick_inds,[prob_stim_onset',prob_reward_time'],frame_rate,session_date');
%     %     %###############################################################################################
%     end
% 
% end
%%
    
%     isrewardIgnore=0;
%     isactivereawrd=0;
    if ~isempty(RewardOmitInds)
        isRewardOmit = 1;
        SessionDesp = 'RewardOmit';
        disp('Reward ignoring trials exists, doing following analysis.\n');
%         ROresults=trial_outcome(RewardOmitInds);
%         isrewardIgnore = 1;
        OmitInds=zeros(1,size_data(1));
        OmitInds(RewardOmitInds)=1;
        OmitInds=logical(OmitInds);
        if ~exist('PTclims','var')
            PTclims = [];
        end
        if ~isdir('./AnsWerT_omit_sort/')
            mkdir('./AnsWerT_omit_sort/');
        end
        cd('./AnsWerT_omit_sort/');
        ReOmitStrc = ReomitPlot(data,OmitInds,trial_outcome,behavResults.Trial_Type,behavResults.Time_answer,behavResults.Time_stimOnset,frame_rate,0);
%         RewardOmitPlot(data,OmitInds,trial_outcome,behavResults.Trial_Type,behavResults.Time_answer,behavResults.Time_stimOnset,frame_rate,session_date',PTclims);
        Inds = RewardOmitPlot(data,OmitInds,trial_outcome,behavResults.Trial_Type,behavResults.Time_answer,behavResults.Time_stimOnset,frame_rate,session_date',PTclims,0);        
        %data strc for summarized data plot
        
        ReOmitLickPlot(lick_time_struct,behavResults.Time_stimOnset,behavResults.Time_answer,10,Inds);
        ReOmtRespComp(data,behavResults.Time_answer,[-0.5,4],0.25,Inds,frame_rate);
        cd ..;

    end

%     %this modulation do not works well with current condition, maybe
%     %considering about using another way---the mouse is just not lick(without the sound cue)
%     if ~isempty(ActiveRewardInds)
%         disp('Active reward trials exists, doing followed analysis.\n');
%         ActiveRewardInds=behavResults.IsActiveReward;
%         isactivereawrd = 1;
%         
%     end

%%
%analysis of different trial result cooresponded neural response
%##################################################################################################################################

analysis_choice=0;
while analysis_choice==0
% continue_char=input('Select from following analysis type.\n 1 for onset time sequence analysis.\n 2 for alignment analysis.\n 3 for pca analysis.\n Other inputs will quit 2afc analysis.\n please input your option.\n','s');
continue_char = '2';
if str2double(continue_char)==1
    
    %################################################
    %%
    %data aligned to answer time, and performing following analysis
    %or maybe this part should be aligned to real reward time??? using
    %variabel 'FRewardLickT'
    if isdir('./Answer_time_align/')==0
        mkdir('./Answer_time_align/');
    end
    cd('./Answer_time_align/');
%     sequence_analysis(data,frame_rate,session_name(19:end),behavResults);
    AnsAlignData=Reward_Get_TimeAlign(data,lick_time_struct,behavResults,behavSettings,trial_outcome,frame_rate,imaging_time); %output is a three field variable with: Data, TrialType, AlignFrame
%     AnsAlignData=Reward_Get_TimeAlign(data,lick_time_struct,behavResults,behavSettings,trial_outcome,frame_rate,imaging_time,0);  % generate data only
    ROC_check(AnsAlignData.Data,AnsAlignData.TrialType,AnsAlignData.AlignFrame,frame_rate,[],'AnsT_Align');
    
    %###############################################
    %%
%     %plot of different types of trials
%     index_name = fieldnames(plot_data_inds);
%     
%     for i=1:length(index_name)
%         index = plot_data_inds.(index_name{i});
%         title_name=index_name{i}(1:end-5);
%         if ~isdir(['./',index_name{i},'/'])
%             mkdir(['./',index_name{i},'/']);
%         end
%         cd(['./',index_name{i},'/']);
%         %use TwoD_plot_matrix function for specific type plot
%         %TwoD_plot_matrix(data,title_name,frame_rate,index,session_name);
%         
%         %use session_plot function for summary plot of all trials
% %         session_plot(data,title_name,plot_data_inds,frame_rate,-1);   %####################################
%         %     function session_plot(data_aligned,session_date,plot_data_inds,frame_rate,varargin)
%         
%         %performing sequencial plot for each trial type
%         % sequence_analysis(data,frame_rate,title_name,behavResults,index);
%         %     function sequence_analysis(data,frame_rate,session_name,behavResults,index,varargin)
%     end
%     
%     cd ..;
    analysis_choice=1;
    
    cd ..;
    
elseif str2double(continue_char)==2
    %%
    SessionData.nROI = size_data(2);
    SessionData.FrameRate = frame_rate;
    %performing stimulus onset alignment
    %2AFC trigger should be at the begaining of each loop
    onset_time=behavResults.Time_stimOnset;
    stim_type_freq=behavResults.Stim_toneFreq;
    align_time_point=min(onset_time);
    alignment_frames=floor((double((onset_time-align_time_point))/1000)*frame_rate); 
    framelength=size_data(3)-max(alignment_frames);
    alignment_frames(alignment_frames<1)=1;
    start_frame=floor((double(align_time_point)/1000)*frame_rate);
    
    data_aligned=zeros(size_data(1),size_data(2),framelength);
    zscore_data_aligned=zeros(size_data(1),size_data(2),framelength);
    NorDataAligned=zeros(size_data(1),size_data(2),framelength);
%     SpikeAlign = zeros(size_data(1),size_data(2),framelength);
    for i=1:size_data(1)
        data_aligned(i,:,1:framelength)=data(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
        zscore_data_aligned(i,:,1:framelength)=zscore_data(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
        NorDataAligned(i,:,1:framelength)=NorData(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
%         SpikeAlign(i,:,:) = nSpikes(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
    end
    TrialTypes=behavResults.Trial_Type;
%     GPUdata=gpuArray(data_aligned);
%     GPUTrialType=gpuArray(TrialTypes);
%     GPUStartFrame=gpuArray(start_frame);
%     GPUFR=gpuArray(frame_rate);
    
    
%     rand_sample_class(data_aligned,start_frame,(start_frame+frame_rate),behavResults.Trial_Type,trial_outcome,session_date','corr');    
%     clearvars GPUdata GPUTrialType GPUStartFrame GPUFR
%%
    smooth_data=zeros(size_data(1),size_data(2),framelength);
    smooth_zs_data=zeros(size_data(1),size_data(2),framelength);
    smoothNorData=zeros(size_data(1),size_data(2),framelength);
%     smoothSpikes = zeros(size_data(1),size_data(2),framelength);
    NumROIs=size_data(2);
    parfor n=1:size_data(1)
        for m=1:NumROIs
%             smooth_data(n,m,:)=smooth(data_aligned(n,m,:),7,'sgolay',5); %using Savitzky¨CGolay filter to do the data smooth
            smooth_data(n,m,:)=smooth(data_aligned(n,m,:),5);
            smooth_zs_data(n,m,:)=smooth(zscore_data_aligned(n,m,:));
            smoothNorData(n,m,:)=smooth(NorDataAligned(n,m,:));
%             smoothSpikes(n,m,:) = smooth(SpikeAlign(n,m,:),3);
%             smooth_zs_data(n,m,:)=smooth(zscore_data_aligned(n,m,:),7,'sgolay',5);
        end
    end
    if isProbAsRandTone
        NormalTrialInds = true(length(behavResults.Trial_isProbeTrial),1);
    else
        NormalTrialInds = behavResults.Trial_isProbeTrial == 0;
    end
        
    if RandomSession
        SigROIinds = FreqRespOnsetHist(data_aligned,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate);
    end
    
    SessionSumColorplot(data_aligned,start_frame,trial_outcome,frame_rate,[],1);
    Partitioned_neurometric_prediction 
    Data_pcTrace_script
    save CSessionData.mat smooth_data data_aligned trial_outcome behavResults start_frame frame_rate NormalTrialInds -v7.3
    
    
    %%
    LRAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
         behavResults.Time_answer(NormalTrialInds),align_time_point,TrialTypes(NormalTrialInds),...
         frame_rate,onset_time(NormalTrialInds),0);
     TimeCourseStrc = TimeCorseROC(data_aligned(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],2);   
     %
     AUCDataAS = ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1.5,'Stim_time_Align');
     save AUCClassData.mat AUCDataAS -v7.3
     %
     AnsAlignData=Reward_Get_TimeAlign(data,lick_time_struct,behavResults,trial_outcome,frame_rate,imaging_time,0);
     if RandomSession
         FreqAlignedStrc = AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
         behavResults.Time_answer(NormalTrialInds),align_time_point,behavResults.Stim_toneFreq(NormalTrialInds),...
         frame_rate,onset_time(NormalTrialInds),0);
         FreqMeanTrace = FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),...
         trial_outcome(radom_inds),2,{1},frame_rate,start_frame,0);
         [ChoiceDataValue,ChoiceDataNumber] = ChoiceProbCal(smooth_data(NormalTrialInds,:,:),behavResults.Stim_toneFreq(NormalTrialInds),...
             behavResults.Action_choice(NormalTrialInds),1.5,start_frame,frame_rate,16000,0);
     end
     ROIAUCcolorp(TimeCourseStrc,start_frame/frame_rate);
     %
     nnspike = DataFluo2Spike(data_aligned,V,P); % estimated spike
     TimeCourseStrcSP = TimeCorseROC(nnspike(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],2,0);  
%      AUCDataASSP = ROC_check(nnspike(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],'Stim_time_Align',0,1.5);
     
     ROIAUCcolorp(TimeCourseStrcSP,start_frame/frame_rate,[],'Spike train');
     %
     script_for_summarizedPlot;  % call a script for data preparation and call summarized plot function
     
    %%
%     ActiveCellGene(data,behavResults,trial_outcome,frame_rate,1.5);
    CallFunCompPlot(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),frame_rate,start_frame,1.5);  % need rf data as function input
%     MeanAlignedDataPlot(smooth_data(NormalTrialInds,:,:),start_frame,behavResults.Trial_Type(NormalTrialInds),frame_rate,trial_outcome(NormalTrialInds));
%     TimeCourseStrc = TimeCorseROC(data_aligned(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,[],2);   %seperated ROC plot
%      AlignedSortPLot(data_aligned(NormalTrialInds,:,:),behavResults.Time_reward(NormalTrialInds),...
%          behavResults.Time_answer(NormalTrialInds),align_time_point,TrialTypes(NormalTrialInds),...
%          frame_rate,onset_time(NormalTrialInds));
    SignalCorr2afc(data_aligned(NormalTrialInds,:,:),trial_outcome(NormalTrialInds),behavResults.Stim_toneFreq(NormalTrialInds),start_frame,frame_rate,1);
%     popuROIpairCorr(smooth_data,behavResults.Stim_toneFreq,start_frame,frame_rate,[],'Max');
   %%
    % class define session and class based analysis
    DataAnaObj = DataAnalysisSum(data_aligned,behavResults.Stim_toneFreq,start_frame,frame_rate,1);  % smooth_data
    if RandomSession
        DataAnaObj.PairedAUCCal(1.5);
    end
    DataAnaObj.popuZscoredCorr(1.5,'Mean');
    DataAnaObj.popuSignalCorr(1.5,'Mean');
    %%
    FlickAnaFun(data,FLickT,FlickInds,TrialTypes,trial_outcome,frame_rate,1.5);
%      ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1.5,'Stim_time_Align');
%     TimeCorseROC(data_aligned,TrialTypes(NormalTrialInds),start_frame,frame_rate);  %cumulated ROC plot
     Left_right_pca_dis(smooth_data,behavResults,session_name,frame_rate,start_frame,[],[],data,2);
%     FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),2,{1},frame_rate,start_frame);
      if RandomSession
%           ShuffleNeuroMTest(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate);
          FlickAnaFun(data,FLickT,FlickInds,double(behavResults.Stim_toneFreq(NormalTrialInds)),trial_outcome,frame_rate,1.5);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1);
          RandNeuroMTPerfcorr(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,1.5);
          NBC_for2afc(smooth_data,behavResults.Stim_toneFreq,start_frame,frame_rate,1.5,TrialTypes); %naive bayes
          RandNeuroMLRC(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,TrialTypes,1.5);
           TrialByTNMtest(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1.5);
          MultiTScaleNMT(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,{0.1,0.15,0.2,0.3,[0.1,0.2],[0.2,0.3]});
          ChoiceProbCal(smooth_data,behavResults.Stim_toneFreq,behavResults.Action_choice,1.5,start_frame,frame_rate,16000);
          %%
%           SessionSumColorplot(data_aligned,start_frame,trial_outcome,frame_rate,[],1);
          if isempty(radom_inds)
                radom_inds = pure_tone_inds;
          end
          if ~exist('AUCDataAS','var')
              AUCDataAS = ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1.5,'Stim_time_Align');
               save AUCClassData.mat AUCDataAS -v7.3
          end
          TbyTAllROIclassInputParse(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,...
              'isWeightsave',1);
          FracTbyTPlot(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,AUCDataAS,...
              1.5,1,1);
          
          MultiTimeWinClass(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1);
%           FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),2,{1},frame_rate,start_frame,[],1);
          if RandomSession
%             RandNMTChoiceDecoding(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1.5,[],1);
%             RandNMTChoiceDecoding(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1.5);
%             RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1);
            multiCClass(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1.5);
            FreqRespCallFun(data_aligned(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),2,{1},frame_rate,start_frame);         
          end
          %
          if ~isdir('./EM_spike_analysis/')
              mkdir('./EM_spike_analysis/');
          end
          cd('./EM_spike_analysis/');
          if ~exist('nnspike','var')
             nnspike = DataFluo2Spike(data_aligned,V,P); % estimated spike
          end
           TbyTAllROIclassInputParse(nnspike(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,...
               'isDataOutput',0,'isErCal',1,'TimeLen',1,'TrOutcomeOp',1,'isWeightsave',1);
           FracTbyTPlot(nnspike(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,AUCDataAS,...
              1.5,1,1);
           MultiTimeWinClass(nnspike(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1,0.1);
%            RandNeuroMTestCrossV(nnspike(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),start_frame,frame_rate,1);
           %
          cd ..;

          %% #############################################
          % % % % %plot psychometrical curve based on decision time window
          ChoicelickTime = double(FLickT);
          OnsetT = double(behavResults.Time_stimOnset);
          TrialOut = trial_outcome;
          TrialType = double(behavResults.Trial_Type);
          RespTDiff = ChoicelickTime - OnsetT;
          CorrTrials = TrialOut == 1;
          CorrTTypes = TrialType(CorrTrials);
          CorrDiffT = RespTDiff(CorrTrials);
          CorrLeftDiffT = CorrDiffT(CorrTTypes == 0);
          CorrRightDiffT = CorrDiffT(CorrTTypes == 1);
          LeftSelectTWin = median(CorrLeftDiffT); 
          RightSelectWin = median(CorrRightDiffT); 
          %%
          if ~isdir('./Decision_win_Curve/')
              mkdir('./Decision_win_Curve/');
          end
          cd('./Decision_win_Curve/');
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,LeftSelectTWin/1000,[],[],SigROIinds);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,RightSelectWin/1000,[],[],SigROIinds);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,0.3,[],[],SigROIinds);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,1,[],[],SigROIinds);
          %%
          % Classification model loaded from outside
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,LeftSelectTWin/1000,[],1,SigROIinds);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,RightSelectWin/1000,[],1,SigROIinds);
          RandNeuroMTestCrossV(smooth_data(radom_inds,:,:),behavResults.Stim_toneFreq(radom_inds),trial_outcome(radom_inds),...
              start_frame,frame_rate,0.3,[],1,SigROIinds);
          %%
          cd ..;
          % % % %
          %% #############################################
          %           RandNeuroMTestNew(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,1.5);
          if ~isdir('./shuffle_CV_randPlot/')
              mkdir('./shuffle_CV_randPlot/');
          end
          cd('./shuffle_CV_randPlot/');
          RandNeuroMTestCrossV(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,frame_rate,1.5,1);
          cd ..;
          RandPTROCSelectivity(smooth_data,behavResults.Stim_toneFreq,start_frame,frame_rate);
          
          ROIremoveNMtest(smooth_data,behavResults.Stim_toneFreq,start_frame,frame_rate,1.5);
      end
    ROICoefDisCorr(smooth_data,center_ROI);
    TypeRespDistance(center_ROI,[],data);
    FCA_2AFC_classification(smooth_data,(double(behavResults.Trial_Type))',trial_outcome,session_name,frame_rate,start_frame);
%     All_trial_plot(data_aligned,plot_data_inds,frame_rate,align_time_point,'Stim onset',session_date);
    ROI_sequence_ana_update(smooth_zs_data,data_aligned,behavResults,plot_data_inds,start_frame,frame_rate,session_name);
    PCA_2AFC_classification(smooth_data,behavResults,session_name,frame_rate,start_frame);
    %###############################################################
    % Binned data generation and for analysis
    [BinnedData,BIn]=DataBinnedFunc(smooth_data,0.1,3,frame_rate);  %100ms binned of data
    BinFramerate = round(frame_rate/BIn);
    stimstart = round(start_frame / BIn);  % after binned data,column correlation is too high for many columns, not suitable for factor analysis
    PCA_2AFC_classification(BinnedData,behavResults,session_name,BinFramerate,stimstart);
    
    %################################################################
    %single trial response trace plot
%     trial_trace_plot(data_aligned,smooth_data,plot_data_inds.left_trials_bingo_inds',plot_data_inds.right_trials_bingo_inds',center_ROI,3);
    
    %########################################################
    %using alignment data for PCA analysis
    
    BinnedPCAPlot(smooth_data,behavResults,session_name,frame_rate,start_frame,3,3);
    if ~isdir('./Spike_Plot/')
        mkdir('./Spike_Plot/');
    end
    cd('./Spike_Plot/');
        MeanAlignedDataPlot(smoothSpikes,start_frame,behavResults.Trial_Type,frame_rate);
        PCA_2AFC_classification(SpikeAlign,behavResults,session_name,frame_rate,start_frame);
    cd ..;
%     Left_right_pca_dis(smooth_data,behavResults,session_name,frame_rate,start_frame,[],[],NorData);
    
    %popu ROI response alignment analysis
    
%     left_raw_data=ROI_sequence_ana(smooth_data(plot_data_inds.left_trials_bingo_inds,:,:),start_frame,frame_rate,session_name,'left_corr');
%     right_raw_data=ROI_sequence_ana(smooth_data(plot_data_inds.right_trials_bingo_inds,:,:),start_frame,frame_rate,session_name,'right_corr');
%     

%     cd ..;
%     ROI_selection_forPCA(data_aligned,behavResults,session_name,frame_rate,start_frame);
      %####################################################################
      %the followingh part will be used for training data for distinguish
%     ROI_selection(left_raw_data,right_raw_data);
%     training_thres_cal(smooth_data,behavResults.Trial_Type);
%     
    
    %#######################################################################
%     %performing data alignment according to the reward onset
%     reward_time_align=behavResults.Time_reward;
%     stim_type_freq=behavResults.Stim_toneFreq;
%     align_time_first_part=floor((double(min(reward_time_align))/1000)*frame_rate)-1;
%     align_time_last_part=size_data(3)-floor((double(max(reward_time_align))/1000)*frame_rate)-1;
%     reward_time_frames=floor((double(reward_time_align)/1000)*frame_rate);
%     framelength=align_time_first_part+align_time_last_part;
% %     alignment_frames(alignment_frames<1)=1;
%     
%     data_aligned_reward=zeros(size_data(1),size_data(2),framelength);
%     for i=1:size_data(1)
%         data_aligned_reward(i,:,1:framelength)=data(i,:,(reward_time_frames(i)-align_time_first_part):(reward_time_frames(i)+align_time_last_part-1));
%     end
% %     align_data_size=size(data_aligned)
% %     smooth_data=zeros(size_data(1),size_data(2),framelength);
% %     for n=1:size_data(1)
% %         for m=1:size_data(2)
% %             smooth_data(n,m,:)=smooth(data_aligned(n,m,:));
% %         end
% %     end
%     All_trial_plot(data_aligned_reward,plot_data_inds,frame_rate,align_time_first_part,'Reward time',session_date);
    %end of alignment according to reward time
    %#######################################################################
    
    
    %plot the 2-D color map with a new function
%     if ~isdir('./alignment_plot_save/')
%         mkdir('./alignment_plot_save/');
%     end
%     cd('./alignment_plot_save/');
%     session_plot(data_aligned,stim_type_freq,session_date,plot_data_inds,frame_rate,align_time_point);
%     
%     cd ..;
    analysis_choice=2;
    
    
elseif str2double(continue_char)==3
    %%
    %performing pca analysis
    if ~exist('data_aligned','var')
        %performing stimulus onset alignment
        %2AFC trigger should be at the begaining of each loop
        onset_time=behavResults.Time_stimOnset;
        align_time_point=min(onset_time);
        alignment_frames=floor((double((onset_time-align_time_point))/1000)*frame_rate);
        framelength=size_data(3)-max(alignment_frames);
        alignment_frames(alignment_frames<1)=1;
        
        data_aligned=zeros(size_data(1),size_data(2),framelength);
        for i=1:size_data(1)
            data_aligned(i,:,1:framelength)=data(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
        end
    end
    
    left_trials_bingo=data_aligned(plot_data_inds.left_trials_bingo_inds,:,:);
    right_trials_bingo=data_aligned(plot_data_inds.right_trials_bingo_inds,:,:);
    left_trials_oops=data_aligned(plot_data_inds.left_trials_oops_inds,:,:);
    right_trials_oops=data_aligned(plot_data_inds.right_trials_oops_inds,:,:);
    
    
    %pca anlysis of right left trials population activities
    corr_left=ROI_pca_ana(left_trials_bingo,session_date(19:end),'Correct left trials analysis result');
%     corr_left=corr_left_raw{1};
    %pca anlysis of wrong left trials population activities
    erro_left=ROI_pca_ana(left_trials_oops,session_date(19:end),'Wrong left trials analysis result');
%     erro_left=erro_left_raw{1};
    %pca anlysis of right right trials population activities
    corr_right=ROI_pca_ana(right_trials_bingo,session_date(19:end),'Correct right trials analysis result');
%     corr_right=corr_right_raw{1};
    %pca anlysis of wrong right trials population activities
    erro_right=ROI_pca_ana(right_trials_oops,session_date(19:end),'Wrong right trials analysis result');
%     erro_right=erro_right_raw{1};
    %the output pca analysis data should be a three dimensional dataform with
    %the three dimension contains three dimensional scores
    if traj_choice==1
        left_corr_erro_dis=sqrt((corr_left(:,1)-erro_left(:,1)).^2+(corr_left(:,2)-erro_left(:,2)).^2+...
            (corr_left(:,3)-erro_left(:,3)).^2);
        right_corr_erro_dis=sqrt((corr_right(:,1)-erro_right(:,1)).^2+(corr_right(:,2)-erro_right(:,2)).^2+...
            (corr_right(:,3)-erro_right(:,3)).^2);
        left_right_corr_dis=sqrt((corr_left(:,1)-corr_right(:,1)).^2+(corr_left(:,2)-corr_right(:,2)).^2+...
            (corr_left(:,3)-corr_right(:,3)).^2);
        
        if ~isdir('./PCA_distance_calculate/')
            mkdir('./PCA_distance_calculate/');
        end
        cd('./PCA_distance_calculate/');
        x=1:length(left_corr_erro_dis);
        h1=figure;
        plot(x,left_corr_erro_dis);
        title('distance of correct left and error left trials');
        %close;
        h2=figure;
        plot(x,right_corr_erro_dis);
        title('distance of correct right and error right trials');
        %close
        h3=figure;
        plot(x,left_right_corr_dis);
        title('distance of correct right and correct left trials');
        %close;
        saveas(h1,'Distance between correct left and error left trials','png');
        saveas(h2,'Distance between correct right and error right trials','png');
        saveas(h3,'Distance between correct left and correct right trials','png');
        close all;
        cd ..;
    else
        disp('analysis done!');
%         return;
    end
    analysis_choice=3;
else
    disp('Error choice,quit 2afc analysis.\n');
    return;
end
   if analysis_choice~=0
       analyzied_option=input('Choosed analysis done, tyr with other analysis?(y/n)\n','s');
       if strcmpi(analyzied_option,'y')
           analysis_choice=0;
       elseif strcmpi(analyzied_option,'n')
%            analysis_choice=1;
              break;
       end
   end
end
disp('2AFC analysis done!\n')
