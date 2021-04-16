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
WTInds = cellfun(@isempty,GroupEPSCDatas(:,2)); % WT data inds
EPSC_BF_rcoefs = cellfun(@(x) x.rMaxCoef,GroupEPSCDatas(~WTInds,1));
EPSC_BF_rSICcoefs = cellfun(@(x) x.rMaxCoefSIC,GroupEPSCDatas(~WTInds,1));
EPSC_BF_rSICSubCoef = cellfun(@(x) x.rMaxCoefSICRm,GroupEPSCDatas(~WTInds,1));

EPSC_AF_rcoefs = cellfun(@(x) x.rMaxCoef,GroupEPSCDatas(~WTInds,2));
EPSC_AF_rSICcoefs = cellfun(@(x) x.rMaxCoefSIC,GroupEPSCDatas(~WTInds,2));
EPSC_AF_rSICSubCoef = cellfun(@(x) x.rMaxCoefSICRm,GroupEPSCDatas(~WTInds,2));

WT_EPSC_rcoef = cellfun(@(x) x.rMaxCoef,GroupEPSCDatas(WTInds,1));
WT_EPSC_rSICSubcoef = cellfun(@(x) x.rMaxCoefSICRm,GroupEPSCDatas(WTInds,1));

%%

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

%% ranksum test
[EPSC_BF_ry,EPSC_BF_rx] = ecdf(EPSC_BF_rcoefs);
[EPSC_BF_rSICRMy,EPSC_BF_rSICRMx] = ecdf(EPSC_BF_rSICSubCoef);

[EPSC_AF_ry,EPSC_AF_rx] = ecdf(EPSC_AF_rcoefs);
[EPSC_AF_rSICRMy,EPSC_AF_rSICRMx] = ecdf(EPSC_AF_rSICSubCoef);

[EPSC_WT_ry,EPSC_WT_rx] = ecdf(WT_EPSC_rcoef);
[EPSC_WT_rSICRMy,EPSC_WT_rSICRMx] = ecdf(WT_EPSC_rSICSubcoef);

Colors = {'k','r','b'};
hf = figure('position',[100 100 420 340]);
hold on
hl1 = plot(EPSC_BF_rx,EPSC_BF_ry,'Color',Colors{1},'linewidth',1.5);
hl2 = plot(EPSC_BF_rSICRMx,EPSC_BF_rSICRMy,'Color',Colors{1},...
    'linewidth',1.5,'linestyle','--');
hl3 = plot(EPSC_AF_rx,EPSC_AF_ry,'Color',Colors{2},'linewidth',1.5);
% hl4 = plot(EPSC_AF_rSICRMx,EPSC_AF_rSICRMy,'Color',Colors{2},...
%     'linewidth',1.5,'linestyle','--');
hl5 = plot(EPSC_WT_rx,EPSC_WT_ry,'Color',Colors{3},'linewidth',1.5);
hl6 = plot(EPSC_WT_rSICRMx,EPSC_WT_rSICRMy,'Color',Colors{3},...
    'linewidth',1.5,'linestyle','--');

legend([hl1,hl2,hl3,hl5,hl6],{'TGBFr','TGBFSICsub','TGAFr','WTr','WTSICsub'},...
    'location','southeast','box','off');
xlabel('correlation coefficient');
ylabel('fraction');

pvalues = struct();
pvalues.EPSC_AFr_BFr_P = ranksum(EPSC_BF_rcoefs,EPSC_AF_rcoefs);
pvalues.EPSC_AFr_AFrsub_P = ranksum(EPSC_AF_rSICSubCoef,EPSC_AF_rcoefs);
pvalues.EPSC_BFr_BFrsub_P = ranksum(EPSC_BF_rSICSubCoef,EPSC_BF_rcoefs);
pvalues.EPSC_AFrsub_BFrsub_P = ranksum(EPSC_BF_rSICSubCoef,EPSC_AF_rSICSubCoef);
pvalues.EPSC_AFr_BFrsub_P = ranksum(EPSC_BF_rSICSubCoef,EPSC_AF_rcoefs);
pvalues.EPSC_BFr_wtr_P = ranksum(EPSC_BF_rcoefs,WT_EPSC_rcoef);
pvalues.EPSC_BFrsub_wtrsub_P = ranksum(EPSC_BF_rSICSubCoef,WT_EPSC_rSICSubcoef);


%%
saveas(gcf, 'EPSC_cumuplot_save');
saveas(gcf, 'EPSC_cumuplot_save','png');
saveas(gcf, 'EPSC_cumuplot_save','pdf');

