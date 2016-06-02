function TwoD_plot_matrix(data,title_name,frame_rate,index,varargin)
%this is a simple function used for plot 2D color mao of the given data
%mainly used imagesc function
%data should be a three dimensional data form with the first dimension
%indicates trial number, second dimension indicates ROI numbers and the
%third indicates the frames
%varargin used for given some extra input used for plot describtion

%%default value of input
if nargin<5
    varargin=[];
    if nargin<4
        index=[];
        if nargin<3
            error(message('Not enough input.'));
        end
    end
end

data_size = size(data);
clim=[0 300];
x_step=floor(frame_rate);
time=floor(data_size(3)/x_step);
x_tick=x_step:x_step:x_step*time;
x_label=1:time;

if isdir('.\select_plot\')==0
    mkdir('.\select_plot\');
end
cd('.\select_plot\');
    
if  ~isempty(varargin)
    title_name_plot=[varargin{1},'_',title_name];
else
    title_name_plot=title_name;
end

for i=1:data_size(2)
    h=figure;
    if isempty(index)
        imagesc(squeeze(data(:,i,:)),clim);
    else
        imagesc(squeeze(data(index,i,:)),clim);
    end
    title(['ROI ',num2str(i),' of ',title_name]);
    set(gca,'XTick',x_tick,'XTickLabel',x_label);
    
    saveas(h,[title_name_plot,' plot of ROI ', num2str(i),'.png'],'png');
    close;
end


    
