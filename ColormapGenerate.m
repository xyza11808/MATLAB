function ColormapGenerate(Data,ROIinfo,ROIcp,varargin)
%this function is used to generate the color map plot of ROI mask, and each
%ROI colr is defined by given data ROIcp,which is a vector data contains
%each ROIs property index
if ~isempty(varargin)
    LeftInds=varargin{1};
    RightInds=varargin{2};
    ROISelection=1;
else
    ROISelection=0;
end


ROIPos=ROIinfo(1).ROIpos;
EmptyROI=cellfun(@isempty,ROIPos);
AllROImask=ROIinfo(1).ROImask;
if (sum(EmptyROI))
    AllROImask(EmptyROI)=[];
    LeftInds(EmptyROI)=[];
    RightInds(EmptyROI)=[];
end

if ROISelection
    ROIcp=zeros(1,length(AllROImask));
    AllROImask=AllROImask(logical(LeftInds+RightInds));
    ROIcp(RightInds)=2;
    ROIcp(LeftInds)=1;
    ROIcp=ROIcp(logical(LeftInds+RightInds));
end
    
ROINum=length(AllROImask);
if ROINum~=length(ROIcp)
    error('The ROI mask number is different from ROIcp length, plaese check the input variables.\n');
end

ROI_sumation_mask=double(AllROImask{1});
ROI_sumation=ROI_sumation_mask*ROIcp(1);
for n=2:ROINum
    ROI_add=double(AllROImask{n});
    ROI_pre=zeros(size(ROI_add));
    ROI_matrix=ROI_sumation_mask+ROI_add;
    Overlap_inds=find(ROI_matrix>1);
    if ~isempty(Overlap_inds)
        ROI_add(Overlap_inds)=0;
%         ROI_pre(Overlap_inds)=0.5;
%         ROI_add(Overlap_inds)=0.5;
    end
    
    ROI_sumation_mask = ROI_sumation_mask + ROI_add;
    ROI_sumation = ROI_sumation + ROI_add * ROIcp(n);
%     ROI_sumation_mask=ROI_sumation_mask+ROI_add-ROI_pre;
%     ROI_sumation=ROI_sumation+ROI_add*ROIcp(n)-ROI_pre*ROIcp(n-1);
end

test=find(ROI_sumation_mask>1);
if ~test
    error('error ROI sumation mask, quit analysis.');
end

% low_clim=min(ROI_sumation(:));
% high_clim=max(ROI_sumation(:));
% step_colorbar=(high_clim-low_clim)/9;
% ytick_colorlabel=low_clim:step_colorbar:high_clim;
% ytick_colorlabel=ytick_colorlabel./1000;

ROI_graymap_label(Data,ROI_sumation);


%%
% h=figure;
% h_im=imagesc(ROI_sumation,[low_clim high_clim]);
% colormap(flipud(hot));
% set(h_im,'alphadata',ROI_sumation~=0);
% h4=colorbar;
% set(get(h4,'title'),'string','\DeltaF/F_0');
% set(h4,'yTicklabel',sprintf('%.1f|',ytick_colorlabel));
% % frame ture;
% title(['In site plot of ROIs tuning properties with CF-' num2str(CF_filed),'Hz']);
% axis off;
% saveas(h,[save_file_name,'ROIs_tuning_info_with_CF',num2str(CF_filed),'.png'],'png');
% close;
% disp([save_file_name,' ROIs in site plot complete!\n']);
