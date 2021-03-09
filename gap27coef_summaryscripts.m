cclr

SourcePath = '/Volumes/Seagate Backup Plus Drive/cooef_electrophysiology_gap27';
TargetDirs = dir(fullfile(SourcePath,'group*'));
NumPaths = length(TargetDirs);


GroupEPSCDatas = cell(NumPaths,2);
for cpInds = 1 : NumPaths
    cfold = fullfile(SourcePath,TargetDirs(cpInds).name);
    cd(cfold);
    
    laggedcoefAnascripts;
    
    GroupEPSCDatas(cpInds,:) = {EPBfcoefinfos, ...
        EPAfcoefinfos};
    
    save EPSClagCorrSave.mat EPBfcoefinfos EPAfcoefinfos -v7.3
    
    saveas(gcf,'EPSC laggedCoef plot save');
    saveas(gcf,'EPSC laggedCoef plot save','png');
    close(gcf);
    
    clearvars EPBfcoefinfos EPAfcoefinfos
    
end

%%
EPSC_BF_rcoefs = cellfun(@(x) x.rMaxCoef,GroupEPSCDatas(:,1));
EPSC_BF_rSICcoefs = cellfun(@(x) x.rMaxCoefSIC,GroupEPSCDatas(:,1));

EPSC_AF_rcoefs = cellfun(@(x) x.rMaxCoef,GroupEPSCDatas(:,2));
EPSC_AF_rSICcoefs = cellfun(@(x) x.rMaxCoefSIC,GroupEPSCDatas(:,2));

EPSCr_AB_coefs = [EPSC_BF_rcoefs,EPSC_AF_rcoefs];
[~,EPSCr_p] = ttest(EPSC_BF_rcoefs,EPSC_AF_rcoefs);
EPSCrSIC_AB_coefs = [EPSC_BF_rSICcoefs,EPSC_AF_rSICcoefs];
[~,EPSCrSIC_p] = ttest(EPSC_BF_rSICcoefs,EPSC_AF_rSICcoefs);

hsumf = figure('position',[50 100 680 270]);
ax1 = subplot(121);
hold on
plot([1,2],EPSCr_AB_coefs','Color',[.7 .7 .7],'linewidth',1.2);
plot([1,2],mean(EPSCr_AB_coefs),'k-o','linewidth',1.5);
GroupSigIndication([1,2],max(EPSCr_AB_coefs),EPSCr_p,ax1);
set(ax1,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Before','After'});
text(1,max(EPSC_BF_rcoefs)+0.02,{num2str(mean(EPSC_BF_rcoefs),'%.3f'),...
    num2str(std(EPSC_BF_rcoefs)/sqrt(numel(EPSC_BF_rcoefs)),'%.3f')});
text(2,max(EPSC_AF_rcoefs)+0.02,{num2str(mean(EPSC_AF_rcoefs),'%.3f'),...
    num2str(std(EPSC_AF_rcoefs)/sqrt(numel(EPSC_AF_rcoefs)),'%.3f')});

ylabel('Max Coef.');
title(sprintf('All Coef p = %.2e',EPSCr_p));

ax2 = subplot(122);
hold on
plot([1,2],EPSCrSIC_AB_coefs','Color',[.7 .7 .7],'linewidth',1.2);
plot([1,2],mean(EPSCrSIC_AB_coefs),'k-o','linewidth',1.5);
GroupSigIndication([1,2],max(EPSCrSIC_AB_coefs),EPSCrSIC_p,ax2);
set(ax2,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Before','After'});
text(1,max(EPSC_BF_rSICcoefs)+0.02,{num2str(mean(EPSC_BF_rSICcoefs),'%.3f'),...
    num2str(std(EPSC_BF_rSICcoefs)/sqrt(numel(EPSC_BF_rSICcoefs)),'%.3f')});
text(2,max(EPSC_AF_rSICcoefs)+0.02,{num2str(mean(EPSC_AF_rSICcoefs),'%.3f'),...
    num2str(std(EPSC_AF_rSICcoefs)/sqrt(numel(EPSC_AF_rSICcoefs)),'%.3f')});

ylabel('Max Coef.');
title(sprintf('SIC trace Coef p=%.3e',EPSCrSIC_p));

%%
saveas(hsumf,'EPSC before and after coef compare plot');
saveas(hsumf,'EPSC before and after coef compare plot','png');
saveas(hsumf,'EPSC before and after coef compare plot','pdf');

%% extract used sweep datas
cclr

SourcePath = '/Volumes/Seagate Backup Plus Drive/cooef_electrophysiology_gap27_and_wt';
TargetDirs = dir(fullfile(SourcePath,'group*'));
NumPaths = length(TargetDirs);


GroupEPSCDatas = cell(NumPaths,2);
for cpInds = 1 : NumPaths
    cfold = fullfile(SourcePath,TargetDirs(cpInds).name);
    cd(cfold);
    
    gap27Coef_usedsw_textInfos;
    
    save UsedSweepdata.mat TextInfo -v7.3
    
    clearvars TextInfo
    
end

