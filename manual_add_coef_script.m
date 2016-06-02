
%this scription will be used for manually added ROI coef data files and
%combine all coef data across sessions together to make a summary plot for
%one imaging field

AddedChar='y';
LeftDisSummary=[];
RightDisSummary=[];
AllDisSummary=[];
LeftCorrSummary=[];
RightCorrSummary=[];
AllCorrSummary=[];
while strcmp(AddedChar,'y')
    [filename,filepath,~]=uigetfile('DistanCorrcoefData.mat','Please select your data file contains ROI distance and coef');
    load(fullfile(filepath,filename));
    LeftDisSummary=[LeftDisSummary LeftD];
    RightDisSummary=[RightDisSummary RightD];
    AllDisSummary=[AllDisSummary;LeftRightD(:)];
    LeftCorrSummary=[LeftCorrSummary;CorrCoef{1}{1}];
    RightCorrSummary=[RightCorrSummary;CorrCoef{2}{1}];
    AllCorrSummary=[AllCorrSummary;CorrCoef{3}{1}];
    AddedChoice=input('Continue to add other data files?\n','s');
    if strcmpi(AddedChoice,'n')
        AddedChar='n';
    end
end

%%
hLeft=figure;
hold on
ClassLabel=ceil(tiedrank(LeftDisSummary)*10/length(LeftDisSummary));
centerD=zeros(1,10);
CoefValue=zeros(1,10);
SemValue=zeros(1,10);
for n=1:10
    labelInds=ClassLabel==n;
    centerD(n)=mean(LeftDisSummary(labelInds));
    CoefValue(n)=mean(LeftCorrSummary(labelInds));
    SemValue(n)=std(LeftCorrSummary(labelInds))/sqrt(sum(labelInds));
    %/sqrt(sum(labelInds))
end
scatter(LeftDisSummary,LeftCorrSummary,20,'c','*');
errorbar(centerD,CoefValue,SemValue,'r-o');
hold off
[LeftCorrCoef,pLeft]=corrcoef(LeftDisSummary,LeftCorrSummary);
if length(LeftCorrCoef)~=1
    title({'ROI distance correlate with corrcoef value within left ROIs',sprintf('R=%.2f and P=%.2e',LeftCorrCoef(1,2),pLeft(1,2))});
else
    title('ROI distance correlate with corrcoef value within left ROIs');
end

%%
SavePath=uigetdir(pwd,'Left Dis_coef save path');
saveas(hLeft,fullfile(SavePath,'\Left_Dis_coef.fig'));
saveas(hLeft,fullfile(SavePath,'\Left_Dis_coef.png'));
% saveas(hLeft,sprintf('%s\Left_Dis_coef.png',SavePath));
close(hLeft);

%%
hRight=figure;
hold on
ClassLabel=ceil(tiedrank(RightDisSummary)*10/length(RightDisSummary));
centerD=zeros(1,10);
CoefValue=zeros(1,10);
SemValue=zeros(1,10);
for n=1:10
    labelInds=ClassLabel==n;
    centerD(n)=mean(RightDisSummary(labelInds));
    CoefValue(n)=mean(RightCorrSummary(labelInds));
    SemValue(n)=std(RightCorrSummary(labelInds))/sqrt(sum(labelInds));
end
scatter(RightDisSummary,RightCorrSummary,20,'c','*');
errorbar(centerD,CoefValue,SemValue,'r-o');
hold off
[RightCorrCoef,pRight]=corrcoef(RightDisSummary,RightCorrSummary);
if length(RightCorrCoef) ~= 1
    title({'ROI distance correlate with corrcoef value within right ROIs',sprintf('R=%.2f and P=%.2e',RightCorrCoef(1,2),pRight(1,2))});
else
    title('ROI distance correlate with corrcoef value within right ROIs');
end

%%
% SavePath=uigetdir(pwd,'Right Dis_coef save path');
saveas(hRight,fullfile(SavePath,'Right_Dis_coef.fig'));
saveas(hRight,fullfile(SavePath,'Right_Dis_coef.png'));
close(hRight);

%%
hAll=figure;
hold on
ClassLabel=ceil(tiedrank(AllDisSummary)*10/length(AllDisSummary));
centerD=zeros(1,10);
CoefValue=zeros(1,10);
SemValue=zeros(1,10);
for n=1:10
    labelInds=ClassLabel==n;
    centerD(n)=mean(AllDisSummary(labelInds));
    CoefValue(n)=mean(AllCorrSummary(labelInds));
    SemValue(n)=std(AllCorrSummary(labelInds))/sqrt(sum(labelInds));
end
scatter(AllDisSummary,AllCorrSummary,20,'c','*');
errorbar(centerD,CoefValue,SemValue,'r-o');
hold off
[LRCorrCoef,pAll]=corrcoef(AllDisSummary,AllCorrSummary);
if length(LRCorrCoef)~=1
    title({'ROI distance correlate with corrcoef value between LR ROIs',sprintf('R=%.2f and P=%.2f',LRCorrCoef(1,2),pAll(1,2))});
else
    title('ROI distance correlate with corrcoef value between LR ROIs');
end

%%
% SavePath=uigetdir(pwd,'LR Dis_coef save path');
saveas(hAll,fullfile(SavePath,'LR_Dis_coef.fig'));
saveas(hAll,fullfile(SavePath,'LR_Dis_coef.png'));
close(hAll);


%%
%second way of summary plot for distance and coef corelation plot
AddedChar='y';
h_summary1=figure('Name','error bar plot');
hold on;
% h_summary2=figure('Name','Right');
% hold on;
% h_summary3=figure('Name','LR');
% hold on;
m=1;

