function [varargout]=in_site_freTuning(FluoData,SoundStim,type,varargin)
%this function used for plot in site frequency tuning map of the ROIs in
%the same window
%to simplify function input, all the four structure is need for this function
%

if strcmpi(type,'2AFC')
    fit_option = varargin{1};
    %load ROI analysis result
    disp('please input the RF ROIs analysis result file path of the same imaging field.\n');
    filepath=uigetdir();
    cd(filepath);
    files=dir('*.mat');
    for i=1:length(files);
        load(files(i).name);
        disp(['loading file ',files(i).name,'...\n']);
    end
    frame_rate=floor(1000/CaTrials(1).FrameTime);
    Ca_string=whos('CaTri*');
    eval(['CaSignal_','RF_insite','=',Ca_string.name,';']);
    triger_time=input('please input the triger time before sound stimulus deliverying, with default value is 1s.\n');
    if isempty(triger_time)
           triger_time=1;
    end
triger_inds=(triger_time*frame_rate);
elseif strcmpi(type,'RF')
    CaSignal_RF_insite=varargin{1};
    if nargin==3
        fit_option=[];
    else
        fit_option=varargin{2};
    end
    triger_inds=varargin{3};
end


%should be the name of result containing file
a=size(CaSignal_RF_insite);
trial_num=a(2);
ROI_frame_size=size(CaSignal_RF_insite(1).f_raw);
% result_size=[trial_num,ROI_frame_size];  % this should be a three elements vector indicates the length of three dimensions
%this place should be modified
% session_date=Ca_string(1).FileName_prefix(:);

% 
% %f_change=zeros(result_size);
% f_raw_trials=zeros(result_size);
% f_baseline=zeros(trial_num,ROI_frame_size(1));
% f_baseline_change=zeros([trial_num,ROI_frame_size]);
% for i=1:result_size(1)
%     f_raw_trials(i,:,:)=CaSignal_RF_insite(i).f_raw;
%      f_baseline(i,:)=mean(CaSignal_RF_insite(i).f_raw(:,1:triger_inds),2);
%     for n=1:ROI_frame_size(1)
%         f0=f_baseline(i,n);
%         if f0==0
%             warning(['Baseline fluorenscent level equal to 0, the percent change calculation might not correct for trial ',num2str(i)]);
%             f0=1;
%         end
%         f_baseline_change(i,n,:)=((f_raw_trials(i,n,:)-f_baseline(i,n))/f0)*100;
%     end
% end
% 
% size_raw_trials=size(f_raw_trials);
% f_mode=zeros(size_raw_trials(2));
% f_percent_change=zeros(size_raw_trials);
% 
% % temp_percent=zeros(size_raw_trials(3));
% for  i=1:size_raw_trials(2)  %ROI mode calculation
%     a=reshape(f_raw_trials(:,i,:),[],1);
%     [N,x]=hist(a,100);
%     f_mode(i)=min(x(N==max(N)));%calculate the value of F0
%     
%     %calculate DF/F0
%     for j=1:size_raw_trials(1)
%         temp_percent=((f_raw_trials(j,i,:)- f_mode(i))/f_mode(i))*100;
%         temp_percent(temp_percent<0)=0;
%         f_percent_change(j,i,:)=temp_percent;
%     end
% end


data_size=size(FluoData);
% Stim_size=size(SoundStim);
save_file_name=CaSignal_RF_insite(1).FileName_prefix(:)';

freq_type=unique(SoundStim(:,1));
DB_type=unique(SoundStim(:,2));
DB_type=sort(DB_type,'descend');
% cf=floor(rand(1,data_size(2))*300);

%%
%mean response generation
time_scale=input('please input the lower and upper value of the mean calculate time scale.\n');
if isempty(time_scale)
    time_scale=[1,2.5];
end
frame_rate=1000/CaSignal_RF_insite(1).FrameTime;
frame_inds=floor(time_scale.*frame_rate);
% maxium_response=zeros(data_size(1),data_size(2),1);
maxium_response_mode=zeros(data_size(1),data_size(2),1);
% maxium_response_BS=zeros(data_size(1),data_size(2),1);
for i=1:data_size(2)
    for j=1:data_size(1)
        maxium_response_mode(j,i,1)=mean(FluoData(j,i,min(frame_inds):max(frame_inds)));
%         maxium_response_BS(j,i,1)=mean(f_baseline_change(j,i,min(frame_inds):max(frame_inds)));
    end
end

