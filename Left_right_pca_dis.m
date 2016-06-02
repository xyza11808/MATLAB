function Left_right_pca_dis(InputData,behavResults,varargin)
%this function is attemptting to classify 2AFC choices according to gived
%data
%XIN Yu, 11th, Aug, 2015

if nargin>2
    session_name=(varargin{1});
    if size(session_name,1)~=1
        session_name=session_name';
    end
    frameRate=varargin{2};
    start_frame=varargin{3};
    
elseif nargin<3
    session_name=datestr(now,30); 
    frameRate=55; %default value
    start_frame=28; %default value
    
end

if nargin>5
    ROInds_left=varargin{4};
    ROInds_right=varargin{5};
    if isempty(ROInds_left) || isempty(ROInds_right)
        ROInds_selection=0;
    else
        ROInds_selection=1;
    end
else
    ROInds_selection=0;
end

if nargin>7
    UnalignedData=varargin{6};
    RewardDIs=1;
    datatype=varargin{7};
else
    RewardDIs=0;
    datatype=1;
%     UnalignedData=0;
end

if ROInds_selection
    ROInds=unique([ROInds_left(:)',ROInds_right(:)']);
    final_data=InputData(:,ROInds,:);
else
    final_data=InputData;
end

if datatype == 1
    if ~isdir('./stim_pca_disZs/')
       mkdir('./stim_pca_disZs/');
    end
    cd('./stim_pca_disZs/');
end

if datatype == 2
    if ~isdir('./stim_pca_disNor/')
        mkdir('./stim_pca_disNor/');
    end
    cd('./stim_pca_disNor/');
end

% data_size=size(final_data);
left_trials_bingo_inds=(behavResults.Trial_Type==0 & behavResults.Time_reward>0);
right_trials_bingo_inds=(behavResults.Trial_Type==1 & behavResults.Time_reward>0);
left_erro_inds=(behavResults.Trial_Type==0 & behavResults.Action_choice==1);
right_erro_inds=(behavResults.Trial_Type==1 & behavResults.Action_choice==0);
left_corr_data=final_data(left_trials_bingo_inds,:,:);
right_corr_data=final_data(right_trials_bingo_inds,:,:);
% left_erro_data=final_data(left_erro_inds,:,:);
% right_erro_data=final_data(right_erro_inds,:,:);

% left_data_size=size(left_corr_data);
% right_data_size=size(right_corr_data);
% left_erro_size=size(left_erro_data);
% right_erro_size=size(right_erro_data);

MeanLeftCorr=squeeze(mean(left_corr_data));
MeanRightCorr=squeeze(mean(right_corr_data));
LRCorrDiff=MeanLeftCorr-MeanRightCorr;
save LRRespDiffData.mat LRCorrDiff
disp('Performing pca analysis using only before and 1s after stim onset.\n');
[coeff,score,latent,ts,explained,mu]=pca(LRCorrDiff(:,start_frame:round(frameRate*1.5)+start_frame));

if sum(explained(1:3))<80
    warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
end
save pca_resp_result.mat coeff score latent ts explained mu
disp('please select your ttest analysis result(*.mat) for cell response.\n');
[filename,filepath,~]=uigetfile('*.mat','Select your ttest analysis result');
CurrentDir=pwd;
cd(filepath);
% files=dir('*.mat');
% for n=1:length(files)
%     filename=files(n).name;
    load(filename);
% end
cd(CurrentDir);
resSubsize=size(resp_inds);
LeftRespOInds=resp_inds(:,1)==1 & resp_inds(:,1+(resSubsize(2)/2))~=1;
RightRespOInds=resp_inds(:,1)~=1 & resp_inds(:,1+(resSubsize(2)/2))==1;
BothRespInds=resp_inds(:,1)==1 & resp_inds(:,1+(resSubsize(2)/2))==1;
NonDisInds=resp_inds(:,1)==0 & resp_inds(:,1+(resSubsize(2)/2))==0;
h=figure;
plot(score(:,1),score(:,2),'+','color','c');
MarkerDesp={'Raw\_pca\_score'};
xlabel('PC1','FontSize',22);
ylabel('PC2','FontSize',22);
title('PC score for different types of neurons')
hold on
plot(score(LeftRespOInds,1),score(LeftRespOInds,2),'o','color','b','LineWidth',1.5);
if sum(LeftRespOInds)
    MarkerDesp=[MarkerDesp,{'LeftResp'}];
