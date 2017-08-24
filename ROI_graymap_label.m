function ROI_graymap_label(InputData,ROImask,varargin)
%this function will be used for in site labeling of different response
%properties.
%maybe only can run on 2014b or above version of matlab

if ndims(InputData)>2
    GroundFigure=squeeze(mean(InputData,3));
else
    GroundFigure=InputData;
end

IsmapCus = 0;
if nargin > 2
    CustomCmap = varargin{1};
    if ~isempty(CustomCmap)
        IsmapCus = 1;
    end
end
if size(GroundFigure)~=size(ROImask)
    error('ROI mask is not as the same size as input data, quit function.\n');
end
maskValueType=unique(ROImask);
low_clim=maskValueType(2);
high_clim=maskValueType(end);
% low_clim=min(ROImask(:));
% high_clim=max(ROImask(:));
step_colorbar=floor((high_clim-low_clim)/9);
if ~IsmapCus 
    if step_colorbar==0
            ytick_colorlabel=1:2;
            ytickcolorlabel={'L','R'};
            low_clim=1;
            high_clim=2;
            titleStr='Resp side';
    else
        ytick_colorlabel=low_clim:step_colorbar:high_clim;
        ytickcolorlabel=num2cell(floor(ytick_colorlabel));
        titleStr='\DeltaF/F_0';
    end
else
    ColorNum = size(CustomCmap,1);
    ytick_colorlabel  = 3/(ColorNum*2) : 3/ColorNum : 3;
    ytick_colorlabel = [0.5,1.5,2.5,3.5];
    ytickcolorlabel = {'NonROI','2afc','RF','Both'};
    low_clim=0;
    high_clim=3;
    titleStr='Active type';
end
% ytick_colorlabel=ytick_colorlabel./1000;
%%
h=figure('position',[200 90 1400 1000],'PaperPositionMode','auto');
ax1=axes;
h_backf=imagesc(GroundFigure,[0 150]);
Cpos=get(ax1,'position');
view(2);
ax2=axes;
h_frontf=imagesc(ROImask,[low_clim high_clim]);
set(h_frontf,'alphadata',ROImask~=0);
linkaxes([ax1,ax2]);
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
colormap(ax1,'gray');
if IsmapCus
   facemapcolor = CustomCmap;
else
    facemapcolor=jet;
end
colormap(ax2,facemapcolor);
% alpha(h_frontf,0.4);
set([ax1,ax2],'position',Cpos);
cb2=colorbar(ax2);
CBPosition=get(cb2,'position');
set(cb2,'position',[CBPosition(1)*1.06 CBPosition(2) CBPosition(3)*0.4 CBPosition(4)]);
set(get(cb2,'title'),'string',titleStr,'fontSize',10);
set(cb2,'ytick',ytick_colorlabel,'yTicklabel',ytickcolorlabel);
title('Combined colormap plot','fontSize',16);
axis off
%%
if nargin>3
    FileDesp=varargin{2};
else
    if step_colorbar==0
        FileDesp='Color_mask_plot';
    else
        FileDesp='ROI_labeling';
    end
end
saveas(h,sprintf('%s_Insite_plot',FileDesp));
saveas(h,sprintf('%s_Insite_plot',FileDesp),'png');
saveas(h,sprintf('%s_Insite_plot',FileDesp),'pdf');
close(h);
