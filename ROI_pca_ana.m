function [varargout]=ROI_pca_ana(data,session_date,comment)
%this function used for ROI pca analysis, given the ROI analysis result at
%first and then calculate the further components according to user demands
%this function should be called by function post_ROI_calculation function

%%
% %load ROI analysis result
% filepath=input('please input the ROI output result file path.\n','s');
% cd(filepath);
% files=dir('*.mat');
% for i=1:length(files);
%     load(files(i).name);
%     if strncmp(files(i).name,'CaSignal',8)
%         export_filename=files(i).name(1:end-4);
%     end
%     disp(['loading file ',files(i).name]);
% end

%%default value of input
if nargin<3
    comment=[];
    if nargin<2
        session_date=datestr(now,30); 
    end
end

% a=size(CaTrials);
% trial_num=a(2);
% ROI_frame_size=size(CaTrials(1).f_raw);
% result_size=[trial_num,ROI_frame_size];  % this should be a three elements vector indicates the length of three dimensions
%this place should be modified
result_size=size(data);%this should be a three dimensional data form
%next reorganize all fluorescence data into a three dimension matrix, three
%dimensions goes as trial number, ROI numbers, spiking train
% data_sum=zeros(result_size);
% for i=1:trial_num
%     data_sum(i,:,:)=CaTrials(i).f_raw;
% end
sum_score=zeros(result_size(3),3);
if comment
    title_name=comment;
else
    title_name=session_date;
end

plot_save_name=strrep(title_name,' ','_');
if isdir(['.\' plot_save_name,'\'])==0
    mkdir(['.\' plot_save_name,'\']);
end
cd(['.\' plot_save_name,'\']);

h1=figure;
for i=1:result_size(1) %number of trials
    % for i=1:1
    %the raw data should be a two dimension data with ROI number of columns and
    %frames numeber of rows
    %thus the origin data need a transform first
    trans_data=permute(squeeze(data(i,:,:)),[2 1]);%rearrange the matrix according to the order given by [], the elements of the vector indicates different dimensions of the given matrix
   for n=1:result_size(2)
       trans_data(:,n)=smooth(trans_data(:,n));
   end
    [~,score,latent,~,~,mu]=pca(trans_data);
    
    if i==1
        pareto(latent);%µ÷ÓÃmatla»­Í¼
        %firstly plot the contribution of different principle components and then
        %they can decide how much principle cmponents are needed
        
        pc_num=input('please input the number of PCs you want to keep according to the plot:\n');
        %typically three components are used to plot the further plots
        temp_score=zeros(1,result_size(2));
        close;
    end
    
    if pc_num>3
        for j=3:pc_num
            temp_score=temp_score+score(:,j);
        end
    else
        temp_score=score(:,3);
    end
    % choosed_score=score(:,1:n);
    sum_score=sum_score+[score(:,1:2) temp_score];
    h1=plot3(score(:,1),score(:,2),temp_score,'color',rand(1,3));
    grid on;
    hold on;
    pause(0.1);
end

title(['population trajectory against timeline for ',title_name(18:end-11)]);
xlabel('component 1');ylabel('component 2');zlabel('component 3');
hold off;
ava_score=sum_score/result_size(1);

%avarage plot
h2=figure;
plot3(ava_score(:,1),ava_score(:,2),ava_score(:,3),'color',rand(1,3));
grid on;
title(['avarage trajectory for ' title_name(18:end-11)]);%bestly the trial data can be part of the title to indicate the tiral session
xlabel('component 1');ylabel('component 2');zlabel('component 3');
name_h1=[title_name 'total_plot' '.png'];
name_h2=[title_name 'ava_trace' '.png'];
saveas(h2,name_h2(19:end),'png');
saveas(h1,name_h1(19:end),'png');
close all;

%output the pca result of the final avarage for maybe the distance analysis
%when there are needed for output, can output the ava_score result
if nargout==1
    varargout{1}=ava_score;
else
    varargout{1}=[];
end 
cd ..;




