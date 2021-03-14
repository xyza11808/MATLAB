cclr
savePath = 'I:\invivo_imaging_data_xnn_20191224_update20210105\ThreeAgeGroupcompare';

p12DatasStrc = load(fullfile(savePath,'p12CoefDatas.mat'));
p18DatasStrc = load(fullfile(savePath,'p18CoefDatas.mat'));
M4DatasStrc = load(fullfile(savePath,'M4CoefDatas.mat'));

%% CoefTypeStrs = {'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
PlotTypeInds = 2;
TypeStr = p12DatasStrc.CoefTypeStrs{PlotTypeInds};
DataPrefix = {'p12','p18','M4'};

for cData = 1 : 3
    eval(['cUsedDatas = ',DataPrefix{cData},'DatasStrc.plotfieldWiseDatas(PlotTypeInds,:);']);
    
    [cWTCoefData,cWTDisData,cTgCoefData,cTgDisData] = deal(cUsedDatas{:});
    cWT_TargetDisCoefs = cellfun(@(x,y) x(y < 200),cWTCoefData,cWTDisData,'UniformOutput',false);
    cTg_TargetDisCoefs = cellfun(@(x,y) x(y < 200),cTgCoefData,cTgDisData,'UniformOutput',false);

    eval([DataPrefix{cData},'WTCoefData = cWT_TargetDisCoefs;']);
    eval([DataPrefix{cData},'TgCoefData = cTg_TargetDisCoefs;']);
    
end

%% within age group coef compare plot, field-wise

p12_WT_FieldCoef = cellfun(@mean,p12WTCoefData);
p12_Tg_FieldCoef = cellfun(@mean,p12TgCoefData);

p18_WT_FieldCoef = cellfun(@mean,p18WTCoefData);
p18_Tg_FieldCoef = cellfun(@mean,p18TgCoefData);

M4_WT_FieldCoef = cellfun(@mean,M4WTCoefData);
M4_Tg_FieldCoef = cellfun(@mean,M4TgCoefData);

WTColors = {[.1 .1 .1],[.3 .3 .3],[.5 .5 .5]};
TgColors = {[.9 .1 .1],[.8 .3 .3],[.7 .4 .4]};
CoefAvgs = [mean(p12_WT_FieldCoef),mean(p12_Tg_FieldCoef),...
    mean(p18_WT_FieldCoef),mean(p18_Tg_FieldCoef),...
    mean(M4_WT_FieldCoef),mean(M4_Tg_FieldCoef)];
Coefsems = [std(p12_WT_FieldCoef)/sqrt(numel(p12_WT_FieldCoef)),std(p12_Tg_FieldCoef)/sqrt(numel(p12_Tg_FieldCoef)),...
    std(p18_WT_FieldCoef)/sqrt(numel(p18_WT_FieldCoef)),std(p18_Tg_FieldCoef)/sqrt(numel(p18_Tg_FieldCoef)),...
    std(M4_WT_FieldCoef)/sqrt(numel(M4_WT_FieldCoef)),std(M4_Tg_FieldCoef)/sqrt(numel(M4_Tg_FieldCoef))];

%% within age group coef compare plot, NOT field-wise !!!!

p12_WT_FieldCoef = cell2mat(p12WTCoefData);
p12_Tg_FieldCoef = cell2mat(p12TgCoefData);

p18_WT_FieldCoef = cell2mat(p18WTCoefData);
p18_Tg_FieldCoef = cell2mat(p18TgCoefData);

M4_WT_FieldCoef = cell2mat(M4WTCoefData);
M4_Tg_FieldCoef = cell2mat(M4TgCoefData);

WTColors = {[.1 .1 .1],[.3 .3 .3],[.5 .5 .5]};
TgColors = {[.9 .1 .1],[.8 .3 .3],[.7 .4 .4]};
CoefAvgs = [mean(p12_WT_FieldCoef),mean(p12_Tg_FieldCoef),...
    mean(p18_WT_FieldCoef),mean(p18_Tg_FieldCoef),...
    mean(M4_WT_FieldCoef),mean(M4_Tg_FieldCoef)];
Coefsems = [std(p12_WT_FieldCoef)/sqrt(numel(p12_WT_FieldCoef)),std(p12_Tg_FieldCoef)/sqrt(numel(p12_Tg_FieldCoef)),...
    std(p18_WT_FieldCoef)/sqrt(numel(p18_WT_FieldCoef)),std(p18_Tg_FieldCoef)/sqrt(numel(p18_Tg_FieldCoef)),...
    std(M4_WT_FieldCoef)/sqrt(numel(M4_WT_FieldCoef)),std(M4_Tg_FieldCoef)/sqrt(numel(M4_Tg_FieldCoef))];
%%
[~,p12_p] = ttest2(p12_WT_FieldCoef,p12_Tg_FieldCoef);
[~,p18_p] = ttest2(p18_WT_FieldCoef,p18_Tg_FieldCoef);
[~,M4_p] = ttest2(M4_WT_FieldCoef,M4_Tg_FieldCoef);

hccf = figure('position',[100 100 680 320]);
% ax1 = subplot(131);
hold on
bar(1,CoefAvgs(1),0.6,'FaceColor',WTColors{1},'edgecolor','none');
bar(2,CoefAvgs(2),0.6,'FaceColor',TgColors{1},'edgecolor','none');
text(0.6,CoefAvgs(1)+0.05,{num2str(CoefAvgs(1),'%.4f');num2str(Coefsems(1),'%.4f')});
text(2.4,CoefAvgs(2)+0.05,{num2str(CoefAvgs(2),'%.4f');num2str(Coefsems(2),'%.4f')});

bar(4,CoefAvgs(3),0.6,'FaceColor',WTColors{2},'edgecolor','none');
bar(5,CoefAvgs(4),0.6,'FaceColor',TgColors{2},'edgecolor','none');
text(3.6,CoefAvgs(3)+0.05,{num2str(CoefAvgs(3),'%.4f');num2str(Coefsems(3),'%.4f')});
text(5.4,CoefAvgs(4)+0.05,{num2str(CoefAvgs(4),'%.4f');num2str(Coefsems(4),'%.4f')});

bar(7,CoefAvgs(5),0.6,'FaceColor',WTColors{3},'edgecolor','none');
bar(8,CoefAvgs(6),0.6,'FaceColor',TgColors{3},'edgecolor','none');
text(6.6,CoefAvgs(5)+0.05,{num2str(CoefAvgs(5),'%.4f');num2str(Coefsems(5),'%.4f')});
text(8.4,CoefAvgs(6)+0.05,{num2str(CoefAvgs(6),'%.4f');num2str(Coefsems(6),'%.4f')});

errorbar([1,2,4,5,7,8],CoefAvgs,Coefsems,'k.','Marker','none');
GroupSigIndication([1,2],CoefAvgs(1:2)+Coefsems(1:2),p12_p,hccf,1.2);
GroupSigIndication([4,5],CoefAvgs(3:4)+Coefsems(3:4),p18_p,hccf,1.2);
GroupSigIndication([7,8],CoefAvgs(5:6)+Coefsems(5:6),M4_p,hccf,1.2);

set(gca,'xtick',[1,2,4,5,7,8],'xticklabel',{'p12WT','p12Tg','p18WT','p18Tg','M4WT','M4Tg',},'xlim',[0 9]);
ylabel('Correlation coefficient');


%%
saveas(hccf,'Distance within 200 Ast coef compare plot')
saveas(hccf,'Distance within 200 Ast coef compare plot','png')
saveas(hccf,'Distance within 200 Ast coef compare plot','pdf')

%% within genotype between age compare plot

[~,WT_p12_p18_p] = ttest2(p12_WT_FieldCoef,p18_WT_FieldCoef);
[~,WT_p12_M4_p] = ttest2(p12_WT_FieldCoef,M4_WT_FieldCoef);
[~,WT_M4_p18_p] = ttest2(M4_WT_FieldCoef,p18_WT_FieldCoef);

hcccf = figure('position',[100 100 940 320]);
ax1 = subplot(121);
hold on
for cAge = 1 : 3
    bar(cAge,CoefAvgs(cAge*2-1),0.6,'FaceColor',WTColors{cAge},'edgecolor','none');
end
errorbar(1:3,CoefAvgs([1,3,5]),Coefsems([1,3,5]),'k.','Marker','none');
MaxValues = max(CoefAvgs([1,3,5]));

GroupSigIndication([1,2],[MaxValues MaxValues],WT_p12_p18_p,ax1,1.2);
GroupSigIndication([3,2],[MaxValues MaxValues],WT_M4_p18_p,ax1,1.4);
GroupSigIndication([1,3],[MaxValues MaxValues],WT_p12_M4_p,ax1,1.6);

set(gca,'xtick',1:3,'xticklabel',{'p12','p18','M4'},'xlim',[0 4]);
title('WT');
ylabel('Correlation coefficient');

[~,Tg_p12_p18_p] = ttest2(p12_Tg_FieldCoef,p18_Tg_FieldCoef);
[~,Tg_p12_M4_p] = ttest2(p12_Tg_FieldCoef,M4_Tg_FieldCoef);
[~,Tg_M4_p18_p] = ttest2(M4_Tg_FieldCoef,p18_Tg_FieldCoef);

ax2 = subplot(122);
hold on
for cAge = 1 : 3
    bar(cAge,CoefAvgs(cAge*2),0.6,'FaceColor',TgColors{cAge},'edgecolor','none');
end
errorbar(1:3,CoefAvgs([2,4,6]),Coefsems([2,4,6]),'k.','Marker','none');
MaxValues = max(CoefAvgs([2,4,6]));

GroupSigIndication([1,2],[MaxValues MaxValues],Tg_p12_p18_p,ax2,1.2);
GroupSigIndication([3,2],[MaxValues MaxValues],Tg_M4_p18_p,ax2,1.4);
GroupSigIndication([1,3],[MaxValues MaxValues],Tg_p12_M4_p,ax2,1.6);

set(gca,'xtick',1:3,'xticklabel',{'p12','p18','M4'},'xlim',[0 4]);
title('Tg');
ylabel('Correlation coefficient');

%%
saveas(hcccf,'Distance within 200 Astcoef BetAge plot')
saveas(hcccf,'Distance within 200 Astcoef BetAge plot','png')
saveas(hcccf,'Distance within 200 Astcoef BetAge plot','pdf')

%% for anovan test preparation
% CoefTypeStrs = {'AllAstNeu','AstAst','NeuNeu','ActiveAstNeu','ActiveAstAst','ActiveNeuNeu'};
PlotTypeInds = 3;
TypeStr = p12DatasStrc.CoefTypeStrs{PlotTypeInds};
DataPrefix = {'p12','p18','M4'};

AgeStrs = [];
GenoStrs = [];
Distances = [];
CoefValues = [];

for cData = 1 : 3
    eval(['cUsedDatas = ',DataPrefix{cData},'DatasStrc.plotfieldWiseDatas(PlotTypeInds,:);']);
    
    [cWTCoefDataC,cWTDisDataC,cTgCoefDataC,cTgDisDataC] = deal(cUsedDatas{:});
    cWTCoefData = cell2mat(cWTCoefDataC);
    cWTDisData = cell2mat(cWTDisDataC);
    cTgCoefData = cell2mat(cTgCoefDataC);
    cTgDisData = cell2mat(cTgDisDataC);
    
%     cWT_TargetDisCoefs = cellfun(@(x,y) x(y < 200),cWTCoefData,cWTDisData,'UniformOutput',false);
%     cTg_TargetDisCoefs = cellfun(@(x,y) x(y < 200),cTgCoefData,cTgDisData,'UniformOutput',false);
    GenoStrs = [GenoStrs;repmat({'WT'},numel(cWTCoefData),1);repmat({'Tg'},numel(cTgCoefData),1)];
    AgeStrs = [AgeStrs;repmat(DataPrefix(cData),numel(cWTCoefData)+numel(cTgCoefData),1)];
    Distances = [Distances;cWTDisData;cTgDisData];
    CoefValues = [CoefValues;cWTCoefData;cTgCoefData];
%     eval([DataPrefix{cData},'WTCoefData = cWT_TargetDisCoefs;']);
%     
%     eval([DataPrefix{cData},'TgCoefData = cTg_TargetDisCoefs;']);
    
end

TermMtx = [1 0 0;...
    0 1 0;...
    0 0 1;...
    1 1 0];
%%

[p,tbl,stats,terms] = anovan(CoefValues,{GenoStrs,AgeStrs,Distances},'varnames',{'GenoType','Age','Distance'},...
    'continuous',[3],'model',TermMtx);

%% Only WT mouse datas
WTInds = strcmpi(GenoStrs,'WT');
[pWT,tblWT,statsWT,termsWT] = anovan(CoefValues(WTInds),{AgeStrs(WTInds),Distances(WTInds)},...
    'varnames',{'Age','Distance'},...
    'continuous',[2],'model','linear');



