clear
clc

dataPath = uigetdir(pwd,'Please select your data file path');
cd(dataPath);

if ~isdir('./Summrized_plots/') %#ok<ISDIR>
    mkdir('./Summrized_plots/');
end
% cd('./Summrized_plots/');

CuroffThres = 0.5; %MissRate
CuroffTrNum = 400;

MatfileDir = dir('*.mat');
nfiles = length(MatfileDir);
MissRateData = cell(nfiles,3);
IsSessionDataUsed = ones(nfiles,1);
for cf = 1 : nfiles
    
    cfname = MatfileDir(cf).name;
    cDataStrc = load(cfname);
    if ~isfield(cDataStrc,'SessionResults')
        IsSessionDataUsed(cf) = 0;
        continue;
    end
    MissRateData{cf,1} = cfname;
    %
    hhf = figure('position',[2000 150 1500 440]);
    
    ax1 = subplot(131);
    
    [behavResults,behavSettings] = behav_cell2struct(cDataStrc.SessionResults,cDataStrc.SessionSettings);
    [UserChoice,sessiontype,h_f]=behavScore_prob(behavResults,behavSettings,cfname,0,ax1); 
    set(gca,'fontsize',16);
    %
    SessTrFreqs = double(behavResults.Stim_toneFreq(:));
    SessTrChoice = double(behavResults.Action_choice(:));
    SessTrTypes = double(behavResults.Trial_Type(:));
    
    UsedInds = 1:numel(SessTrTypes);
    
    SessMissRate = smooth(SessTrChoice == 2,20);
    
    CutOffInds = find(SessMissRate > CuroffThres);
    if ~isempty(CutOffInds)
        UsedEndInds = min(CutOffInds(CutOffInds > CuroffTrNum));
        if ~isempty(UsedEndInds)
            UsedInds = 1 : UsedEndInds;
        end
    end
    
    UsedSessTrFreqs = SessTrFreqs(UsedInds);
    UsedSessTrChoice = SessTrChoice(UsedInds);
    UsedSessTrTypes = SessTrTypes(UsedInds);
    UsedSessMissTrs = double(UsedSessTrChoice == 2);
%     UsedSessCorrRate = double(UsedSessTrChoice == UsedSessTrTypes);
    
    FreqTypes = unique(UsedSessTrFreqs);
    NumFreqs = length(FreqTypes);
    FreqOctaves = log2(FreqTypes/min(FreqTypes));
    FreqStrs = cellstr(num2str(FreqTypes(:)/1000,'%.1f'));
    
    UsedNMInds = UsedSessTrChoice ~= 2;
    MissCorrRNMCorrRateAll = zeros(NumFreqs,3);
%     WIthMissCorrectRate = zeros(NumFreqs,1);
%     NMCorrRate = zeros(NumFreqs,1);
    for cfreq = 1 : NumFreqs
        cfInds = UsedSessTrFreqs == FreqTypes(cfreq);
        cfMissRate = mean(UsedSessMissTrs(cfInds));
        cfNMRightProb = mean(UsedSessTrChoice(cfInds & UsedNMInds) == 1);
        cfAllRightProb = mean(UsedSessTrChoice(cfInds) == 1);
        MissCorrRNMCorrRateAll(cfreq,:) = [cfMissRate,cfNMRightProb,cfAllRightProb];
    end
    subplot(132)
    hold on
    hl1 = plot(FreqOctaves,MissCorrRNMCorrRateAll(:,1),'k-o','linewidth',1.4);
    hl2 = plot(FreqOctaves,MissCorrRNMCorrRateAll(:,3),'-o','linewidth',1.4,'Color',[.7 .7 .7]);
    hl3 = plot(FreqOctaves,MissCorrRNMCorrRateAll(:,2),'-o','linewidth',1.4,'Color','r');
    legend([hl1,hl2,hl3],{'MissRate','CorrRate','NMCorr'},'Box','off','FontSize',8,'location','Northwest');
    set(gca,'ylim',[-0.05 1.05],'xlim',[-0.1 2.1],'xtick',FreqOctaves,'xticklabel',FreqStrs);
    xlabel('Freqs (kHz)');
    ylabel('Probability');
    set(gca,'FontSize',12);
    title(sprintf('Used Inds %d-%d',UsedInds(1),UsedInds(end)));
    
    % plot the psychometric curve
    UsedSessTrOcts = log2(UsedSessTrFreqs/min(FreqTypes));
    FitAll = FitPsycheCurveWH_nx(UsedSessTrOcts(UsedNMInds),UsedSessTrChoice(UsedNMInds));
    subplot(133)
    hold on
    plot(FreqOctaves,MissCorrRNMCorrRateAll(:,2),'-o','linewidth',1.4,'Color','m');
    plot(FitAll.curve(:,1),FitAll.curve(:,2),'linewidth',2,'Color','r');
    set(gca,'ylim',[-0.05 1.05],'xlim',[-0.1 2.1],'xtick',FreqOctaves,'xticklabel',FreqStrs);
    xlabel('Freqs (kHz)');
    ylabel('Probability');
    set(gca,'FontSize',12);
    
    saveas(hhf,sprintf('./Summrized_plots/%s_sumplots',cfname(1:end-4)));
    saveas(hhf,sprintf('./Summrized_plots/%s_sumplots',cfname(1:end-4)),'png');
    close(hhf);
    
    MissRateData{cf,2} = MissCorrRNMCorrRateAll;
    MissRateData{cf,3} = FitAll;
   %