end
plot(score(RightRespOInds,1),score(RightRespOInds,2),'d','color','r','LineWidth',1.5);
if sum(RightRespOInds)
    MarkerDesp=[MarkerDesp,{'RightResp'}];
end
plot(score(NonDisInds,1),score(NonDisInds,2),'p','color','g','LineWidth',1.5);
if sum(NonDisInds)
    MarkerDesp=[MarkerDesp,{'NonDis'}];
end
plot(score(BothRespInds,1),score(BothRespInds,2),'s','color','g','LineWidth',1.5);
if sum(NonDisInds)
    MarkerDesp=[MarkerDesp,{'BothResp'}];
end
hold off
legend(MarkerDesp,'location','NorthEastOutside'); %this will make some mistake when some of the Inds are empty
saveas(h,[session_name 'pca_stim'],'png');
saveas(h,[session_name 'pca_stim']);
close;
save LeftRightRespInds.mat LeftRespOInds RightRespOInds NonDisInds -v7.3
currentpath=pwd;
if sum(LeftRespOInds) || sum(RightRespOInds)
    ROI_Plot([],[],1,LeftRespOInds,RightRespOInds);
end
cd(currentpath);
% cd ..;

%calculate the left and right response time, seperate into left and right,
%each of the will be separated by correct and error trials.
%correct trials will using the time reward as onset, but the error trials
%will use time answer as onset. miss trials wll be excluded
if RewardDIs
    LeftCRewardT=floor((double(behavResults.Time_reward(left_trials_bingo_inds))/1000)*frameRate);
    RightCRewardT=floor((double(behavResults.Time_reward(right_trials_bingo_inds))/1000)*frameRate);
    LeftERewardT=floor((double(behavResults.Time_answer(left_erro_inds))/1000)*frameRate);
    RightERewardT=floor((double(behavResults.Time_answer(right_erro_inds))/1000)*frameRate);
    
    LeftCData=UnalignedData(left_trials_bingo_inds,:,:);
    LeftCRData=zeros(size(LeftCData,1),size(LeftCData,2),frameRate);
    for n=1:size(LeftCData,1)
        if (LeftCRewardT(n)+frameRate) > size(LeftCData,3)
            LeftCRData(n,:,:)=LeftCData(n,:,end-frameRate+1:end);
        else
            LeftCRData(n,:,:)=LeftCData(n,:,(LeftCRewardT(n)+1):(LeftCRewardT(n)+frameRate));
        end
    end
    MeanLeftCRData=squeeze(mean(LeftCRData));
    
    RightCData=UnalignedData(right_trials_bingo_inds,:,:);
    RightCRData=zeros(size(RightCData,1),size(RightCData,2),frameRate);
    for n=1:size(RightCData,1)
        if (RightCRewardT(n)+frameRate) > size(RightCData,3)
            RightCRData(n,:,:)=RightCData(n,:,(end-frameRate+1):end);
        else
            RightCRData(n,:,:)=RightCData(n,:,(RightCRewardT(n)+1):(RightCRewardT(n)+frameRate));
        end
    end
    
    MeanRightCRData=squeeze(mean(RightCRData));
    
    LeftEData=UnalignedData(left_erro_inds,:,:);
    LeftERData=zeros(size(LeftEData,1),size(LeftEData,2),frameRate);
    for n=1:size(LeftEData,1)
        if (LeftERewardT(n)+frameRate) > size(LeftEData,3)
            LeftERData(n,:,:)=LeftEData(n,:,(end-frameRate+1):end);
        else
            LeftERData(n,:,:)=LeftEData(n,:,(LeftERewardT(n)+1):(LeftERewardT(n)+frameRate));
        end
    end
    if size(LeftERData,1)==1
        MeanLeftERData=squeeze(LeftERData);
    else
        MeanLeftERData=squeeze(mean(LeftERData));
    end
    
    RightEData=UnalignedData(right_erro_inds,:,:);
    RightERData=zeros(size(RightEData,1),size(RightEData,2),frameRate);
    for n=1:size(RightEData,1)
        if (RightERewardT(n)+frameRate) > size(RightEData,3)
            RightERData(n,:,:)=RightEData(n,:,(end-frameRate+1):end);
        else
            RightERData(n,:,:)=RightEData(n,:,(RightERewardT(n)+1):(RightERewardT(n)+frameRate));
        end
    end
    if size(RightERData,1)==1
        MeanRightERData=squeeze(RightERData);
    else
        MeanRightERData=squeeze(mean(RightERData));
    end
    
    LeftCRDiff=MeanLeftCRData-MeanLeftERData;
    RightCRDiff=MeanRightCRData-MeanRightERData;
    LeftRightDiff=LeftCRDiff+RightCRDiff; %matrix with m ROIs by n timepoints
    
