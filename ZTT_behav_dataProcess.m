
cclr
%%

% Session saved data path: K:\Xin_Yu\Data_Sharing\ZhouTT_Early_Behavior_Data
% summrize behav session path
AnmName = cell(5,1);
BehavPathAll = {};
AnmIndex = [];
nPath = 0;
AnmName{1} = 'ztt_curve01';
% anmName = 'ztt_curve01';
cd('R:\Xulab_Share_Nutstore\Projects\Behavior_data\Zhou_Taotao\curve_plot_fitting\curve01\bootStrap_fit')
datafnames = {'bootStrap_fit_results_curve01_20150921_psycurveday1.mat',...
'bootStrap_fit_results_curve01_20150929_psycurveday2.mat',...
'bootStrap_fit_results_curve01_20150930_psycurveday3.mat',...
'bootStrap_fit_results_curve01_20151001_psycurveday4.mat',...
'bootStrap_fit_results_curve01_20151002_psycurveday5.mat',...
'bootStrap_fit_results_curve01_20151003_psycurveday6.mat',...
'bootStrap_fit_results_curve01_20151005_psycurveday7.mat'};
inds_use = 2:7;
for cInds = 1 : length(inds_use)
    nPath = nPath + 1;
    BehavPathAll{nPath} = fullfile(pwd,datafnames{inds_use(cInds)});
    AnmIndex(nPath) = 1;
end
%
% Animal_2: curve02
anmName = 'ztt_curve02';
AnmName{2} = anmName;

