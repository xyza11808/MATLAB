function [varargout]=ROI_sequence_ana(data,start_frame,frame_rate,varargin)
%another way of population analysis of neural activity
%the atandard three dimensional data is needed, this data should be raw
%data that have been aligned to stim onset time.
%trial inds give all correct trials type

if nargin>3
    session_disp=varargin{1};
    trial_type=varargin{2};
    trial_type_save=trial_type;
    trial_type=strrep(trial_type,'_','\_');
elseif nargin==3
    session_disp=[];
    trial_type=[];
    trial_type_save=[];
end

data_size=size(data);
smooth_data=zeros(data_size);
x_tick=frame_rate:frame_rate:data_size(3);
x_ticklabel=1:length(x_tick);

% for n=1:data_size(1)
%     for m=1:data_size(2)
%         smooth_data(n,m,:)=smooth(data(n,m,:));
%     end
% end



popu_data=zeros(data_size(2),data_size(3));
popu_data_zscore=zeros(data_size(2),data_size(3));
for n=1:data_size(1)
    popu_data=popu_data+squeeze(data(n,:,:));
end
popu_data=popu_data/data_size(2);%Avg value for all ROI in a single session

%calculate zscore for the mean result for each ROI value that will be
%further used for sort
for n=1:data_size(2)
    popu_data_zscore(n,:)=zscore(popu_data(n,:));
end

ROI_max_inds=zeros(1,data_size(2));
ROI_max_raw_inds=zeros(1,data_size(2));
for n=1:data_size(2)
    [~,ma_inds]=max(popu_data_zscore(n,:));
    ROI_max_inds(n)=ma_inds;
    
    [~,max_inds]=max(popu_data(n,:));
    ROI_max_raw_inds(n)=max_inds;
end

if ~isdir('./popu_sequence/')
    mkdir('./popu_sequence/');
end
cd('./popu_sequence/');

[~,I_zs]=sort(ROI_max_inds);
clims(1)=min(popu_data_zscore(:));
clims(2)=max(popu_data_zscore(:));
if clims(2)>(10*median(popu_data_zscore(:)))
    clims(2) = clims(2)/3;
end

h_popu=figure;
imagesc(popu_data_zscore(I_zs,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title([trial_type 'population sort']);
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
if ~isdir('./popu_zscore_sort/')
    mkdir('./popu_zscore_sort/');
end
cd('./popu_zscore_sort/');
saveas(h_popu,[session_disp '_' trial_type_save  '_Popu_sort'],'png');
close;

%population correlation efficience for given ROIs using zscored data
trans_popu=popu_data_zscore';
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
hold on;
%tril is used for seletting lower triangular data and
%triu is used for selectting upper triangular data 
[sig_row,sig_col,~]=find(diag_p<0.05 & diag_p~=0);
scatter(sig_col,sig_row,15,'*');
title('Pairwised correlation of all ROIs');
saveas(h_coff,[session_disp '_' trial_type_save  '_pairwised_corr'],'png');
close;
cd ..;

%#########################################################################
%population sort with raw response data
%#########################################################################
if ~isdir('./popu_raw_sort/')
    mkdir('./popu_raw_sort/');
end
cd('./popu_raw_sort/');

[~,I]=sort(ROI_max_raw_inds);
clims(1)=min(popu_data(:));
clims(2)=max(popu_data(:));
if clims(2) > (10*median(popu_data(:)))
    clims(2) = clims(2)/3;
end
if clims(2) > 500
    clims(2) = 300;
end

h_popu=figure;
imagesc(popu_data(I,:),clims);
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('ROIs');
title([trial_type 'population sort (raw)']);
h_bar=colorbar;
plot_position_2=get(h_bar,'position');
set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
set(get(h_bar,'Title'),'string','zscored');
haxis=axis;
hold on;
plot([start_frame,start_frame],[haxis(3),haxis(4)],'color','y','LineWidth',1.5);
hold off;
% if ~isdir('./popu_sequence_sort/')
%     mkdir('./popu_sequence_sort/');
% end
% cd('./popu_sequence_sort/');
saveas(h_popu,[session_disp '_' trial_type_save  '_Popu_sort_raw'],'png');
close;

%population correlation efficience for given ROIs using zscored data
trans_popu=popu_data';
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
hold on;
%tril is used for selectting lower triangular data and
%triu is used for selectting upper triangular data 
[sig_row,sig_col,~]=find(diag_p<0.05 & diag_p~=0);
scatter(sig_col,sig_row,15,'*');
title('Pairwised correlation of all ROIs (raw data)');
saveas(h_coff,[session_disp '_' trial_type_save  '_pairwised_corr_raw'],'png');
close;
cd ..;

inds_table=table(I_zs',I','VariableNames',{[trial_type_save '_zs_sort'],[trial_type_save '_raw_sort']});
file_name=[session_disp '_' trial_type_save 'ROI_inds.xlsx'];
if ~isdir('./ROI_inds_save/')
    mkdir('./ROI_inds_save/');
end
cd('./ROI_inds_save/');
writetable(inds_table,file_name);
cd ..;
if nargout==1
    varargout{1}=popu_data;
end
cd ..;