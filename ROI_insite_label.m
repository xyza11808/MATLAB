function [varargout]=ROI_insite_label(ROI_info,varargin)
%this function is just used for plot out all of the ROIs positing at a
%blank mask
if ~isempty(varargin)
    Plot_flag=varargin{1};
else
    Plot_flag=1;
end
disp('performing insite ROI position labeling.\n');
single_trial_ROI=ROI_info.ROImask; %this should contains all ROIS info for a single session
EmptyROI=cellfun(@isempty,ROI_info.ROImask);
single_trial_ROI(EmptyROI)=[];
ROI_num=length(single_trial_ROI);

%performing in site plot of ROIs CF
center_ROI_posi=zeros(ROI_num,2);
ROI_sumation_mask=double(single_trial_ROI{1});
[row,col,~]=find(ROI_sumation_mask);
center_ROI_posi(1,1)=mean(row);
center_ROI_posi(1,2)=mean(col);
for n=2:ROI_num  %number of ROIs
    ROI_add=double(single_trial_ROI{n});
%     ROI_pre=zeros(size(ROI_add));
    if isempty(ROI_sumation_mask)
        ROI_sumation_mask=ROI_add;
        continue;
    end
    ROI_sumation_mask=ROI_sumation_mask+ROI_add;
    over_inds=find(ROI_sumation_mask==2);
    if ~isempty(over_inds)
        ROI_sumation_mask(over_inds)=1;
    end
    [row,col,~]=find(ROI_add);
    center_ROI_posi(n,1)=mean(row);
    center_ROI_posi(n,2)=mean(col);
end
test=find(ROI_sumation_mask>1);
if ~test
    error('error ROI sumation mask, quit analysis.');
end

if Plot_flag
    h=figure;
    imagesc(ROI_sumation_mask);
    colormap(cool);
    % colorbar;
    title('ROI labeling');
    axis off;
    box off;
    hold on;
    for n=1:ROI_num
        text(center_ROI_posi(n,2),center_ROI_posi(n,1),num2str(n),'color','b','FontSize',8,'HorizontalAlignment','center');
    end 
    hold off;
    if ~isdir('./ROI_labeling/')
        mkdir('./ROI_labeling/');
    end
    cd('./ROI_labeling/');
    saveas(h,'ROI_insite_labeling','png');
    
    close;
    cd ..;
end

if nargout==2
    varargout{1}=center_ROI_posi;
    varargout{2}=EmptyROI;
elseif nargout==1
    varargout{1}=center_ROI_posi;
end
