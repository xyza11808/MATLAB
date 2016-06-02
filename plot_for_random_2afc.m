function plot_for_random_2afc(data,freq,type_inds,frame_rate,cell_description,description,clims)

if nargin<7
    clims=[];
    clims(1)=min(data(:));
    clims(2)=max(data(:));
end

data_size=size(data);
xtick=frame_rate:frame_rate:data_size(2);
xTick_lable=1:floor(data_size(2)/frame_rate);

[~,I]=sort(freq(type_inds));
B=unique(freq(type_inds));

temp_sub_data=data(type_inds,:);

imagesc(temp_sub_data(I,:),clims);
if ~isempty(strfind(description,'miss'))
colorbar;
end
title(['ROI' num2str(n) '\_' description]);
set(gca,'xtick',xtick,'xticklabel',xTick_lable);
set(gca,'ytick',B);
hold on;
hh1=axis;
triger_position=alignment_point*frame_rate;
for m=1:length(triger_position)
    plot([triger_position(m),triger_position(m)],[hh1(3),hh1(4)],'color','y','LineWidth',2);
    text(triger_position(m),1.03*hh1(4),cell_description{m});
end
hold off;