function TypeRespDistance(ROIpos,ROITypeInds,varargin)
%this function is used to calculate the distance between different ROIs and
%plot its distribution according to the ROI types, and if ROI correlation
%data is gived, this function will also calculate the relationship between
%ROIs correlation coefficience and ROI distance

%last modification 26, Oct, 2015

if isempty(ROITypeInds)
    disp('No ROI type data gived, please select your former analysis result position.\n');
    [filename,filepath,~]=uigetfile('LeftRightRespInds.mat','Select ROI type result storage file');
    load(fullfile(filepath,filename));
    LeftInds = LeftRespOInds;
    RightInds = RightRespOInds;
else
    LeftInds = ROITypeInds(:,1);  %using the first column to store the Left type ROI inds
    RightInds = ROITypeInds(:,2);  %using the second column to store the right type ROI inds
end

ROINum=size(ROIpos,1);
LeftROIpos=ROIpos(LeftInds,:);
RightROIpos=ROIpos(RightInds,:);
LeftROINum=sum(LeftInds);
RightROINum=sum(RightInds);
disp(['Left Responsive ROI Num is ' num2str(LeftROINum) ', and right is ' num2str(RightROINum)]);

if ~isdir('./Responsive_ROI_dis/')
    mkdir('./Responsive_ROI_dis/');
end
cd('./Responsive_ROI_dis/');

%####################################################################################################
%calculate left ROIs distance's distribution and mean value
LeftD=pdist(LeftROIpos);
h_left=figure;
hist(LeftD,10);
title({'Left Responsive ROIs distance';['Mean distance = ' num2str(mean(LeftD))]});
saveas(h_left,'Left Rosponsive ROIs distance','png');
saveas(h_left,'Left Rosponsive ROIs distance');
close(h_left);

%####################################################################################################
%calculate Right ROIs distance's distribution and mean value
RightD=pdist(RightROIpos);
h_right=figure;
hist(RightD,10);
title({'Right Responsive ROIs distance';['Mean distance = ' num2str(mean(RightD))]});
saveas(h_right,'Right Rosponsive ROIs distance','png');
saveas(h_right,'Right Rosponsive ROIs distance');
close(h_right);


%####################################################################################################
%calculate Random left and right ROIs distance's distribution and mean value
LeftRightD=pdist2(LeftROIpos,RightROIpos);
h_LRDis=figure;
hist(LeftRightD(:),10);
title({'Left and Right Responsive ROIs distance';['Mean distance = ' num2str(mean(LeftRightD(:)))]});
saveas(h_LRDis,'Left_Right Rosponsive ROIs distance','png');
saveas(h_LRDis,'Left_Right Rosponsive ROIs distance');
close(h_LRDis);

[h_LR,p_LR]=ttest2(LeftD,RightD);
[h_LM,p_LM]=ttest2(LeftD,LeftRightD(:));
[h_RM,p_RM]=ttest2(RightD,LeftRightD(:));
LRDisSta=[h_LR,p_LR]';
LMDisSta=[h_LM,p_LM]';
RMDisSta=[h_RM,p_RM]';
T=table(LRDisSta,LMDisSta,RMDisSta,'RowNames',{'h';'p_value'});
disp(T);
save ttest_result_summary.m T -v7.3


%##W######################################################################################################
%considering the correlations between distance and ROIs correlation
%coefficience
if nargin>2
    ROICorrResp=1;
    RawData = varargin{1};
    poolobj=gcp('nocreate');
    if isempty(poolobj)
        parpool('local',8);
    end
    Trials=size(RawData,1);
    ROIsNum=size(RawData,2);
    SmoothData=zeros(size(RawData));
    parfor n=1:Trials
        for m=1:ROIsNum
            TimeTrace=squeeze(RawData(n,m,:));
            SmoothData(n,m,:)=smooth(TimeTrace,'sgolay',4);
        end
    end
            
    if ~isdir('./Dis_corrcoef_corr/')
        mkdir('./Dis_corrcoef_corr/');
    end
    cd('./Dis_corrcoef_corr/');
else
%     ROICorrResp=0;
    disp('No ROI coefficience data input, skip distance and coefficience correlation analysis.');
    return;
end

if ROICorrResp
    CorrCoef=ROI_Coeff_Calcu(SmoothData,[LeftInds,RightInds]);
    LcoefDis=figure;
    hist(CorrCoef{1}{1},20);
    title(sprintf('Left side corr coef distribution with mean=%.3f',mean(CorrCoef{1}{1})));
    saveas(LcoefDis,'Left Coef Distribution.png');
    saveas(LcoefDis,'Left Coef Distribution');
    close(LcoefDis);
    
    RcoefDis=figure;
    hist(CorrCoef{2}{1},20);
    title(sprintf('Right side corr coef distribution with mean=%.3f',mean(CorrCoef{2}{1})));
    saveas(RcoefDis,'Right Coef Distribution.png');
    saveas(RcoefDis,'Right Coef Distribution');
    close(RcoefDis);
    
    LRcoefDis=figure;
    TempLRcoefdata=CorrCoef{3}{1};
    hist(TempLRcoefdata(:),20);
    title(sprintf('LR side corr coef distribution with mean=%.3f',mean(TempLRcoefdata(:))));
    saveas(LRcoefDis,'LR Coef Distribution.png');
    saveas(LRcoefDis,'LR Coef Distribution');
    close(LRcoefDis);
    