cd('R:\Xulab_Share_Nutstore\Projects\Behavior_data\Zhou_Taotao\curve_plot_fitting\curve02\bootStrap_fit');
% matfiles = dir('bootStrap*.mat')
% for i = 1:length(matfiles),fprintf('''%s'',...\n',matfiles(i).name);end;
    %
    datafnames = {...
    'bootStrap_fit_results_curve02_20150925_psycurveday1.mat',...
    'bootStrap_fit_results_curve02_20150929_psycurveday2.mat',...
    'bootStrap_fit_results_curve02_20150930_psycurveday3.mat',...
    'bootStrap_fit_results_curve02_20151001_psycurveday4.mat',...
    'bootStrap_fit_results_curve02_20151002_psycurveday5.mat',...
    'bootStrap_fit_results_curve02_20151003_psycurveday6.mat',...
    'bootStrap_fit_results_curve02_20151005_psycurv.mat'};
    inds_use = 2:7;
    for cInds = 1 : length(inds_use)
        nPath = nPath + 1;
        BehavPathAll{nPath} = fullfile(pwd,datafnames{inds_use(cInds)});
        AnmIndex(nPath) = 2;
    end
%
% Animal_3: curve03

AnmName{3} = 'ztt_curve03';
cd('R:\Xulab_Share_Nutstore\Projects\Behavior_data\Zhou_Taotao\curve_plot_fitting\curve03\bootStrap_fit')
% matfiles = dir('bootStrap*.mat')
% for i = 1:length(matfiles),fprintf('''%s'',...\n',matfiles(i).name);end;
    %
    datafnames = {...
    'bootStrap_fit_results_ztt_curve03_150921_psycurveday1.mat',...
    'bootStrap_fit_results_ztt_curve03_150925_psycurveday2.mat',...
    'bootStrap_fit_results_ztt_curve03_150929_psycurveday3.mat',...
    'bootStrap_fit_results_ztt_curve03_150930_psycurveday4.mat',...
    'bootStrap_fit_results_ztt_curve03_151001_psycurveday5.mat',...
    'bootStrap_fit_results_ztt_curve03_151002_psycurveday6.mat',...
    'bootStrap_fit_results_ztt_curve03_151003_psycurveday7.mat',...
    'bootStrap_fit_results_ztt_curve03_151005_psycurv.mat'};
    inds_use = 3:8;
    for cInds = 1 : length(inds_use)
        nPath = nPath + 1;
        BehavPathAll{nPath} = fullfile(pwd,datafnames{inds_use(cInds)});
        AnmIndex(nPath) = 3;
    end
%
% Animal_4: curve04

AnmName{4} = 'ztt_curve04';
cd('R:\Xulab_Share_Nutstore\Projects\Behavior_data\Zhou_Taotao\curve_plot_fitting\curve04\bootStrap_fit')
% matfiles = dir('bootStrap*.mat')
% for i = 1:length(matfiles),fprintf('''%s'',...\n',matfiles(i).name);end;
    %
    datafnames = {...
        'bootStrap_fit_results_2015_09_21_curve04_psycurveday1.mat',...
        'bootStrap_fit_results_2015_09_25_curve04_psycurveday2.mat',...
        'bootStrap_fit_results_2015_09_29_curve04_psycurveday3.mat',...
        'bootStrap_fit_results_2015_09_30_curve04_psycurveday4.mat',...
        'bootStrap_fit_results_2015_10_01_curve04_psycurveday5.mat',...
        'bootStrap_fit_results_2015_10_02_curve04_psycurveday6.mat',...
        'bootStrap_fit_results_2015_10_02_curve04_psycurveday6_2.mat',...
        'bootStrap_fit_results_2015_10_03_curve04_psycurveday7.mat',...
        'bootStrap_fit_results_2015_10_05_curve04_psycurve.mat'};
    inds_use = [2 3 4 5 6 8 9];
for cInds = 1 : length(inds_use)
    nPath = nPath + 1;
    BehavPathAll{nPath} = fullfile(pwd,datafnames{inds_use(cInds)});
    AnmIndex(nPath) = 4;
end
%
% Animal_5: curve05
AnmName{5} = 'ztt_curve05';

cd('R:\Xulab_Share_Nutstore\Projects\Behavior_data\Zhou_Taotao\curve_plot_fitting\curve05\bootStrap_fit')
% matfiles = dir('bootStrap*.mat')
% for i = 1:length(matfiles),fprintf('''%s'',...\n',matfiles(i).name);end;
    %
    datafnames = {...
        'bootStrap_fit_results_curve05_20150921_psycurve01.mat',...
        'bootStrap_fit_results_curve05_20150925_psycurve02.mat',...
        'bootStrap_fit_results_curve05_20150929_psycurve03.mat',...
        'bootStrap_fit_results_curve05_20150930_psycurve04.mat',...
        'bootStrap_fit_results_curve05_20151001_psycurve05.mat',...
        'bootStrap_fit_results_curve05_20151002_psycurve06.mat',...
        'bootStrap_fit_results_curve05_20151003_psycurve07.mat',...
        'bootStrap_fit_results_curve05_20151005_psycurv.mat'};
    inds_use = 4:8;
for cInds = 1 : length(inds_use)
    nPath = nPath + 1;
    BehavPathAll{nPath} = fullfile(pwd,datafnames{inds_use(cInds)});
    AnmIndex(nPath) = 5;
end

cd('E:\DataToGo\data_for_xu\ZTT_data_summary');
save UsedSessPathSave.mat BehavPathAll nPath AnmIndex -v7.3

%% process each session data
% if ~isdir('./Session_behav_example/')
%     mkdir('./Session_behav_example/');
% end
% cd('./Session_behav_example/');

TickTone = [8000;16000;32000];
TickOct = log2(TickTone/8000);
TickStrs = cellstr(num2str(TickTone(:)/1000,'%.1f'));

SessBehavData = cell(nPath,1);
SessBehavOct = cell(nPath,1);
SessBoundSlope = zeros(nPath,2);
for cSess = 1 : nPath

    cSessF = BehavPathAll{cSess};
    cSessData = load(cSessF);
    if isfield(cSessData,'behav_choice')
        BehavDataStc = cSessData.behav_choice;
    elseif isfield(cSessData,'behav_data')
        BehavDataStc = cSessData.behav_data;
    end
    cSessOcts = log2(double(BehavDataStc.toneFreq)/8000);
    cSessChoice = BehavDataStc.frac_choice_right;
    SessBehavData{cSess} = cSessChoice(:);
    SessBehavOct{cSess} = cSessOcts(:);
    
    
%     hhf = figure('position',[100 100 480 400]);
%     scatter(cSessOcts,cSessChoice,50,'MarkerEdgeColor','k','LineWidth',3);
%     yyaxis left
%     hold on;
%     % for parameters: g,l,u,v
%     UL = [0.5, 0.5, max(cSessOcts), 100];
%     SP = [cSessChoice(1),1 - cSessChoice(end)-cSessChoice(1), mean(cSessOcts), 1];
%     LM = [0, 0, min(cSessOcts), 0];
%     ParaBoundLim = ([UL;SP;LM]);
%     F=@(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
%     fit_ReNew = FitPsycheCurveWH_nx(cSessOcts, cSessChoice, ParaBoundLim);
% %     syms x
% %     ff = F(fit_ReNew.ffit.g,fit_ReNew.ffit.l,fit_ReNew.ffit.u,fit_ReNew.ffit.v,x);
% %     fslope = diff(ff,x);
% %     DerivData = double(subs(fslope,fit_ReNew.curve(:,1))); % calculate the derivative function and convert into double value
%     
%     %
%     OctStep = mean(diff(fit_ReNew.curve(:,1)));
%     BehavDerivateCurve = diff(fit_ReNew.curve(:,2));
%     BehavDerivateCurve = [BehavDerivateCurve(1);BehavDerivateCurve]/OctStep;
%     [MaxV,MaxInds] = max(BehavDerivateCurve);
%     SessBoundSlope(cSess,:) = [fit_ReNew.curve(MaxInds,1),MaxV];
%     %
%     plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'color','k','LineWidth',2.4);
%     ylim([0 1]);
%     ylabel('Rightward choice');
% 
%     yyaxis right
%     plot(fit_ReNew.curve(:,1),BehavDerivateCurve,'Color',[.7 .7 .7],'linewidth',2);
%     set(gca,'yColor',[.7 .7 .7]);
%     Ryscales = get(gca,'ylim');
%     set(gca,'ylim',[-0.1 Ryscales(2)]);
%     ylabel('Derivative')
% 
% %     set(gca,'xtick',cSessOcts);
%     set(gca,'xtick',TickOct);
% %     Freqs = double(unique(BehavDataStc.toneFreq));
% %     set(gca,'xticklabel',cellstr(num2str(Freqs(:)/1000,'%.1f')));
%     set(gca,'xticklabel',TickStrs);
%     xlabel('Frequency(kHz)');
%     set(gca,'FontSize',14);
% 
%     title(sprintf('Session%d',cSess));
%     saveas(hhf,sprintf('Session%d behavior plot save',cSess));
%     saveas(hhf,sprintf('Session%d behavior plot save',cSess),'png');
%     close(hhf);
end
% save BehavDataSum.mat SessBehavData SessBehavOct SessBoundSlope -v7.3
% cd ..;
%%
% hf = GrdistPlot(SessBoundSlope,{'BehavBound','Slope'});
% saveas(hf,'Bound slope distribution save');
% saveas(hf,'Bound slope distribution save','png');
hh_f = figure;
ha = axes;
BoundaryData = SessBoundSlope(:,1) - 1;
BoundScales = -1:0.1:1;
[BinCount,BoundInds] = hist(BoundaryData,BoundScales);
DataCounts = BinCount(BinCount ~= 0);
DataIndex = BoundInds(BinCount ~= 0);
bar(DataIndex,DataCounts,1,'FaceColor',[0.8 0.4 0],'EdgeColor','k');
box off
yscales = get(gca,'ylim');
line([0 0],yscales+[0 2],'Color',[.1 .5 .2],'linewidth',1.8,'linestyle','--');
set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ylim',yscales+[0 2]);
xlabel('Boundary (Oct.)');
ylabel('Session number')
set(gca,'FontSize',16);
haxis = get(ha,'position');
LinePos = [haxis(1)+haxis(3)/2,haxis(2)+haxis(4)*0.9];
BoundArrowx = [LinePos(1)+0.06,LinePos(1)];
BoundArrowy = [LinePos(2),LinePos(2)];
annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color',[.1 .5 .2],'LineWidth',2);
saveas(hh_f,'Boundary distribution hist plot');
saveas(hh_f,'Boundary distribution hist plot','png');
saveas(hh_f,'Boundary distribution hist plot','pdf');
%%
hh_f = figure;
ha = axes;
SlopeData = SessBoundSlope(:,2);
SlopeScales = 0:0.5:5;
[BinCount,SlopeInds] = hist(SlopeData,SlopeScales);
DataCounts = BinCount(BinCount ~= 0);
DataIndex = SlopeInds(BinCount ~= 0);
bar(DataIndex,DataCounts,1,'FaceColor',[0.8 0.4 0],'EdgeColor','k');
box off
yscales = get(gca,'ylim');
line([mean(SlopeData) mean(SlopeData)],yscales+[0 2],'Color',[.1 .5 .2],'linewidth',1.8,'linestyle','--');
set(gca,'xlim',[0 5],'xtick',0:5,'ylim',yscales+[0 2]);
xlabel('Slope');
ylabel('Session number')
set(gca,'FontSize',16);
haxis = get(ha,'position');
LinePos = [haxis(1)+haxis(3)*(mean(SlopeData)/5),haxis(2)+haxis(4)*0.9];
SlopeArrowx = [LinePos(1)+0.06,LinePos(1)];
SlopeArrowy = [LinePos(2),LinePos(2)];
annotation('textarrow',SlopeArrowx,SlopeArrowy,'String','Averaged Slope','Color',[.1 .5 .2],'LineWidth',2);
saveas(hh_f,'Slope distribution hist plot');
saveas(hh_f,'Slope distribution hist plot','png');
saveas(hh_f,'Slope distribution hist plot','pdf');

%%
SessOctMtx = cell2mat(SessBehavOct);
SessBehavMtx = cell2mat(SessBehavData);

MeanBehavOct = mean(SessOctMtx);
MeanBehavData = mean(SessBehavMtx);
SEMBehavData = std(SessBehavMtx)/sqrt(size(SessBehavMtx,1));

UL = [0.5, 0.5, max(MeanBehavOct), 100];
SP = [MeanBehavData(1),1 - MeanBehavData(end)-MeanBehavData(1), mean(MeanBehavOct), 1];
LM = [0, 0, min(MeanBehavOct), 0];
ParaBoundLim = ([UL;SP;LM]);
% F=@(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
fit_ReNew = FitPsycheCurveWH_nx(SessOctMtx(:), SessBehavMtx(:), ParaBoundLim);
fitCI = predint(fit_ReNew.ffit,fit_ReNew.curve(:,1),0.95,'functional','on');
h_f = figure('position',[100 100 360 300]);
hold on
plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'k','linewidth',2.4);
plot(fit_ReNew.curve(:,1),fitCI,'Color',[.7 .7 .7],'linestyle','--','linewidth',1.6);
errorbar(MeanBehavOct,MeanBehavData,SEMBehavData,'bo','linewidth',1.8,'MarkerSize',8);
% set(gca,'xtick',MeanBehavOct,'xticklabel',cellstr(num2str(Freqs(:)/1000,'%.1f')),'ytick',[0 0.5 1],'ylim',[-0.05 1.05]);
set(gca,'xtick',TickOct,'xticklabel',TickStrs,'ytick',[0 0.5 1],'ylim',[-0.05 1.05]);
xlabel('Frequency (kHz)');
ylabel('Right Prob');
title(sprintf('n = %d',length(SessBehavData)));
set(gca,'FontSize',14)
saveas(h_f,'Summarized multiSess behav Data fitting plot');
saveas(h_f,'Summarized multiSess behav Data fitting plot','png');
saveas(h_f,'Summarized multiSess behav Data fitting plot','pdf');

%% summarize the behavior data for each animal
TickTone = [8000;16000;32000];
TickOct = log2(TickTone/8000);
TickStrs = cellstr(num2str(TickTone(:)/1000,'%.1f'));

AnmIndexTypes = unique(AnmIndex);
AnmNumbers = numel(AnmIndexTypes);
AnmProbFit = cell(AnmNumbers,6);

for cAnm = 1 : AnmNumbers
    cAnmInds = AnmIndex == AnmIndexTypes(cAnm);
    cAnmSessRProb = SessBehavData(cAnmInds);
    cAnmSessOcts = SessBehavOct(cAnmInds);
    cAnmRProbVec = cell2mat(cAnmSessRProb);
    cAnmOctVec = cell2mat(cAnmSessOcts);
    
    cAnmFits = FitPsycheCurveWH_nx(cAnmOctVec, cAnmRProbVec);
    
    cAnmRProbMtx = cell2mat(cAnmSessRProb');
    cAnmRProbAvg = mean(cAnmRProbMtx,2);
    cAnmRProbStd = std(cAnmRProbMtx,[],2)/sqrt(size(cAnmRProbMtx,2));
    cAnmOctMtx = cell2mat(cAnmSessOcts');
    cAnmOctAvg = mean(cAnmOctMtx,2);
    
    
    AnmProbFit(cAnm,:) = {cAnmFits,cAnmRProbAvg,cAnmOctAvg,cAnmRProbStd,cAnmRProbMtx,cAnmOctMtx};
    
    % plot current result
    hf = figure('position',[2000 100 340 240]);
    hold on
    plot(cAnmFits.curve(:,1),cAnmFits.curve(:,2),'k','linewidth',1.5);
    errorbar(cAnmOctAvg,cAnmRProbAvg,cAnmRProbStd,'ko','linewidth',1.2);
    set(gca,'xlim',[min(cAnmOctAvg)-0.1,max(cAnmOctAvg)+0.1],'xtick',TickOct,'xticklabel',TickStrs,'ylim',[-0.05 1.05],'ytick',[0 0.5 1]);
    xlabel('Frequency (kHz)');
    ylabel('Rightward choice');
    title(sprintf('Anm %d',AnmIndexTypes(cAnm)));
    set(gca,'FontSize',12);
    saveas(hf,sprintf('Anm%d behav curve plot',cAnm));
    saveas(hf,sprintf('Anm%d behav curve plot',cAnm),'pdf');
    saveas(hf,sprintf('Anm%d behav curve plot',cAnm),'png');
    close(hf);
    
end



