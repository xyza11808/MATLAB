function sub_plot_sweep(sort_data,soundarray,frame_rate,plot_item,type,description,stim_onset,varargin)

%%
%inputs check
if type==1
   trial_modulation='normal';
elseif type==2
  trial_modulation='reverse';
else
  error('Error type of trial types, quit analysis.');
end

if nargin<7
   stim_onset=1;
elseif nargin<6
  description=[];
end

if ~isempty(varargin)
    clims=varargin{1};
else
    clims=[];
    clims(1)=min(sort_data(:));
    clims(2)=max(sort_data(:));
end
%%
%data preparation
data_size=size(sort_data);
xtick=frame_rate:frame_rate:data_size(2);
xticklabel=1:floor(data_size(2)/frame_rate);
x_label='time(s)';
ytick=unique(soundarray(:,1)); %the initial frequency of each sweep
y_label=description;
onset_frame=floor(stim_onset*frame_rate);

%%
%data plot
imagesc(sort_data,clims);
set(gca,'XTick',xtick,'XTickLabel',xticklabel);
set(gca,'YTick',ytick);
xlabel(x_label);
ylabel(y_label);
title([plot_item '\_' trial_modulation]);
hold on;
hh3=axis;   
% triger_position=stim_onset*frame_rate;
plot([onset_frame,onset_frame],[hh3(3),hh3(4)],'color','g','LineWidth',2);
hold off;


