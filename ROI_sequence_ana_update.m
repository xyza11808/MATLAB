function ROI_sequence_ana_update(data,RawData,bevaResult,plot_data_inds,start_frame,frame_rate,varargin)
%another way of population analysis of neural activity
%the atandard three dimensional data is needed, this data should be raw
%data that have been aligned to stim onset time.
%trial inds give all correct trials type
%for the inpu variable trial_inds, the first column gives all correct left
%trials index, and second colmn gives all correct right trials

if nargin>5
    session_disp=varargin{1};
    if size(session_disp,1)~=1
        session_disp=session_disp';
    end
else
    session_disp=[];
end

data_size=size(data);
% smooth_data=zeros(data_size);
x_tick=frame_rate:frame_rate:data_size(3);
x_ticklabel=1:length(x_tick);

% for n=1:data_size(1)
%     for m=1:data_size(2)
%         smooth_data(n,m,:)=smooth(data(n,m,:));
%     end
% end

% zscore_data=zeros(data_size);
% for n=1:data_size(2)
%     temp_data=squeeze(data(:,n,:));
%     mean_temp=mean(temp_data(:));
%     std_temp=std(temp_data(:));
%     zscore_data(:,n,:)=(temp_data-mean_temp)/std_temp;
% end

if ~isdir('./popu_ROIzscore_sort/')
    mkdir('./popu_ROIzscore_sort/');
end
cd('./popu_ROIzscore_sort/');

PCA_2AFC_classification(data,bevaResult,session_disp,frame_rate,start_frame);
%#########################################################################
%scale define
% clim=[];
% clim(1)=min(zscore_data(:));
% clim(2)=max(zscore_data(:));
clim_raw=[];
clim_raw(1)=min(RawData(:));
clim_raw(2)=max(RawData(:));
if clim_raw(1) < -20
    clim_raw(1) = -20;
end
if clim_raw(2)>(10*median(RawData(:)))
 clim_raw(2) = (clim_raw(2)+median(RawData(:)))/3;
end
if clim_raw(2) > 100
     clim_raw(2) = 60;
end
% clim_raw(2)=50;

tiral_inds_left=plot_data_inds.left_trials_bingo_inds';
tiral_inds_right=plot_data_inds.right_trials_bingo_inds';


data_left=data(tiral_inds_left,:,:);
data_size_left=size(data_left);
data_right=data(tiral_inds_right,:,:);
data_size_right=size(data_right);
data_left_raw=RawData(tiral_inds_left,:,:);
data_right_raw=RawData(tiral_inds_right,:,:);

% mean_left=mean(data_left(:));
% std_left=std(data_left(:));
% mean_right=mean(data_right(:));
% std_right=std(data_right(:));

% popu_zscore_left=squeeze(mean(data_left));
% popu_zscore_right=squeeze(mean(data_right));

popu_raw_left=squeeze(mean(data_left_raw));
popu_raw_right=squeeze(mean(data_right_raw));

