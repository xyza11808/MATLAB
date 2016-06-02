function SaveResult=ROI_extraction_Meg(FinalImage,NumberImages,h2,varargin)

if isempty(varargin)
    %%
    %ROI drawing
    figure(h2);
    hold on
    nROI=0;
    ROIDraw=1;
    ROI_Struct=struct('ROImask',[],'ROIposi',[],'ROIvalue',[],'ROIPixel',[]);
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
                ROI_pos_label(h_position,nROI,h2);
            case 'Yes&E'
                ROI_Struct(nROI).ROImask=h_mask;
                ROI_Struct(nROI).ROIposi=h_position;
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
    
else
    ROI_Struct=varargin{1};
    if isempty(ROI_Struct)
        [filename,filepath,~]=uigetfile('ROI_result_save.mat','Empty input, select your former ROI analysis data');
        load(fullfile(filepath,filename));
    end
    nROI=length(ROI_Struct);
end

if nROI
    for n=1:nROI
        ROI_Struct(n).ROIvalue=zeros(1,NumberImages);
        ROI_Struct(n).ROIPixel=cell(1,NumberImages);
    end
    for m=1:NumberImages
        TempImage=squeeze(FinalImage(:,:,m));
        for n=1:nROI
            nROIPixel=TempImage(ROI_Struct(n).ROImask);
            nROIvalue=mean(nROIPixel);
            ROI_Struct(n).ROIvalue(m)=nROIvalue;
            ROI_Struct(n).ROIPixel(m)={nROIPixel};
        end
    end
end
clearvars nROIPixel nROIvalue
save ROI_result_save.mat ROI_Struct -v7.3


%%
BS_ROI_char=input('Please input the BS ROI number:\n','s');
BS_ROI=str2num(BS_ROI_char);
if length(BS_ROI)~=1
    singleTrace=length(ROI_Struct(1).ROIvalue);
    SumBSvalue=zeros(length(BS_ROI),singleTrace);
    for n=1:length(BS_ROI)
        SumBSvalue(n,:)=ROI_Struct(n).ROIvalue;
    end
    BS_trace=mean(SumBSvalue);
else
    BS_trace=ROI_Struct(BS_ROI).ROIvalue;
end

% BS_trace_diff=BS_trace-BS_trace(1);
ROIAdjust=zeros(nROI,NumberImages);
ROIchange=zeros(nROI,NumberImages);
FbaseROI=zeros(nROI,1);
BSvalue=zeros(nROI,1);
MaxROIValue=zeros(nROI,1);
for n=1:nROI
%     if n==BS_ROI
%         FbaseROI(n)=0;
%         ROIchange(n,:)=nan(1,NumberImages);
%         MaxROIValue(n)=NaN;
%         continue;
%     end
    ROIAdjust(n,:)=ROI_Struct(n).ROIvalue-BS_trace;
    [x,Value]=hist(ROIAdjust(n,:));
    maxinds=find(double(x==max(x)),1,'first');
    BSvalue(n)=Value(maxinds);
    if BSvalue(n)==0
        f0=1;
    else
        f0=BSvalue(n);
    end
%     [counts,centers]=hist(ROIAdjust(n,:),30);
%     f0=centers(find(counts==max(counts),1,'first'));
    FbaseROI(n)=f0;
    ROIchange(n,:)=(ROIAdjust(n,:)-f0)./(f0-BS_trace)*100;
    MaxROIValue(n)=max(ROIchange(n,:));
end

ActiveROIMax=MaxROIValue;
ActiveROIMax(BS_ROI)=[];
ROI_Meg_str=input('Please input the megnatic field value:\n','s');  %0 means no meg, -1 means meg off response, positive values as real intensity of meg
ROI_Meg_value=str2num(ROI_Meg_str);
SaveResult=struct('MegValue',ROI_Meg_value,'ROIvalueMax',ActiveROIMax,'ROIChange',ROIchange,'BSROI',BS_ROI,'Fbase',FbaseROI);
save(sprintf('FChange_Meg%dmT.mat',ROI_Meg_value),'SaveResult','-v7.3');