mean_max_resp=zeros(data_size(2),length(DB_type),length(freq_type));
step=floor(max(freq_type)/(length(freq_type)));
freq_tick=step:step:max(freq_type);
% format bank;
% freq_label=log2(freq_type/min(freq_type));
freq_label=freq_type./1000;
DB_label=num2cell(DB_type);
% DB_label=flipud(DB_label);
%by now the maxium_response should be an three dimensional data form with
%the third dimension indicates the maxium value of each trial and ROI

%#######################  mode percent change
%plot  ######################################
if isdir('.\mode_percent_change\')==0
    mkdir('.\mode_percent_change\');
end
cd('.\mode_percent_change\');

if isdir('.\ROI_response\')==0
    mkdir('.\ROI_response\');
end

if isdir('.\line_plot\')==0
    mkdir('.\line_plot\');
end

maxium_response=maxium_response_mode;
for i=1:data_size(2)
    if (sum(maxium_response(:,i,:))==0) | (sum(isnan(maxium_response(:,i,:)))~=0)
           maxium_response(:,i,:)=[];
            continue;
    end
    for j=1:length(DB_type)
        for k=1:length(freq_type)
            %             mean_max_resp(k,:,:)=freq_type(k);
            %             mean_max_resp(:,j,:)=DB_type(j);
            mean_max_resp(i,j,k)=mean(squeeze(maxium_response(SoundStim(:,1)==freq_type(k)&SoundStim(:,2)==DB_type(j),i,:)));
        end
    end
    cd('.\ROI_response\');
    C=cast(squeeze(mean_max_resp(i,:,:)),'int16');
    cmin_value=min(C(:));
    cmax_value=max(C(:));
    h1=figure;
    imagesc(freq_type,DB_type,C,[cmin_value cmax_value]);
    colormap(flipud(hot));
    set(gca,'YDir','normal');
    title(['sound response of ROI ',num2str(i)]);
    xlabel('frequency(KHz)');
    set(gca,'XTick',freq_tick);
    set(gca,'xticklabel',sprintf('%.1f|',freq_label));
    ylabel('Intensity(Volume)');
    set(gca,'YTick',flipud(DB_type));
    set(gca,'yticklabel',flipud(DB_label));
    colorbar;
    set(get(colorbar,'Title'),'string','\Deltaf/f_0');
    hold on;
    final_name=[save_file_name '_ROI_' num2str(i) '.png'];
    saveas(h1,final_name);
    %     close;
    % end
    %
    % cd ..;
    %
    if strcmpi(fit_option,'nfit')
        boundary_inds=zeros(length(DB_type),2);
        cf=zeros(1,data_size(2));
        % for i=1:data_size(2)
        f_sum=reshape(mean_max_resp(i,:,:),[],1);
        base_value=2*std(f_sum);
        for j=1:length(DB_type)
            freq_response=squeeze(mean_max_resp(i,j,:));
            freq_response=smooth(freq_response,9);
            inds=find(freq_response>base_value);
            if min(inds)==max(inds)
                boundary_inds(j,1)=min(inds)-1;
                boundary_inds(j,2)=max(inds)+1;
            elseif isempty(inds)
                inds=find(freq_response>2*std(freq_response));
                boundary_inds(j,1)=min(inds);
                boundary_inds(j,2)=max(inds);
            else
                boundary_inds(j,1)=min(inds);
                boundary_inds(j,2)=max(inds);
            end
        end
        %     h2=figure;
        %     imagesc(freq_type,DB_type,cast(squeeze(mean_max_resp(i,:,:)),'int16'),[0 300]);
        %     colormap(flipud(hot));
        %     hold on;
        boundary_points=[freq_type(reshape(boundary_inds,[],1)),repmat(DB_type,2,1)];
        scatter(boundary_points(:,1),boundary_points(:,2),20,'MarkerEdgeColor','b','MarkerFaceColor','g','LineWidth',0.5);
        hold on;
        
        modelfun=@(b,x)(b(1)*power(x,2)+b(2)*x+b(3));
        beta0=[1,1,1];
        opts = statset('nlinfit');
        opts.RobustWgtFun = 'bisquare';
        beta=nlinfit(boundary_points(:,1),boundary_points(:,2),modelfun,beta0,opts);
        if beta(1)>=0
            error('wrong fit of boundary points, see the points distribution to reshape the fitting data');
        else
            fit_curve=modelfun(beta,freq_type);
            plot(freq_type,fit_curve);
            hold off;
            saveas(h1,['fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
            close;
            %         model=@(x)(beta(1)*x.^2+beta(2)*x+beta(3));
            %         CF=fsolve(model,repmat(mean(boundary_points(:,2)),1,2));
            cf(i) = min(fit_curve);
            close;
        end
    elseif (strcmpi(fit_option,'no-fit')||isempty(fit_option));
        disp('avoiding non-linear fit analysis.\n');
        hold off;
        saveas(h1,['fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
        close;
    elseif strcmpi(fit_option,'simple_fit')
        cf(i)=0;
        m=1;
        [B,I]=sort(C(end,:),'descend');
        f_sum=reshape(mean_max_resp(i,:,:),[],1);
        base_value=2*std(f_sum);
        
        while  cf(i)==0
            inds=I(m);
            if inds==length(B)
                inds_scale=inds-1:inds;
            elseif inds==1
                inds_scale=inds:inds+1;
            else
                inds_scale=inds-1:inds+1;
            end
            if sum(C(end-1,inds_scale)>base_value)
                cf(i)=freq_type(I(m));
%                 maxium_response(i)=B(m);
            end
            m=m+1;
            if m>length(B)
                cf(i)=freq_type(I(1));
                %              error('No CF found, quit analysis.\n');
            end
        end
        scatter(freq_tick(I(m-1)),DB_type(end),20,'MarkerEdgeColor','b','MarkerFaceColor','g','LineWidth',0.5);
        hold off;
        saveas(h1,['none-fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
        close;
    end
    
    cd ..;
    
    cd('.\line_plot\');
    h3=figure;
    %     label=zeros(length(DB_type),1);
    for j=1:length(DB_type)
        label(j)={[num2str(DB_type(j)),'DB']};
    end
    %     hh=axis;
    %     triger_time=input('please input the triger time before sound stimulus deliverying, with default value is 1s.\n');
    %     if isempty(triger_time)
    %         triger_time=1;
    %     end
    %     plot([triger_time,triger_time],[hh(3),hh(4)],'color','k','LineWidth',1);
    plot(C','-o','LineWidth',1.5,'MarkerSize',8);
    hold off;
    legend(label,'Location','NorthEastOutside');
    title(['ROI',num2str(i)]);
    set(gca,'xtick',1:length(freq_type),'xticklabel',sprintf('%.1f|',freq_label));
    xlabel('frequency(KHz)');
    ylabel('\DeltaF/F_0');
    saveas(h3,['DB_diff plot of  ' save_file_name,' ROI ' num2str(i) '.png'],'png');
    close;
    cd ..;
end

disp('critical tuning frequency for all ROIs calculation done!\n');

if nargout==1
    varargout=cf;
else
    varargout=[];
end

%%
%performing in site plot of ROIs CF
ROI_sumation_mask=double(CaSignal_RF_insite(1).ROIinfo.ROImask{1});
ROI_sumation=ROI_sumation_mask*cf(1);
for i=2:data_size(2)  %number of ROIs
    ROI_add=double(CaSignal_RF_insite(1).ROIinfo.ROImask{i});
    ROI_pre=zeros(size(ROI_add));
    ROI_matrix=ROI_sumation_mask+ROI_add;
    over_inds=find(ROI_matrix==2);
    if ~over_inds
        ROI_pre(over_inds)=0.5;
        ROI_add(over_inds)=0.5;
    end
    ROI_sumation_mask=ROI_sumation_mask+ROI_add-ROI_pre;
    ROI_sumation=ROI_sumation+ROI_add*cf(i)-ROI_pre*cf(i-1);
end

test=find(ROI_sumation_mask>1);
if ~test
    error('error ROI sumation mask, quit analysis.');
end

low_clim=min(ROI_sumation(:));
high_clim=max(ROI_sumation(:));
step_colorbar=(high_clim-low_clim)/9;
ytick_colorlabel=low_clim:step_colorbar:high_clim;
ytick_colorlabel=ytick_colorlabel./1000;
[M,~,C]=mode(cf);
if length(C{1})>1
    CF_filed=mean(C{1});
else
    CF_filed=M;
end

h3=figure;
imagesc(ROI_sumation,[low_clim high_clim]);
colormap(flipud(hot));
h4=colorbar;
set(get(h4,'title'),'string','Freq(KHz)');
set(h4,'yTicklabel',sprintf('%.1f|',ytick_colorlabel));
% frame ture;
title(['In site plot of ROIs tuning properties with CF-' num2str(CF_filed),'Hz']);
axis off;
saveas(h3,[save_file_name,'ROIs_tuning_info_with_CF',num2str(CF_filed),'.png'],'png');
close;
disp([save_file_name,' ROIs in site plot complete!\n']);

% %#############baseline plot plot########################
% if isdir('.\baseline_percent_change\')==0
%     mkdir('.\baseline_percent_change\');
% end
% cd('.\baseline_percent_change\');
% 
% if isdir('.\ROI_response\')==0
%     mkdir('.\ROI_response\');
% end
% 
% if isdir('.\line_plot\')==0
%     mkdir('.\line_plot\');
% end
% maxium_response=maxium_response_BS;
% for i=1:data_size(2)
%     if (sum(maxium_response(:,i,:))==0) | (sum(isnan(maxium_response(:,i,:)))~=0)
%            maxium_response(:,i,:)=[];
%             continue;
%     end
%     for j=1:length(DB_type)
%         for k=1:length(freq_type)
%             %             mean_max_resp(k,:,:)=freq_type(k);
%             %             mean_max_resp(:,j,:)=DB_type(j);
%             mean_max_resp(i,j,k)=mean(squeeze(maxium_response(SoundStim(:,1)==freq_type(k)&SoundStim(:,2)==DB_type(j),i,:)));
%         end
%     end
%     cd('.\ROI_response\');
%     C=cast(squeeze(mean_max_resp(i,:,:)),'int16');
%     cmin_value=min(C(:));
%     cmax_value=max(C(:));
%     h1=figure;
%     imagesc(freq_type,DB_type,C,[cmin_value cmax_value]);
%     colormap(flipud(hot));
%     set(gca,'YDir','normal');
%     title(['sound response of ROI ',num2str(i)]);
%     xlabel('frequency(KHz)');
%     set(gca,'XTick',freq_tick);
%     set(gca,'xticklabel',sprintf('%.1f|',freq_label));
%     ylabel('Intensity(Volume)');
%     set(gca,'YTick',flipud(DB_type));
%     set(gca,'yticklabel',flipud(DB_label));
%     colorbar;
%     set(get(colorbar,'Title'),'string','\Deltaf/f_0');
%     hold on;
%     final_name=[save_file_name '_ROI_' num2str(i) '.png'];
%     saveas(h1,final_name);
%     %     close;
%     % end
%     %
%     % cd ..;
%     %
%     if strcmpi(fit_option,'nfit')
%         boundary_inds=zeros(length(DB_type),2);
%         cf=zeros(1,data_size(2));
%         % for i=1:data_size(2)
%         f_sum=reshape(mean_max_resp(i,:,:),[],1);
%         base_value=2*std(f_sum);
%         for j=1:length(DB_type)
%             freq_response=squeeze(mean_max_resp(i,j,:));
%             freq_response=smooth(freq_response,9);
%             inds=find(freq_response>base_value);
%             if min(inds)==max(inds)
%                 boundary_inds(j,1)=min(inds)-1;
%                 boundary_inds(j,2)=max(inds)+1;
%             elseif isempty(inds)
%                 inds=find(freq_response>2*std(freq_response));
%                 boundary_inds(j,1)=min(inds);
%                 boundary_inds(j,2)=max(inds);
%             else
%                 boundary_inds(j,1)=min(inds);
%                 boundary_inds(j,2)=max(inds);
%             end
%         end
%         %     h2=figure;
%         %     imagesc(freq_type,DB_type,cast(squeeze(mean_max_resp(i,:,:)),'int16'),[0 300]);
%         %     colormap(flipud(hot));
%         %     hold on;
%         boundary_points=[freq_type(reshape(boundary_inds,[],1)),repmat(DB_type,2,1)];
%         scatter(boundary_points(:,1),boundary_points(:,2),20,'MarkerEdgeColor','b','MarkerFaceColor','g','LineWidth',0.5);
%         hold on;
%         
%         modelfun=@(b,x)(b(1)*power(x,2)+b(2)*x+b(3));
%         beta0=[1,1,1];
%         opts = statset('nlinfit');
%         opts.RobustWgtFun = 'bisquare';
%         beta=nlinfit(boundary_points(:,1),boundary_points(:,2),modelfun,beta0,opts);
%         if beta(1)>=0
%             error('wrong fit of boundary points, see the points distribution to reshape the fitting data');
%         else
%             fit_curve=modelfun(beta,freq_type);
%             plot(freq_type,fit_curve);
%             hold off;
%             saveas(h1,['fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
%             close;
%             %         model=@(x)(beta(1)*x.^2+beta(2)*x+beta(3));
%             %         CF=fsolve(model,repmat(mean(boundary_points(:,2)),1,2));
%             cf(i) = min(fit_curve);
%             close;
%         end
%     elseif (strcmpi(fit_option,'no-fit')||isempty(fit_option));
%         disp('avoiding non-linear fit analysis.\n');
%         hold off;
%         saveas(h1,['fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
%         close;
%     elseif strcmpi(fit_option,'simple_fit')
%         cf(i)=0;
%         m=1;
%         [B,I]=sort(C(end,:),'descend');
%         f_sum=reshape(mean_max_resp(i,:,:),[],1);
%         base_value=2*std(f_sum);
%         
%         while  cf(i)==0
%             inds=I(m);
%             if inds==length(B)
%                 inds_scale=inds-1:inds;
%             elseif inds==1
%                 inds_scale=inds:inds+1;
%             else
%                 inds_scale=inds-1:inds+1;
%             end
%             if sum(C(end-1,inds_scale)>base_value)
%                 cf(i)=freq_type(I(m));
% %                 maxium_response(i)=B(m);
%             end
%             m=m+1;
%             if m>length(B)
%                 cf(i)=freq_type(I(1));
%                 %              error('No CF found, quit analysis.\n');
%             end
%         end
%         scatter(freq_tick(I(m-1)),DB_type(end),20,'MarkerEdgeColor','b','MarkerFaceColor','g','LineWidth',0.5);
%         hold off;
%         saveas(h1,['none-fit result of ' save_file_name,' ROI ' num2str(i) '.png'],'png');
%         close;
%     end
%     
%     cd ..;
%     
%     cd('.\line_plot\');
%     h3=figure;
%     %     label=zeros(length(DB_type),1);
%     for j=1:length(DB_type)
%         label(j)={[num2str(DB_type(j)),'DB']};
%     end
%     %     hh=axis;
%     %     triger_time=input('please input the triger time before sound stimulus deliverying, with default value is 1s.\n');
%     %     if isempty(triger_time)
%     %         triger_time=1;
%     %     end
%     %     plot([triger_time,triger_time],[hh(3),hh(4)],'color','k','LineWidth',1);
%     plot(C','-o','LineWidth',1.5,'MarkerSize',8);
%     hold off;
%     legend(label,'Location','NorthEastOutside');
%     title(['ROI',num2str(i)]);
%     set(gca,'xtick',1:length(freq_type),'xticklabel',sprintf('%.1f|',freq_label));
%     xlabel('frequency(KHz)');
%     ylabel('\DeltaF/F_0');
%     saveas(h3,['DB_diff plot of  ' save_file_name,' ROI ' num2str(i) '.png'],'png');
%     close;
%     cd ..;
% end
% 
% disp('critical tuning frequency for all ROIs calculation done!\n');
% 
% if nargout==1
%     varargout=cf;
% else
%     varargout=[];
% end
% 
% %%
% %performing in site plot of ROIs CF
% ROI_sumation_mask=double(CaSignal_RF_insite(1).ROIinfo.ROImask{1});
% ROI_sumation=ROI_sumation_mask*cf(1);
% for i=2:data_size(2)  %number of ROIs
%     ROI_add=double(CaSignal_RF_insite(1).ROIinfo.ROImask{i});
%     ROI_pre=zeros(size(ROI_add));
%     ROI_matrix=ROI_sumation_mask+ROI_add;
%     over_inds=find(ROI_matrix==2);
%     if ~over_inds
%         ROI_pre(over_inds)=0.5;
%         ROI_add(over_inds)=0.5;
%     end
%     ROI_sumation_mask=ROI_sumation_mask+ROI_add-ROI_pre;
%     ROI_sumation=ROI_sumation+ROI_add*cf(i)-ROI_pre*cf(i-1);
% end
% 
% test=find(ROI_sumation_mask>1);
% if ~test
%     error('error ROI sumation mask, quit analysis.');
% end
% 
% low_clim=min(ROI_sumation(:));
% high_clim=max(ROI_sumation(:));
% step_colorbar=(high_clim-low_clim)/9;
% ytick_colorlabel=low_clim:step_colorbar:high_clim;
% ytick_colorlabel=ytick_colorlabel./1000;
% [M,~,C]=mode(cf);
% if length(C{1})>1
%     CF_filed=mean(C{1});
% else
%     CF_filed=M;
% end
% 
% h3=figure;
% imagesc(ROI_sumation,[low_clim high_clim]);
% colormap(flipud(hot));
% h4=colorbar;
% set(get(h4,'title'),'string','Freq(KHz)');
% set(h4,'yTicklabel',sprintf('%.1f|',ytick_colorlabel));
% % frame ture;
% title(['In site plot of ROIs tuning properties with CF-' num2str(CF_filed),'Hz']);
% axis off;
% saveas(h3,[save_file_name,'ROIs_tuning_info_with_CF',num2str(CF_filed),'.png'],'png');
% close;
% disp([save_file_name,' ROIs in site plot complete!\n']);
