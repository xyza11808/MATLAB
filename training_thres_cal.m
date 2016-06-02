function training_thres_cal(raw_data,trial_type)
%raw_data indicates for the three dimensional data that contains all the
%fluorescence data within a session
%comparing each ROIs own response with population mean result, and then
%calculate the mean value as final similarity

data_size=size(raw_data);
disp('Please select your reference data position.\n');
[filename,filepath,~]=uigetfile({'*.mat';'*.m'},'reference data selection');
cd(filepath);
load(filename);

if ~isdir('./training_result_save/')
    mkdir('./training_result_save/');
end
cd('./training_result_save/');

if ~isstruct(inds_struct)
	error('Error mat file being selected, no target variable exists.\n');
else
	if sum(isfield(inds_struct,{'left_corr_zs_sort_data','left_corr_zs_sort_inds','right_corr_zs_sort_inds','right_corr_zs_sort_data'}))<2;
		disp('Error field names within struct inds_struct, quit analysis.\n');
	end
end

left_corr_refer_inds=inds_struct.left_corr_zs_sort_inds;
left_corr_refer_data=inds_struct.left_corr_zs_sort_data;
right_corr_refer_inds=inds_struct.right_corr_zs_sort_inds;
right_corr_refer_data=inds_struct.right_corr_zs_sort_data;

% left_inds=find(trial_type==0);
% right_inds=find(trial_type==1);
% raw_left_data=raw_data(trial_type==0,:,:);
% raw_right_data=raw_data(trial_type==1,:,:);

if (0<size(raw_data,1)) && (size(raw_data,1)<100)
    sample_size=50;
elseif (100<=size(raw_data,1)) && (size(raw_data,1)<150)
    sample_size=100;
elseif 150<=size(raw_data,1)
    sample_size=120;
end

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    parpool('local',4);
end

training_num=10000;
mean_left_coeff=zeros(training_num,sample_size);
mean_right_coeff=zeros(training_num,sample_size);
trial_type_sample=zeros(training_num,sample_size);
size_raw_data=size(raw_data,1);
tic;
disp('Start training with distinguishing threshold.\n');
parfor n=1:training_num
    sample_inds=randsample(1:size_raw_data,sample_size);
    sample_raw_data=raw_data(sample_inds,:,:);
    sample_trial_type=trial_type(sample_inds);
    for m=1:sample_size
        temp_sample_data=squeeze(sample_raw_data(m,:,:));  %this variable is a two dimensional data with ROIs rows and time number of columns
        left_fit_data=temp_sample_data(left_corr_refer_inds,:);
        right_fit_data=temp_sample_data(right_corr_refer_inds,:);
        left_coeff=0;
        right_coeff=0;
        for k=1:size(left_fit_data,1)
            r=xcorr(left_fit_data(k,:),left_corr_refer_data(k,:),'coeff');
            left_coeff=left_coeff+max(r);
        end
        left_coeff=left_coeff/size(left_fit_data,1);
        
        for k=1:size(right_fit_data,1)
            r=xcorr(right_fit_data(k,:),right_corr_refer_data(k,:),'coeff');
            right_coeff=right_coeff+max(r);
        end
        right_coeff=right_coeff/size(right_fit_data,1);
        %considering the same trial with two different calculation
        %similarity, and using this value to calculate the correlation between this ratio and real trial type 
        mean_left_coeff(n,m)=left_coeff;
        mean_right_coeff(n,m)=right_coeff;
        trial_type_sample(n,m)=sample_trial_type(m);
    end
end
t=toc;
disp(['training data cost ' num2str(t) ' seconds.\n']);
%calculate the appropriate ratio to distinguish two types of trials
% left_trials=find(trial_type_sample==0);
% right_tiral=find(trial_type_sample==1);
mean_left_coeff(isnan(mean_left_coeff))=0.5;
mean_right_coeff(isnan(mean_right_coeff))=0.5;
if sum(isnan(mean_left_coeff))>20 | sum(isnan(mean_right_coeff))>20
    warning('Too many NaN data exists, the training data may not so accurate.\n All NaN data will be set to 0.5.\n');
end
distin_index=(mean_left_coeff-mean_right_coeff)./(mean_left_coeff+mean_right_coeff);
% left_trial_ratio=mean_left_coeff(trial_type_sample==0)./mean_right_coeff(trial_type_sample==0);
% right_trial_ratio=mean_right_coeff(trial_type_sample==1)./mean_left_coeff(trial_type_sample==1);
left_trial_index=distin_index(trial_type_sample==0);
right_trial_index=distin_index(trial_type_sample==1);

%##########################################################################
%do a ttest about the population mean value
[h,p,ci,status] = ttest2(left_trial_index(:),right_trial_index(:),'Vartype','unequal');
t_test=struct('Hypothesis',h,'p_value',p,'CI',ci,'status',status);
% save ttest_result.mat t_test -v7.3

%##########################################################################

h=figure;
subplot(1,2,1);
hist(left_trial_index);
title('left trial response index distribution');

subplot(1,2,2)
hist(right_trial_index);
title('right trial response index distribution');

saveas(h,'response ratio distribution of left and right trials','png');
close;

rowname={'Mean';'Std';'Median';'Var';'Max';'Min'};
left_index_summary=[mean(left_trial_index);std(left_trial_index);median(left_trial_index);var(left_trial_index);max(left_trial_index);min(left_trial_index)];
right_index_summary=[mean(right_trial_index);std(right_trial_index);median(right_trial_index);var(right_trial_index);max(right_trial_index);min(right_trial_index)];
summary=table(left_index_summary,right_index_summary,'RowNames',rowname);
disp('Training conplete.!\n')
disp(summary);
% disp('\n');
final_save=struct('Left_index',left_trial_index,'Right_index',right_trial_index,'TTest',t_test);
save index_result.mat final_save -v7.3

cd ..;
cd ..;