%     if ~isdir('./reward_pca_disZs/')
%         mkdir('./reward_pca_disZs/');
%         cd('./reward_pca_disZs/');
%     elseif ~isdir('./reward_pca_disNor/')
%         mkdir('./reward_pca_disNor/');
%         cd('./reward_pca_disNor/');
%     else
%         cd('./reward_pca_disZs/');
%     end

    LeftRewardInds=resp_inds(:,1)~=1 & resp_inds(:,2)==1 & resp_inds(:,3)~=1 & resp_inds(:,4)~=1;
    RightRewardInds=resp_inds(:,1)~=1 & resp_inds(:,2)~=1 & resp_inds(:,3)~=1 & resp_inds(:,4)==1;
 if ~(isempty(LeftCRDiff) || sum(isnan(LeftCRDiff(:))))
    %single side correct and error trial response difference classification
    [coeff_1,score_1,latent_1,ts_1,explained_1,mu_1]=pca(LeftCRDiff);
    if sum(explained_1(1:3))<80
        warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
    end
    save pca_reward_LeftCRresult.mat coeff_1 score_1 latent_1 ts_1 explained_1 mu_1
    h_1=figure;
    plot(score_1(:,1),score_1(:,2),'+','color','c');
    xlabel('PC1');
    ylabel('PC2');
    title('Left correct and error response(reward) PC score');
    hold on
    plot(score_1(LeftRewardInds,1),score_1(LeftRewardInds,2),'o','color','r');
    hold off
    legend('Raw\_score','LeftReward','location','NorthEastOutside'); 
    saveas(h_1,'reward_response_diff_left_trial','png');
    saveas(h_1,'reward_response_diff_left_trial');
    close;
 end
    
 if ~(isempty(RightCRDiff) || sum(isnan(RightCRDiff(:))))
    [coeff_2,score_2,latent_2,ts_2,explained_2,mu_2]=pca(RightCRDiff);
    if sum(explained_2(1:3))<80
        warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
    end
    save pca_reward_RightCRresult.mat coeff_2 score_2 latent_2 ts_2 explained_2 mu_2
    h_2=figure;
    plot(score_2(:,1),score_2(:,2),'+','color','c');
    xlabel('PC1');
    ylabel('PC2');
    title('Left correct and error response(reward) PC score');
    hold on
    plot(score_2(RightRewardInds,1),score_2(RightRewardInds,2),'o','color','r');
    hold off
    legend('Raw\_score','RightReward','location','NorthEastOutside'); 
    saveas(h_2,'reward_response_diff_right_trial','png');
    saveas(h_2,'reward_response_diff_right_trial');
    close;
 end
 
 if ~(isempty(LeftRightDiff) || sum(isnan(LeftRightDiff(:))))
    [coeff_3,score_3,latent_3,ts_3,explained_3,mu_3]=pca(LeftRightDiff);
    if sum(explained_3(1:3))<80
        warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
    end
    save pca_reward_RightCRresult.mat coeff_3 score_3 latent_3 ts_3 explained_3 mu_3
    h_3=figure;
    plot(score_3(:,1),score_3(:,2),'+','color','c');
    xlabel('PC1');
    ylabel('PC2');
    title('Left correct and error response(reward) PC score');
    hold on
    plot(score_3(RightRewardInds,1),score_3(RightRewardInds,2),'o','color','r');
    plot(score_3(LeftRewardInds,1),score_3(LeftRewardInds,2),'d','color','b');
    hold off
    legend('Raw\_score','RightReward','LeftReward','location','NorthEastOutside'); 
    saveas(h_3,'reward_response_diff_CR_trial','png');
    saveas(h_3,'reward_response_diff_CR_trial');
    close;
 end
    cd ..;