%     LeftCell=SigInds{1};
    LeftCorrData=CorrCoef{1};
    if length(LeftCorrData{1}) == length(LeftD)
        h_L_C=figure;
        hold on
        LeftCorrDataDouble=LeftCorrData{1};
        ClassLabel=ceil(tiedrank(LeftD)*10/length(LeftD));
        centerDL=zeros(1,10);
        CoefValueL=zeros(1,10);
        SemValueL=zeros(1,10);
        for n=1:10
            labelInds=ClassLabel==n;
            centerDL(n)=mean(LeftD(labelInds));
            CoefValueL(n)=mean(LeftCorrDataDouble(labelInds));
            SemValueL(n)=std(LeftCorrDataDouble(labelInds))/sqrt(sum(labelInds));
        end
        scatter(LeftD,LeftCorrDataDouble,20,'k','*');
        errorbar(centerDL,CoefValueL,SemValueL,'r-o','Linewidth',2);
        hold off
        [LeftCorrCoef,pLeft]=corrcoef(LeftD,LeftCorrDataDouble);
        if length(LeftCorrCoef)~=1
            title({'ROI distance correlate with corrcoef value within left ROIs',sprintf('R=%.2f and P=%.2e',LeftCorrCoef(1,2),pLeft(1,2))});
        else
            title('ROI distance correlate with corrcoef value within left ROIs');
        end
        saveas(h_L_C,'Left inds corrcoef vs Distance distribution','png');
        saveas(h_L_C,'Left inds corrcoef vs Distance distribution');
        close(h_L_C);
    end
%     RightCell=SigInds{2};
    RightCorrData=CorrCoef{2};
    if length(RightCorrData{1}) == length(RightD)
        h_R_C=figure;
        hold on
        RightCorrDataDouble=RightCorrData{1};
        ClassLabel=ceil(tiedrank(RightD)*10/length(RightD));
        centerDR=zeros(1,10);
        CoefValueR=zeros(1,10);
        SemValueR=zeros(1,10);
        for n=1:10
            labelInds=ClassLabel==n;
            centerDR(n)=mean(RightD(labelInds));
            CoefValueR(n)=mean(RightCorrDataDouble(labelInds));
            SemValueR(n)=std(RightCorrDataDouble(labelInds))/sqrt(sum(labelInds));
        end
        scatter(RightD,RightCorrDataDouble,20,'b','o');
        errorbar(centerDR,CoefValueR,SemValueR,'r-o','Linewidth',2);
        hold off
        [RightCorrCoef,pRight]=corrcoef(RightD,RightCorrDataDouble);
        if length(RightCorrCoef) ~= 1
            title({'ROI distance correlate with corrcoef value within right ROIs',sprintf('R=%.2f and P=%.2e',RightCorrCoef(1,2),pRight(1,2))});
        else
            title('ROI distance correlate with corrcoef value within right ROIs');
        end
        saveas(h_R_C,'Right inds corrcoef vs Distance distribution','png');
        saveas(h_R_C,'Right inds corrcoef vs Distance distribution');
        close(h_R_C);
    end
%     AllCell=SigInds{3};
    AllCorrData=CorrCoef{3};
    if length(AllCorrData{1}) == length(LeftRightD(:))
        h_LR_C=figure;
        hold on
        AllCorrDataDouble=AllCorrData{1};
        LeftRightDall=LeftRightD(:);
        ClassLabel=ceil(tiedrank(LeftRightDall)*10/length(LeftRightDall));
        centerDLR=zeros(1,10);
        CoefValueLR=zeros(1,10);
        SemValueLR=zeros(1,10);
        for n=1:10
            labelInds=ClassLabel==n;
            centerDLR(n)=mean(LeftRightDall(labelInds));
            CoefValueLR(n)=mean(AllCorrDataDouble(labelInds));
            SemValueLR(n)=std(AllCorrDataDouble(labelInds))/sqrt(sum(labelInds));
        end
%         scatter(LeftRightDall,AllCorrDataDouble,20,'b','o');
        scatter(LeftRightDall,AllCorrDataDouble,20,'g','*');
        errorbar(centerDLR,CoefValueLR,SemValueLR,'r-o','Linewidth',2);
        hold off
        [LRCorrCoef,pAll]=corrcoef(LeftRightDall,AllCorrDataDouble);
        if length(LRCorrCoef)~=1
            title({'ROI distance correlate with corrcoef value between LR ROIs',sprintf('R=%.2f and P=%.2f',LRCorrCoef(1,2),pAll(1,2))});
        else
            title('ROI distance correlate with corrcoef value between LR ROIs');
        end
        saveas(h_LR_C,'LAndR inds corrcoef vs Distance distribution','png');
        saveas(h_LR_C,'LAndR inds corrcoef vs Distance distribution');
        close(h_LR_C);
    end
    save DistanCorrcoefData.mat LeftCorrCoef RightCorrCoef LRCorrCoef  LeftD RightD LeftRightD CorrCoef ...
        pLeft pRight pAll -v7.3
    save SampleCenter.mat centerDLR CoefValueLR SemValueLR centerDR CoefValueR SemValueR centerDL CoefValueL SemValueL -v7.3
end
cd ..;
cd ..;