end
RealMissRateData = MissRateData(logical(IsSessionDataUsed),:);
%
save SummedDAtaSave.mat RealMissRateData FreqStrs FreqOctaves  -v7.3

%% summarized plots
SalineData = load('R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\saline control matfile\SummedDAtaSave.mat');
CNOControlData = load('R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\control for CNO matfile\SummedDAtaSave.mat');
CNOData = load('R:\Xulab_Share_Nutstore\Zhang_Yuan\hM4D withmiss sum plot\ACtx hM4D raw behavior\CNO matfile\SummedDAtaSave.mat');
%% missrate plot
SalineMissRateAll = cellfun(@(x) (x(:,1))',SalineData.RealMissRateData(:,2),'UniformOutput',false);
CNOControlMissRateAll = cellfun(@(x) (x(:,1))',CNOControlData.RealMissRateData(:,2),'UniformOutput',false);
CNOMissRateAll = cellfun(@(x) (x(:,1))',CNOData.RealMissRateData(:,2),'UniformOutput',false);
%
SalineMissRateData = cell2mat(SalineMissRateAll);
CNOMissRateData = cell2mat(CNOMissRateAll);

SalineMissRateMeanSem = [mean(SalineMissRateData);std(SalineMissRateData)/sqrt(size(SalineMissRateData,1))];
CNOMissRateMeanSem = [mean(CNOMissRateData);std(CNOMissRateData)/sqrt(size(CNOMissRateData,1))];

hf = figure('position',[100 100 380 300]);
hold on
el1 = errorbar(SalineData.FreqOctaves,SalineMissRateMeanSem(1,:),SalineMissRateMeanSem(2,:),'k-o','linewidth',2.4);
el2 = errorbar(CNOData.FreqOctaves,CNOMissRateMeanSem(1,:),CNOMissRateMeanSem(2,:),'r-o','linewidth',2.4);
set(gca,'xtick',CNOData.FreqOctaves,'xlim',[-0.1 2.1],'xticklabel',CNOData.FreqStrs);
ylabel('MissRate');
xlabel('Freq (kHz)');
set(gca,'FontSize',14);
legend([el1,el2],{'Saline','CNO'},'box','off','location','Northwest');

%% rightward choice probability plot
SalineRProbAll = cellfun(@(x) (x(:,2))',SalineData.RealMissRateData(:,2),'UniformOutput',false);
CNOControlRProbRateAll = cellfun(@(x) (x(:,2))',CNOControlData.RealMissRateData(:,2),'UniformOutput',false);
CNORProbAll = cellfun(@(x) (x(:,2))',CNOData.RealMissRateData(:,2),'UniformOutput',false);
%
SalineRProbData = cell2mat(SalineRProbAll);
CNORProbData = cell2mat(CNORProbAll);

SalineRProbMeanSem = [mean(SalineRProbData);std(SalineRProbData)/sqrt(size(SalineRProbData,1))];
CNORProbMeanSem = [mean(CNORProbData);std(CNORProbData)/sqrt(size(CNORProbData,1))];

hf = figure('position',[10 100 380 300]);
hold on
el1 = errorbar(CNOData.FreqOctaves,SalineRProbMeanSem(1,:),SalineRProbMeanSem(2,:),'k-o','linewidth',2.4);
el2 = errorbar(CNOData.FreqOctaves,CNORProbMeanSem(1,:),CNORProbMeanSem(2,:),'r-o','linewidth',2.4);
set(gca,'xtick',CNOData.FreqOctaves,'xlim',[-0.1 2.1],'xticklabel',CNOData.FreqStrs);
ylabel('Right prob.');
xlabel('Freq (kHz)');
set(gca,'FontSize',14);
% legend([el1,el2],{'Saline','CNO'},'box','off','location','Northwest');

%% with miss right prob curve
SalineWMRProbAll = cellfun(@(x) (x(:,3))',SalineData.RealMissRateData(:,2),'UniformOutput',false);
CNOControlWMRProbRateAll = cellfun(@(x) (x(:,3))',CNOControlData.RealMissRateData(:,2),'UniformOutput',false);
CNOWMRProbAll = cellfun(@(x) (x(:,3))',CNOData.RealMissRateData(:,2),'UniformOutput',false);
%
SalineWMRProbData = cell2mat(SalineWMRProbAll);
CNOWMRProbData = cell2mat(CNOWMRProbAll);

SalineWMRProbMeanSem = [mean(SalineWMRProbData);std(SalineWMRProbData)/sqrt(size(SalineWMRProbData,1))];
CNOWMRProbMeanSem = [mean(CNOWMRProbData);std(CNOWMRProbData)/sqrt(size(CNOWMRProbData,1))];

el3 = errorbar(CNOData.FreqOctaves,SalineWMRProbMeanSem(1,:),SalineWMRProbMeanSem(2,:),'k-o','linewidth',2.4,'linestyle','--');
el4 = errorbar(CNOData.FreqOctaves,CNOWMRProbMeanSem(1,:),CNOWMRProbMeanSem(2,:),'r-o','linewidth',2.4,'linestyle','--');

legend([el1,el2,el3,el4],{'SalineNM','CNONM','SalineWM','CNOWM'},'box','off','location','Northwest','FontSize',10);