while strcmp(AddedChar,'y')
    [filename,filepath,~]=uigetfile('DistanCorrcoefData.mat','Please select your data file contains ROI distance and coef');
    cd(filepath);
    load(filename);
    
%     figure(h_summary1);
    LeftCorr=CorrCoef{1}{1};
    ClassLabel=ceil(tiedrank(LeftD)*10/length(LeftD));
    centerD=zeros(1,10);
    CoefValue=zeros(1,10);
    SemValue=zeros(1,10);
    for n=1:10
        labelInds=ClassLabel==n;
        centerD(n)=mean(LeftD(labelInds));
        CoefValue(n)=mean(LeftCorr(labelInds));
        SemValue(n)=std(LeftCorr(labelInds))/sqrt(sum(labelInds));
    end
%     scatter(LeftD,LeftCorr,20,'c','*');
    errorbar(centerD,CoefValue,SemValue,'r-o','LineWidth',1.5);
    [LeftCorrCoef,~]=corrcoef(LeftD,LeftCorr);
    if length(LeftCorrCoef)~=1
        SumLCorrCoef(m)=LeftCorrCoef(1,2);
    else
         SumLCorrCoef(m)=NaN;
    end
    
%     figure(h_summary2);
    RightCorr=CorrCoef{2}{1};
    ClassLabel=ceil(tiedrank(RightD)*10/length(RightD));
    centerD=zeros(1,10);
    CoefValue=zeros(1,10);
    SemValue=zeros(1,10);
    for n=1:10
        labelInds=ClassLabel==n;
        centerD(n)=mean(RightD(labelInds));
        CoefValue(n)=mean(RightCorr(labelInds));
        SemValue(n)=std(RightCorr(labelInds))/sqrt(sum(labelInds));
    end
%     scatter(RightD,RightCorr,20,'c','*');
    errorbar(centerD,CoefValue,SemValue,'r-o','LineWidth',1.5);
    [RightCorrCoef,~]=corrcoef(RightD,RightCorr);
    if length(RightCorrCoef)~=1
        SumRCorrCoef(m)=RightCorrCoef(1,2);
    else
        SumRCorrCoef(m)=NaN;
    end
    
%     figure(h_summary3)
    LRCorr=CorrCoef{3}{1};
    LRD=LeftRightD(:);
    ClassLabel=ceil(tiedrank(LeftRightD(:))*10/length(LRD));
    centerD=zeros(1,10);
    CoefValue=zeros(1,10);
    SemValue=zeros(1,10);
    for n=1:10
        labelInds=ClassLabel==n;
        centerD(n)=mean(LRD(labelInds));
        CoefValue(n)=mean(LRCorr(labelInds));
        SemValue(n)=std(LRCorr(labelInds))/sqrt(sum(labelInds));
    end
%     scatter(LRD,LRCorr,20,'c','*');
    errorbar(centerD,CoefValue,SemValue,'r-o','LineWidth',1.5);
    [LRCorrCoef,pAll]=corrcoef(LRD,LRCorr);
    if length(LRCorrCoef)~=1
        SumLRCC(m)=LRCorrCoef(1,2);
    else
        SumLRCC(m)=NaN;
    end
    
    AddedChoice=input('Continue to add other data files?\n','s');
    if strcmpi(AddedChoice,'n')
        AddedChar='n';
    end
    m=m+1;
end

nanInds=isnan(SumLCorrCoef);
SumLCorrCoef(nanInds)=[];
nanInds=isnan(SumRCorrCoef);
SumRCorrCoef(nanInds)=[];
nanInds=isnan(SumLRCC);
SumLRCC(nanInds)=[];

%%
SavePath=uigetdir(pwd,'Left Dis_coef save path');
% saveas(h_summary1,fullfile(SavePath,'\Left_Dis_coef.png'));
% saveas(h_summary2,fullfile(SavePath,'\Right_Dis_coef.png'));
% saveas(h_summary3,fullfile(SavePath,'\LR_Dis_coef.png'));
LSEM=std(SumLCorrCoef)/sqrt(length(SumLCorrCoef));
RSEM=std(SumRCorrCoef)/sqrt(length(SumRCorrCoef));
LRSEM=std(SumLRCC)/sqrt(length(SumLRCC));

figure(h_summary1)
scatter(ones(size(SumLCorrCoef)),-SumLCorrCoef,40,[.8 .8 .8],'o','LineWidth',2.5);
scatter(ones(size(SumRCorrCoef))*2,-SumRCorrCoef,40,[.8 .8 .8],'o','LineWidth',2.5);
scatter(ones(size(SumLRCC))*3,-SumLRCC,40,[.8 .8 .8],'o','LineWidth',2.5);
errorbar([1,2,3],[mean(-SumLCorrCoef) mean(-SumRCorrCoef) mean(-SumLRCC)],[LSEM RSEM LRSEM],'ko','Linewidth',2);
bar([1,2,3],[mean(-SumLCorrCoef) mean(-SumRCorrCoef) mean(-SumLRCC)],'c','facealpha',0.25);
set(gca,'xtick',[1 2 3],'xticklabel',{'L','R','L vs R'});
ylabel('Negtive correlation coefficient');
[h1,p1]=ttest(-SumLCorrCoef);
[h2,p2]=ttest(-SumRCorrCoef);
[h3,p3]=ttest(-SumLRCC);
save ttest_result.mat h1 h2 h3 p1 p2 p3 SumLCorrCoef SumRCorrCoef SumLRCC -v7.3
saveas(h_summary1,fullfile(SavePath,'\Sum_Dis_coef.png'));