popu_zscore_left=(zscore(popu_raw_left'))';   %using real zscore value as 
popu_zscore_right=(zscore(popu_raw_right'))';

% popu_zscore_left=zeros(data_size_left(2),data_size_left(3));
% popu_zscore_right=zeros(data_size_right(2),data_size_right(3));
% popu_raw_left=zeros(data_size_left(2),data_size_left(3));
% popu_raw_right=zeros(data_size_right(2),data_size_right(3));
% for n=1:data_size_left(1)
%     popu_zscore_left=popu_zscore_left+squeeze(data_left(n,:,:));
%     popu_raw_left=popu_raw_left+squeeze(data_left_raw(n,:,:));
% end
% popu_zscore_left=popu_zscore_left/data_size_left(1);
% popu_raw_left=popu_raw_left/data_size_left(1);
% 
% for n=1:data_size_right(1)
%     popu_zscore_right=popu_zscore_right+squeeze(data_right(n,:,:));
%     popu_raw_right=popu_raw_right+squeeze(data_right_raw(n,:,:));
% end
% popu_zscore_right=popu_zscore_right/data_size_right(1);
% popu_raw_right=popu_raw_right/data_size_right(1);

max_inds_left=zeros(1,data_size(2));
max_inds_right=zeros(1,data_size(2));
for n=1:data_size(2)
    [~,max_inds]=max(popu_zscore_left(n,:));
    max_inds_left(n)=max_inds;
    
    [~,max_inds]=max(popu_zscore_right(n,:));
    max_inds_right(n)=max_inds;
end
[~,I_left]=sort(max_inds_left);
[~,I_right]=sort(max_inds_right);

%#########################################################################
%imagesc scale define
clims_left=[];
clims_left(1)=min(popu_zscore_left(:));
clims_left(2)=max(popu_zscore_left(:));
if clims_left(2)>(10*median(popu_zscore_left(:)))
    clims_left(2) = clims_left(2)/3;
end

clims_right=[];
clims_right(1)=min(popu_zscore_right(:));
clims_right(2)=max(popu_zscore_right(:));
if clims_right(2)>(10*median(popu_zscore_right(:)))
    clims_right(2) = clims_right(2)/3;
end

clims=[];
clims(1)=max(clims_left(1),clims_right(1));
clims(2)=min(clims_left(2),clims_right(2));
if clims(1) < -2
    clims(1) = -1.5;
end
%#########################################################################


%########################################################################################################
%left trial plot

h_left=figure;
subplot(2,2,1);
imagesc(popu_zscore_left(I_left,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by left zscore');
% h_bar=colorbar;
% plot_position_2=get(h_bar,'position');
% set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
% set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;

subplot(2,2,2);
imagesc(popu_zscore_left(I_right,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by right zscore');
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
% suptitle('left trial zscore sort');
% saveas(h_left,[session_disp 'left_Popu_sort'],'png');
% close;

subplot(2,2,3);
imagesc(popu_raw_left(I_left,:),clim_raw);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by left zscore');
% h_bar=colorbar;
% plot_position_2=get(h_bar,'position');
% set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
% set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
% suptitle('left trial raw sort');
% saveas(h_left,[session_disp 'left_Popu_sort'],'png');
% close;

subplot(2,2,4);
imagesc(popu_raw_left(I_right,:),clim_raw);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by right zscore');
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','\DeltaF/F_0');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
suptitle('left trial raw sort');
saveas(h_left,[session_disp 'left_Popu_sort'],'png');
close;

%population correlation efficience for given ROIs using zscored data
trans_popu=popu_zscore_left';
[coff,p_value,~,~]=corrcoef(trans_popu);
h_coff=figure('color',[1 1 1]);
diag_data=triu(coff);
% diag_data(diag_data==0)=NaN;
diag_p=triu(p_value);
h_im=imagesc(diag_data);
set(h_im,'alphadata',diag_data~=0);
xlabel('ROIs');
ylabel('ROIs');
axis off;
box off;
colorbar;
% hold on;
%tril is used for seletting lower triangular data and
%triu is used for selectting upper triangular data 
% [sig_row,sig_col,~]=find(diag_p<0.05 & diag_p~=0);
% scatter(sig_col,sig_row,15,'*');
title('Pairwised correlation of all ROIs');
saveas(h_coff,[session_disp '_left_zs_pairwised_corr'],'png');
close;

%########################################################################################################
%right trial plot

h_right=figure;
subplot(2,2,1);
imagesc(popu_zscore_right(I_right,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by right zscore');
% h_bar=colorbar;
% plot_position_2=get(h_bar,'position');
% set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
% set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;

subplot(2,2,2);
imagesc(popu_zscore_right(I_left,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by left zscore');
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
% suptitle('right trial zscore sort');
% saveas(h_left,[session_disp 'right_Popu_sort'],'png');
% close;

subplot(2,2,3);
imagesc(popu_raw_right(I_right,:),clim_raw);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by right zscore');
% h_bar=colorbar;
% plot_position_2=get(h_bar,'position');
% set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
% set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
% suptitle('left trial raw sort');
% saveas(h_left,[session_disp 'left_Popu_sort'],'png');
% close;

subplot(2,2,4);
imagesc(popu_raw_right(I_left,:),clim_raw);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title('Sorted by left zscore');
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','\DeltaF/F_0');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
suptitle('right trial raw sort');
saveas(h_right,[session_disp 'right_Popu_sort'],'png');
close;

%population correlation efficience for given ROIs using zscored data
trans_popu=popu_zscore_right';
[coff,p_value,~,~]=corrcoef(trans_popu);
h_coff=figure('color',[1 1 1]);
diag_data=triu(coff);
% diag_data(diag_data==0)=NaN;
diag_p=triu(p_value);
h_im=imagesc(diag_data);
set(h_im,'alphadata',diag_data~=0);
xlabel('ROIs');
ylabel('ROIs');
axis off;
box off;
colorbar;
% hold on;
%tril is used for seletting lower triangular data and
%triu is used for selectting upper triangular data 
% [sig_row,sig_col,~]=find(diag_p<0.05 & diag_p~=0);
% scatter(sig_col,sig_row,15,'*');
title('Pairwised correlation of all ROIs');
saveas(h_coff,[session_disp '_right_zs_pairwised_corr'],'png');
close;

popu_inds=table(I_left',I_right','VariableNames',{'popu_left_zsinds','popu_right_zsinds'});
inds_filename=[session_disp 'popu_zscore_sortinds.xlsx'];
writetable(popu_inds,inds_filename);

cd ..;