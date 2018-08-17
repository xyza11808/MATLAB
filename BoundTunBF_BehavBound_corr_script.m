clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
clearvars -except fn fp BoundTunROIindex
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
SessBehavBound = {};
% ROICoefAll = {};
% ROIPvalueAll = {};
SessBoundROIBF = {};
SessBoundROIPassBF = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
%        PassLine = fgetl(PassFid);
        continue;
    end
    %
    BehavDatas = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavStims = BehavDatas.boundary_result.StimType(:);
    GroupStimsNum = floor(length(BehavStims)/2);
    BehavOctaves = log2(double(BehavStims)/16000);
    FreqStrs = cellstr(num2str(BehavStims/1000,'%.1f'));
    
    TuningDataPath = fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat');
    TunData = load(TuningDataPath);
    
    cBoundTunROIInds = BoundTunROIindex{cSess,1};
    TunROIData = TunData.CorrTunningFun(:,cBoundTunROIInds);
    PassTunROIData = TunData.PassTunningfun(:,cBoundTunROIInds);
    PassTones = TunData.PassFreqOctave;
    TaskTones = TunData.TaskFreqOctave;
    disp(TaskTones);
    disp(PassTones');
    UsedStr = input('Please select the used ovtve inds:\n','s');
    UsedInds = str2num(UsedStr);
    if ~isempty(UsedInds)
        PassUsedOcts = PassTones(UsedInds);
        PassUsedData = PassTunROIData(UsedInds,:);
    else
        cSess = cSess + 1;
        tline = fgetl(ff);
        continue;
    end
    
    BehavBound = BehavDatas.boundary_result.FitValue.u - 1;
    
    [~,TunROIOctInds] = max(TunROIData(2:end-1,:));
    [~,PassTunInds] = max(PassUsedData);
    
    BoundTunOcts = zeros(size(TunROIOctInds));
    PassTunOcts = zeros(size(TunROIOctInds));
    for cROI = 1 : length(BoundTunOcts)
        BoundTunOcts(cROI) = BehavOctaves(TunROIOctInds(cROI)+1);
        if abs(BoundTunOcts(cROI)) > 0.6
            return;
        end
        
        PassTunOcts(cROI) = PassUsedOcts(PassTunInds(cROI));
    end
    
    SessBoundROIBF{cSess} = BoundTunOcts;
    SessBehavBound{cSess} = repmat(BehavBound,size(BoundTunOcts,1),size(BoundTunOcts,2));
    SessBoundROIPassBF{cSess} = PassTunOcts;
    
    cSess = cSess + 1;
    tline = fgetl(ff);
   %
end

%%
cd('E:\DataToGo\data_for_xu\BoundTun_DataSave\BoundBF_BehavBound');
save SessBoundBFAll.mat SessBoundROIBF SessBehavBound SessBoundROIPassBF -v7.3
%% plot the correlation between behavior boundary and boundTun BF
BehavBoundOctAll = cell2mat(SessBehavBound);
ROIBFOctAll = cell2mat(SessBoundROIBF);
PassROIBFOctAll = cell2mat(SessBoundROIPassBF);
hhf = figure('position',[100 100 360 300]);
hold on
% plot(BehavBoundOctAll,PassROIBFOctAll,'o','Color',[.7 .7 .7],'linewidth',1.4);
plot(BehavBoundOctAll,ROIBFOctAll,'o','color',[1 0.7 0.2],'linewidth',1.5);
[rr,pp] = corrcoef(BehavBoundOctAll,ROIBFOctAll);
% [Prr, Ppp] = corrcoef(BehavBoundOctAll,PassROIBFOctAll);
[~,LinefitData] = lmFunCalPlot(BehavBoundOctAll,ROIBFOctAll,0);
plot(LinefitData(:,1),LinefitData(:,2),'Color',[0.9 0.6 0.1],'linewidth',1.8);
set(gca,'xlim',[-0.8 0.8],'ylim',[-0.8 0.8]);
xlabel('Behavior boundary');
ylabel('ROI BF');
title(sprintf('T Coef %.3f,p %.3e',rr(1,2),pp(1,2)));
% title({sprintf('T Coef %.3f,p %.3e',rr(1,2),pp(1,2));...
%     sprintf('P Coef %.3f,p %.3e',Prr(1,2),Ppp(1,2))});

saveas(hhf,'BoundTunBF with behavOct correlation ana');
saveas(hhf,'BoundTunBF with behavOct correlation ana','pdf');
saveas(hhf,'BoundTunBF with behavOct correlation ana','png');
