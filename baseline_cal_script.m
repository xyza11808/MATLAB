% triger_inds=floor(triger_time*frame_rate);
%f_change=zeros(result_size);
f_raw_trials=zeros([size(CaTrials,2),ROI_frame_size]);
f_baseline=zeros(trial_num,ROI_frame_size(1));
f_baseline_change=zeros([size(CaTrials,2),ROI_frame_size]);
for i=1:result_size(1)
    if size(CaTrials(i).f_raw,2)~=ROI_frame_size(2)
        %         CaTrials(i)=[];
        f_raw_trials(i,:,:)=NaN;
        exclude_trials=[exclude_trials i];
        continue;
    end
    f_raw_trials(i,:,:)=CaTrials(i).f_raw;
    if strcmpi(type,'rf')
       f_baseline(i,:)=mean(CaTrials(i).f_raw(:,1:triger_inds),2);
    elseif strcmpi(type,'2afc')
        f_baseline(i,:)=mean(CaTrials(i).f_raw(:,1:stim_onset_frame(i)),2);
    end
    for n=1:ROI_frame_size(1)
        f0=f_baseline(i,n);
        if f0==0
            warning(['Baseline fluorenscent level equal to 0, the percent change calculation might not correct for trial ',num2str(i)]);
            f0=1;
        end
        f_baseline_change(i,n,:)=((f_raw_trials(i,n,:)-f_baseline(i,n))/f0)*100;
    end
    %     f_baseline_change(i,:,:)=f_raw_trials(i,:,:)-repmat(f_baseline(i,:),ROI_frame_size(1),1);
end
if ~isempty(exclude_inds)
    CaTrials(exclude_inds)=[];
    eval(['CaSignal_',type,'(exclude_inds)','=','[];']);
    f_raw_trials(exclude_inds,:,:)=[];
    f_baseline(exclude_inds,:)=[];
end
f_baseline_change(f_baseline_change<0)=0;
%f_raw_trials is a three dimension matrix which first dimension means
%number of trials, sencond is number of ROIs, third is the number of frames
%it cantains the absolute value of ROI lightness

%######################################################################################
%add with a critiria to evaluate the mean fluorances change during single
%session, achived by mean value of single trial and go through all trials
%within a session, and plot a line to indicate
%since the analysis here only considering ROIs flu change during single
%session, so if we want to show the mean flu change within imaging field
%should use the load_scim_data.m function and a loop containing mean(x(:))
%of each frame to combined all imaging frames
%#######################################################################################


size_raw_trials=size(f_raw_trials);
f_mode=zeros(size_raw_trials(2));
f_percent_change=zeros(size_raw_trials);
f0_sign_data=zeros(size_raw_trials);

if ~isdir('./f0_distribution/')
    mkdir('./f0_distribution/');
end
cd('./f0_distribution/');
% temp_percent=zeros(size_raw_trials(3));
for  i=1:size_raw_trials(2)  %ROI mode calculation
    a=reshape(f_raw_trials(:,i,:),[],1);
    [N,x]=hist(a,100);
    [~,I]=max(N);
    %###########################################################
    h_raw=figure('visible','off');
    subplot(1,2,1);
    bar(x,N);
    hold on;
    temp_axis=axis;
    plot([x(I) x(I)],[temp_axis(3),temp_axis(4)],'color','r','LineWidth',1.5);
    text(x(I)*0.85,temp_axis(4)*1.02,'f_0 value');
    hold off;
    subplot(1,2,2);
    plot(a);
    set(gca,'xlim',[0 length(a)]);
    hold on;
    plot([0 length(a)],[x(I) x(I)],'color','r','LineWidth',2.5);
    hold off;
    suptitle(['Raw data distribution for ROI' num2str(i)]);
    saveas(h_raw,['Raw data distribution for ROI' num2str(i)],'png');
    close;
    %##############################################################
    
    f_mode(i)=min(x(I));
    try
        y=histogram(a,100,'Visible','off');
        value_scale = [y.BinEdges(I) y.BinEdges(I+1)];
    catch
        value_scale=[x(I-1) x(I+1)];
    end
    %to calculate the value scale of this centered bar or just use this
    %single value
%     f_mode(i)=min(x(N==max(N))); %calculate the value of F0
    
%###################################################################
    %plot the f0 distribution of procedeed dara
    f0_sign_data(:,i,:)=double(f_raw_trials(:,i,:) > value_scale(1) & f_raw_trials(:,i,:) < value_scale(2));
    h=imagesc(squeeze(f0_sign_data(:,i,:)));
    colorbar;
    xlabel('Frames');
    ylabel('Trials');
    title({['F_0 distribution for ROI' num2str(i)],'1 means F_0 value position'});
    saveas(h,['f0 distribution for ROI' num2str(i)],'png');
    close;
%##################################################################
    
    %calculate DF/F0
    for j=1:size_raw_trials(1)
        temp_percent=((f_raw_trials(j,i,:)- f_mode(i))/f_mode(i))*100;
        temp_percent(temp_percent<0)=0;
        f_percent_change(j,i,:)=temp_percent;
    end
end
save f0_dist_data.mat f0_sign_data -v7.3;