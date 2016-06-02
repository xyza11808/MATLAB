function sequence_analysis(data,frame_rate,session_name,behavResults,index,varargin)
%this function used for sequencial analysis of the given trial data
%basically the data is a three dimensional data

if nargin<5
    index=[];
elseif nargin<4
    error(message('not enough input for sequencial plot.\n'));
end

%data_size=size(data);
if isempty(index)
    data_plot=data;
%     choice=1;
    [~,I]=sort(behavResults.Time_stimOnset);
else
    data_plot=data(index,:,:);
%     choice=2;
    [~,I]=sort(behavResults.Time_stimOnset(index));
end

data_size=size(data_plot);


clim=[];
x_tick=frame_rate:frame_rate:floor(data_size(3)/frame_rate)*frame_rate;
x_label=1:floor(data_size(3)/frame_rate);

for i=1:data_size(2)
    temp_data=squeeze(data_plot(:,i,:));
    clim(1)=min(temp_data(:));
    clim(2)=max(temp_data(:));
    h=figure;
    imagesc(temp_data(I,:),clim);
    h_bar=colorbar;
    set(get(h_bar,'Title'),'string','\DeltaF/F_0');
    title(['ROI',num2str(i)]);
    xlabel('time(s)');
    set(gca,'XTick',x_tick,'XTickLabel',x_label);
    saveas(h,[session_name,' plot of ROI ',num2str(i),'.png'],'png');
    close;
end

