function [RawDataAll,FchangeDataAll,ROI_Struct,BaselineValue]=ROI_extraction_Meg_2p(FinalImage,NumberImages,h2,IsTypeSelect,varargin)
%for two photon data analysis
 %%
 if isempty(IsTypeSelect)
     TypeSelect = 0;
 else
     TypeSelect = 1;
 end
    %ROI drawing
    figure(h2);
    hold on
    nROI=0;
    ROIDraw=1;
    ROI_Struct=struct('ROImask',[],'ROIposi',[],'ROIvalue',[],'ROITypes',{},'ROIPixel',[]);
    while ROIDraw
        nROI=nROI+1;
        h_ROI=imfreehand;
        h_mask=createMask(h_ROI);
        h_position=getPosition(h_ROI);
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes&C','Yes&E', 'Re-draw','Yes&C');
        switch choice
            case 'Yes&C'
                ROI_Struct(nROI).ROImask=h_mask;
                ROI_Struct(nROI).ROIposi=h_position;
                delete(h_ROI);
                if TypeSelect
                    ROIType = ROITypeSelection;
                    ROI_Struct(nROI).ROITypes = ROIType;
                end
                ROI_pos_label(h_position,nROI,h2);
            case 'Yes&E'
                ROI_Struct(nROI).ROImask=h_mask;
                ROI_Struct(nROI).ROIposi=h_position;
                if TypeSelect
                    ROIType = ROITypeSelection;
                    ROI_Struct(nROI).ROITypes = ROIType;
                end
                delete(h_ROI);
                ROIDraw=0;
                ROI_pos_label(h_position,nROI,h2);
            case 'Re-draw'
                nROI=nROI-1;
                delete(h_ROI);
            otherwise
                disp('Quit ROI drawing.\n');
                delete(h_ROI);
                ROIDraw=0;
    %             close all;
        end
        
    end
    
%%
%ROI data extraction
RawDataAll=zeros(nROI,NumberImages);
if nROI
%     for n=1:nROI
%         ROI_Struct(n).ROIvalue=zeros(1,NumberImages);
%         ROI_Struct(n).ROIPixel=cell(1,NumberImages);
%     end
%     for m=1:NumberImages
%         TempImage=squeeze(FinalImage(:,:,m));
%         for n=1:nROI
%             nROIPixel=TempImage(ROI_Struct(n).ROImask);
%             nROIvalue=mean(nROIPixel);
%             ROI_Struct(n).ROIvalue(m)=nROIvalue;
%             RawDataAll(n,m)=nROIvalue;
%             ROI_Struct(n).ROIPixel(m)={nROIPixel};
%             
%         end
%     end
    for n=1:nROI
        cROImask=ROI_Struct(n).ROImask;
        mask3d=repmat(cROImask,1,1,NumberImages);
        AllPixelVector=FinalImage(mask3d);
        PixelMatrix=reshape(AllPixelVector,[],NumberImages);
        ROI_Struct(n).ROIvalue = mean(PixelMatrix);
        ROI_Struct(n).ROIPixel = PixelMatrix;
        
        RawDataAll(n,:) = mean(PixelMatrix);
    end
end
clearvars nROIPixel nROIvalue
% save ROI_result_save.mat ROI_Struct -v7.3

%%
if ~isempty(varargin)
    MegOnT = varargin{1};
    % DeltaF calculation
    FchangeDataAll=zeros(size(RawDataAll));
    BaselineValue=zeros(nROI,1);
    if ~isempty(varargin{2})
        baseStartT=varargin{2};
        if baseStartT==0
            baseStartT=1;
        end
        for n=1:nROI
            BaselineValue(n)=mean(RawDataAll(n,baseStartT:MegOnT));
            FchangeDataAll(n,:)=(RawDataAll(n,:)-BaselineValue(n))/BaselineValue(n)*100;
        end
    else
        for n=1:nROI
            BaselineValue(n)=mean(RawDataAll(n,1:MegOnT));
            FchangeDataAll(n,:)=(RawDataAll(n,:)-BaselineValue(n))/BaselineValue(n)*100;
        end
    end

    save MatrixData.mat RawDataAll FchangeDataAll BaselineValue -v7.3
else
    % no stim onset time was given, using 8 percentile value as baseline
    FchangeDataAll=zeros(size(RawDataAll));
    BaselineValue=zeros(nROI,1);
    for cr = 1 : nROI
        crData = RawDataAll(cr,:);
%         [Count,cent] = hist(crData,30);
%         [~,MaxInds] = max(Count);
%         BaselineValue(cr) = cent(MaxInds);
        BaselineValue(cr) = prctile(crData,8);
        FchangeDataAll(cr,:) = (crData - BaselineValue(cr))/BaselineValue(cr);
    end
end