end
% %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% %the following part will be used for correct and error trial distinguish
% if ~isempty(UnalignedData)
%    RewardTime=behavResults.Time_reward;
%    TrialFrameLength=size(UnalignedData,3);
%    RewardFrame=floor((double(RewardTime)/1000)*frameRate);
%    SegmentRange=[frameRate frameRate];
%    if (max(RewardFrame)+frameRate) > TrialFrameLength
%        SegmentRange(2)=TrialFrameLength-max(RewardFrame)-1;
%    end
%    SegmentData=UnalignedData(:,:,(RewardFrame-SegmentRange(1)):(RewardFrame+SegmentRange(2)));
%     %use time answer instead for error trials
%    LeftErroData=SegmentData(left_erro_inds,:,:);
%    RightErroData=SegmentData(right_erro_inds,:,:);
%    MeanErroLeft=squeeze(mean(LeftErroData));
%    MeanErroRight=squeeze(mean(RightErroData));
%    DiffLeftCR=MeanLeftCorr-MeanErroLeft;  %matrix with m ROIs by n timepoints
%    DiffRightCR=MeanRightCorr-MeanErroRight; %matrix with m ROIs by n timepoints
%    [coeff2,score2,latent2,ts2,explained2,mu2]=pca(DiffLeftCR);
%    if sum(explained2(1:3))<80
%     warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
%    end
%    save pca_resp_LeftCRresult.mat coeff2 score2 latent2 ts2 explained2 mu2
%    LeftRewardInds=resp_inds(:,1)~=1 & resp_inds(:,2)==1 & resp_inds(:,3)~=1 & resp_inds(:,4)~=1;
%    RightRewardInds=resp_inds(:,1)~=1 & resp_inds(:,2)~=1 & resp_inds(:,3)~=1 & resp_inds(:,4)==1;
%    
%     h2=figure;
%     plot(score2(:,1),score2(:,2),'+','color','c');
%     xlabel('PC1');
%     ylabel('PC2');
%     title('PC score for different types of neurons')
%     hold on
%     plot(score2(LeftRewardInds,1),score2(LeftRewardInds,2),'o','color','r');
%     legend('Raw\_pca_score','LReResp','location','NorthEastOutside');
%     hold off
%     saveas(h2,[session_name '_pca_LRe'],'png');
%     saveas(h2,[session_name '_pca_LRe']);
%     close;
%     
%     [coeff3,score3,latent3,ts3,explained3,mu3]=pca(DiffRightCR);
%     if sum(explained2(1:3))<80
%      warning('The contribution of the first three PC is less than 80%, the pca result may not that good.\n');
%     end
%     save pca_resp_LeftCRresult.mat coeff3 score3 latent3 ts3 explained3 mu3
%     h3=figure;
%     plot(score3(:,1),score3(:,2),'+','color','c');
%     xlabel('PC1');
%     ylabel('PC2');
%     title('PC score for different types of neurons')
%     hold on
%     plot(score3(RightRewardInds,1),score3(RightRewardInds,2),'d','color','r');
%     legend('Raw\_pca_score','RReResp','location','NorthEastOutside');
%     hold off
%     saveas(h3,[session_name '_pca_RRe'],'png');
%     saveas(h3,[session_name '_pca_RRe']);
%     close;
% end