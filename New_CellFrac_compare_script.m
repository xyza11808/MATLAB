% plot the colormap plot according to different cell types
% three neuron types will be considered, 
% categorical neuron, tuning neurons, no significantly selective neurons
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the session pathsave file');
if ~fi
    return;
end
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
%
nSess = 1;
SessBehavBoundModeOctave = [];
SessROItypeFrac = [];  % CategFrac.  TuningFrac.  NoSelectiveFrac.  NonRespFrac. TotalROInumber
SessColDescription = {'CategFrac','TuningFrac','NoSelectiveFrac','NonRespFrac','TotalROInumber'};
BoundTunROIindex = {};
SessBehavAll = {};
cMap = blue2red_2(100,0.9);
PreferC = [0 0.5 0.1];
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
%     tline = ['D:\data\xinyu\Data\',tline(4:end)];
    % passive tuning frequency colormap plot
    TunDataAllStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.FitModelAll{1}{2}.ffit.u - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    SessBehavAll{nSess} = BehavCorr;
    %
    GrNum = floor(length(BehavCorr)/2);
    BehavPsycho = BehavCorr;
    BehavPsycho(1:GrNum) = 1 - BehavPsycho(1:GrNum);
    BehavStims = log2(double(BehavBoundfile.boundary_result.StimType)/16000);

    ROITypeDatafile = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots',...
        'NewLog_fit_test_new','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    IIsResponsiveROI = logical(ROITypeDataStrc.ROIisResponsive);
    SessROItypeFrac(nSess,:) = [sum(CategROIInds),sum(TunedROIInds),sum(IIsResponsiveROI) - sum(CategROIInds) - sum(TunedROIInds),...
        sum(~IIsResponsiveROI),length(CategROIInds)];
    if ~isdir('CellType CP plot mean')
        mkdir('CellType CP plot mean');
    end
    cd('CellType CP plot mean');
    
    % plot the tuning ROI tuning peak color plot
    PassUsedOctavesInds = ~(abs(TunDataAllStrc.PassFreqOctave) > 1);
    PassUsedOctaves = TunDataAllStrc.PassFreqOctave(PassUsedOctavesInds);
    PassUsedOctaves = PassUsedOctaves(:);
    PassUsedOctData = TunDataAllStrc.PassTunningfun(PassUsedOctavesInds,:);
    nTotalROIs = size(PassUsedOctData,2);
    [MaxAmp,MaxInds] = max(PassUsedOctData);
    MaxIndsOctave = zeros(nTotalROIs,1);
    for n = 1 : nTotalROIs
        MaxIndsOctave(n) = PassUsedOctaves(MaxInds(n));
    end
    cTunedROIinds = TunedROIInds;
    TunedROIOctaves = MaxIndsOctave(cTunedROIinds);
    PassOctaves = TunedROIOctaves;
    cTunedROIs = length(TunedROIOctaves);
    
    % plot the task data tuning colormap
    TaskUsedOctaves = TunDataAllStrc.TaskFreqOctave(:);
    TaskUsedData = TunDataAllStrc.CorrTunningFun;
    TotalROIs = size(TaskUsedData,2);
    [MaxAmp,MaxInds] = max(TaskUsedData);
    TaskMaxOctaves = zeros(TotalROIs,1);
    for n = 1 : TotalROIs
        TaskMaxOctaves(n) = TaskUsedOctaves(MaxInds(n));
    end
    TunedROIOctaves = TaskMaxOctaves(TunedROIInds);
    TaskOctaves = TunedROIOctaves;
    TunedROIindex = find(cTunedROIinds);  % real index value for each ROI
    % try to distinguish boundary tuning data and sensory tuning data
    % define within 0.2 Octave Tuning peak as boundary tuning ROIs
    NearBoundTunInds = abs(TaskOctaves - BehavBoundData) < 0.2;
    BoundTunROIinds = TunedROIindex(NearBoundTunInds);
    NearBoundTunIndsC = abs(TaskOctaves - BehavBoundData) < 0.1;
    BoundTunROIindsConst = TunedROIindex(NearBoundTunIndsC);
    PassMaxOct = MaxIndsOctave;
    save TuningTypeIndexSave.mat CategROIInds  TunedROIInds  IIsResponsiveROI PassMaxOct TaskMaxOctaves  ...
        BoundTunROIinds BoundTunROIindsConst BehavBoundData CategROIInds -v7.3
    
    BoundTunROIindex{nSess,1} = BoundTunROIinds;
    BoundTunROIindex{nSess,2} = NearBoundTunInds;
    BoundTunROIindex{nSess,3} = BoundTunROIindsConst;
    BoundTunROIindex{nSess,4} = NearBoundTunIndsC;
    BoundTunROIindex{nSess,5} = BehavBoundData;
    BoundTunROIindex{nSess,6} = CategROIInds;
    BoundTunROIindex{nSess,7} = TunedROIInds;
    
    SessBehavBoundModeOctave(nSess,:) = [BehavBoundData,mode(PassMaxOct),mode(TaskMaxOctaves),mean(TaskOctaves - PassOctaves)];

    %
    tline = fgetl(fid);
    nSess = nSess + 1;
end
cd('E:\DataToGo\data_for_xu\BoundShiftData\BoundShift_index');
save SessBTTypeIndexSave.mat BoundTunROIindex SessBehavBoundModeOctave -v7.3
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSess = 1;
SessTypeNumDespNew = {'Categ','TotalTun','BoundTun','OtherTun','BoundTunConst','OtherTunConst','NoSelective','NoResp','total'};
SessTypeNum = [];
BoundANDOtherTunOctTask = {}; % BoundOct, OtherBoundOct,BoundConstrain, OtherBoundConst,BehavBound
BoundANDOtherTunOctPass = {};
%%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
%     tline = ['D:\data\xinyu\Data\',tline(4:end)];
    DataPath = fullfile(tline,'Tunning_fun_plot_New1s','CellType CP plot mean','TuningTypeIndexSave.mat');
    cSessDataStrc = load(DataPath);
    CategROINum = sum(cSessDataStrc.CategROIInds);
    TunedROINumTotal = sum(cSessDataStrc.TunedROIInds);
    BoundTunNum = length(cSessDataStrc.BoundTunROIinds);
    BoundTunNumConst = length(cSessDataStrc.BoundTunROIindsConst);
    SigButNoSelectiveNum = sum(cSessDataStrc.IIsResponsiveROI) - CategROINum - TunedROINumTotal;
    NoSigResp = sum(~cSessDataStrc.IIsResponsiveROI);
    TaskTunOctave = cSessDataStrc.TaskMaxOctaves(:);
    PassTunOctave = cSessDataStrc.PassMaxOct(:);
    SessTypeData = [CategROINum,TunedROINumTotal,BoundTunNum,TunedROINumTotal - BoundTunNum,...
        BoundTunNumConst,TunedROINumTotal - BoundTunNumConst,SigButNoSelectiveNum,NoSigResp,length(TaskTunOctave)];
    SessTypeNum(nSess,:) = SessTypeData;
    NoBoundTunInds = cSessDataStrc.TunedROIInds;
    NoBoundTunInds(cSessDataStrc.BoundTunROIinds) = false;
    NoBoundTunIndsConst = cSessDataStrc.TunedROIInds;
    NoBoundTunIndsConst(cSessDataStrc.BoundTunROIindsConst) = false;
    
    BoundANDOtherTunOctTask{nSess,1} = TaskTunOctave(cSessDataStrc.BoundTunROIinds);
    BoundANDOtherTunOctTask{nSess,2} = TaskTunOctave(NoBoundTunInds);
    BoundANDOtherTunOctTask{nSess,3} = TaskTunOctave(cSessDataStrc.BoundTunROIindsConst);
    BoundANDOtherTunOctTask{nSess,4} = TaskTunOctave(NoBoundTunIndsConst);
    BoundANDOtherTunOctTask{nSess,5} = cSessDataStrc.BehavBoundData;
    
    BoundANDOtherTunOctPass{nSess,1} = PassTunOctave(cSessDataStrc.BoundTunROIinds);
    BoundANDOtherTunOctPass{nSess,2} = PassTunOctave(NoBoundTunInds);
    BoundANDOtherTunOctPass{nSess,3} = PassTunOctave(cSessDataStrc.BoundTunROIindsConst);
    BoundANDOtherTunOctPass{nSess,4} = PassTunOctave(NoBoundTunIndsConst);
    BoundANDOtherTunOctPass{nSess,5} = cSessDataStrc.BehavBoundData;
    
    tline = fgetl(fid);
    nSess = nSess + 1;
end
cd('E:\DataToGo\data_for_xu\BoundShiftData\BoundShift_index');
save TypeFracSummary.mat BoundANDOtherTunOctPass BoundANDOtherTunOctTask SessTypeNum -v7.3

%%
% pie plot for categorical fraction
nSessions = size(SessTypeNum,1);
CategFrac = mean(SessTypeNum(:,1)./SessTypeNum(:,9));
CategFracSEM = std(SessTypeNum(:,1)./SessTypeNum(:,9));

BoundTunROIFrac = mean(SessTypeNum(:,3)./SessTypeNum(:,9));
BoundTunROIFracSEM = std(SessTypeNum(:,3)./SessTypeNum(:,9));

OtherTunROIFrac = mean(SessTypeNum(:,4)./SessTypeNum(:,9));
OtherTunROIFracSEM = std(SessTypeNum(:,4)./SessTypeNum(:,9));

ConstBoundTunROIFrac = mean(SessTypeNum(:,5)./SessTypeNum(:,9));
ConstBoundTunROIFracSEM = std(SessTypeNum(:,5)./SessTypeNum(:,9));

ConstOtherTunROIFrac = mean(SessTypeNum(:,6)./SessTypeNum(:,9));
ConstOtherTunROIFracSEM = std(SessTypeNum(:,6)./SessTypeNum(:,9));

RestFrac = 1 - BoundTunROIFrac - OtherTunROIFrac - CategFrac;
PieData = [CategFrac,BoundTunROIFrac,OtherTunROIFrac,RestFrac];
PieDataConst = [CategFrac,ConstBoundTunROIFrac,ConstOtherTunROIFrac,RestFrac];
PieStrs = {sprintf('Categ. %.2f%%',CategFrac*100);sprintf('BoundTun %.2f%%',BoundTunROIFrac*100);...
    sprintf('OtherTun %.2f%%',OtherTunROIFrac*100);sprintf('NoSelect. %.2f%%',RestFrac*100)};
PieStrsConst = {sprintf('Categ. %.2f%%',CategFrac*100);sprintf('BoundTunC %.2f%%',ConstBoundTunROIFrac*100);...
    sprintf('OtherTunC %.2f%%',ConstOtherTunROIFrac*100);sprintf('NoSelect. %.2f%%',RestFrac*100)};
CategExplode = [1 0 0 0];
tunExplode = [0 1 0 0];
hhf = figure('position',[100 100 620 600]);
subplot(221)
hp = pie(PieData,CategExplode,PieStrs);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor','c','EdgeColor','none');
set(hp(6),'Color','b');
set(hp(7),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(8),'Color',[.1 .1 .1]);
title(sprintf('Scale = 0.2,Std = %.4f',CategFracSEM));

subplot(222)
hp = pie(PieData,tunExplode,PieStrs);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor','c','EdgeColor','none');
set(hp(6),'Color','b');
set(hp(7),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(8),'Color',[.1 .1 .1]);
title(sprintf('Scale = 0.2,Std = %.4f',BoundTunROIFracSEM));
% constrained boundary tuning fraction data
subplot(223)
hp = pie(PieDataConst,CategExplode,PieStrsConst);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor','c','EdgeColor','none');
set(hp(6),'Color','b');
set(hp(7),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(8),'Color',[.1 .1 .1]);
title(sprintf('Scale = 0.1,Std = %.4f',CategFracSEM));

subplot(224)
hp = pie(PieDataConst,tunExplode,PieStrsConst);
set(hp(1),'FaceColor','m','EdgeColor','none');
set(hp(2),'Color','m');
set(hp(3),'FaceColor','g','EdgeColor','none');
set(hp(4),'Color',[0 0.5 0]);
set(hp(5),'FaceColor','c','EdgeColor','none');
set(hp(6),'Color','b');
set(hp(7),'FaceColor',[.5 .5 .5],'EdgeColor','none');
set(hp(8),'Color',[.1 .1 .1]);
title(sprintf('Scale = 0.1,Std = %.4f',ConstBoundTunROIFracSEM));
% saveas(hhf,'Cell Fraction summary across sessions');
% saveas(hhf,'Cell Fraction summary across sessions','pdf');
% saveas(hhf,'Cell Fraction summary across sessions','png');
% 
% save CellTypeFracSum.mat CategFrac BoundTunROIFrac OtherTunROIFrac ConstBoundTunROIFrac ConstOtherTunROIFrac ...
%     CategFracSEM BoundTunROIFracSEM OtherTunROIFracSEM ConstBoundTunROIFracSEM ConstOtherTunROIFracSEM
%% plot the distribution of tuning octave for task and passive condition
% plot the loess boundary constrain condition
SessBoundTun2BoundTAll = [];
SessOtherTun2BoundTAll = [];
SessBoundTun2BoundPAll = [];
SessOtherTun2BoundPAll = [];

nSessUsed = size(BoundANDOtherTunOctTask,1);
for cSess = 1 : nSessUsed
    cSessBoundTData = BoundANDOtherTunOctTask{cSess,1} - BoundANDOtherTunOctTask{cSess,5};
    cSessOtherTData = BoundANDOtherTunOctTask{cSess,2} - BoundANDOtherTunOctTask{cSess,5};
    cSessBoundPData = BoundANDOtherTunOctPass{cSess,1} - BoundANDOtherTunOctPass{cSess,5};
    cSessOtherPData = BoundANDOtherTunOctPass{cSess,2} - BoundANDOtherTunOctPass{cSess,5};
    SessBoundTun2BoundTAll = [SessBoundTun2BoundTAll;cSessBoundTData];
    SessOtherTun2BoundTAll = [SessOtherTun2BoundTAll;cSessOtherTData];
    SessBoundTun2BoundPAll = [SessBoundTun2BoundPAll;cSessBoundPData];
    SessOtherTun2BoundPAll = [SessOtherTun2BoundPAll;cSessOtherPData];
end

%%
HistBound = -1.5:0.05:1.5;
HistBoundP = -1.5:0.1:1.5;
[BountTunTCo,BountTunTCe] = hist(SessBoundTun2BoundTAll,HistBound);
[BountTunPCo,BountTunPCe] = hist(SessBoundTun2BoundPAll,HistBoundP);
%
hf = figure('position',[100 100 620 300]);
subplot(121)
hold on
BoundTunTBar = plot(BountTunTCe,BountTunTCo,'Color',[1 0.7 0.2],'linewidth',1.8);
BoundTunPBar = plot(BountTunPCe,BountTunPCo,'Color',[.7 .7 .7],'linewidth',1.8);
set(gca,'xtick',[-1.5 0 1.5]);
xlabel('DisTance to boundary');
ylabel('Cell Count')
title('BoundDis = 0.2');
set(gca,'FontSize',14)
legend([BoundTunTBar,BoundTunPBar],{'Task','Passive'},'Box','off','FontSize',12);
% BoundTunTBar = bar(BountTunTCe,BountTunTCo,0.4,'FaceColor',[1 0.7 0.2],'EdgeColor','none');
% BoundTunPBar = bar(BountTunPCe,BountTunPCo,0.4,'FaceColor',[.7 .7 .7],'EdgeColor','none');

[OtherTunTCo,OtherTunTCe] = hist(SessOtherTun2BoundTAll,HistBoundP);
[OtherTunPCo,OtherTunPCe] = hist(SessOtherTun2BoundPAll,HistBoundP);
subplot(122)
hold on
OtherTunTBar = plot(OtherTunTCe,OtherTunTCo,'Color',[1 0.7 0.2],'linewidth',1.8);
OtherTunPBar = plot(OtherTunPCe,OtherTunPCo,'Color',[.7 .7 .7],'linewidth',1.8);
set(gca,'xtick',[-1.5 0 1.5]);
xlabel('DisTance to boundary');
ylabel('Cell Count')
title('BoundDis = 0.2');
set(gca,'FontSize',14)
legend([BoundTunTBar,BoundTunPBar],{'Task','Passive'},'Box','off','FontSize',12);

% saveas(hf,'Tuning Octave comparison between task and passive');
% saveas(hf,'Tuning Octave comparison between task and passive','pdf');

%% constrain bound distance distribution plot
SessBoundTun2BoundTAllC = [];
SessOtherTun2BoundTAllC = [];
SessBoundTun2BoundPAllC = [];
SessOtherTun2BoundPAllC = [];

nSessUsed = size(BoundANDOtherTunOctTask,1);
for cSess = 1 : nSessUsed
    cSessBoundTData = BoundANDOtherTunOctTask{cSess,3} - BoundANDOtherTunOctTask{cSess,5};
    cSessOtherTData = BoundANDOtherTunOctTask{cSess,4} - BoundANDOtherTunOctTask{cSess,5};
    cSessBoundPData = BoundANDOtherTunOctPass{cSess,3} - BoundANDOtherTunOctPass{cSess,5};
    cSessOtherPData = BoundANDOtherTunOctPass{cSess,4} - BoundANDOtherTunOctPass{cSess,5};
    SessBoundTun2BoundTAllC = [SessBoundTun2BoundTAllC;cSessBoundTData];
    SessOtherTun2BoundTAllC = [SessOtherTun2BoundTAllC;cSessOtherTData];
    SessBoundTun2BoundPAllC = [SessBoundTun2BoundPAllC;cSessBoundPData];
    SessOtherTun2BoundPAllC = [SessOtherTun2BoundPAllC;cSessOtherPData];
end
% plot the distribution function
HistBound = -1.5:0.05:1.5;
HistBoundP = -1.5:0.1:1.5;
[BountTunTCo,BountTunTCe] = hist(SessBoundTun2BoundTAllC,HistBound);
[BountTunPCo,BountTunPCe] = hist(SessBoundTun2BoundPAllC,HistBoundP);
% 
hf = figure('position',[100 100 620 300]);
subplot(121)
hold on
BoundTunTBarC = plot(BountTunTCe,BountTunTCo,'Color',[1 0.7 0.2],'linewidth',1.8);
BoundTunPBarC = plot(BountTunPCe,BountTunPCo,'Color',[.7 .7 .7],'linewidth',1.8);
set(gca,'xtick',[-1.5 0 1.5]);
xlabel('DisTance to boundary');
ylabel('Cell Count')
title('BoundDis = 0.1');
set(gca,'FontSize',14)
legend([BoundTunTBarC,BoundTunPBarC],{'Task','Passive'},'Box','off','FontSize',12);
% BoundTunTBar = bar(BountTunTCe,BountTunTCo,0.4,'FaceColor',[1 0.7 0.2],'EdgeColor','none');
% BoundTunPBar = bar(BountTunPCe,BountTunPCo,0.4,'FaceColor',[.7 .7 .7],'EdgeColor','none');

[OtherTunTCo,OtherTunTCe] = hist(SessOtherTun2BoundTAllC,HistBoundP);
[OtherTunPCo,OtherTunPCe] = hist(SessOtherTun2BoundPAllC,HistBoundP);
subplot(122)
hold on
OtherTunTBarC = plot(OtherTunTCe,OtherTunTCo,'Color',[1 0.7 0.2],'linewidth',1.8);
OtherTunPBarC = plot(OtherTunPCe,OtherTunPCo,'Color',[.7 .7 .7],'linewidth',1.8);
set(gca,'xtick',[-1.5 0 1.5]);
xlabel('DisTance to boundary');
ylabel('Cell Count')
title('BoundDis = 0.1');
set(gca,'FontSize',14)
legend([BoundTunTBarC,BoundTunPBarC],{'Task','Passive'},'Box','off','FontSize',12);

saveas(hf,'Constrained Tuning Octave comparison between task and passive');
saveas(hf,'Constrained Tuning Octave comparison between task and passive','pdf');

%%
%% ROI type fraction plot
CategFrac = (SessTypeNum(:,1)./SessTypeNum(:,9));
% plot the categorical ROI fraction across session
hf = figure('position',[100 100 380 310]);
hold on
[CategCout,CategCent] = hist(CategFrac);
FracSEM = std(CategFrac)/sqrt(numel(CategFrac));
bar(CategCent,CategCout,0.8,'EdgeColor','none','FaceColor',[.8 .8 .8]);
yscales = get(gca,'ylim');
line([mean(CategFrac) mean(CategFrac)],yscales+[0 1],'Color',[0.2 0.7 0.3],'linewidth',1.6,'linestyle','--');
% line([-1,1]*FracSEM+mean(CategFrac),[max(CategCout)+0.5,max(CategCout)+0.5],'linewidth',2.4,'Color','k');
xlabel('Frac.');
ylabel('# Session');
title(sprintf('Categ ROI fraction, std = %.4f',std(CategFrac)));
set(gca,'FontSize',14);
text(mean(CategFrac)+0.02,yscales(2)*0.9,sprintf('%.4f',mean(CategFrac)),'Color',[0.2 0.7 0.3]);

% saveas(hf,'Session Categorical ROI fraction');
% saveas(hf,'Session Categorical ROI fraction','png');
% saveas(hf,'Session Categorical ROI fraction','pdf');

% plot the BoundTun ROI fraction across session
BoundTunROIFrac = (SessTypeNum(:,3)./SessTypeNum(:,9));
hf = figure('position',[500 100 380 310]);
hold on
[TunCout,TunCent] = hist(BoundTunROIFrac);
FracSEM = std(BoundTunROIFrac)/sqrt(numel(BoundTunROIFrac));
bar(TunCent,TunCout,0.8,'EdgeColor','none','FaceColor',[.8 .8 .8]);
yscales = get(gca,'ylim');
line([mean(BoundTunROIFrac) mean(BoundTunROIFrac)],yscales+[0 1],'Color',[0.2 0.7 0.3],'linewidth',1.6,'linestyle','--');
% line([-1,1]*FracSEM+mean(BoundTunROIFrac),[max(TunCout)+0.5,max(TunCout)+0.5],'linewidth',2.4,'Color','k');
xlabel('Frac.');
ylabel('# Session');
title(sprintf('Tuned ROI fraction, std = %.4f',std(BoundTunROIFrac)));
set(gca,'FontSize',14);
text(mean(BoundTunROIFrac)+0.02,yscales(2)*0.9,sprintf('%.4f',mean(BoundTunROIFrac)),'Color',[0.2 0.7 0.3]);

% saveas(hf,'Session Tuning ROI fraction');
% saveas(hf,'Session Tuning ROI fraction','png');
% saveas(hf,'Session Tuning ROI fraction','pdf');

% plot the constrained boundary tuning fraction
ConstBoundTunROIFrac = (SessTypeNum(:,5)./SessTypeNum(:,9));
hf = figure('position',[900 100 380 310]);
hold on
[TunCout,TunCent] = hist(ConstBoundTunROIFrac);
FracSEM = std(ConstBoundTunROIFrac)/sqrt(numel(ConstBoundTunROIFrac));
bar(TunCent,TunCout,0.8,'EdgeColor','none','FaceColor',[.8 .8 .8]);
yscales = get(gca,'ylim');
line([mean(ConstBoundTunROIFrac) mean(ConstBoundTunROIFrac)],yscales+[0 1],'Color',[0.2 0.7 0.3],'linewidth',1.6,'linestyle','--');
% line([-1,1]*FracSEM+mean(ConstBoundTunROIFrac),[max(TunCout)+0.5,max(TunCout)+0.5],'linewidth',2.4,'Color','k');
xlabel('Frac.');
ylabel('# Session');
title(sprintf('Tuned ROI fraction, std = %.4f',std(ConstBoundTunROIFrac)));
set(gca,'FontSize',14);
text(mean(ConstBoundTunROIFrac)+0.02,yscales(2)*0.9,sprintf('%.4f',mean(ConstBoundTunROIFrac)),'Color',[0.2 0.7 0.3]);

% saveas(hf,'Session Tuning ROI fraction constrain');
% saveas(hf,'Session Tuning ROI fraction constrain','png');
% saveas(hf,'Session Tuning ROI fraction constrain','pdf');
